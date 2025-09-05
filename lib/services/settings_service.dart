import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../services/logging_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _settingsKey = 'app_settings';

  AppSettings _currentSettings = const AppSettings();
  final StreamController<AppSettings> _settingsController =
      StreamController<AppSettings>.broadcast();

  Stream<AppSettings> get settingsStream => _settingsController.stream;
  AppSettings get currentSettings => _currentSettings;

  Future<void> initialize() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _currentSettings = AppSettings.fromJson(settingsMap);
        _settingsController.add(_currentSettings);
        return;
      }

      _currentSettings = const AppSettings();
      _settingsController.add(_currentSettings);
    } catch (e) {
      log.error('Error loading settings', e);
      _currentSettings = const AppSettings();
      _settingsController.add(_currentSettings);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_currentSettings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      log.error('Error saving settings', e);
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _currentSettings = newSettings;
    _settingsController.add(_currentSettings);
    await _saveSettings();
  }

  Future<void> updateAutoScanning(bool enabled) async {
    final newSettings = _currentSettings.copyWith(autoScanningEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateBatteryOptimization(bool enabled, int? thresholdPercent) async {
    final newSettings = _currentSettings.copyWith(
      batteryOptimizationEnabled: enabled,
      batteryThresholdPercent: thresholdPercent ?? _currentSettings.batteryThresholdPercent,
    );
    await updateSettings(newSettings);
  }

  Future<void> updateScanInterval(int seconds) async {
    final newSettings = _currentSettings.copyWith(scanIntervalSeconds: seconds);
    await updateSettings(newSettings);
  }

  Future<void> updateDataRetention(int days) async {
    final newSettings = _currentSettings.copyWith(dataRetentionDays: days);
    await updateSettings(newSettings);
  }

  Future<void> updateLocationTracking(bool enabled) async {
    final newSettings = _currentSettings.copyWith(locationTrackingEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateVerboseLogging(bool enabled) async {
    final newSettings = _currentSettings.copyWith(verboseLoggingEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateNotifications(bool enabled) async {
    final newSettings = _currentSettings.copyWith(showNotifications: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateAutoScanWhenPluggedIn(bool enabled) async {
    final newSettings = _currentSettings.copyWith(autoScanWhenPluggedIn: enabled);
    await updateSettings(newSettings);
  }

  Future<void> resetToDefaults() async {
    await updateSettings(const AppSettings());
  }

  void dispose() {
    _settingsController.close();
  }
}
