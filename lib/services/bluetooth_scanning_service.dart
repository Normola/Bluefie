import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../models/bluetooth_device_record.dart';
import '../services/database_helper.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../services/battery_service.dart';
import '../config/scan_config.dart';

class BluetoothScanningService {
  static final BluetoothScanningService _instance = BluetoothScanningService._internal();
  factory BluetoothScanningService() => _instance;
  BluetoothScanningService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final LocationService _locationService = LocationService();
  final SettingsService _settingsService = SettingsService();
  final BatteryService _batteryService = BatteryService();
  
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  StreamSubscription<bool>? _lowBatterySubscription;
  Timer? _continuousScanTimer;
  
  bool _isServiceRunning = false;
  bool _isScanning = false;
  
  final StreamController<int> _deviceCountController = StreamController<int>.broadcast();
  final StreamController<List<BluetoothDeviceRecord>> _recentDevicesController = 
      StreamController<List<BluetoothDeviceRecord>>.broadcast();

  // Streams for UI updates
  Stream<int> get deviceCountStream => _deviceCountController.stream;
  Stream<List<BluetoothDeviceRecord>> get recentDevicesStream => _recentDevicesController.stream;
  
  bool get isServiceRunning => _isServiceRunning;
  bool get isScanning => _isScanning;

  Future<bool> startContinuousScanning() async {
    if (_isServiceRunning) {
      return true;
    }

    try {
      // Check if Bluetooth is available and enabled
      BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        print('Bluetooth is not enabled');
        return false;
      }

      // Check battery level before starting
      if (_batteryService.shouldStopScanning()) {
        print('Battery too low to start scanning: ${_batteryService.currentBatteryLevel}%');
        return false;
      }

      // Start location tracking if enabled
      final settings = _settingsService.currentSettings;
      if (settings.locationTrackingEnabled) {
        await _locationService.startLocationTracking();
      }
      
      // Set up scan results listener
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        _processScanResults(results);
      }, onError: (e) {
        print('Scan results error: $e');
      });

      // Set up scanning state listener
      _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
        _isScanning = state;
      });

      // Set up low battery listener
      _lowBatterySubscription = _batteryService.lowBatteryStream.listen((isLowBattery) {
        if (isLowBattery && _isServiceRunning) {
          print('Low battery detected - stopping continuous scanning');
          stopContinuousScanning();
        }
      });

      // Start continuous scanning timer
      _startContinuousScanTimer();
      
      _isServiceRunning = true;
      print('Continuous Bluetooth scanning started');
      return true;
    } catch (e) {
      print('Error starting continuous scanning: $e');
      return false;
    }
  }

  void _startContinuousScanTimer() {
    final settings = _settingsService.currentSettings;
    Duration scanInterval = Duration(seconds: settings.scanIntervalSeconds);
    
    _continuousScanTimer = Timer.periodic(scanInterval, (timer) async {
      if (!_isScanning && !_batteryService.shouldStopScanning()) {
        await _performScan();
      } else if (_batteryService.shouldStopScanning()) {
        if (settings.verboseLoggingEnabled) {
          print('Skipping scan due to low battery: ${_batteryService.currentBatteryLevel}%');
        }
      }
    });
    
    // Start the first scan immediately if battery allows
    if (!_batteryService.shouldStopScanning()) {
      _performScan();
    }
  }

  Future<void> _performScan() async {
    try {
      final settings = _settingsService.currentSettings;
      if (settings.verboseLoggingEnabled) {
        print('Starting Bluetooth scan...');
      }
      await FlutterBluePlus.startScan(
        timeout: ScanConfig.scanDuration,
        androidUsesFineLocation: ScanConfig.useAndroidFineLocation,
      );
    } catch (e) {
      print('Error starting scan: $e');
    }
  }

  void _processScanResults(List<ScanResult> results) async {
    final settings = _settingsService.currentSettings;
    Position? currentLocation;
    
    if (settings.locationTrackingEnabled) {
      currentLocation = _locationService.currentPosition;
    }
    
    DateTime timestamp = DateTime.now();
    
    List<BluetoothDeviceRecord> newRecords = [];
    
    for (ScanResult result in results) {
      try {
        // Extract manufacturer data
        String? manufacturerData;
        if (result.advertisementData.manufacturerData.isNotEmpty) {
          manufacturerData = jsonEncode(result.advertisementData.manufacturerData.map(
            (key, value) => MapEntry(key.toString(), value.map((e) => e.toRadixString(16)).join())
          ));
        }

        // Extract service UUIDs
        String? serviceUuids;
        if (result.advertisementData.serviceUuids.isNotEmpty) {
          serviceUuids = result.advertisementData.serviceUuids.map((uuid) => uuid.toString()).join(',');
        }

        // Create device record
        BluetoothDeviceRecord record = BluetoothDeviceRecord(
          deviceId: result.device.remoteId.toString(),
          deviceName: result.advertisementData.localName.isNotEmpty 
              ? result.advertisementData.localName 
              : result.device.platformName.isNotEmpty 
                  ? result.device.platformName 
                  : 'Unknown Device',
          macAddress: result.device.remoteId.toString(),
          rssi: result.rssi,
          latitude: currentLocation?.latitude,
          longitude: currentLocation?.longitude,
          timestamp: timestamp,
          manufacturerData: manufacturerData,
          serviceUuids: serviceUuids,
          isConnectable: result.advertisementData.connectable,
        );

        // Store in database
        int insertId = await _databaseHelper.insertDevice(record);
        if (insertId > 0) {
          newRecords.add(record);
          final settings = _settingsService.currentSettings;
          if (settings.verboseLoggingEnabled) {
            print('Stored device: ${record.deviceName} (${record.macAddress}) RSSI: ${record.rssi}');
          }
        }
      } catch (e) {
        print('Error processing scan result: $e');
      }
    }

    if (newRecords.isNotEmpty) {
      await _updateStreams();
    }
  }

  Future<void> _updateStreams() async {
    try {
      // Update device count
      int totalCount = await _databaseHelper.getDeviceCount();
      _deviceCountController.add(totalCount);

      // Update recent devices (using config value)
      List<BluetoothDeviceRecord> recentDevices = await _databaseHelper.getAllDevices();
      final settings = _settingsService.currentSettings;
      _recentDevicesController.add(recentDevices.take(ScanConfig.maxRecentDevices).toList());
    } catch (e) {
      print('Error updating streams: $e');
    }
  }

  Future<void> stopContinuousScanning() async {
    if (!_isServiceRunning) {
      return;
    }

    try {
      // Stop scanning
      if (_isScanning) {
        await FlutterBluePlus.stopScan();
      }

      // Cancel timers and subscriptions
      _continuousScanTimer?.cancel();
      _scanResultsSubscription?.cancel();
      _isScanningSubscription?.cancel();
      _lowBatterySubscription?.cancel();

      // Stop location tracking
      _locationService.stopLocationTracking();

      _isServiceRunning = false;
      _isScanning = false;
      
      print('Continuous Bluetooth scanning stopped');
    } catch (e) {
      print('Error stopping continuous scanning: $e');
    }
  }

  Future<List<BluetoothDeviceRecord>> getAllStoredDevices() async {
    return await _databaseHelper.getAllDevices();
  }

  Future<List<BluetoothDeviceRecord>> getUniqueDevices() async {
    return await _databaseHelper.getUniqueDevices();
  }

  Future<int> getTotalDeviceCount() async {
    return await _databaseHelper.getDeviceCount();
  }

  Future<int> getUniqueDeviceCount() async {
    return await _databaseHelper.getUniqueDeviceCount();
  }

  Future<void> clearAllData() async {
    await _databaseHelper.clearAllData();
    await _updateStreams();
  }

  Future<void> cleanupOldData({int? daysToKeep}) async {
    int days = daysToKeep ?? ScanConfig.defaultDataRetentionDays;
    DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
    await _databaseHelper.deleteOldRecords(cutoffDate);
    await _updateStreams();
  }

  void dispose() {
    stopContinuousScanning();
    _deviceCountController.close();
    _recentDevicesController.close();
    _locationService.dispose();
  }
}
