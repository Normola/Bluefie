import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_settings.dart';
import '../models/bluetooth_device_record.dart';
import '../services/battery_service.dart';
import '../services/database_helper.dart';
import '../services/location_service.dart';
import '../services/logging_service.dart';
import '../services/settings_service.dart';

class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final SettingsService _settingsService = SettingsService();
  final LocationService _locationService = LocationService();
  final BatteryService _batteryService = BatteryService();
  final LoggingService log = LoggingService();

  /// Export all data to a JSON file
  Future<String?> exportAllDataToJson({
    bool includeDeviceRecords = true,
    bool includeSettings = true,
    bool includeSystemInfo = true,
    String? customFilename,
  }) async {
    try {
      log.info('Starting data export...');

      // Request storage permission
      if (!await _requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      // Collect all data
      final Map<String, dynamic> exportData = {
        'export_info': {
          'app_name': 'Blufie-UI',
          'export_version': '1.0',
          'export_timestamp': DateTime.now().toIso8601String(),
          'export_timestamp_epoch': DateTime.now().millisecondsSinceEpoch,
        }
      };

      // Include device records
      if (includeDeviceRecords) {
        exportData['device_records'] = await _exportDeviceRecords();
      }

      // Include app settings
      if (includeSettings) {
        exportData['app_settings'] = await _exportAppSettings();
      }

      // Include system information
      if (includeSystemInfo) {
        exportData['system_info'] = await _exportSystemInfo();
      }

      // Generate filename
      final String filename = customFilename ?? _generateFilename();

      // Write to file
      final String filePath = await _writeJsonToFile(exportData, filename);

      log.info('Data export completed: $filePath');
      return filePath;
    } catch (e) {
      log.error('Error during data export', e);
      rethrow;
    }
  }

  /// Export device records with statistics
  Future<Map<String, dynamic>> _exportDeviceRecords() async {
    try {
      // Get all device records
      final List<BluetoothDeviceRecord> allDevices = await _databaseHelper.getAllDevices();
      final List<BluetoothDeviceRecord> uniqueDevices = await _databaseHelper.getUniqueDevices();

      // Convert to JSON-serializable format
      final List<Map<String, dynamic>> allDevicesJson = allDevices
          .map((device) => {
                ...device.toMap(),
                'timestamp_iso':
                    DateTime.fromMillisecondsSinceEpoch(device.timestamp.millisecondsSinceEpoch)
                        .toIso8601String(),
              })
          .toList();

      final List<Map<String, dynamic>> uniqueDevicesJson = uniqueDevices
          .map((device) => {
                ...device.toMap(),
                'timestamp_iso':
                    DateTime.fromMillisecondsSinceEpoch(device.timestamp.millisecondsSinceEpoch)
                        .toIso8601String(),
              })
          .toList();

      // Calculate statistics
      final Map<String, dynamic> statistics = await _calculateDeviceStatistics(allDevices);

      return {
        'total_records': allDevices.length,
        'unique_devices': uniqueDevices.length,
        'statistics': statistics,
        'all_devices': allDevicesJson,
        'unique_devices_latest': uniqueDevicesJson,
      };
    } catch (e) {
      log.error('Error exporting device records', e);
      return {'error': e.toString()};
    }
  }

  /// Calculate comprehensive device statistics
  Future<Map<String, dynamic>> _calculateDeviceStatistics(
      List<BluetoothDeviceRecord> devices) async {
    if (devices.isEmpty) {
      return {
        'total_scans': 0,
        'date_range': null,
        'rssi_stats': null,
        'location_stats': null,
        'device_name_stats': null,
      };
    }

    // Date range
    final DateTime earliest =
        devices.map((d) => d.timestamp).reduce((a, b) => a.isBefore(b) ? a : b);
    final DateTime latest = devices.map((d) => d.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);

    // RSSI statistics
    final List<int> rssiValues = devices.map((d) => d.rssi).toList();
    rssiValues.sort();

    final Map<String, dynamic> rssiStats = {
      'min': rssiValues.first,
      'max': rssiValues.last,
      'average': rssiValues.reduce((a, b) => a + b) / rssiValues.length,
      'median': rssiValues.length % 2 == 0
          ? (rssiValues[rssiValues.length ~/ 2 - 1] + rssiValues[rssiValues.length ~/ 2]) / 2
          : rssiValues[rssiValues.length ~/ 2],
    };

    // Location statistics
    final List<BluetoothDeviceRecord> devicesWithLocation =
        devices.where((d) => d.latitude != null && d.longitude != null).toList();
    Map<String, dynamic>? locationStats;

    if (devicesWithLocation.isNotEmpty) {
      final List<double> latitudes = devicesWithLocation.map((d) => d.latitude!).toList();
      final List<double> longitudes = devicesWithLocation.map((d) => d.longitude!).toList();

      locationStats = {
        'records_with_location': devicesWithLocation.length,
        'records_without_location': devices.length - devicesWithLocation.length,
        'latitude_range': {
          'min': latitudes.reduce((a, b) => a < b ? a : b),
          'max': latitudes.reduce((a, b) => a > b ? a : b),
        },
        'longitude_range': {
          'min': longitudes.reduce((a, b) => a < b ? a : b),
          'max': longitudes.reduce((a, b) => a > b ? a : b),
        },
      };
    }

    // Device name statistics
    final Map<String, int> deviceNameCounts = {};
    for (final device in devices) {
      deviceNameCounts[device.deviceName] = (deviceNameCounts[device.deviceName] ?? 0) + 1;
    }

    final sortedDeviceNames = deviceNameCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final Map<String, dynamic> deviceNameStats = {
      'unique_device_names': deviceNameCounts.length,
      'most_frequent_devices': sortedDeviceNames
          .take(10)
          .map((e) => {
                'device_name': e.key,
                'count': e.value,
              })
          .toList(),
    };

    return {
      'total_scans': devices.length,
      'date_range': {
        'earliest': earliest.toIso8601String(),
        'latest': latest.toIso8601String(),
        'earliest_epoch': earliest.millisecondsSinceEpoch,
        'latest_epoch': latest.millisecondsSinceEpoch,
        'duration_days': latest.difference(earliest).inDays,
      },
      'rssi_stats': rssiStats,
      'location_stats': locationStats,
      'device_name_stats': deviceNameStats,
    };
  }

  /// Export app settings
  Future<Map<String, dynamic>> _exportAppSettings() async {
    try {
      final AppSettings settings = _settingsService.currentSettings;

      return {
        'auto_scanning_enabled': settings.autoScanningEnabled,
        'location_tracking_enabled': settings.locationTrackingEnabled,
        'verbose_logging_enabled': settings.verboseLoggingEnabled,
        'battery_optimization_enabled': settings.batteryOptimizationEnabled,
        'battery_threshold_percent': settings.batteryThresholdPercent,
        'scan_interval_seconds': settings.scanIntervalSeconds,
        'data_retention_days': settings.dataRetentionDays,
        'show_notifications': settings.showNotifications,
        'auto_scan_when_plugged_in': settings.autoScanWhenPluggedIn,
      };
    } catch (e) {
      log.error('Error exporting app settings', e);
      return {'error': e.toString()};
    }
  }

  /// Export system information
  Future<Map<String, dynamic>> _exportSystemInfo() async {
    try {
      final Map<String, dynamic> systemInfo = {
        'platform': defaultTargetPlatform.toString(),
        'export_timestamp': DateTime.now().toIso8601String(),
      };

      // Current location
      if (_locationService.currentPosition != null) {
        systemInfo['current_location'] = {
          'latitude': _locationService.currentPosition!.latitude,
          'longitude': _locationService.currentPosition!.longitude,
          'accuracy': _locationService.currentPosition!.accuracy,
          'timestamp': _locationService.currentPosition!.timestamp.toIso8601String(),
          'location_string': _locationService.getLocationString(_locationService.currentPosition),
        };
      }

      // Battery information
      systemInfo['battery_info'] = {
        'current_level': _batteryService.currentBatteryLevel,
        'battery_state': _batteryService.currentBatteryState.toString(),
        'is_charging': _batteryService.isCharging,
        'is_low_battery': _batteryService.isLowBattery,
      };

      // Database statistics
      systemInfo['database_stats'] = {
        'total_records': await _databaseHelper.getDeviceCount(),
        'unique_devices': await _databaseHelper.getUniqueDeviceCount(),
      };

      return systemInfo;
    } catch (e) {
      log.error('Error exporting system info', e);
      return {'error': e.toString()};
    }
  }

  /// Generate a filename with timestamp
  String _generateFilename() {
    final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    return 'blufie_export_$timestamp.json';
  }

  /// Write JSON data to file
  Future<String> _writeJsonToFile(Map<String, dynamic> data, String filename) async {
    try {
      // Get the documents directory
      Directory? directory;

      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        directory ??= await getApplicationDocumentsDirectory();
      }
      if (!Platform.isAndroid) {
        directory = await getApplicationDocumentsDirectory();
      }

      // Ensure directory is not null
      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create the file
      final File file = File('${directory.path}/$filename');

      // Write JSON data with pretty formatting
      final String jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      log.error('Error writing JSON file', e);
      rethrow;
    }
  }

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
      return true; // iOS doesn't need explicit storage permission for app documents
    } catch (e) {
      log.error('Error requesting storage permission', e);
      return false;
    }
  }

  /// Share the exported JSON file
  Future<void> shareExportedFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)], text: 'Blufie-UI Data Export');
    } catch (e) {
      log.error('Error sharing exported file', e);
      rethrow;
    }
  }

  /// Import data from JSON file (for future use)
  Future<bool> importDataFromJson(String filePath) async {
    try {
      // This would be implemented for importing previously exported data
      // For now, just log the attempt
      log.info('Import functionality not yet implemented: $filePath');
      return false;
    } catch (e) {
      log.error('Error importing data', e);
      return false;
    }
  }
}
