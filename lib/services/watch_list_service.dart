import 'dart:async';
import 'dart:io';

import '../models/bluetooth_device_record.dart';
import 'logging_service.dart';
import 'settings_service.dart';

/// Service for managing device watch list functionality including
/// device presence tracking and audio alerts for re-detection
class WatchListService {
  static final WatchListService _instance = WatchListService._internal();
  factory WatchListService() => _instance;
  WatchListService._internal();

  final LoggingService _loggingService = LoggingService();
  final SettingsService _settingsService = SettingsService();

  // Track currently detected devices on the watch list
  final Set<String> _currentlyDetectedDevices = <String>{};

  // Track devices that have left detection range
  final Set<String> _devicesOutOfRange = <String>{};

  // Stream controller for watch list events
  final StreamController<WatchListEvent> _eventController =
      StreamController<WatchListEvent>.broadcast();

  Stream<WatchListEvent> get eventStream => _eventController.stream;

  /// Add a device to the watch list by MAC address
  Future<bool> addDeviceToWatchList(String macAddress) async {
    try {
      final settings = _settingsService.currentSettings;
      final currentWatchList = List<String>.from(settings.watchListDevices);

      if (!currentWatchList.contains(macAddress)) {
        currentWatchList.add(macAddress);
        final updatedSettings = settings.copyWith(
          watchListDevices: currentWatchList,
        );
        await _settingsService.updateSettings(updatedSettings);

        _loggingService.info('Added device $macAddress to watch list');
        _eventController.add(WatchListEvent(
          type: WatchListEventType.deviceAdded,
          macAddress: macAddress,
        ));

        return true;
      }
      return false;
    } catch (e) {
      _loggingService.error('Failed to add device to watch list: $e');
      return false;
    }
  }

  /// Remove a device from the watch list
  Future<bool> removeDeviceFromWatchList(String macAddress) async {
    try {
      final settings = _settingsService.currentSettings;
      final currentWatchList = List<String>.from(settings.watchListDevices);

      if (currentWatchList.remove(macAddress)) {
        final updatedSettings = settings.copyWith(
          watchListDevices: currentWatchList,
        );
        await _settingsService.updateSettings(updatedSettings);

        // Clean up tracking sets
        _currentlyDetectedDevices.remove(macAddress);
        _devicesOutOfRange.remove(macAddress);

        _loggingService.info('Removed device $macAddress from watch list');
        _eventController.add(WatchListEvent(
          type: WatchListEventType.deviceRemoved,
          macAddress: macAddress,
        ));

        return true;
      }
      return false;
    } catch (e) {
      _loggingService.error('Failed to remove device from watch list: $e');
      return false;
    }
  }

  /// Process a detected Bluetooth device to check for watch list events
  Future<void> processDetectedDevice(BluetoothDeviceRecord device) async {
    try {
      final settings = _settingsService.currentSettings;

      // Skip if watch list is disabled
      if (!settings.watchListEnabled) {
        return;
      }

      final macAddress = device.macAddress;

      // Check if this device is on the watch list
      if (!settings.watchListDevices.contains(macAddress)) {
        return;
      }

      // Device is on watch list - check if it was previously out of range
      if (_devicesOutOfRange.contains(macAddress)) {
        // Device has re-entered detection range!
        _devicesOutOfRange.remove(macAddress);
        _currentlyDetectedDevices.add(macAddress);

        _loggingService.info(
            'Watch list device re-detected: $macAddress (${device.deviceName})');

        final event = WatchListEvent(
          type: WatchListEventType.deviceReDetected,
          macAddress: macAddress,
          deviceName: device.deviceName,
          device: device,
        );

        _eventController.add(event);

        // Play audio alert if enabled
        if (settings.watchListAudioAlertsEnabled) {
          await _playAudioAlert();
        }
      } else if (!_currentlyDetectedDevices.contains(macAddress)) {
        // First time detecting this watch list device in this session
        _currentlyDetectedDevices.add(macAddress);

        _loggingService.info(
            'Watch list device detected: $macAddress (${device.deviceName})');

        _eventController.add(WatchListEvent(
          type: WatchListEventType.deviceDetected,
          macAddress: macAddress,
          deviceName: device.deviceName,
          device: device,
        ));
      }
    } catch (e) {
      _loggingService
          .error('Error processing detected device for watch list: $e');
    }
  }

