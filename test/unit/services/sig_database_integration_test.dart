import 'dart:io';

import 'package:blufie_ui/services/sig_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SIG Database Integration Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('should show where to place database files', () async {
      final sigService = SigService();

      try {
        final databasePath = await sigService.getDatabasePath();
        print('');
        print('🗂️  Database Path Information');
        print('============================');
        print('Target directory: $databasePath');
        print('');
        print('To use converted SIG data:');
        print(
            '1. Copy the files from converted_sig_data/ to the target directory');
        print('2. Call sigService.refreshDatabases() to load them');
        print('');

        // Check if the directory exists
        final dir = Directory(databasePath);
        final exists = await dir.exists();
        print('Directory exists: $exists');

        if (!exists) {
          print('Creating directory...');
          await dir.create(recursive: true);
          print('Directory created successfully');
        }

        // List current files in the directory
        if (await dir.exists()) {
          final files = await dir.list().toList();
          print('');
          print('Current files in directory:');
          if (files.isEmpty) {
            print('  (no files)');
          } else {
            for (final file in files) {
              print('  ${file.path.split(Platform.pathSeparator).last}');
            }
          }
        }

        expect(databasePath, isNotNull);
        expect(databasePath, isNotEmpty);
      } catch (e) {
        print('Error getting database path: $e');
        // This is expected in test environment due to path_provider limitations
        expect(e.toString(), contains('MissingPluginException'));
      }
    });

    test('should test with mock files if available', () async {
      final sigService = SigService();

      // Initialize with well-known data first
      await sigService.initialize();

      print('');
      print('📊 SIG Service Status Before Extended Data');
      print('==========================================');
      final initialStatus = sigService.getDatabaseStatus();
      print(initialStatus);

      // Try to refresh (will load extended data if available)
      try {
        final success = await sigService.refreshDatabases();
        print('');
        print('🔄 Refresh Result: $success');

        print('');
        print('📊 SIG Service Status After Refresh Attempt');
        print('===========================================');
        final finalStatus = sigService.getDatabaseStatus();
        print(finalStatus);
      } catch (e) {
        print('Error during refresh (expected in test environment): $e');
      }

      // Test some lookups
      print('');
      print('🔍 UUID Lookup Tests');
      print('====================');

      // Test well-known services
      final genericAccess = sigService.getServiceName('1800');
      final batteryService = sigService.getServiceName('180f');
      print('Service 0x1800: $genericAccess');
      print('Service 0x180F: $batteryService');

      // Test well-known characteristics
      final deviceName = sigService.getCharacteristicName('2a00');
      final batteryLevel = sigService.getCharacteristicName('2a19');
      print('Characteristic 0x2A00: $deviceName');
      print('Characteristic 0x2A19: $batteryLevel');

      expect(genericAccess, isNotNull);
      expect(batteryService, isNotNull);
      expect(deviceName, isNotNull);
      expect(batteryLevel, isNotNull);
    });
  });
}
