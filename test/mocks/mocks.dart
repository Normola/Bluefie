import 'package:blufie_ui/services/battery_service.dart';
import 'package:blufie_ui/services/database_helper.dart';
import 'package:blufie_ui/services/location_service.dart';
import 'package:blufie_ui/services/settings_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Generate mocks by running: flutter packages pub run build_runner build
@GenerateMocks([
  SettingsService,
  BatteryService,
  LocationService,
  DatabaseHelper,
  SharedPreferences,
  BluetoothDevice,
  AdvertisementData,
])
void main() {
  // This file is just for mock generation
}