  /// Check for devices that have left detection range
  /// This should be called periodically by the scanning service
  Future<void> checkForMissingDevices(List<String> currentlyScannedMacs) async {
    try {
      final settings = _settingsService.currentSettings;

      if (!settings.watchListEnabled) {
        return;
      }

      // Find watch list devices that were detected but are no longer in scan results
      final missingDevices = _currentlyDetectedDevices
          .where((mac) => !currentlyScannedMacs.contains(mac))
          .toList();

      for (final macAddress in missingDevices) {
        _currentlyDetectedDevices.remove(macAddress);
        _devicesOutOfRange.add(macAddress);

        _loggingService
            .info('Watch list device left detection range: $macAddress');

        _eventController.add(WatchListEvent(
          type: WatchListEventType.deviceLeftRange,
          macAddress: macAddress,
        ));
      }
    } catch (e) {
      _loggingService.error('Error checking for missing devices: $e');
    }
  }

  /// Play audio alert for watch list events
  Future<void> _playAudioAlert() async {
    try {
      // For now, we'll use a simple system beep
      // In a real implementation, you might want to play a custom sound file
      if (Platform.isWindows) {
        await Process.run('rundll32', ['user32.dll,MessageBeep']);
      } else if (Platform.isLinux) {
        await Process.run('paplay', ['/usr/share/sounds/alsa/Front_Left.wav']);
      } else if (Platform.isMacOS) {
        await Process.run('afplay', ['/System/Library/Sounds/Glass.aiff']);
      }

      _loggingService.info('Audio alert played for watch list re-detection');
    } catch (e) {
      _loggingService.warning('Failed to play audio alert: $e');
    }
  }

  /// Get current watch list status
  Future<WatchListStatus> getStatus() async {
    final settings = _settingsService.currentSettings;

    return WatchListStatus(
      enabled: settings.watchListEnabled,
      audioAlertsEnabled: settings.watchListAudioAlertsEnabled,
      watchedDevices: List<String>.from(settings.watchListDevices),
      currentlyDetected: List<String>.from(_currentlyDetectedDevices),
      outOfRange: List<String>.from(_devicesOutOfRange),
    );
  }

  /// Enable or disable the watch list feature
  Future<void> setWatchListEnabled(bool enabled) async {
    try {
      final settings = _settingsService.currentSettings;
      final updatedSettings = settings.copyWith(watchListEnabled: enabled);
      await _settingsService.updateSettings(updatedSettings);

      if (!enabled) {
        // Clear tracking when disabled
        _currentlyDetectedDevices.clear();
        _devicesOutOfRange.clear();
      }

      _loggingService.info('Watch list ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _loggingService.error('Failed to set watch list enabled state: $e');
    }
  }

  /// Enable or disable audio alerts
  Future<void> setAudioAlertsEnabled(bool enabled) async {
    try {
      final settings = _settingsService.currentSettings;
      final updatedSettings =
          settings.copyWith(watchListAudioAlertsEnabled: enabled);
      await _settingsService.updateSettings(updatedSettings);

      _loggingService
          .info('Watch list audio alerts ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _loggingService.error('Failed to set audio alerts enabled state: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _eventController.close();
  }
}

/// Event types for watch list notifications
enum WatchListEventType {
  deviceAdded,
  deviceRemoved,
  deviceDetected,
  deviceReDetected,
  deviceLeftRange,
}

/// Watch list event data
class WatchListEvent {
  final WatchListEventType type;
  final String macAddress;
  final String? deviceName;
  final BluetoothDeviceRecord? device;
  final DateTime timestamp;

  WatchListEvent({
    required this.type,
    required this.macAddress,
    this.deviceName,
    this.device,
  }) : timestamp = DateTime.now();
}

/// Current status of the watch list service
class WatchListStatus {
  final bool enabled;
  final bool audioAlertsEnabled;
  final List<String> watchedDevices;
  final List<String> currentlyDetected;
  final List<String> outOfRange;

  WatchListStatus({
    required this.enabled,
    required this.audioAlertsEnabled,
    required this.watchedDevices,
    required this.currentlyDetected,
    required this.outOfRange,
  });
}
