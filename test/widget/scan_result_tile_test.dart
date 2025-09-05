import 'package:blufie_ui/widgets/scan_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  group('ScanResultTile Widget', () {
    late ScanResult testScanResult;
    late MockBluetoothDevice mockDevice;
    late MockAdvertisementData mockAdvData;

    setUp(() {
      mockDevice = MockBluetoothDevice();
      mockAdvData = MockAdvertisementData();

      // Set up mock device properties
      when(mockDevice.platformName).thenReturn('Test Device');
      when(mockDevice.remoteId)
          .thenReturn(const DeviceIdentifier('test-device-001'));
      when(mockDevice.connectionState).thenAnswer(
          (_) => Stream.value(BluetoothConnectionState.disconnected));

      // Set up mock advertisement data
      when(mockAdvData.connectable).thenReturn(true);
      when(mockAdvData.advName).thenReturn('Test Device');
      when(mockAdvData.txPowerLevel).thenReturn(null);
      when(mockAdvData.appearance).thenReturn(null);
      when(mockAdvData.msd).thenReturn([]);
      when(mockAdvData.serviceUuids).thenReturn([]);
      when(mockAdvData.serviceData).thenReturn({});

      // Create the ScanResult with mocked dependencies
      testScanResult = ScanResult(
        device: mockDevice,
        advertisementData: mockAdvData,
        rssi: -45,
        timeStamp: DateTime.now(),
      );
    });

    testWidgets('should display device information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanResultTile(
              result: testScanResult,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify the device name is displayed
      expect(find.text('Test Device'), findsOneWidget);

      // Verify the device ID is displayed
      expect(find.text('test-device-001'), findsOneWidget);

      // Verify RSSI is displayed
      expect(find.text('-45'), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanResultTile(
              result: testScanResult,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // Tap on the connect button (since that's what triggers the onTap)
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify the tap callback was called
      expect(wasTapped, true);
    });

    testWidgets('should display expandable tile structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanResultTile(
              result: testScanResult,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify the ExpansionTile is displayed
      expect(find.byType(ExpansionTile), findsOneWidget);

      // Verify the connect button is displayed
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should handle non-connectable device',
        (WidgetTester tester) async {
      final mockNonConnectableDevice = MockBluetoothDevice();
      final mockNonConnectableAdvData = MockAdvertisementData();

      when(mockNonConnectableDevice.platformName)
          .thenReturn('Non-Connectable Device');
      when(mockNonConnectableDevice.remoteId)
          .thenReturn(const DeviceIdentifier('test-device-002'));
      when(mockNonConnectableDevice.connectionState).thenAnswer(
          (_) => Stream.value(BluetoothConnectionState.disconnected));

      when(mockNonConnectableAdvData.connectable).thenReturn(false);
      when(mockNonConnectableAdvData.advName).thenReturn('');
      when(mockNonConnectableAdvData.txPowerLevel).thenReturn(null);
      when(mockNonConnectableAdvData.appearance).thenReturn(null);
      when(mockNonConnectableAdvData.msd).thenReturn([]);
      when(mockNonConnectableAdvData.serviceUuids).thenReturn([]);
      when(mockNonConnectableAdvData.serviceData).thenReturn({});

      final nonConnectableScanResult = ScanResult(
        device: mockNonConnectableDevice,
        advertisementData: mockNonConnectableAdvData,
        rssi: -60,
        timeStamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanResultTile(
              result: nonConnectableScanResult,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify the device name is still displayed
      expect(find.text('Non-Connectable Device'), findsOneWidget);

      // Verify the device ID is displayed
      expect(find.text('test-device-002'), findsOneWidget);

      // Verify the connect button is disabled (null onPressed)
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should display signal strength with appropriate values',
        (WidgetTester tester) async {
      // Test with strong signal
      final mockStrongDevice = MockBluetoothDevice();
      final mockStrongAdvData = MockAdvertisementData();

      when(mockStrongDevice.platformName).thenReturn('Strong Signal');
      when(mockStrongDevice.remoteId)
          .thenReturn(const DeviceIdentifier('test-device-003'));
      when(mockStrongDevice.connectionState).thenAnswer(
          (_) => Stream.value(BluetoothConnectionState.disconnected));

      when(mockStrongAdvData.connectable).thenReturn(true);
      when(mockStrongAdvData.advName).thenReturn('');
      when(mockStrongAdvData.txPowerLevel).thenReturn(null);
      when(mockStrongAdvData.appearance).thenReturn(null);
      when(mockStrongAdvData.msd).thenReturn([]);
      when(mockStrongAdvData.serviceUuids).thenReturn([]);
      when(mockStrongAdvData.serviceData).thenReturn({});

      final strongSignalResult = ScanResult(
        device: mockStrongDevice,
        advertisementData: mockStrongAdvData,
        rssi: -30, // Strong signal
        timeStamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanResultTile(
              result: strongSignalResult,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify strong signal is displayed
      expect(find.text('-30'), findsOneWidget);

      // Test with weak signal
      final mockWeakDevice = MockBluetoothDevice();
      final mockWeakAdvData = MockAdvertisementData();

      when(mockWeakDevice.platformName).thenReturn('Weak Signal');
      when(mockWeakDevice.remoteId)
          .thenReturn(const DeviceIdentifier('test-device-004'));
      when(mockWeakDevice.connectionState).thenAnswer(
          (_) => Stream.value(BluetoothConnectionState.disconnected));

      when(mockWeakAdvData.connectable).thenReturn(true);
      when(mockWeakAdvData.advName).thenReturn('');
      when(mockWeakAdvData.txPowerLevel).thenReturn(null);
      when(mockWeakAdvData.appearance).thenReturn(null);
      when(mockWeakAdvData.msd).thenReturn([]);
      when(mockWeakAdvData.serviceUuids).thenReturn([]);
      when(mockWeakAdvData.serviceData).thenReturn({});

      final weakSignalResult = ScanResult(
        device: mockWeakDevice,
        advertisementData: mockWeakAdvData,
        rssi: -90, // Weak signal
        timeStamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanResultTile(
              result: weakSignalResult,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify weak signal is displayed
      expect(find.text('-90'), findsOneWidget);
    });

    testWidgets('should show connect button appropriately',
        (WidgetTester tester) async {
      final mockConnectableDevice = MockBluetoothDevice();
      final mockConnectableAdvData = MockAdvertisementData();

      when(mockConnectableDevice.platformName).thenReturn('Connectable Device');
      when(mockConnectableDevice.remoteId)
          .thenReturn(const DeviceIdentifier('test-device-005'));
      when(mockConnectableDevice.connectionState).thenAnswer(
          (_) => Stream.value(BluetoothConnectionState.disconnected));

      when(mockConnectableAdvData.connectable).thenReturn(true);
      when(mockConnectableAdvData.advName).thenReturn('');
      when(mockConnectableAdvData.txPowerLevel).thenReturn(null);
      when(mockConnectableAdvData.appearance).thenReturn(null);
      when(mockConnectableAdvData.msd).thenReturn([]);
      when(mockConnectableAdvData.serviceUuids).thenReturn([]);
      when(mockConnectableAdvData.serviceData).thenReturn({});

      final connectableScanResult = ScanResult(
        device: mockConnectableDevice,
        advertisementData: mockConnectableAdvData,
        rssi: -50,
        timeStamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanResultTile(
              result: connectableScanResult,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify the ScanResultTile is displayed
      expect(find.byType(ScanResultTile), findsOneWidget);

      // Verify the connect button is present and enabled
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      // Verify the button text is "CONNECT" for disconnected device
      expect(find.text('CONNECT'), findsOneWidget);
    });
  });
}
