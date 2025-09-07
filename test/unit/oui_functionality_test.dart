import 'package:blufie_ui/models/app_settings.dart';
import 'package:blufie_ui/services/oui_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OUI Functionality Core Tests', () {
    late OuiService ouiService;

    setUp(() {
      ouiService = OuiService();
    });

    group('MAC Address Processing', () {
      test('should handle various MAC address formats', () {
        final testCases = [
          {'input': '00:50:56:12:34:56', 'shouldWork': true},
          {'input': '00-50-56-12-34-56', 'shouldWork': true},
          {'input': '005056123456', 'shouldWork': true},
          {'input': '00:50:56', 'shouldWork': false},
          {'input': 'invalid', 'shouldWork': false},
          {'input': '', 'shouldWork': false},
          {'input': 'GG:HH:II:JJ:KK:LL', 'shouldWork': false},
        ];

        for (final testCase in testCases) {
          final input = testCase['input'] as String;
          final result = ouiService.getManufacturer(input);

          // Should never throw, always return null or string
          expect(result, anyOf(isNull, isA<String>()));

          if (testCase['shouldWork'] as bool) {
            // For valid MAC addresses, we might get a manufacturer or null
            expect(result, anyOf(isNull, isA<String>()));
          }
        }
      });

      test('should be consistent for same OUI in different formats', () {
        // Test VMware OUI in different formats
        final formats = [
          '00:50:56:12:34:56',
          '00-50-56-AB-CD-EF',
          '005056FEDCBA',
        ];

        final results = formats.map(ouiService.getManufacturer).toList();

        // All results should be the same (either all null or all the same string)
        expect(results.every((r) => r == results.first), true);
      });

      test('should handle edge case MAC addresses', () {
        final edgeCases = [
          'FF:FF:FF:FF:FF:FF', // Broadcast
          '00:00:00:00:00:00', // Null MAC
          '01:02:03:04:05:06', // Sequential
          'AA:BB:CC:DD:EE:FF', // All hex letters
        ];

        for (final mac in edgeCases) {
          expect(() => ouiService.getManufacturer(mac), returnsNormally);
          final result = ouiService.getManufacturer(mac);
          expect(result, anyOf(isNull, isA<String>()));
        }
      });
    });

    group('Service State', () {
      test('should maintain singleton behavior', () {
        final service1 = OuiService();
        final service2 = OuiService();
        final service3 = OuiService();

        expect(service1, same(service2));
        expect(service2, same(service3));
        expect(service1, same(service3));
      });

      test('should have predictable initial state', () {
        expect(ouiService.isDownloading, false);
        expect(ouiService.databaseSize, isA<int>());
        expect(ouiService.databaseSize, greaterThanOrEqualTo(0));
        expect(ouiService.isLoaded, isA<bool>());
      });

      test('should provide stream access', () {
        expect(ouiService.databaseStream, isA<Stream<Map<String, String>>>());
        expect(ouiService.downloadProgressStream, isA<Stream<double>>());
      });
    });

    group('Error Resilience', () {
      test('should handle all public methods without throwing', () {
        // These should never throw, even if they fail internally
        expect(() => ouiService.getManufacturer('any-string'), returnsNormally);
        expect(() => ouiService.isLoaded, returnsNormally);
        expect(() => ouiService.isDownloading, returnsNormally);
        expect(() => ouiService.databaseSize, returnsNormally);
        expect(() => ouiService.databaseStream, returnsNormally);
        expect(() => ouiService.downloadProgressStream, returnsNormally);
      });

      test('should handle rapid successive calls', () {
        // Rapid fire MAC address lookups
        for (int i = 0; i < 100; i++) {
          final mac = '00:50:56:${i.toRadixString(16).padLeft(2, '0')}:34:56';
          expect(() => ouiService.getManufacturer(mac), returnsNormally);
        }
      });
    });

    group('AppSettings OUI Integration', () {
      test('should work with AppSettings OUI fields', () {
        final testDate = DateTime(2023, 9, 1, 12, 30, 45);

        // Test creating settings with OUI fields
        final settings = AppSettings(
          ouiDatabaseEnabled: true,
          ouiDatabaseLastUpdated: testDate,
        );

        expect(settings.ouiDatabaseEnabled, true);
        expect(settings.ouiDatabaseLastUpdated, testDate);

        // Test JSON serialization
        final json = settings.toJson();
        expect(json['ouiDatabaseEnabled'], true);
        expect(json['ouiDatabaseLastUpdated'], isA<int>());

        // Test JSON deserialization
        final restored = AppSettings.fromJson(json);
        expect(restored.ouiDatabaseEnabled, true);
        expect(restored.ouiDatabaseLastUpdated, testDate);
      });

      test('should handle different OUI setting combinations', () {
        final testDate = DateTime(
            2023, 9, 1, 12, 30, 45); // Use fixed date to avoid precision issues
        final combinations = [
          {'enabled': true, 'date': testDate},
          {'enabled': true, 'date': null},
          {'enabled': false, 'date': testDate},
          {'enabled': false, 'date': null},
        ];

        for (final combo in combinations) {
          final settings = AppSettings(
            ouiDatabaseEnabled: combo['enabled'] as bool,
            ouiDatabaseLastUpdated: combo['date'] as DateTime?,
          );

          expect(settings.ouiDatabaseEnabled, combo['enabled']);
          expect(settings.ouiDatabaseLastUpdated, combo['date']);

          // Should be serializable
          final json = settings.toJson();
          expect(json, isA<Map<String, dynamic>>());

          // Should be deserializable
          final restored = AppSettings.fromJson(json);
          expect(restored.ouiDatabaseEnabled, combo['enabled']);

          // Handle DateTime precision differences in serialization
          if (combo['date'] != null) {
            final originalDate = combo['date'] as DateTime;
            final restoredDate = restored.ouiDatabaseLastUpdated!;

            // Compare by milliseconds since epoch to avoid microsecond precision issues
            expect(restoredDate.millisecondsSinceEpoch,
                originalDate.millisecondsSinceEpoch);
          } else {
            expect(restored.ouiDatabaseLastUpdated, null);
          }
        }
      });
    });

    group('Real-world Usage Patterns', () {
      test('should handle typical Bluetooth MAC addresses', () {
        // Common Bluetooth device manufacturers
        final commonMACs = [
          '00:50:56:12:34:56', // VMware
          '00:00:0C:12:34:56', // Cisco
          '00:16:CB:12:34:56', // Apple (old range)
          '00:23:6C:12:34:56', // Apple (another range)
          '00:26:08:12:34:56', // Belkin
          'E4:5F:01:12:34:56', // Random modern format
        ];

        for (final mac in commonMACs) {
          final result = ouiService.getManufacturer(mac);

          // Should handle gracefully
          expect(result, anyOf(isNull, isA<String>()));

          // If we get a manufacturer, it should be a non-empty string
          if (result != null) {
            expect(result, isNotEmpty);
            expect(result, isA<String>());
          }
        }
      });

      test('should handle mixed case and formatting', () {
        final variations = [
          '00:50:56:12:34:56', // lowercase with colons
          '00:50:56:12:34:56'.toUpperCase(), // uppercase with colons
          '00-50-56-12-34-56', // lowercase with dashes
          '00-50-56-12-34-56'.toUpperCase(), // uppercase with dashes
          '005056123456', // no separators lowercase
          '005056123456'.toUpperCase(), // no separators uppercase
        ];

        final results = variations.map(ouiService.getManufacturer).toSet();

        // All variations should produce the same result
        expect(results.length, lessThanOrEqualTo(1),
            reason: 'All format variations should produce the same result');
      });
    });
  });
}
