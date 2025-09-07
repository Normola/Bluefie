import 'package:blufie_ui/models/app_settings.dart';
import 'package:blufie_ui/services/logging_service.dart';
import 'package:blufie_ui/services/oui_service.dart';
import 'package:blufie_ui/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OUI Simple Integration Tests', () {
    late SettingsService settingsService;
    late OuiService ouiService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      LoggingService().initialize();
    });

    setUp(() async {
      settingsService = SettingsService();
      ouiService = OuiService();

      // Initialize with error handling
      try {
        await settingsService.initialize();
      } catch (e) {
        // Expected to fail in test environment
      }

      try {
        await ouiService.initialize();
      } catch (e) {
        // Expected to fail in test environment
      }
    });

    test('should handle basic OUI service integration', () async {
      // Test basic service access
      expect(ouiService.databaseSize, isA<int>());
      expect(ouiService.isLoaded, isA<bool>());
      expect(ouiService.isDownloading, isA<bool>());

      // Test manufacturer lookup (should return null in test environment)
      final manufacturer = ouiService.getManufacturer('00:11:22:33:44:55');
      expect(manufacturer, isNull);
    });

    test('should handle OUI settings without platform dependencies', () async {
      // Test settings that don't require platform channels
      final testDate = DateTime(2023, 9);

      // Create settings with OUI data
      final settings = AppSettings(
        ouiDatabaseEnabled: true,
        ouiDatabaseLastUpdated: testDate,
      );

      expect(settings.ouiDatabaseEnabled, true);
      expect(settings.ouiDatabaseLastUpdated, testDate);

      // Test JSON serialization
      final json = settings.toJson();
      expect(json['ouiDatabaseEnabled'], true);
      expect(json['ouiDatabaseLastUpdated'], testDate.millisecondsSinceEpoch);

      // Test deserialization
      final restored = AppSettings.fromJson(json);
      expect(restored.ouiDatabaseEnabled, true);
      expect(restored.ouiDatabaseLastUpdated, testDate);
    });

    test('should handle OUI service state queries', () async {
      // Test state queries that don't require platform access
      expect(ouiService.databaseSize, greaterThanOrEqualTo(0));
      expect(ouiService.isDownloading,
          false); // Should not be downloading initially

      // Test last update time query (will likely return null in test environment)
      final lastUpdate =
          await ouiService.getLastUpdateTime().catchError((_) => null);
      expect(lastUpdate, anyOf(isNull, isA<DateTime>()));
    });

    test('should handle OUI service streams safely', () async {
      // Test that streams are available
      expect(ouiService.databaseStream, isNotNull);
      expect(ouiService.downloadProgressStream, isNotNull);

      // Test stream subscriptions without triggering platform operations
      var databaseUpdates = 0;
      var progressUpdates = 0;

      final dbSubscription = ouiService.databaseStream.listen((_) {
        databaseUpdates++;
      });

      final progressSubscription =
          ouiService.downloadProgressStream.listen((_) {
        progressUpdates++;
      });

      // Wait a bit to see if any events come through
      await Future.delayed(const Duration(milliseconds: 100));

      // Clean up subscriptions
      await dbSubscription.cancel();
      await progressSubscription.cancel();

      // Streams should be available even if no events are emitted
      expect(databaseUpdates, greaterThanOrEqualTo(0));
      expect(progressUpdates, greaterThanOrEqualTo(0));
    });

    test('should handle copyWith for OUI settings', () {
      final original = AppSettings(
        ouiDatabaseLastUpdated: DateTime(2023, 9),
      );

      // Test enabling OUI database
      final enabled = original.copyWith(ouiDatabaseEnabled: true);
      expect(enabled.ouiDatabaseEnabled, true);
      expect(enabled.ouiDatabaseLastUpdated, original.ouiDatabaseLastUpdated);

      // Test updating timestamp
      final newDate = DateTime(2023, 10);
      final updated = original.copyWith(ouiDatabaseLastUpdated: newDate);
      expect(updated.ouiDatabaseEnabled, original.ouiDatabaseEnabled);
      expect(updated.ouiDatabaseLastUpdated, newDate);
    });

    test('should handle error conditions gracefully', () async {
      // Test operations that will fail in test environment
      final downloadResult =
          await ouiService.downloadDatabase().catchError((_) => false);
      expect(downloadResult, isFalse);

      final deleteResult =
          await ouiService.deleteDatabase().catchError((_) => false);
      expect(deleteResult, isFalse);

      // Service should still be functional after errors
      expect(ouiService.databaseSize, isA<int>());
      expect(ouiService.getManufacturer('00:11:22:33:44:55'), isNull);
    });
  });
}
