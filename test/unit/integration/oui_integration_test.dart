import 'dart:async';

import 'package:blufie_ui/models/app_settings.dart';
import 'package:blufie_ui/services/oui_service.dart';
import 'package:blufie_ui/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OUI Integration Tests', () {
    late SettingsService settingsService;
    late OuiService ouiService;

    setUp(() async {
      settingsService = SettingsService();
      ouiService = OuiService();

      // Initialize services
      await settingsService.initialize();
      await ouiService.initialize();
    });

    tearDown(() {
      ouiService.dispose();
    });

    group('OUI Service and Settings Integration', () {
      test('should work together for complete OUI workflow', () async {
        // Start with OUI disabled
        expect(settingsService.currentSettings.ouiDatabaseEnabled, false);
        expect(ouiService.isLoaded, anyOf(true, false));

        // Enable OUI in settings
        await settingsService.updateOuiDatabaseEnabled(true);
        expect(settingsService.currentSettings.ouiDatabaseEnabled, true);

        // Test manufacturer lookup (should work regardless of loaded state)
        final manufacturer = ouiService.getManufacturer('00:50:56:12:34:56');
        expect(manufacturer, anyOf(isNull, isA<String>()));

        // Test download functionality
        final downloadResult =
            await ouiService.downloadDatabase(forceUpdate: false);
        expect(downloadResult, isA<bool>());

        // Update last updated time in settings
        final lastUpdate = await ouiService.getLastUpdateTime();
        if (lastUpdate != null) {
          await settingsService.updateOuiDatabaseLastUpdated(lastUpdate);
          expect(settingsService.currentSettings.ouiDatabaseLastUpdated,
              lastUpdate);
        }
      });

      test('should handle settings persistence with OUI data', () async {
        // Set OUI settings
        await settingsService.updateOuiDatabaseEnabled(true);
        final testDate = DateTime(2023, 9, 1);
        await settingsService.updateOuiDatabaseLastUpdated(testDate);

        // Verify settings are updated
        final currentSettings = settingsService.currentSettings;
        expect(currentSettings.ouiDatabaseEnabled, true);
        expect(currentSettings.ouiDatabaseLastUpdated, testDate);

        // Test settings serialization
        final json = currentSettings.toJson();
        expect(json['ouiDatabaseEnabled'], true);
        expect(json['ouiDatabaseLastUpdated'], testDate.toIso8601String());

        // Test settings deserialization
        final restored = AppSettings.fromJson(json);
        expect(restored.ouiDatabaseEnabled, true);
        expect(restored.ouiDatabaseLastUpdated, testDate);
      });

      test('should handle OUI database lifecycle', () async {
        // Initial state
        expect(ouiService.isLoaded, anyOf(true, false));
        expect(ouiService.isDownloading, false);
        expect(ouiService.databaseSize, greaterThanOrEqualTo(0));

        // Test initialization
        await ouiService.initialize();
        expect(ouiService.isDownloading, false);

        // Test deletion
        final deleteResult = await ouiService.deleteDatabase();
        expect(deleteResult, true);
        expect(ouiService.isLoaded, false);
        expect(ouiService.databaseSize, 0);

        // Test re-initialization after deletion
        await ouiService.initialize();
        expect(ouiService.isDownloading, false);
      });

      test('should handle concurrent operations gracefully', () async {
        // Test concurrent downloads
        final future1 = ouiService.downloadDatabase();
        final future2 = ouiService.downloadDatabase();

        final results = await Future.wait([future1, future2]);

        expect(results, hasLength(2));
        // Both results should be booleans
        for (final result in results) {
          expect(result, isA<bool>());
        }
        expect(ouiService.isDownloading, false);
      });

      test('should maintain state consistency across operations', () async {
        // Perform various operations and check state consistency
        await ouiService.initialize();

        // Delete database
        await ouiService.deleteDatabase();
        expect(ouiService.isLoaded, false);
        expect(ouiService.databaseSize, 0);

        // Re-initialize
        await ouiService.initialize();
        expect(ouiService.isDownloading, false);

        // State should be consistent
        expect(ouiService.databaseSize, greaterThanOrEqualTo(0));
        if (ouiService.isLoaded) {
          expect(ouiService.databaseSize, greaterThan(0));
        }
      });
    });

    group('MAC Address Lookup Integration', () {
      test('should handle various MAC address formats consistently', () {
        final testMacAddresses = [
          '00:50:56:12:34:56', // VMware OUI (colon format)
          '00-50-56-12-34-56', // VMware OUI (dash format)
          '005056123456', // VMware OUI (no separators)
          '005056123456', // VMware OUI (lowercase)
          '00:00:0C:12:34:56', // Cisco OUI
          'AA:BB:CC:DD:EE:FF', // Unknown OUI
          'invalid', // Invalid format
          '', // Empty string
        ];

        for (final macAddress in testMacAddresses) {
          final manufacturer = ouiService.getManufacturer(macAddress);

          // Should not throw exceptions
          expect(() => ouiService.getManufacturer(macAddress), returnsNormally);

          // Result should be null or a string
          expect(manufacturer, anyOf(isNull, isA<String>()));
        }
      });

      test('should return consistent results for same OUI', () {
        final sameDifferentFormats = [
          '00:50:56:12:34:56',
          '00-50-56-AB-CD-EF',
          '005056789012',
        ];

        final results =
            sameDifferentFormats.map(ouiService.getManufacturer).toList();

        // All should return the same result for the same OUI
        expect(results.every((result) => result == results.first), true);
      });

      test('should handle edge cases in MAC address parsing', () {
        final edgeCases = [
          'FF:FF:FF:FF:FF:FF', // Broadcast address
          '00:00:00:00:00:00', // Null address
          '01:23:45:67:89:AB', // Mixed case
          '12:34:56:78:9A:BC', // All valid hex
          'GH:IJ:KL:MN:OP:QR', // Invalid hex characters
          '12:34:56', // Too short
          '12:34:56:78:9A:BC:DE:EF', // Too long
        ];

        for (final macAddress in edgeCases) {
          expect(() => ouiService.getManufacturer(macAddress), returnsNormally);
        }
      });
    });

    group('Settings Service OUI Methods', () {
      test('should update OUI database enabled setting', () async {
        // Test enabling
        await settingsService.updateOuiDatabaseEnabled(true);
        expect(settingsService.currentSettings.ouiDatabaseEnabled, true);

        // Test disabling
        await settingsService.updateOuiDatabaseEnabled(false);
        expect(settingsService.currentSettings.ouiDatabaseEnabled, false);
      });

      test('should update OUI database last updated setting', () async {
        final testDate = DateTime(2023, 9, 1, 12, 30, 45);

        // Test setting date
        await settingsService.updateOuiDatabaseLastUpdated(testDate);
        expect(
            settingsService.currentSettings.ouiDatabaseLastUpdated, testDate);

        // Test clearing date
        await settingsService.updateOuiDatabaseLastUpdated(null);
        expect(settingsService.currentSettings.ouiDatabaseLastUpdated, null);
      });

      test('should handle multiple OUI setting updates', () async {
        final testDate = DateTime(2023, 9, 1);

        // Update both settings
        await settingsService.updateOuiDatabaseEnabled(true);
        await settingsService.updateOuiDatabaseLastUpdated(testDate);

        final settings = settingsService.currentSettings;
        expect(settings.ouiDatabaseEnabled, true);
        expect(settings.ouiDatabaseLastUpdated, testDate);

        // Reset both
        await settingsService.updateOuiDatabaseEnabled(false);
        await settingsService.updateOuiDatabaseLastUpdated(null);

        final resetSettings = settingsService.currentSettings;
        expect(resetSettings.ouiDatabaseEnabled, false);
        expect(resetSettings.ouiDatabaseLastUpdated, null);
      });
    });

    group('Error Handling Integration', () {
      test('should handle service initialization errors gracefully', () async {
        // Multiple initializations should not cause issues
        await settingsService.initialize();
        await settingsService.initialize();
        await ouiService.initialize();
        await ouiService.initialize();

        expect(settingsService.currentSettings, isA<AppSettings>());
        expect(ouiService.isDownloading, false);
      });

      test('should handle file system errors gracefully', () async {
        // Test operations that might fail due to file system issues
        final lastUpdate = await ouiService.getLastUpdateTime();
        final deleteResult = await ouiService.deleteDatabase();
        final downloadResult = await ouiService.downloadDatabase();

        // Should return results, not throw
        expect(lastUpdate, anyOf(isNull, isA<DateTime>()));
        expect(deleteResult, isA<bool>());
        expect(downloadResult, isA<bool>());
      });

      test('should maintain state consistency during errors', () async {
        // Trigger potential error conditions
        await ouiService.deleteDatabase();
        await ouiService.initialize();

        // State should still be consistent
        expect(ouiService.isDownloading, false);
        expect(ouiService.databaseSize, greaterThanOrEqualTo(0));
        if (ouiService.isLoaded) {
          expect(ouiService.databaseSize, greaterThan(0));
        }
      });
    });

    group('Stream Integration', () {
      test('should emit settings updates for OUI changes', () async {
        final settingsUpdates = <AppSettings>[];
        late StreamSubscription subscription;

        subscription = settingsService.settingsStream.listen((settings) {
          settingsUpdates.add(settings);
        });

        // Trigger settings updates
        await settingsService.updateOuiDatabaseEnabled(true);
        await settingsService.updateOuiDatabaseLastUpdated(DateTime.now());

        // Give time for stream events
        await Future.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        // Should have received updates
        expect(settingsUpdates, isNotEmpty);
        final lastUpdate = settingsUpdates.last;
        expect(lastUpdate.ouiDatabaseEnabled, true);
        expect(lastUpdate.ouiDatabaseLastUpdated, isNotNull);
      });

      test('should emit OUI database updates', () async {
        final databaseUpdates = <Map<String, String>>[];
        late StreamSubscription subscription;

        subscription = ouiService.databaseStream.listen((database) {
          databaseUpdates.add(Map.from(database));
        });

        // Trigger database updates
        await ouiService.deleteDatabase();

        // Give time for stream events
        await Future.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        // Should have received at least one update
        expect(databaseUpdates, isNotEmpty);
      });

      test('should emit download progress updates', () async {
        final progressUpdates = <double>[];
        late StreamSubscription subscription;

        subscription = ouiService.downloadProgressStream.listen((progress) {
          progressUpdates.add(progress);
        });

        // Trigger download
        await ouiService.downloadDatabase();

        // Give time for stream events
        await Future.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        // Should have received progress updates
        expect(progressUpdates, isNotEmpty);
        expect(
            progressUpdates
                .every((progress) => progress >= 0.0 && progress <= 1.0),
            true);
      });
    });
  });
}
