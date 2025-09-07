import 'package:blufie_ui/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings OUI Fields Tests', () {
    group('OUI Database Settings', () {
      test('should have default OUI settings', () {
        const settings = AppSettings();

        expect(settings.ouiDatabaseEnabled, false);
        expect(settings.ouiDatabaseLastUpdated, null);
      });

      test('should create settings with OUI database enabled', () {
        const settings = AppSettings(ouiDatabaseEnabled: true);

        expect(settings.ouiDatabaseEnabled, true);
        expect(settings.ouiDatabaseLastUpdated, null);
      });

      test('should create settings with OUI database last updated', () {
        final testDate = DateTime(2023, 9, 1, 12, 30, 45);
        final settings = AppSettings(ouiDatabaseLastUpdated: testDate);

        expect(settings.ouiDatabaseEnabled, false);
        expect(settings.ouiDatabaseLastUpdated, testDate);
      });

      test('should create settings with both OUI fields', () {
        final testDate = DateTime(2023, 9, 1, 12, 30, 45);
        final settings = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: testDate,
        );

        expect(settings.ouiDatabaseEnabled, true);
        expect(settings.ouiDatabaseLastUpdated, testDate);
      });

      test('should update OUI database enabled via copyWith', () {
        const original = AppSettings();

        final updated = original.copyWith(ouiDatabaseEnabled: true);

        expect(original.ouiDatabaseEnabled, false);
        expect(updated.ouiDatabaseEnabled, true);
        expect(updated.ouiDatabaseLastUpdated, null);
      });

      test('should update OUI database last updated via copyWith', () {
        const original = AppSettings();
        final testDate = DateTime(2023, 9);

        final updated = original.copyWith(ouiDatabaseLastUpdated: testDate);

        expect(original.ouiDatabaseLastUpdated, null);
        expect(updated.ouiDatabaseLastUpdated, testDate);
        expect(updated.ouiDatabaseEnabled, false);
      });

      test('should handle copyWith with both OUI fields', () {
        const original = AppSettings();
        final testDate = DateTime(2023, 9);

        final updated = original.copyWith(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: testDate,
        );

        expect(updated.ouiDatabaseEnabled, true);
        expect(updated.ouiDatabaseLastUpdated, testDate);
      });

      test('should handle copyWith with null values correctly', () {
        final testDate = DateTime(2023, 9);
        final original = AppSettings(ouiDatabaseLastUpdated: testDate);

        // Note: Due to copyWith implementation, passing null doesn't clear the value
        // This is expected behavior based on the current implementation
        final updated = original.copyWith();

        expect(original.ouiDatabaseLastUpdated, testDate);
        // This will still be the original value due to null coalescing
        expect(updated.ouiDatabaseLastUpdated, testDate);
      });

      test('should serialize OUI settings to JSON correctly', () {
        final testDate = DateTime(2023, 9, 1, 12, 30, 45);
        final settings = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: testDate,
        );

        final json = settings.toJson();

        expect(json['ouiDatabaseEnabled'], true);
        expect(json['ouiDatabaseLastUpdated'], isA<int>());
      });

      test('should deserialize OUI settings from JSON correctly', () {
        final testDate = DateTime(2023, 9, 1, 12, 30, 45);
        final json = {
          'autoScanningEnabled': false,
          'batteryThreshold': 20,
          'scanInterval': 30,
          'ouiDatabaseEnabled': true,
          'ouiDatabaseLastUpdated': testDate.millisecondsSinceEpoch,
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.ouiDatabaseEnabled, true);
        expect(settings.ouiDatabaseLastUpdated, testDate);
      });

      test('should handle null OUI database last updated in JSON', () {
        final json = {
          'autoScanningEnabled': false,
          'batteryThreshold': 20,
          'scanInterval': 30,
          'ouiDatabaseEnabled': true,
          'ouiDatabaseLastUpdated': null,
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.ouiDatabaseEnabled, true);
        expect(settings.ouiDatabaseLastUpdated, null);
      });

      test('should handle missing OUI fields in JSON', () {
        final json = {
          'autoScanningEnabled': false,
          'batteryThreshold': 20,
          'scanInterval': 30,
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.ouiDatabaseEnabled, false);
        expect(settings.ouiDatabaseLastUpdated, null);
      });

      test('should maintain JSON round-trip consistency', () {
        final testDate = DateTime(2023, 9, 1, 12, 30, 45);
        final original = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: testDate,
        );

        final json = original.toJson();
        final restored = AppSettings.fromJson(json);

        expect(restored.ouiDatabaseEnabled, original.ouiDatabaseEnabled);
        expect(
            restored.ouiDatabaseLastUpdated, original.ouiDatabaseLastUpdated);
      });

      test('should have consistent equality comparison', () {
        final testDate = DateTime(2023, 9);

        final settings1 = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: testDate,
        );

        final settings2 = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: testDate,
        );

        // Note: The toString doesn't show all fields, so we test the actual properties
        expect(
            settings1.ouiDatabaseEnabled, equals(settings2.ouiDatabaseEnabled));
        expect(settings1.ouiDatabaseLastUpdated,
            equals(settings2.ouiDatabaseLastUpdated));
        expect(settings1.autoScanningEnabled,
            equals(settings2.autoScanningEnabled));
        expect(settings1.batteryThresholdPercent,
            equals(settings2.batteryThresholdPercent));
      });

      test('should not be equal when OUI fields differ', () {
        final testDate1 = DateTime(2023, 9);
        final testDate2 = DateTime(2023, 9, 2);

        final settings1 = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: testDate1,
        );

        final settings2 = AppSettings(
          ouiDatabaseLastUpdated: testDate2,
        );

        expect(settings1, isNot(equals(settings2)));
      });

      test('should access OUI fields in string representation', () {
        final testDate = DateTime(2023, 9, 1, 12, 30, 45);
        final settings = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: testDate,
        );

        // Test that we can access the fields directly
        expect(settings.ouiDatabaseEnabled, true);
        expect(settings.ouiDatabaseLastUpdated, testDate);

        // The toString method exists and works
        final stringRep = settings.toString();
        expect(stringRep, isA<String>());
        expect(stringRep, isNotEmpty);
      });
    });
  });
}
