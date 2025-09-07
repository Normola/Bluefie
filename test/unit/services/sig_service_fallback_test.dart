import 'package:blufie_ui/services/sig_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SIG Service Well-Known Fallback Tests', () {
    late SigService sigService;

    setUp(() {
      sigService = SigService();
    });

    test(
        'should return service name for 1800 (Generic Access) without database',
        () {
      // Before initialization, should still return well-known service names
      final serviceName = sigService.getServiceName('1800');
      expect(serviceName, equals('Generic Access'));
    });

    test(
        'should return service name for 0x1800 (Generic Access) with 0x prefix',
        () {
      final serviceName = sigService.getServiceName('0x1800');
      expect(serviceName, equals('Generic Access'));
    });

    test('should return service name for 180a (Device Information)', () {
      final serviceName = sigService.getServiceName('180a');
      expect(serviceName, equals('Device Information'));
    });

    test('should return service name for 180f (Battery Service)', () {
      final serviceName = sigService.getServiceName('180f');
      expect(serviceName, equals('Battery Service'));
    });

    test('should return characteristic name for 2a00 (Device Name)', () {
      final charName = sigService.getCharacteristicName('2a00');
      expect(charName, equals('Device Name'));
    });

    test('should return characteristic name for 2a19 (Battery Level)', () {
      final charName = sigService.getCharacteristicName('2a19');
      expect(charName, equals('Battery Level'));
    });

    test('should return null for unknown service UUID', () {
      final serviceName = sigService.getServiceName('ffff');
      expect(serviceName, isNull);
    });

    test('should return null for unknown characteristic UUID', () {
      final charName = sigService.getCharacteristicName('ffff');
      expect(charName, isNull);
    });

    test('should handle UUID normalization correctly', () {
      // Test various UUID formats
      expect(sigService.getServiceName('1800'), equals('Generic Access'));
      expect(sigService.getServiceName('0x1800'), equals('Generic Access'));
      expect(sigService.getServiceName('0X1800'), equals('Generic Access'));
      expect(sigService.getServiceName('1800'.toUpperCase()),
          equals('Generic Access'));
    });
  });
}
