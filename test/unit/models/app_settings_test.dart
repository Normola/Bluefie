import 'package:blufie_ui/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings', () {
    test('should create with default values', () {
      const settings = AppSettings();

      expect(settings.autoScanningEnabled, false);
      expect(settings.autoScanWhenPluggedIn, false);
      expect(settings.scanIntervalSeconds, 30);
      expect(settings.locationTrackingEnabled, true);
      expect(settings.batteryOptimizationEnabled, true);
      expect(settings.batteryThresholdPercent, 20);
      expect(settings.verboseLoggingEnabled, false);
      expect(settings.showNotifications, true);
      expect(settings.dataRetentionDays, 30);
    });

    test('should create with custom values', () {
      const settings = AppSettings(
        autoScanningEnabled: true,
        scanIntervalSeconds: 60,
        batteryThresholdPercent: 15,
        verboseLoggingEnabled: true,
      );

      expect(settings.autoScanningEnabled, true);
      expect(settings.scanIntervalSeconds, 60);
      expect(settings.batteryThresholdPercent, 15);
      expect(settings.verboseLoggingEnabled, true);
    });

    test('should serialize to JSON correctly', () {
      const settings = AppSettings(
        autoScanningEnabled: true,
        scanIntervalSeconds: 45,
        batteryThresholdPercent: 25,
      );

      final json = settings.toJson();

      expect(json['autoScanningEnabled'], true);
      expect(json['scanIntervalSeconds'], 45);
      expect(json['batteryThresholdPercent'], 25);
      expect(json['locationTrackingEnabled'], true); // default value
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'autoScanningEnabled': true,
        'autoScanWhenPluggedIn': true,
        'scanIntervalSeconds': 60,
        'locationTrackingEnabled': false,
        'batteryOptimizationEnabled': false,
        'batteryThresholdPercent': 15,
        'verboseLoggingEnabled': true,
        'showNotifications': false,
        'dataRetentionDays': 90,
      };

      final settings = AppSettings.fromJson(json);

      expect(settings.autoScanningEnabled, true);
      expect(settings.autoScanWhenPluggedIn, true);
      expect(settings.scanIntervalSeconds, 60);
      expect(settings.locationTrackingEnabled, false);
      expect(settings.batteryOptimizationEnabled, false);
      expect(settings.batteryThresholdPercent, 15);
      expect(settings.verboseLoggingEnabled, true);
      expect(settings.showNotifications, false);
      expect(settings.dataRetentionDays, 90);
    });

    test('should handle JSON serialization round trip', () {
      const originalSettings = AppSettings(
        autoScanningEnabled: true,
        scanIntervalSeconds: 120,
        batteryThresholdPercent: 10,
        verboseLoggingEnabled: true,
      );

      final json = originalSettings.toJson();
      final deserializedSettings = AppSettings.fromJson(json);

      expect(deserializedSettings.autoScanningEnabled, originalSettings.autoScanningEnabled);
      expect(deserializedSettings.scanIntervalSeconds, originalSettings.scanIntervalSeconds);
      expect(
          deserializedSettings.batteryThresholdPercent, originalSettings.batteryThresholdPercent);
      expect(deserializedSettings.verboseLoggingEnabled, originalSettings.verboseLoggingEnabled);
    });

    test('should handle partial JSON data with defaults', () {
      final json = {
        'autoScanningEnabled': true,
        'scanIntervalSeconds': 90,
        // Missing other fields should use defaults
      };

      final settings = AppSettings.fromJson(json);

      expect(settings.autoScanningEnabled, true);
      expect(settings.scanIntervalSeconds, 90);
      expect(settings.locationTrackingEnabled, true); // default
      expect(settings.batteryOptimizationEnabled, true); // default
      expect(settings.verboseLoggingEnabled, false); // default
    });
  });
}
