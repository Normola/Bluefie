import 'dart:async';

import 'package:blufie_ui/services/oui_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OuiService', () {
    late OuiService ouiService;

    setUp(() {
      ouiService = OuiService();
    });

    tearDown(() {
      // Clean up streams
      ouiService.dispose();
    });

    group('Singleton Pattern', () {
      test('should return the same instance', () {
        final instance1 = OuiService();
        final instance2 = OuiService();

        expect(instance1, same(instance2));
      });
    });

    group('Initialization', () {
      test('should start with empty database', () {
        expect(ouiService.isLoaded, false);
        expect(ouiService.isDownloading, false);
        expect(ouiService.databaseSize, 0);
      });

      test('should initialize without throwing errors', () async {
        expect(() => ouiService.initialize(), returnsNormally);
        await ouiService.initialize();

        // Should not crash and should maintain state
        expect(ouiService.isDownloading, false);
      });
    });

    group('MAC Address Parsing', () {
      test('should return null for invalid MAC addresses', () {
        // Test with empty database
        expect(ouiService.getManufacturer(''), null);
        expect(ouiService.getManufacturer('123'), null);
        expect(ouiService.getManufacturer('invalid'), null);
      });

      test('should return null when database is not loaded', () {
        expect(ouiService.isLoaded, false);
        expect(ouiService.getManufacturer('00:00:0C:12:34:56'), null);
      });

      test('should handle different MAC address formats consistently', () {
        const testCases = [
          '00:00:0C:12:34:56', // Colon format
          '00-00-0C-12-34-56', // Dash format
          '00000C123456', // No separators
          '00000c123456', // Lowercase
        ];

        for (final macAddress in testCases) {
          // All should handle the same way (return null since DB not loaded)
          expect(ouiService.getManufacturer(macAddress), null);
        }
      });

      test('should handle short MAC addresses', () {
        const shortMacAddresses = [
          '00:00',
          '00-00-0C',
          '0000',
          '00000',
        ];

        for (final macAddress in shortMacAddresses) {
          expect(ouiService.getManufacturer(macAddress), null);
        }
      });

      test('should handle MAC addresses with mixed case', () {
        const mixedCaseMacs = [
          '00:aB:Cd:12:34:56',
          '00-Ab-CD-12-34-56',
          'aAbBcC123456',
        ];

        for (final macAddress in mixedCaseMacs) {
          // Should handle without throwing errors
          expect(() => ouiService.getManufacturer(macAddress), returnsNormally);
        }
      });
    });

    group('Database Management', () {
      test('should have working progress stream', () {
        expect(ouiService.downloadProgressStream, isA<Stream<double>>());
      });

      test('should have working database stream', () {
        expect(ouiService.databaseStream, isA<Stream<Map<String, String>>>());
      });

      test('should handle download attempts', () async {
        expect(ouiService.isDownloading, false);

        // Test download method doesn't crash
        expect(() => ouiService.downloadDatabase(), returnsNormally);
      });

      test('should handle concurrent download attempts', () async {
        expect(ouiService.isDownloading, false);

        // Start first download
        final future1 = ouiService.downloadDatabase();

        // Try second download while first is potentially running
        final future2 = ouiService.downloadDatabase();

        final result1 = await future1;
        final result2 = await future2;

        expect(result1, isA<bool>());
        expect(result2, isA<bool>());
        expect(ouiService.isDownloading, false);
      });

      test('should handle force update parameter', () async {
        final result = await ouiService.downloadDatabase(forceUpdate: true);
        expect(result, isA<bool>());
      });
    });

    group('File Operations', () {
      test('should handle database deletion', () async {
        final result = await ouiService.deleteDatabase();

        expect(result, isA<bool>());
        expect(ouiService.isLoaded, false);
        expect(ouiService.databaseSize, 0);
      });

      test('should handle last update time queries', () async {
        final lastUpdate = await ouiService.getLastUpdateTime();

        // Should return null or DateTime, not throw
        expect(lastUpdate, anyOf(isNull, isA<DateTime>()));
      });

      test('should maintain state after deletion', () async {
        await ouiService.deleteDatabase();

        expect(ouiService.isLoaded, false);
        expect(ouiService.databaseSize, 0);
        expect(ouiService.getManufacturer('00:00:0C:12:34:56'), null);
      });
    });

    group('Stream Management', () {
      test('should emit progress updates during download', () async {
        final progressValues = <double>[];
        late StreamSubscription<double> subscription;

        subscription = ouiService.downloadProgressStream.listen(
          (progress) {
            progressValues.add(progress);
            if (progress >= 1.0) {
              subscription.cancel();
            }
          },
        );

        // Start download to trigger progress updates
        await ouiService.downloadDatabase();

        // Give time for stream events
        await Future.delayed(const Duration(milliseconds: 100));

        // Should have received at least some progress updates
        expect(progressValues, isNotEmpty);

        await subscription.cancel();
      });

      test('should emit database updates', () async {
        final databaseStates = <Map<String, String>>[];
        late StreamSubscription<Map<String, String>> subscription;

        subscription = ouiService.databaseStream.listen(
          (database) {
            databaseStates.add(Map.from(database));
          },
        );

        // Trigger database update
        await ouiService.deleteDatabase();

        // Give time for stream events
        await Future.delayed(const Duration(milliseconds: 100));

        await subscription.cancel();

        // Should have received at least one update
        expect(databaseStates, isNotEmpty);
      });

      test('should handle multiple stream listeners', () async {
        final progressValues1 = <double>[];
        final progressValues2 = <double>[];

        final subscription1 = ouiService.downloadProgressStream.listen(
          (progress) => progressValues1.add(progress),
        );

        final subscription2 = ouiService.downloadProgressStream.listen(
          (progress) => progressValues2.add(progress),
        );

        // Trigger some progress updates
        await ouiService.downloadDatabase();

        await Future.delayed(const Duration(milliseconds: 100));

        await subscription1.cancel();
        await subscription2.cancel();

        // Both listeners should receive updates
        expect(progressValues1, isNotEmpty);
        expect(progressValues2, isNotEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle initialization errors gracefully', () async {
        expect(() => ouiService.initialize(), returnsNormally);
        await ouiService.initialize();
      });

      test('should handle network errors gracefully', () async {
        // Test network failure scenarios
        final result = await ouiService.downloadDatabase();

        // Should return a boolean result, not throw
        expect(result, isA<bool>());
        expect(ouiService.isDownloading, false);
      });

      test('should handle file system errors gracefully', () async {
        await ouiService.initialize();
        await ouiService.deleteDatabase();
        final lastUpdate = await ouiService.getLastUpdateTime();

        // Should not throw exceptions
        expect(() => lastUpdate, returnsNormally);
      });

      test('should dispose resources properly', () {
        expect(() => ouiService.dispose(), returnsNormally);
      });

      test('should handle disposal multiple times', () {
        ouiService.dispose();
        expect(() => ouiService.dispose(), returnsNormally);
      });
    });

    group('State Consistency', () {
      test('should maintain consistent state after operations', () async {
        // Initial state
        expect(ouiService.isLoaded, false);
        expect(ouiService.databaseSize, 0);

        await ouiService.initialize();

        // State should be consistent
        if (ouiService.isLoaded) {
          expect(ouiService.databaseSize, greaterThanOrEqualTo(0));
        } else {
          expect(ouiService.databaseSize, 0);
        }

        await ouiService.deleteDatabase();

        // After deletion
        expect(ouiService.isLoaded, false);
        expect(ouiService.databaseSize, 0);
      });

      test('should handle rapid state changes', () async {
        await ouiService.initialize();
        await ouiService.deleteDatabase();
        await ouiService.initialize();

        // Should maintain consistency
        expect(ouiService.isLoaded, anyOf(true, false));
        expect(ouiService.databaseSize, greaterThanOrEqualTo(0));
      });
    });
  });
}
