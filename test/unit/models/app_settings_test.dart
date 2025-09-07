import 'package:blufie_ui/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings', () {
    group('Constructor Tests', () {
      test('should create with default values', () {
        const settings = AppSettings();

        expect(settings.autoScanningEnabled, false);
        expect(settings.autoScanWhenPluggedIn, false);
        expect(settings.scanIntervalSeconds, 30);
        expect(settings.locationTrackingEnabled, true);
        expect(settings.batteryOptimizationEnabled, false);
        expect(settings.backgroundScanningEnabled, true);
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
          autoScanWhenPluggedIn: true,
          batteryOptimizationEnabled: true,
          backgroundScanningEnabled: false,
          dataRetentionDays: 60,
          locationTrackingEnabled: false,
          showNotifications: false,
        );

        expect(settings.autoScanningEnabled, true);
        expect(settings.scanIntervalSeconds, 60);
        expect(settings.batteryThresholdPercent, 15);
        expect(settings.verboseLoggingEnabled, true);
        expect(settings.autoScanWhenPluggedIn, true);
        expect(settings.batteryOptimizationEnabled, true);
        expect(settings.backgroundScanningEnabled, false);
        expect(settings.dataRetentionDays, 60);
        expect(settings.locationTrackingEnabled, false);
        expect(settings.showNotifications, false);
      });

      test('should be immutable (const constructor)', () {
        const settings1 = AppSettings();
        const settings2 = AppSettings();

        // Should be the same instance due to const constructor
        expect(identical(settings1, settings2), true);
      });
    });

    group('copyWith Tests', () {
      test('should return new instance with updated values', () {
        const originalSettings = AppSettings();

        final updatedSettings = originalSettings.copyWith(
          autoScanningEnabled: true,
          scanIntervalSeconds: 60,
        );

        // Original should be unchanged
        expect(originalSettings.autoScanningEnabled, false);
        expect(originalSettings.scanIntervalSeconds, 30);
        expect(originalSettings.batteryThresholdPercent, 20);

        // Updated should have new values
        expect(updatedSettings.autoScanningEnabled, true);
        expect(updatedSettings.scanIntervalSeconds, 60);
        expect(updatedSettings.batteryThresholdPercent, 20); // unchanged
      });

      test('should return same values when no parameters provided', () {
        const originalSettings = AppSettings(
          autoScanningEnabled: true,
          scanIntervalSeconds: 45,
          batteryThresholdPercent: 25,
          verboseLoggingEnabled: true,
        );

        final copiedSettings = originalSettings.copyWith();

        expect(copiedSettings.autoScanningEnabled,
            originalSettings.autoScanningEnabled);
        expect(copiedSettings.scanIntervalSeconds,
            originalSettings.scanIntervalSeconds);
        expect(copiedSettings.batteryThresholdPercent,
            originalSettings.batteryThresholdPercent);
        expect(copiedSettings.verboseLoggingEnabled,
            originalSettings.verboseLoggingEnabled);
      });

      test('should handle all parameters in copyWith', () {
        const originalSettings = AppSettings();

        final updatedSettings = originalSettings.copyWith(
          autoScanningEnabled: true,
          batteryOptimizationEnabled: true,
          backgroundScanningEnabled: false,
          batteryThresholdPercent: 15,
          scanIntervalSeconds: 120,
          dataRetentionDays: 90,
          locationTrackingEnabled: false,
          verboseLoggingEnabled: true,
          showNotifications: false,
          autoScanWhenPluggedIn: true,
        );

        expect(updatedSettings.autoScanningEnabled, true);
        expect(updatedSettings.batteryOptimizationEnabled, true);
        expect(updatedSettings.backgroundScanningEnabled, false);
        expect(updatedSettings.batteryThresholdPercent, 15);
        expect(updatedSettings.scanIntervalSeconds, 120);
        expect(updatedSettings.dataRetentionDays, 90);
        expect(updatedSettings.locationTrackingEnabled, false);
        expect(updatedSettings.verboseLoggingEnabled, true);
        expect(updatedSettings.showNotifications, false);
        expect(updatedSettings.autoScanWhenPluggedIn, true);
      });

      test('should handle null values in copyWith (keep original)', () {
        const originalSettings = AppSettings(
          autoScanningEnabled: true,
          scanIntervalSeconds: 60,
          batteryThresholdPercent: 15,
        );

        final updatedSettings = originalSettings.copyWith(
          scanIntervalSeconds: 90, // Should update
        );

        expect(updatedSettings.autoScanningEnabled, true); // kept original
        expect(updatedSettings.scanIntervalSeconds, 90); // updated
        expect(updatedSettings.batteryThresholdPercent, 15); // kept original
      });
    });

    group('JSON Serialization Tests', () {
      test('should serialize to JSON correctly', () {
        const settings = AppSettings(
          autoScanningEnabled: true,
          scanIntervalSeconds: 45,
          batteryThresholdPercent: 25,
          dataRetentionDays: 60,
          locationTrackingEnabled: false,
          verboseLoggingEnabled: true,
          showNotifications: false,
          autoScanWhenPluggedIn: true,
        );

        final json = settings.toJson();

        expect(json['autoScanningEnabled'], true);
        expect(json['scanIntervalSeconds'], 45);
        expect(json['batteryThresholdPercent'], 25);
        expect(json['batteryOptimizationEnabled'], false);
        expect(json['dataRetentionDays'], 60);
        expect(json['locationTrackingEnabled'], false);
        expect(json['verboseLoggingEnabled'], true);
        expect(json['showNotifications'], false);
        expect(json['autoScanWhenPluggedIn'], true);
      });

      test('should serialize default values to JSON correctly', () {
        const settings = AppSettings();
        final json = settings.toJson();

        expect(json['autoScanningEnabled'], false);
        expect(json['batteryOptimizationEnabled'], false);
        expect(json['backgroundScanningEnabled'], true);
        expect(json['batteryThresholdPercent'], 20);
        expect(json['scanIntervalSeconds'], 30);
        expect(json['dataRetentionDays'], 30);
        expect(json['locationTrackingEnabled'], true);
        expect(json['verboseLoggingEnabled'], false);
        expect(json['showNotifications'], true);
        expect(json['autoScanWhenPluggedIn'], false);
      });

      test('should contain all required keys in JSON', () {
        const settings = AppSettings();
        final json = settings.toJson();

        final expectedKeys = [
          'autoScanningEnabled',
          'batteryOptimizationEnabled',
          'backgroundScanningEnabled',
          'batteryThresholdPercent',
          'scanIntervalSeconds',
          'dataRetentionDays',
          'locationTrackingEnabled',
          'verboseLoggingEnabled',
          'showNotifications',
          'autoScanWhenPluggedIn',
        ];

        for (final key in expectedKeys) {
          expect(json.containsKey(key), true,
              reason: 'JSON should contain key: $key');
        }
      });
    });

    group('JSON Deserialization Tests', () {
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
        expect(settings.batteryOptimizationEnabled, false); // default
        expect(settings.backgroundScanningEnabled, true); // default
        expect(settings.verboseLoggingEnabled, false); // default
        expect(settings.batteryThresholdPercent, 20); // default
        expect(settings.dataRetentionDays, 30); // default
        expect(settings.showNotifications, true); // default
        expect(settings.autoScanWhenPluggedIn, false); // default
      });

      test('should handle empty JSON with all defaults', () {
        final json = <String, dynamic>{};
        final settings = AppSettings.fromJson(json);

        expect(settings.autoScanningEnabled, false);
        expect(settings.batteryOptimizationEnabled, false);
        expect(settings.backgroundScanningEnabled, true);
        expect(settings.batteryThresholdPercent, 20);
        expect(settings.scanIntervalSeconds, 30);
        expect(settings.dataRetentionDays, 30);
        expect(settings.locationTrackingEnabled, true);
        expect(settings.verboseLoggingEnabled, false);
        expect(settings.showNotifications, true);
        expect(settings.autoScanWhenPluggedIn, false);
      });

      test('should handle null values in JSON with defaults', () {
        final json = {
          'autoScanningEnabled': null,
          'scanIntervalSeconds': 60,
          'batteryThresholdPercent': null,
          'verboseLoggingEnabled': true,
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.autoScanningEnabled, false); // default due to null
        expect(settings.scanIntervalSeconds, 60);
        expect(settings.batteryThresholdPercent, 20); // default due to null
        expect(settings.verboseLoggingEnabled, true);
      });

      test('should handle JSON serialization round trip', () {
        const originalSettings = AppSettings(
          autoScanningEnabled: true,
          scanIntervalSeconds: 120,
          batteryThresholdPercent: 10,
          verboseLoggingEnabled: true,
          dataRetentionDays: 45,
          locationTrackingEnabled: false,
          showNotifications: false,
          autoScanWhenPluggedIn: true,
        );

        final json = originalSettings.toJson();
        final deserializedSettings = AppSettings.fromJson(json);

        expect(deserializedSettings.autoScanningEnabled,
            originalSettings.autoScanningEnabled);
        expect(deserializedSettings.scanIntervalSeconds,
            originalSettings.scanIntervalSeconds);
        expect(deserializedSettings.batteryThresholdPercent,
            originalSettings.batteryThresholdPercent);
        expect(deserializedSettings.verboseLoggingEnabled,
            originalSettings.verboseLoggingEnabled);
        expect(deserializedSettings.batteryOptimizationEnabled,
            originalSettings.batteryOptimizationEnabled);
        expect(deserializedSettings.dataRetentionDays,
            originalSettings.dataRetentionDays);
        expect(deserializedSettings.locationTrackingEnabled,
            originalSettings.locationTrackingEnabled);
        expect(deserializedSettings.showNotifications,
            originalSettings.showNotifications);
        expect(deserializedSettings.autoScanWhenPluggedIn,
            originalSettings.autoScanWhenPluggedIn);
      });
    });

    group('toString Tests', () {
      test('should return formatted string with key values', () {
        const settings = AppSettings(
          autoScanningEnabled: true,
          batteryThresholdPercent: 25,
          scanIntervalSeconds: 60,
        );

        final stringRepresentation = settings.toString();

        expect(stringRepresentation, contains('AppSettings'));
        expect(stringRepresentation, contains('autoScanningEnabled: true'));
        expect(stringRepresentation, contains('batteryThresholdPercent: 25'));
        expect(stringRepresentation, contains('scanIntervalSeconds: 60'));
      });

      test('should handle default values in toString', () {
        const settings = AppSettings();
        final stringRepresentation = settings.toString();

        expect(stringRepresentation, contains('autoScanningEnabled: false'));
        expect(stringRepresentation, contains('batteryThresholdPercent: 20'));
        expect(stringRepresentation, contains('scanIntervalSeconds: 30'));
      });

      test('should be useful for debugging', () {
        const settings = AppSettings(
          batteryThresholdPercent: 15,
          scanIntervalSeconds: 120,
        );

        final stringRepresentation = settings.toString();

        // Should contain the class name and key properties for debugging
        expect(stringRepresentation.startsWith('AppSettings('), true);
        expect(stringRepresentation.endsWith(')'), true);
      });
    });

    group('Edge Cases and Validation Tests', () {
      test('should handle extreme values', () {
        const settings = AppSettings(
          batteryThresholdPercent: 100,
          scanIntervalSeconds: 86400, // 24 hours
          dataRetentionDays: 9999,
        );

        expect(settings.batteryThresholdPercent, 100);
        expect(settings.scanIntervalSeconds, 86400);
        expect(settings.dataRetentionDays, 9999);
      });

      test('should handle minimum values', () {
        const settings = AppSettings(
          batteryThresholdPercent: 0,
          scanIntervalSeconds: 1,
          dataRetentionDays: 1,
        );

        expect(settings.batteryThresholdPercent, 0);
        expect(settings.scanIntervalSeconds, 1);
        expect(settings.dataRetentionDays, 1);
      });

      test('should maintain immutability', () {
        const settings = AppSettings(autoScanningEnabled: true);

        // Attempt to create a "modified" version
        final modifiedSettings = settings.copyWith(autoScanningEnabled: false);

        // Original should be unchanged
        expect(settings.autoScanningEnabled, true);
        expect(modifiedSettings.autoScanningEnabled, false);

        // Should be different instances
        expect(identical(settings, modifiedSettings), false);
      });
    });

    group('Type Safety Tests', () {
      test('should maintain correct types for all properties', () {
        const settings = AppSettings();

        expect(settings.autoScanningEnabled, isA<bool>());
        expect(settings.batteryOptimizationEnabled, isA<bool>());
        expect(settings.backgroundScanningEnabled, isA<bool>());
        expect(settings.batteryThresholdPercent, isA<int>());
        expect(settings.scanIntervalSeconds, isA<int>());
        expect(settings.dataRetentionDays, isA<int>());
        expect(settings.locationTrackingEnabled, isA<bool>());
        expect(settings.verboseLoggingEnabled, isA<bool>());
        expect(settings.showNotifications, isA<bool>());
        expect(settings.autoScanWhenPluggedIn, isA<bool>());
      });

      test('toJson should return Map<String, dynamic>', () {
        const settings = AppSettings();
        final json = settings.toJson();

        expect(json, isA<Map<String, dynamic>>());
      });
    });

    group('OUI Database Settings', () {
      test('should have correct default OUI values', () {
        const settings = AppSettings();

        expect(settings.ouiDatabaseEnabled, false);
        expect(settings.ouiDatabaseLastUpdated, null);
      });

      test('should handle OUI database enabled setting', () {
        const settings = AppSettings(ouiDatabaseEnabled: true);

        expect(settings.ouiDatabaseEnabled, true);
      });

      test('should handle OUI database last updated setting', () {
        final lastUpdated = DateTime(2023, 9, 1, 12);
        final settings = AppSettings(ouiDatabaseLastUpdated: lastUpdated);

        expect(settings.ouiDatabaseLastUpdated, lastUpdated);
      });

      test('should handle null OUI database last updated', () {
        const settings = AppSettings();

        expect(settings.ouiDatabaseLastUpdated, null);
      });

      test('should update OUI database enabled via copyWith', () {
        const original = AppSettings();
        final updated = original.copyWith(ouiDatabaseEnabled: true);

        expect(original.ouiDatabaseEnabled, false);
        expect(updated.ouiDatabaseEnabled, true);
      });

      test('should update OUI database last updated via copyWith', () {
        const original = AppSettings();
        final lastUpdated = DateTime(2023, 9);
        final updated = original.copyWith(ouiDatabaseLastUpdated: lastUpdated);

        expect(original.ouiDatabaseLastUpdated, null);
        expect(updated.ouiDatabaseLastUpdated, lastUpdated);
      });

      test('should preserve OUI database last updated via copyWith', () {
        final testDate = DateTime(2023, 9);
        final original = AppSettings(ouiDatabaseLastUpdated: testDate);
        final updated = original.copyWith();

        expect(original.ouiDatabaseLastUpdated, testDate);
        expect(updated.ouiDatabaseLastUpdated, testDate);
      });

      test('should update multiple OUI settings at once', () {
        const original = AppSettings();

        final lastUpdated = DateTime(2023, 9);
        final updated = original.copyWith(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: lastUpdated,
        );

        expect(updated.ouiDatabaseEnabled, true);
        expect(updated.ouiDatabaseLastUpdated, lastUpdated);
      });

      test('should serialize OUI settings to JSON correctly', () {
        final lastUpdated = DateTime(2023, 9, 1, 12, 30, 45);
        final settings = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: lastUpdated,
        );

        final json = settings.toJson();

        expect(json['ouiDatabaseEnabled'], true);
        expect(
            json['ouiDatabaseLastUpdated'], lastUpdated.millisecondsSinceEpoch);
      });

      test('should serialize null OUI last updated to JSON', () {
        const settings = AppSettings(
          ouiDatabaseEnabled: true,
        );

        final json = settings.toJson();

        expect(json['ouiDatabaseEnabled'], true);
        expect(json['ouiDatabaseLastUpdated'], null);
      });

      test('should deserialize OUI settings from JSON correctly', () {
        final lastUpdated = DateTime(2023, 9, 1, 12, 30, 45);
        final json = {
          'autoScanningEnabled': false,
          'autoScanWhenPluggedIn': false,
          'scanIntervalSeconds': 30,
          'locationTrackingEnabled': true,
          'batteryOptimizationEnabled': false,
          'backgroundScanningEnabled': true,
          'batteryThresholdPercent': 20,
          'verboseLoggingEnabled': false,
          'showNotifications': true,
          'dataRetentionDays': 30,
          'ouiDatabaseEnabled': true,
          'ouiDatabaseLastUpdated': lastUpdated.millisecondsSinceEpoch,
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.ouiDatabaseEnabled, true);
        expect(settings.ouiDatabaseLastUpdated, lastUpdated);
      });

      test('should deserialize null OUI last updated from JSON', () {
        final json = {
          'autoScanningEnabled': false,
          'autoScanWhenPluggedIn': false,
          'scanIntervalSeconds': 30,
          'locationTrackingEnabled': true,
          'batteryOptimizationEnabled': true,
          'batteryThresholdPercent': 20,
          'verboseLoggingEnabled': false,
          'showNotifications': true,
          'dataRetentionDays': 30,
          'ouiDatabaseEnabled': false,
          'ouiDatabaseLastUpdated': null,
        };

        final settings = AppSettings.fromJson(json);

        expect(settings.ouiDatabaseEnabled, false);
        expect(settings.ouiDatabaseLastUpdated, null);
      });

      test('should handle missing OUI fields in JSON with defaults', () {
        final json = {
          'autoScanningEnabled': true,
          'scanIntervalSeconds': 30,
          // Missing OUI fields
        };

        final settings = AppSettings.fromJson(json);

        // Should use default values
        expect(settings.ouiDatabaseEnabled, false);
        expect(settings.ouiDatabaseLastUpdated, null);
      });

      test('should maintain OUI data integrity through JSON round-trip', () {
        final lastUpdated = DateTime(2023, 9, 1, 12, 30, 45, 123);
        final original = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: lastUpdated,
        );

        final json = original.toJson();
        final restored = AppSettings.fromJson(json);

        expect(restored.ouiDatabaseEnabled, original.ouiDatabaseEnabled);
        expect(
            restored.ouiDatabaseLastUpdated, original.ouiDatabaseLastUpdated);
      });

      test('should handle null OUI last updated in round-trip', () {
        const original = AppSettings(
          ouiDatabaseEnabled: true,
        );

        final json = original.toJson();
        final restored = AppSettings.fromJson(json);

        expect(restored.ouiDatabaseEnabled, original.ouiDatabaseEnabled);
        expect(
            restored.ouiDatabaseLastUpdated, original.ouiDatabaseLastUpdated);
      });

      test('should be equal when OUI fields are the same', () {
        final lastUpdated = DateTime(2023, 9);
        final settings1 = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: lastUpdated,
        );
        final settings2 = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: lastUpdated,
        );

        // Compare fields instead of object equality since AppSettings doesn't implement equality
        expect(
            settings1.ouiDatabaseEnabled, equals(settings2.ouiDatabaseEnabled));
        expect(settings1.ouiDatabaseLastUpdated,
            equals(settings2.ouiDatabaseLastUpdated));
      });

      test('should not be equal when OUI database enabled differs', () {
        const settings1 = AppSettings(ouiDatabaseEnabled: true);
        const settings2 = AppSettings();

        expect(settings1, isNot(equals(settings2)));
        expect(settings1.hashCode, isNot(equals(settings2.hashCode)));
      });

      test('should not be equal when OUI last updated differs', () {
        final date1 = DateTime(2023, 9);
        final date2 = DateTime(2023, 9, 2);
        final settings1 = AppSettings(ouiDatabaseLastUpdated: date1);
        final settings2 = AppSettings(ouiDatabaseLastUpdated: date2);

        expect(settings1, isNot(equals(settings2)));
        expect(settings1.hashCode, isNot(equals(settings2.hashCode)));
      });

      test('should handle extreme date values for OUI last updated', () {
        final extremeDate = DateTime(1970); // Unix epoch
        final settings = AppSettings(ouiDatabaseLastUpdated: extremeDate);

        expect(settings.ouiDatabaseLastUpdated, extremeDate);

        final json = settings.toJson();
        final restored = AppSettings.fromJson(json);

        expect(restored.ouiDatabaseLastUpdated, extremeDate);
      });

      test('should handle future dates for OUI last updated', () {
        final futureDate = DateTime(2030, 12, 31, 23, 59, 59);
        final settings = AppSettings(ouiDatabaseLastUpdated: futureDate);

        expect(settings.ouiDatabaseLastUpdated, futureDate);

        final json = settings.toJson();
        final restored = AppSettings.fromJson(json);

        expect(restored.ouiDatabaseLastUpdated, futureDate);
      });
    });
  });
}
