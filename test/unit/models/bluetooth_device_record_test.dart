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

    group('Constructor Edge Cases', () {
      test('should handle minimum required parameters', () {
        final timestamp = DateTime.now();
        final record = BluetoothDeviceRecord(
          deviceId: 'min-test',
          deviceName: 'Minimum Test',
          macAddress: '00:00:00:00:00:00',
          rssi: 0,
          timestamp: timestamp,
          isConnectable: false,
        );

        expect(record.deviceId, equals('min-test'));
        expect(record.deviceName, equals('Minimum Test'));
        expect(record.macAddress, equals('00:00:00:00:00:00'));
        expect(record.rssi, equals(0));
        expect(record.timestamp, equals(timestamp));
        expect(record.isConnectable, isFalse);
        expect(record.id, isNull);
        expect(record.latitude, isNull);
        expect(record.longitude, isNull);
        expect(record.manufacturerData, isNull);
        expect(record.serviceUuids, isNull);
      });

      test('should handle empty string values', () {
        final timestamp = DateTime.now();
        final record = BluetoothDeviceRecord(
          deviceId: '',
          deviceName: '',
          macAddress: '',
          rssi: -127,
          timestamp: timestamp,
          isConnectable: true,
          manufacturerData: '',
          serviceUuids: '',
        );

        expect(record.deviceId, equals(''));
        expect(record.deviceName, equals(''));
        expect(record.macAddress, equals(''));
        expect(record.manufacturerData, equals(''));
        expect(record.serviceUuids, equals(''));
      });

      test('should handle extreme RSSI values', () {
        final timestamp = DateTime.now();
        final minRssiRecord = BluetoothDeviceRecord(
          deviceId: 'min-rssi',
          deviceName: 'Min RSSI',
          macAddress: '00:00:00:00:00:01',
          rssi: -127,
          timestamp: timestamp,
          isConnectable: true,
        );

        final maxRssiRecord = BluetoothDeviceRecord(
          deviceId: 'max-rssi',
          deviceName: 'Max RSSI',
          macAddress: '00:00:00:00:00:02',
          rssi: 127,
          timestamp: timestamp,
          isConnectable: true,
        );

        expect(minRssiRecord.rssi, equals(-127));
        expect(maxRssiRecord.rssi, equals(127));
      });

      test('should handle extreme coordinate values', () {
        final timestamp = DateTime.now();
        final record = BluetoothDeviceRecord(
          deviceId: 'extreme-coords',
          deviceName: 'Extreme Coords',
          macAddress: '00:00:00:00:00:03',
          rssi: -50,
          timestamp: timestamp,
          isConnectable: true,
          latitude: -90.0,
          longitude: -180.0,
        );

        expect(record.latitude, equals(-90.0));
        expect(record.longitude, equals(-180.0));
      });

      test('should handle very long string values', () {
        final timestamp = DateTime.now();
        final longString = 'x' * 1000;
        final record = BluetoothDeviceRecord(
          deviceId: longString,
          deviceName: longString,
          macAddress: longString,
          rssi: -50,
          timestamp: timestamp,
          isConnectable: true,
          manufacturerData: longString,
          serviceUuids: longString,
        );

        expect(record.deviceId.length, equals(1000));
        expect(record.deviceName.length, equals(1000));
        expect(record.macAddress.length, equals(1000));
        expect(record.manufacturerData!.length, equals(1000));
        expect(record.serviceUuids!.length, equals(1000));
      });

      test('should handle maximum integer ID', () {
        final timestamp = DateTime.now();
        const maxInt = 9223372036854775807; // max int64
        final record = BluetoothDeviceRecord(
          id: maxInt,
          deviceId: 'max-id-test',
          deviceName: 'Max ID Test',
          macAddress: 'FF:FF:FF:FF:FF:FF',
          rssi: 0,
          timestamp: timestamp,
          isConnectable: true,
        );

        expect(record.id, equals(maxInt));
      });
    });

    group('toMap() Edge Cases', () {
      test('should handle map conversion with all null optionals', () {
        final timestamp = DateTime.now();
        final record = BluetoothDeviceRecord(
          deviceId: 'null-optionals',
          deviceName: 'Null Optionals',
          macAddress: '00:11:22:33:44:55',
          rssi: -30,
          timestamp: timestamp,
          isConnectable: true,
        );

        final map = record.toMap();

        expect(map['id'], isNull);
        expect(map['latitude'], isNull);
        expect(map['longitude'], isNull);
        expect(map['manufacturerData'], isNull);
        expect(map['serviceUuids'], isNull);
        expect(map['timestamp'], equals(timestamp.millisecondsSinceEpoch));
        expect(map['isConnectable'], equals(1));
      });

      test('should preserve timestamp precision', () {
        final preciseTimestamp = DateTime.fromMillisecondsSinceEpoch(1725541800123);
        final record = BluetoothDeviceRecord(
          deviceId: 'precision-test',
          deviceName: 'Precision Test',
          macAddress: '00:00:00:00:00:04',
          rssi: -35,
          timestamp: preciseTimestamp,
          isConnectable: false,
        );

        final map = record.toMap();
        expect(map['timestamp'], equals(1725541800123));
      });

      test('should handle zero and negative coordinates', () {
        final timestamp = DateTime.now();
        final record = BluetoothDeviceRecord(
          deviceId: 'zero-coords',
          deviceName: 'Zero Coords',
          macAddress: '00:00:00:00:00:05',
          rssi: -40,
          timestamp: timestamp,
          isConnectable: true,
          latitude: 0.0,
          longitude: -0.0,
        );

        final map = record.toMap();
        expect(map['latitude'], equals(0.0));
        expect(map['longitude'], equals(-0.0));
      });
    });

    group('fromMap() Edge Cases', () {
      test('should handle map with missing optional fields', () {
        final timestamp = DateTime.now();
        final map = {
          'deviceId': 'missing-optionals',
          'deviceName': 'Missing Optionals',
          'macAddress': '66:77:88:99:AA:BB',
          'rssi': -50,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'isConnectable': 1,
        };

        final record = BluetoothDeviceRecord.fromMap(map);

        expect(record.id, isNull);
        expect(record.latitude, isNull);
        expect(record.longitude, isNull);
        expect(record.manufacturerData, isNull);
        expect(record.serviceUuids, isNull);
        expect(record.deviceId, equals('missing-optionals'));
        expect(record.isConnectable, isTrue);
      });

      test('should handle boolean conversion from various integer values', () {
        final timestamp = DateTime.now();
        final trueMap = {
          'deviceId': 'bool-true',
          'deviceName': 'Bool True',
          'macAddress': '00:11:22:33:44:55',
          'rssi': -40,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'isConnectable': 1,
        };

        final falseMap = {
          'deviceId': 'bool-false',
          'deviceName': 'Bool False',
          'macAddress': '00:11:22:33:44:56',
          'rssi': -40,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'isConnectable': 0,
        };

        final trueRecord = BluetoothDeviceRecord.fromMap(trueMap);
        final falseRecord = BluetoothDeviceRecord.fromMap(falseMap);

        expect(trueRecord.isConnectable, isTrue);
        expect(falseRecord.isConnectable, isFalse);
      });

      test('should handle epoch timestamp', () {
        final epochMap = {
          'deviceId': 'epoch-test',
          'deviceName': 'Epoch Test',
          'macAddress': '00:00:00:00:00:00',
          'rssi': 0,
          'timestamp': 0,
          'isConnectable': 1,
        };

        final record = BluetoothDeviceRecord.fromMap(epochMap);
        expect(record.timestamp, equals(DateTime.fromMillisecondsSinceEpoch(0)));
      });

      test('should handle large timestamp values', () {
        const largeTimestamp = 2147483647000; // Year 2038
        final futureMap = {
          'deviceId': 'future-test',
          'deviceName': 'Future Test',
          'macAddress': 'FF:FF:FF:FF:FF:FF',
          'rssi': 0,
          'timestamp': largeTimestamp,
          'isConnectable': 1,
        };

        final record = BluetoothDeviceRecord.fromMap(futureMap);
        expect(record.timestamp, equals(DateTime.fromMillisecondsSinceEpoch(largeTimestamp)));
      });

      test('should handle decimal coordinates', () {
        final timestamp = DateTime.now();
        final map = {
          'deviceId': 'decimal-coords',
          'deviceName': 'Decimal Coords',
          'macAddress': '12:34:56:78:90:AB',
          'rssi': -45,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'isConnectable': 1,
          'latitude': 37.7749295,
          'longitude': -122.4194155,
        };

        final record = BluetoothDeviceRecord.fromMap(map);
        expect(record.latitude, equals(37.7749295));
        expect(record.longitude, equals(-122.4194155));
      });
    });

    group('toString() Tests', () {
      test('should include all key information in string representation', () {
        final timestamp = DateTime.parse('2025-09-05 12:00:00');
        final record = BluetoothDeviceRecord(
          id: 99,
          deviceId: 'string-test',
          deviceName: 'String Test Device',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          rssi: -55,
          latitude: 51.5074,
          longitude: -0.1278,
          timestamp: timestamp,
          isConnectable: true,
        );

        final stringRepresentation = record.toString();

        expect(stringRepresentation, contains('BluetoothDeviceRecord'));
        expect(stringRepresentation, contains('id: 99'));
        expect(stringRepresentation, contains('deviceName: String Test Device'));
        expect(stringRepresentation, contains('macAddress: AA:BB:CC:DD:EE:FF'));
        expect(stringRepresentation, contains('rssi: -55'));
        expect(stringRepresentation, contains('lat: 51.5074'));
        expect(stringRepresentation, contains('lng: -0.1278'));
        expect(stringRepresentation, contains('timestamp: $timestamp'));
      });

      test('should handle null values in toString', () {
        final timestamp = DateTime.now();
        final record = BluetoothDeviceRecord(
          deviceId: 'null-values',
          deviceName: 'Null Values',
          macAddress: '00:00:00:00:00:00',
          rssi: -30,
          timestamp: timestamp,
          isConnectable: true,
        );

        final stringRepresentation = record.toString();

        expect(stringRepresentation, contains('id: null'));
        expect(stringRepresentation, contains('lat: null'));
        expect(stringRepresentation, contains('lng: null'));
      });

      test('should be consistent across multiple calls', () {
        final timestamp = DateTime.now();
        final record = BluetoothDeviceRecord(
          deviceId: 'consistency-test',
          deviceName: 'Consistency Test',
          macAddress: '11:22:33:44:55:66',
          rssi: -40,
          timestamp: timestamp,
          isConnectable: false,
        );

        final firstCall = record.toString();
        final secondCall = record.toString();

        expect(firstCall, equals(secondCall));
      });
    });

    group('Multiple Round-trip Conversions', () {
      test('should maintain data integrity through multiple conversions', () {
        final originalTimestamp = DateTime.parse('2025-09-05 10:30:45');
        var record = BluetoothDeviceRecord(
          id: 100,
          deviceId: 'multi-roundtrip',
          deviceName: 'Multi Roundtrip Test',
          macAddress: 'CC:DD:EE:FF:00:11',
          rssi: -65,
          latitude: 40.7128,
          longitude: -74.0060,
          timestamp: originalTimestamp,
          manufacturerData: 'Test Manufacturer',
          serviceUuids: 'service1,service2,service3',
          isConnectable: true,
        );

        // Perform multiple round-trip conversions
        for (int i = 0; i < 10; i++) {
          final map = record.toMap();
          record = BluetoothDeviceRecord.fromMap(map);
        }

        // Verify all data is preserved
        expect(record.id, equals(100));
        expect(record.deviceId, equals('multi-roundtrip'));
        expect(record.deviceName, equals('Multi Roundtrip Test'));
        expect(record.macAddress, equals('CC:DD:EE:FF:00:11'));
        expect(record.rssi, equals(-65));
        expect(record.latitude, equals(40.7128));
        expect(record.longitude, equals(-74.0060));
        expect(record.timestamp, equals(originalTimestamp));
        expect(record.manufacturerData, equals('Test Manufacturer'));
        expect(record.serviceUuids, equals('service1,service2,service3'));
        expect(record.isConnectable, isTrue);
      });

      test('should handle null values through multiple conversions', () {
        // Use a timestamp with millisecond precision to avoid precision loss
        final originalTimestamp =
            DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);
        var record = BluetoothDeviceRecord(
          deviceId: 'null-roundtrip',
          deviceName: 'Null Roundtrip Test',
          macAddress: '99:88:77:66:55:44',
          rssi: -75,
          timestamp: originalTimestamp,
          isConnectable: false,
        );

        // Perform multiple round-trip conversions
        for (int i = 0; i < 5; i++) {
          final map = record.toMap();
          record = BluetoothDeviceRecord.fromMap(map);
        }

        // Verify null values are preserved
        expect(record.id, isNull);
        expect(record.latitude, isNull);
        expect(record.longitude, isNull);
        expect(record.manufacturerData, isNull);
        expect(record.serviceUuids, isNull);
        expect(record.deviceId, equals('null-roundtrip'));
        expect(record.timestamp, equals(originalTimestamp));
        expect(record.isConnectable, isFalse);
      });
    });

    group('Type Safety', () {
      test('should maintain correct types for all fields', () {
        final timestamp = DateTime.now();
        final record = BluetoothDeviceRecord(
          id: 123,
          deviceId: 'type-test',
          deviceName: 'Type Test',
          macAddress: 'AB:CD:EF:12:34:56',
          rssi: -50,
          latitude: 25.7617,
          longitude: -80.1918,
          timestamp: timestamp,
          manufacturerData: 'Type Manufacturer',
          serviceUuids: 'type-service',
          isConnectable: true,
        );

        expect(record.id, isA<int?>());
        expect(record.deviceId, isA<String>());
        expect(record.deviceName, isA<String>());
        expect(record.macAddress, isA<String>());
        expect(record.rssi, isA<int>());
        expect(record.latitude, isA<double?>());
        expect(record.longitude, isA<double?>());
        expect(record.timestamp, isA<DateTime>());
        expect(record.manufacturerData, isA<String?>());
        expect(record.serviceUuids, isA<String?>());
        expect(record.isConnectable, isA<bool>());
      });

      test('should produce map with correct types', () {
        final timestamp = DateTime.now();
        final record = BluetoothDeviceRecord(
          id: 456,
          deviceId: 'map-type-test',
          deviceName: 'Map Type Test',
          macAddress: '12:34:56:78:90:AB',
          rssi: -60,
          timestamp: timestamp,
          isConnectable: false,
        );

        final map = record.toMap();

        expect(map['id'], isA<int?>());
        expect(map['deviceId'], isA<String>());
        expect(map['deviceName'], isA<String>());
        expect(map['macAddress'], isA<String>());
        expect(map['rssi'], isA<int>());
        expect(map['latitude'], isA<double?>());
        expect(map['longitude'], isA<double?>());
        expect(map['timestamp'], isA<int>());
        expect(map['manufacturerData'], isA<String?>());
        expect(map['serviceUuids'], isA<String?>());
        expect(map['isConnectable'], isA<int>());
      });

      test('should handle type coercion in fromMap', () {
        final timestamp = DateTime.now();
        final map = {
          'deviceId': 'coercion-test',
          'deviceName': 'Coercion Test',
          'macAddress': 'FE:DC:BA:98:76:54',
          'rssi': -70,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'isConnectable': 1,
        };

        final record = BluetoothDeviceRecord.fromMap(map);
        expect(record, isA<BluetoothDeviceRecord>());
        expect(record.timestamp, isA<DateTime>());
        expect(record.isConnectable, isA<bool>());
        expect(record.isConnectable, isTrue);
      });
    });

    group('Performance and Stress Tests', () {
      test('should handle creating many instances efficiently', () {
        final timestamp = DateTime.now();
        final records = <BluetoothDeviceRecord>[];

        for (int i = 0; i < 1000; i++) {
          final record = BluetoothDeviceRecord(
            id: i,
            deviceId: 'device-$i',
            deviceName: 'Device $i',
            macAddress: '${i.toRadixString(16).padLeft(2, '0')}:11:22:33:44:55',
            rssi: -30 - (i % 100),
            timestamp: timestamp.add(Duration(seconds: i)),
            isConnectable: i % 2 == 0,
          );
          records.add(record);
        }

        expect(records.length, equals(1000));
        expect(records.first.deviceId, equals('device-0'));
        expect(records.last.deviceId, equals('device-999'));
      });

      test('should handle batch map conversions efficiently', () {
        final timestamp = DateTime.now();
        final records = <BluetoothDeviceRecord>[];

        // Create 100 records
        for (int i = 0; i < 100; i++) {
          records.add(BluetoothDeviceRecord(
            id: i,
            deviceId: 'batch-$i',
            deviceName: 'Batch Device $i',
            macAddress:
                '${i.toRadixString(16).padLeft(2, '0')}:00:00:00:00:${i.toRadixString(16).padLeft(2, '0')}',
            rssi: -40 - i,
            timestamp: timestamp.add(Duration(minutes: i)),
            isConnectable: i % 3 == 0,
            latitude: i.toDouble(),
            longitude: -i.toDouble(),
          ));
        }

        // Convert all to maps and back
        final maps = records.map((r) => r.toMap()).toList();
        final recreatedRecords = maps.map((m) => BluetoothDeviceRecord.fromMap(m)).toList();

        expect(recreatedRecords.length, equals(100));
        for (int i = 0; i < 100; i++) {
          expect(recreatedRecords[i].id, equals(records[i].id));
          expect(recreatedRecords[i].deviceId, equals(records[i].deviceId));
          expect(recreatedRecords[i].rssi, equals(records[i].rssi));
        }
      });
    });
  });
}
