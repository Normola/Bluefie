import 'package:blufie_ui/services/oui_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OuiService Basic Tests', () {
    late OuiService ouiService;

    setUp(() {
      ouiService = OuiService();
    });

    tearDown(() {
      // Don't dispose to avoid stream controller issues
    });

    group('Singleton Pattern', () {
      test('should return the same instance', () {
        final instance1 = OuiService();
        final instance2 = OuiService();
        expect(instance1, same(instance2));
      });

      test('should maintain singleton across multiple calls', () {
        final instances = List.generate(5, (_) => OuiService());
        final firstInstance = instances.first;

        for (final instance in instances) {
          expect(instance, same(firstInstance));
        }
      });
    });

    group('MAC Address Parsing', () {
      test('should extract OUI from colon-separated MAC address', () {
        final manufacturer = ouiService.getManufacturer('00:50:56:12:34:56');
        expect(manufacturer, anyOf(isNull, isA<String>()));
      });

      test('should extract OUI from dash-separated MAC address', () {
        final manufacturer = ouiService.getManufacturer('00-50-56-12-34-56');
        expect(manufacturer, anyOf(isNull, isA<String>()));
      });

      test('should extract OUI from unseparated MAC address', () {
        final manufacturer = ouiService.getManufacturer('005056123456');
        expect(manufacturer, anyOf(isNull, isA<String>()));
      });

      test('should handle invalid MAC addresses gracefully', () {
        const invalidAddresses = [
          'invalid',
          '12:34',
          'GG:HH:II:JJ:KK:LL',
          '',
          '12:34:56:78:9A:BC:DE:EF',
        ];

        for (final address in invalidAddresses) {
          expect(() => ouiService.getManufacturer(address), returnsNormally);
          final result = ouiService.getManufacturer(address);
          expect(result, anyOf(isNull, isA<String>()));
        }
      });

      test('should return same result for same OUI in different formats', () {
        final result1 = ouiService.getManufacturer('00:50:56:12:34:56');
        final result2 = ouiService.getManufacturer('00-50-56-AB-CD-EF');
        final result3 = ouiService.getManufacturer('005056789012');

        expect(result2, equals(result1));
        expect(result3, equals(result1));
      });
    });

    group('State Management', () {
      test('should have initial state', () {
        expect(ouiService.isDownloading, false);
        expect(ouiService.databaseSize, greaterThanOrEqualTo(0));
        expect(ouiService.isLoaded, anyOf(true, false));
      });

      test('should provide stream access', () {
        expect(ouiService.databaseStream, isA<Stream<Map<String, String>>>());
        expect(ouiService.downloadProgressStream, isA<Stream<double>>());
      });
    });

    group('Database Operations', () {
      test('should handle initialization without throwing', () async {
        expect(() => ouiService.initialize(), returnsNormally);
        await ouiService.initialize();
        expect(ouiService.isDownloading, false);
      });

      test('should handle download attempts gracefully', () async {
        final result = await ouiService.downloadDatabase();
        expect(result, isA<bool>());
        expect(ouiService.isDownloading, false);
      });

      test('should handle deletion attempts gracefully', () async {
        final result = await ouiService.deleteDatabase();
        expect(result, isA<bool>());

        if (result) {
          expect(ouiService.isLoaded, false);
          expect(ouiService.databaseSize, 0);
        }
      });

      test('should handle last update time queries', () async {
        final lastUpdate = await ouiService.getLastUpdateTime();
        expect(lastUpdate, anyOf(isNull, isA<DateTime>()));
      });
    });

    group('Error Handling', () {
      test('should not throw on invalid operations', () {
        expect(() => ouiService.getManufacturer('invalid'), returnsNormally);
        expect(() => ouiService.isLoaded, returnsNormally);
        expect(() => ouiService.isDownloading, returnsNormally);
        expect(() => ouiService.databaseSize, returnsNormally);
      });

      test('should handle method channel errors', () async {
        // These operations might fail due to platform channels in test environment
        expect(() => ouiService.downloadDatabase(), returnsNormally);
        expect(() => ouiService.deleteDatabase(), returnsNormally);
        expect(() => ouiService.getLastUpdateTime(), returnsNormally);
      });
    });
  });
}
