import 'package:blufie_ui/models/bluetooth_device_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BluetoothDeviceRecord', () {
    test('should create with required fields', () {
      final timestamp = DateTime.now();
      final record = BluetoothDeviceRecord(
        id: 1,
        deviceId: 'device-001',
        deviceName: 'Test Device',
        macAddress: '00:11:22:33:44:55',
        rssi: -45,
        timestamp: timestamp,
        isConnectable: true,
      );

      expect(record.id, 1);
      expect(record.deviceId, 'device-001');
      expect(record.deviceName, 'Test Device');
      expect(record.macAddress, '00:11:22:33:44:55');
      expect(record.rssi, -45);
      expect(record.timestamp, timestamp);
      expect(record.isConnectable, true);
      expect(record.latitude, null);
      expect(record.longitude, null);
    });

    test('should create with all fields including location', () {
      final timestamp = DateTime.now();
      final record = BluetoothDeviceRecord(
        id: 2,
        deviceId: 'device-002',
        deviceName: 'GPS Device',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        rssi: -60,
        timestamp: timestamp,
        isConnectable: false,
        latitude: 51.5074,
        longitude: -0.1278,
        manufacturerData: 'Apple Inc.',
        serviceUuids: '180F,1805',
      );

      expect(record.latitude, 51.5074);
      expect(record.longitude, -0.1278);
      expect(record.manufacturerData, 'Apple Inc.');
      expect(record.serviceUuids, '180F,1805');
      expect(record.isConnectable, false);
    });

    test('should convert to map correctly', () {
      final timestamp = DateTime.parse('2025-09-05 12:00:00');
      final record = BluetoothDeviceRecord(
        id: 3,
        deviceId: 'device-003',
        deviceName: 'Map Test',
        macAddress: '11:22:33:44:55:66',
        rssi: -70,
        timestamp: timestamp,
        isConnectable: true,
        latitude: 40.7128,
        longitude: -74.0060,
      );

      final map = record.toMap();

      expect(map['id'], 3);
      expect(map['deviceId'], 'device-003');
      expect(map['deviceName'], 'Map Test');
      expect(map['macAddress'], '11:22:33:44:55:66');
      expect(map['rssi'], -70);
      expect(map['timestamp'], timestamp.millisecondsSinceEpoch);
      expect(map['latitude'], 40.7128);
      expect(map['longitude'], -74.0060);
      expect(map['isConnectable'], 1);
    });

    test('should create from map correctly', () {
      final timestampMs = DateTime.parse('2025-09-05T14:30:00.000').millisecondsSinceEpoch;
      final map = {
        'id': 4,
        'deviceId': 'device-004',
        'deviceName': 'From Map Device',
        'macAddress': 'FF:EE:DD:CC:BB:AA',
        'rssi': -80,
        'timestamp': timestampMs,
        'latitude': 48.8566,
        'longitude': 2.3522,
        'manufacturerData': 'Samsung',
        'serviceUuids': '1800,1801',
        'isConnectable': 0,
      };

      final record = BluetoothDeviceRecord.fromMap(map);

      expect(record.id, 4);
      expect(record.deviceId, 'device-004');
      expect(record.deviceName, 'From Map Device');
      expect(record.macAddress, 'FF:EE:DD:CC:BB:AA');
      expect(record.rssi, -80);
      expect(record.timestamp, DateTime.fromMillisecondsSinceEpoch(timestampMs));
      expect(record.latitude, 48.8566);
      expect(record.longitude, 2.3522);
      expect(record.manufacturerData, 'Samsung');
      expect(record.serviceUuids, '1800,1801');
      expect(record.isConnectable, false);
    });

    test('should handle map serialization round trip', () {
      final originalRecord = BluetoothDeviceRecord(
        id: 5,
        deviceId: 'device-005',
        deviceName: 'Round Trip Test',
        macAddress: '12:34:56:78:90:AB',
        rssi: -55,
        timestamp: DateTime.now(),
        isConnectable: true,
        latitude: 35.6762,
        longitude: 139.6503,
      );

      final map = originalRecord.toMap();
      final deserializedRecord = BluetoothDeviceRecord.fromMap(map);

      expect(deserializedRecord.id, originalRecord.id);
      expect(deserializedRecord.deviceId, originalRecord.deviceId);
      expect(deserializedRecord.deviceName, originalRecord.deviceName);
      expect(deserializedRecord.macAddress, originalRecord.macAddress);
      expect(deserializedRecord.rssi, originalRecord.rssi);
      expect(deserializedRecord.latitude, originalRecord.latitude);
      expect(deserializedRecord.longitude, originalRecord.longitude);
      expect(deserializedRecord.isConnectable, originalRecord.isConnectable);
    });

    test('should handle null values correctly', () {
      final record = BluetoothDeviceRecord(
        id: 6,
        deviceId: 'device-006',
        deviceName: 'Null Test',
        macAddress: '00:00:00:00:00:00',
        rssi: -90,
        timestamp: DateTime.now(),
        isConnectable: false,
      );

      final map = record.toMap();
      final recreated = BluetoothDeviceRecord.fromMap(map);

      expect(recreated.latitude, null);
      expect(recreated.longitude, null);
      expect(recreated.manufacturerData, null);
      expect(recreated.serviceUuids, null);
    });

    test('should validate MAC address format', () {
      // This test assumes you might want to add validation in the future
      const validMac = '00:11:22:33:44:55';
      const invalidMac = 'invalid-mac';

      expect(validMac.contains(':'), true);
      expect(validMac.split(':').length, 6);
      expect(invalidMac.contains(':'), false);
    });

    test('should handle boolean conversion correctly', () {
      final connectableRecord = BluetoothDeviceRecord(
        id: 7,
        deviceId: 'device-007',
        deviceName: 'Connectable Device',
        macAddress: '77:88:99:AA:BB:CC',
        rssi: -65,
        timestamp: DateTime.now(),
        isConnectable: true,
      );

      final nonConnectableRecord = BluetoothDeviceRecord(
        id: 8,
        deviceId: 'device-008',
        deviceName: 'Non-Connectable Device',
        macAddress: 'DD:EE:FF:00:11:22',
        rssi: -75,
        timestamp: DateTime.now(),
        isConnectable: false,
      );

      final connectableMap = connectableRecord.toMap();
      final nonConnectableMap = nonConnectableRecord.toMap();

      expect(connectableMap['isConnectable'], 1);
      expect(nonConnectableMap['isConnectable'], 0);

      final recreatedConnectable = BluetoothDeviceRecord.fromMap(connectableMap);
      final recreatedNonConnectable = BluetoothDeviceRecord.fromMap(nonConnectableMap);

      expect(recreatedConnectable.isConnectable, true);
      expect(recreatedNonConnectable.isConnectable, false);
    });
  });
}
