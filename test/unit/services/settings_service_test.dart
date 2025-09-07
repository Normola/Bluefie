import 'package:blufie_ui/models/app_settings.dart';
import 'package:blufie_ui/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock class for SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SettingsService', () {
    late SettingsService settingsService;

    setUp(() {
      // Set up SharedPreferences mock for testing
      SharedPreferences.setMockInitialValues({});
      settingsService = SettingsService();
    });

    test('should have default settings initially', () {
      final settings = settingsService.currentSettings;

      expect(settings.autoScanningEnabled, false);
      expect(settings.autoScanWhenPluggedIn, false);
      expect(settings.scanIntervalSeconds, 30);
      expect(settings.locationTrackingEnabled, true);
      expect(settings.batteryOptimizationEnabled,
          false); // Default is false for background scanning
      expect(settings.batteryThresholdPercent, 20);
      expect(settings.verboseLoggingEnabled, false);
      expect(settings.showNotifications, true);
      expect(settings.dataRetentionDays, 30);
    });

    test('should update auto scanning setting', () async {
      // Directly update the setting in memory only
      final newSettings =
          settingsService.currentSettings.copyWith(autoScanningEnabled: true);
      settingsService.updateSettings(newSettings);

      // Verify the setting was updated
      expect(settingsService.currentSettings.autoScanningEnabled, true);
    });

    test('should update scan interval', () async {
      // Directly update the setting in memory only
      final newSettings =
          settingsService.currentSettings.copyWith(scanIntervalSeconds: 60);
      settingsService.updateSettings(newSettings);

      // Verify the setting was updated
      expect(settingsService.currentSettings.scanIntervalSeconds, 60);
    });

    test('should update battery optimization settings', () async {
      // Directly update the settings in memory only
      final newSettings = settingsService.currentSettings.copyWith(
        batteryOptimizationEnabled: false,
        batteryThresholdPercent: 15,
      );
      settingsService.updateSettings(newSettings);

      // Verify the settings were updated
      expect(settingsService.currentSettings.batteryOptimizationEnabled, false);
      expect(settingsService.currentSettings.batteryThresholdPercent, 15);
    });

    test('should update location tracking setting', () async {
      // Directly update the setting in memory only
      final newSettings = settingsService.currentSettings
          .copyWith(locationTrackingEnabled: false);
      settingsService.updateSettings(newSettings);

      // Verify the setting was updated
      expect(settingsService.currentSettings.locationTrackingEnabled, false);
    });

    test('should update verbose logging setting', () async {
      // Directly update the setting in memory only
      final newSettings =
          settingsService.currentSettings.copyWith(verboseLoggingEnabled: true);
      settingsService.updateSettings(newSettings);

      // Verify the setting was updated
      expect(settingsService.currentSettings.verboseLoggingEnabled, true);
    });

    test('should update notifications setting', () async {
      // Directly update the setting in memory only
      final newSettings =
          settingsService.currentSettings.copyWith(showNotifications: false);
      settingsService.updateSettings(newSettings);

      // Verify the setting was updated
      expect(settingsService.currentSettings.showNotifications, false);
    });

    test('should update data retention setting', () async {
      // Directly update the setting in memory only
      final newSettings =
          settingsService.currentSettings.copyWith(dataRetentionDays: 90);
      settingsService.updateSettings(newSettings);

      // Verify the setting was updated
      expect(settingsService.currentSettings.dataRetentionDays, 90);
    });

    test('should provide settings stream', () {
      final settingsStream = settingsService.settingsStream;
      expect(settingsStream, isNotNull);
      expect(settingsStream, isA<Stream<AppSettings>>());
    });

    test('should emit settings changes through stream', () async {
      // Listen to the stream
      final streamValues = <AppSettings>[];
      final subscription = settingsService.settingsStream.listen((settings) {
        streamValues.add(settings);
      });

      // Update a setting
      final newSettings =
          settingsService.currentSettings.copyWith(autoScanningEnabled: true);
      settingsService.updateSettings(newSettings);

      // Give the stream time to emit
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify the stream emitted the change
      expect(streamValues.isNotEmpty, true);
      expect(streamValues.last.autoScanningEnabled, true);

      await subscription.cancel();
    });
  });
}
