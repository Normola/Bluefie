import 'package:blufie_ui/models/bluetooth_device_record.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper functions for creating test data

/// Creates a sample BluetoothDeviceRecord for testing
BluetoothDeviceRecord createTestDeviceRecord({
  int? id,
  String? deviceId,
  String? deviceName,
  String? macAddress,
  int? rssi,
  DateTime? timestamp,
  bool? isConnectable,
  double? latitude,
  double? longitude,
  String? manufacturerData,
  String? serviceUuids,
}) {
  return BluetoothDeviceRecord(
    id: id ?? 1,
    deviceId: deviceId ?? 'test-device-001',
    deviceName: deviceName ?? 'Test Device',
    macAddress: macAddress ?? '00:11:22:33:44:55',
    rssi: rssi ?? -50,
    timestamp: timestamp ?? DateTime.now(),
    isConnectable: isConnectable ?? true,
    latitude: latitude,
    longitude: longitude,
    manufacturerData: manufacturerData,
    serviceUuids: serviceUuids,
  );
}

/// Creates a list of test devices with varying signal strengths
List<BluetoothDeviceRecord> createTestDeviceList() {
  final now = DateTime.now();
  return [
    createTestDeviceRecord(
      id: 1,
      deviceId: 'device-001',
      deviceName: 'Strong Signal Device',
      macAddress: '00:11:22:33:44:55',
      rssi: -30,
      timestamp: now.subtract(const Duration(minutes: 1)),
      latitude: 51.5074,
      longitude: -0.1278,
    ),
    createTestDeviceRecord(
      id: 2,
      deviceId: 'device-002',
      deviceName: 'Medium Signal Device',
      macAddress: 'AA:BB:CC:DD:EE:FF',
      rssi: -60,
      timestamp: now.subtract(const Duration(minutes: 2)),
      isConnectable: false,
    ),
    createTestDeviceRecord(
      id: 3,
      deviceId: 'device-003',
      deviceName: 'Weak Signal Device',
      macAddress: '11:22:33:44:55:66',
      rssi: -90,
      timestamp: now.subtract(const Duration(minutes: 3)),
      latitude: 48.8566,
      longitude: 2.3522,
      manufacturerData: 'Apple Inc.',
      serviceUuids: '180F,1805',
    ),
  ];
}

/// Test helper for asserting device record properties
void expectDeviceRecord(
  BluetoothDeviceRecord actual,
  BluetoothDeviceRecord expected,
) {
  expect(actual.id, expected.id);
  expect(actual.deviceId, expected.deviceId);
  expect(actual.deviceName, expected.deviceName);
  expect(actual.macAddress, expected.macAddress);
  expect(actual.rssi, expected.rssi);
  expect(actual.timestamp, expected.timestamp);
  expect(actual.isConnectable, expected.isConnectable);
  expect(actual.latitude, expected.latitude);
  expect(actual.longitude, expected.longitude);
  expect(actual.manufacturerData, expected.manufacturerData);
  expect(actual.serviceUuids, expected.serviceUuids);
}

/// Helper for creating test GPS coordinates
class TestCoordinates {
  static const london = TestLocation(51.5074, -0.1278, 'London');
  static const paris = TestLocation(48.8566, 2.3522, 'Paris');
  static const newYork = TestLocation(40.7128, -74.0060, 'New York');
  static const tokyo = TestLocation(35.6762, 139.6503, 'Tokyo');
}

class TestLocation {
  final double latitude;
  final double longitude;
  final String name;

  const TestLocation(this.latitude, this.longitude, this.name);
}

/// Helper for creating mock time ranges
class TestTimeRanges {
  static DateTime get now => DateTime.now();
  static DateTime get oneMinuteAgo => now.subtract(const Duration(minutes: 1));
  static DateTime get oneHourAgo => now.subtract(const Duration(hours: 1));
  static DateTime get oneDayAgo => now.subtract(const Duration(days: 1));
  static DateTime get oneWeekAgo => now.subtract(const Duration(days: 7));
}
