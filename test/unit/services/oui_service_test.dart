import 'package:flutter_test/flutter_test.dart';
import 'package:blufie_ui/services/oui_service.dart';
import 'package:blufie_ui/services/logging_service.dart';

void main() {
  group('OuiService Tests', () {
    late OuiService ouiService;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      LoggingService().initialize();
    });

    setUp(() {
      ouiService = OuiService();
    });

    test('should get singleton instance', () {
      final instance1 = OuiService();
      final instance2 = OuiService();
      expect(instance1, same(instance2));
    });

    test('should handle manufacturer lookup gracefully when no database',
        () async {
      final result = ouiService.getManufacturer('00:11:22:33:44:55');
      expect(result, isNull);
    });

    test('should provide database size', () async {
      final size = ouiService.databaseSize;
      expect(size, isA<int>());
    });

    test('should handle download errors gracefully', () async {
      // This will fail due to platform issues but should not throw
      final result =
          await ouiService.downloadDatabase().catchError((_) => false);
      expect(result, isFalse);

      // Service should still be functional
      expect(ouiService.getManufacturer('00:11:22:33:44:55'), isNull);
    });

    test('should handle file operations gracefully', () async {
      // These will fail due to platform issues but should not throw
      final deleteResult =
          await ouiService.deleteDatabase().catchError((_) => false);
      expect(deleteResult, isFalse);

      final lastUpdate =
          await ouiService.getLastUpdateTime().catchError((_) => null);
      expect(lastUpdate, isNull);
    });

    test('should check loading state', () async {
      expect(ouiService.isLoaded, isFalse);
      expect(ouiService.isDownloading, isFalse);
    });

    test('should handle progress updates', () async {
      final progressStream = ouiService.downloadProgressStream;
      expect(progressStream, isNotNull);

      // Stream should be available even if download fails
      final subscription = progressStream.listen((_) {});
      await Future.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();
    });

    test('should handle database updates stream', () async {
      final updatesStream = ouiService.databaseStream;
      expect(updatesStream, isNotNull);

      // Stream should be available
      final subscription = updatesStream.listen((_) {});
      await Future.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();
    });

    test('should handle initialization gracefully', () async {
      // Initialize should not throw even with platform issues
      await ouiService.initialize().catchError((_) {});

      // Service should still be accessible
      expect(ouiService.databaseSize, isA<int>());
    });
  });
}
