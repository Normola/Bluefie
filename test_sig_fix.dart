import 'package:blufie_ui/services/sig_service.dart';

void main() {
  print('Testing SIG service fallback...');

  final sigService = SigService();

  // Test without initialization (should use well-known services)
  final genericAccessName = sigService.getServiceName('1800');
  print('Service 1800: $genericAccessName');

  final deviceInfoName = sigService.getServiceName('180a');
  print('Service 180a: $deviceInfoName');

  final batteryServiceName = sigService.getServiceName('180f');
  print('Service 180f: $batteryServiceName');

  // Test with 0x prefix
  final genericAccessWithPrefix = sigService.getServiceName('0x1800');
  print('Service 0x1800: $genericAccessWithPrefix');

  // Test some characteristics
  final deviceNameChar = sigService.getCharacteristicName('2a00');
  print('Characteristic 2a00: $deviceNameChar');

  final batteryLevelChar = sigService.getCharacteristicName('2a19');
  print('Characteristic 2a19: $batteryLevelChar');
}
