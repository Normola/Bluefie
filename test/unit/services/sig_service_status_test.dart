import 'package:blufie_ui/services/sig_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SigService Status Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('should provide detailed status information', () async {
      final sigService = SigService();
      // Initialize the service
      await sigService.initialize();

      // Get status information
      final status = sigService.getDatabaseStatus();

      print('Current SIG Service Status:');
      print(status);

      expect(status, contains('SIG Database Status:'));
      expect(status, contains('Services:'));
      expect(status, contains('Characteristics:'));
    });

    test('should attempt refresh and report results', () async {
      final sigService = SigService();
      // Try refreshing (this will load from disk if files are available)
      final success = await sigService.refreshDatabases();

      // Get detailed status after refresh attempt
      final status = sigService.getDatabaseStatus();

      print('\n${'=' * 50}');
      print('REFRESH ATTEMPT RESULTS:');
      print('=' * 50);
      print('Refresh success: $success');
      print(status);
      print('=' * 50);

      // The refresh should succeed even if only well-known data is available
      expect(success, isTrue);
    });
  });
}
