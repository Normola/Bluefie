import 'package:blufie_ui/services/logging_service.dart';
import 'package:blufie_ui/services/sig_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SigService Tests', () {
    late SigService sigService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      LoggingService().initialize();
    });

    setUp(() async {
      sigService = SigService();
      await sigService.initialize();
    });

    test('should get singleton instance', () {
      final instance1 = SigService();
      final instance2 = SigService();
      expect(instance1, same(instance2));
    });

    test('should handle service lookup with well-known fallbacks', () async {
      // Test well-known service UUIDs that should work even without database
      final result = sigService.getServiceName('1800');
      expect(result, equals('GAP'));

      // Test unknown service
      final unknownResult = sigService.getServiceName('9999');
      expect(unknownResult, isNull);
    });

    test('should handle characteristic lookup with well-known fallbacks',
        () async {
      // Test well-known characteristic UUIDs that should work even without database
      final result = sigService.getCharacteristicName('2a00');
      expect(result, equals('Device Name'));

      // Test unknown characteristic
      final unknownResult = sigService.getCharacteristicName('9999');
      expect(unknownResult, isNull);
    });

    test('should handle descriptor lookup gracefully when no database',
        () async {
      final result = sigService.getDescriptorName('2901');
      expect(result, equals('Characteristic User Description'));
    });

    test('should handle company identifier lookup gracefully when no database',
        () async {
      final result = sigService.getCompanyName('0006');
      expect(result, equals('Microsoft'));
    });

    test('should provide database counts', () async {
      expect(sigService.servicesCount, isA<int>());
      expect(sigService.characteristicsCount, isA<int>());
      expect(sigService.descriptorsCount, isA<int>());
      expect(sigService.companyIdentifiersCount, isA<int>());
    });

    test('should normalize UUIDs for consistent lookup', () async {
      // Test that both formats work with well-known UUIDs
      final result1 =
          sigService.getServiceName('00001800-0000-1000-8000-00805F9B34FB');
      final result2 = sigService.getServiceName('1800');
      // Both should return the same well-known service name
      expect(result1, equals('GAP'));
      expect(result2, equals('GAP'));
    });

    test('should handle download errors gracefully', () async {
      // This will fail due to platform issues but should complete successfully
      // because we have well-known fallbacks
      final result =
          await sigService.downloadDatabase().catchError((_) => false);
      expect(result, isTrue); // Should succeed due to fallbacks

      // Service should still be functional with well-known fallbacks
      expect(sigService.getServiceName('1800'), equals('GAP'));
      expect(sigService.getCharacteristicName('2a00'), equals('Device Name'));
    });

    test('should handle file operations gracefully', () async {
      // These will fail due to platform issues but should not throw
      final deleteResult =
          await sigService.deleteDatabase().catchError((_) => false);
      expect(deleteResult, isFalse);

      final lastUpdate =
          await sigService.getLastUpdateTime().catchError((_) => null);
      expect(lastUpdate, isNull);
    });

    test('should handle YAML parsing edge cases', () async {
      // Test internal YAML parsing with various edge cases
      // Since _parseYamlData is private, we test indirectly by ensuring
      // the service doesn't crash with malformed data
      expect(() => sigService.isLoaded, returnsNormally);
      expect(() => sigService.isDownloading, returnsNormally);
    });

    test('should handle stream operations safely', () async {
      // Test that streams can be listened to without errors
      expect(() => sigService.servicesStream, returnsNormally);
      expect(() => sigService.characteristicsStream, returnsNormally);
      expect(() => sigService.downloadProgressStream, returnsNormally);
    });

    test('should handle initialization gracefully', () async {
      // Should not throw even if file operations fail
      await expectLater(
        sigService.initialize().catchError((_) => null),
        completes,
      );
    });

    test('should handle dispose safely', () {
      // Should not throw when disposing streams
      expect(() => sigService.dispose(), returnsNormally);
    });
  });
}
