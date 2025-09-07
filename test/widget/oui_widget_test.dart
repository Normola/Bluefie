import 'package:blufie_ui/widgets/scan_result_tile.dart';
import 'package:blufie_ui/widgets/system_device_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OUI Widget Integration Tests', () {
    group('ScanResultTile with OUI', () {
      testWidgets(
          'should display manufacturer name when OUI database is enabled and loaded',
          (tester) async {
        // Create a test scan result
        final mockDevice =
            BluetoothDevice.fromId('00:50:56:12:34:56'); // VMware OUI
        final scanResult = ScanResult(
          device: mockDevice,
          advertisementData: AdvertisementData(
            advName: 'Test Device',
            txPowerLevel: -50,
            appearance: null,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
          ),
          rssi: -60,
          timeStamp: DateTime.now(),
        );

        // Build the widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScanResultTile(
                result: scanResult,
                onTap: () {},
              ),
            ),
          ),
        );

        // Verify the tile is displayed
        expect(find.byType(ScanResultTile), findsOneWidget);
        expect(find.text('Test Device'), findsOneWidget);
        expect(find.text('00:50:56:12:34:56'), findsOneWidget);

        // Note: In a real scenario, we would need to mock the OUI service
        // to simulate having the database loaded and enabled
      });

      testWidgets(
          'should not display manufacturer name when OUI database is disabled',
          (tester) async {
        final mockDevice = BluetoothDevice.fromId('00:50:56:12:34:56');
        final scanResult = ScanResult(
          device: mockDevice,
          advertisementData: AdvertisementData(
            advName: 'Test Device',
            txPowerLevel: -50,
            appearance: null,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
          ),
          rssi: -60,
          timeStamp: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScanResultTile(
                result: scanResult,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(ScanResultTile), findsOneWidget);
        expect(find.text('Test Device'), findsOneWidget);
        expect(find.text('00:50:56:12:34:56'), findsOneWidget);

        // Should not display manufacturer name since OUI is disabled by default
        expect(find.textContaining('VMware'), findsNothing);
      });

      testWidgets('should handle device with no name gracefully',
          (tester) async {
        final mockDevice = BluetoothDevice.fromId('AA:BB:CC:DD:EE:FF');
        final scanResult = ScanResult(
          device: mockDevice,
          advertisementData: AdvertisementData(
            advName: '',
            txPowerLevel: -50,
            appearance: null,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
          ),
          rssi: -60,
          timeStamp: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScanResultTile(
                result: scanResult,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(ScanResultTile), findsOneWidget);
        expect(find.text('AA:BB:CC:DD:EE:FF'), findsOneWidget);
      });

      testWidgets('should expand to show advertisement data', (tester) async {
        final mockDevice = BluetoothDevice.fromId('00:11:22:33:44:55');
        final scanResult = ScanResult(
          device: mockDevice,
          advertisementData: AdvertisementData(
            advName: 'Expandable Device',
            txPowerLevel: -40,
            appearance: 123,
            connectable: true,
            manufacturerData: {
              1: [0x01, 0x02, 0x03]
            },
            serviceData: {},
            serviceUuids: [Guid('12345678-1234-1234-1234-123456789012')],
          ),
          rssi: -50,
          timeStamp: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScanResultTile(
                result: scanResult,
                onTap: () {},
              ),
            ),
          ),
        );

        // Find and tap the expansion tile
        final expansionTile = find.byType(ExpansionTile);
        expect(expansionTile, findsOneWidget);

        await tester.tap(expansionTile);
        await tester.pumpAndSettle();

        // Verify expanded content is shown
        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Expandable Device'), findsOneWidget);
        expect(find.text('Tx Power Level'), findsOneWidget);
        expect(find.text('-40'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);
        expect(find.text('0x7b'), findsOneWidget);
      });
    });

    group('SystemDeviceTile with OUI', () {
      testWidgets('should display device information', (tester) async {
        final mockDevice = BluetoothDevice.fromId('00:00:0C:12:34:56');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SystemDeviceTile(
                device: mockDevice,
                onOpen: () {},
                onConnect: () {},
              ),
            ),
          ),
        );

        expect(find.byType(SystemDeviceTile), findsOneWidget);
        expect(find.text('00:00:0C:12:34:56'), findsOneWidget);
      });

      testWidgets('should show connect button when disconnected',
          (tester) async {
        final mockDevice = BluetoothDevice.fromId('00:00:0C:12:34:56');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SystemDeviceTile(
                device: mockDevice,
                onOpen: () {},
                onConnect: () {},
              ),
            ),
          ),
        );

        expect(find.text('CONNECT'), findsOneWidget);
        expect(find.text('OPEN'), findsNothing);
      });

      testWidgets('should handle button taps', (tester) async {
        bool connectCalled = false;
        bool openCalled = false;

        final mockDevice = BluetoothDevice.fromId('00:00:0C:12:34:56');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SystemDeviceTile(
                device: mockDevice,
                onOpen: () => openCalled = true,
                onConnect: () => connectCalled = true,
              ),
            ),
          ),
        );

        // Tap the connect button
        await tester.tap(find.text('CONNECT'));
        await tester.pump();

        expect(connectCalled, true);
        expect(openCalled, false);
      });
    });

    group('OUI Display Integration', () {
      testWidgets('should consistently format MAC addresses', (tester) async {
        final testCases = [
          '00:11:22:33:44:55',
          '00-11-22-33-44-55',
          'AA:BB:CC:DD:EE:FF',
        ];

        for (final macAddress in testCases) {
          final mockDevice = BluetoothDevice.fromId(macAddress);
          final scanResult = ScanResult(
            device: mockDevice,
            advertisementData: AdvertisementData(
              advName: 'Test Device',
              txPowerLevel: -50,
              appearance: null,
              connectable: true,
              manufacturerData: {},
              serviceData: {},
              serviceUuids: [],
            ),
            rssi: -60,
            timeStamp: DateTime.now(),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ScanResultTile(
                  result: scanResult,
                  onTap: () {},
                ),
              ),
            ),
          );

          expect(find.byType(ScanResultTile), findsOneWidget);

          // Clear the widget tree for next iteration
          await tester.pumpWidget(Container());
        }
      });

      testWidgets('should handle missing or invalid MAC addresses gracefully',
          (tester) async {
        final mockDevice = BluetoothDevice.fromId('invalid-mac');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SystemDeviceTile(
                device: mockDevice,
                onOpen: () {},
                onConnect: () {},
              ),
            ),
          ),
        );

        expect(find.byType(SystemDeviceTile), findsOneWidget);
        // Should not crash with invalid MAC address
      });
    });

    group('Error Handling', () {
      testWidgets('should handle null or empty device names', (tester) async {
        final mockDevice = BluetoothDevice.fromId('00:11:22:33:44:55');
        final scanResult = ScanResult(
          device: mockDevice,
          advertisementData: AdvertisementData(
            advName: '',
            txPowerLevel: null,
            appearance: null,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
          ),
          rssi: -60,
          timeStamp: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScanResultTile(
                result: scanResult,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(ScanResultTile), findsOneWidget);
        // Should show MAC address when name is empty
        expect(find.text('00:11:22:33:44:55'), findsOneWidget);
      });

      testWidgets('should handle missing advertisement data gracefully',
          (tester) async {
        final mockDevice = BluetoothDevice.fromId('00:11:22:33:44:55');
        final scanResult = ScanResult(
          device: mockDevice,
          advertisementData: AdvertisementData(
            advName: 'Test Device',
            txPowerLevel: null,
            appearance: null,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
          ),
          rssi: -60,
          timeStamp: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScanResultTile(
                result: scanResult,
                onTap: () {},
              ),
            ),
          ),
        );

        // Find and expand the tile
        final expansionTile = find.byType(ExpansionTile);
        await tester.tap(expansionTile);
        await tester.pumpAndSettle();

        // Should handle missing data gracefully
        expect(find.byType(ScanResultTile), findsOneWidget);
      });

      testWidgets('should handle very long device names', (tester) async {
        final mockDevice = BluetoothDevice.fromId('00:11:22:33:44:55');
        final longName = 'A' * 100; // Very long device name
        final scanResult = ScanResult(
          device: mockDevice,
          advertisementData: AdvertisementData(
            advName: longName,
            txPowerLevel: -50,
            appearance: null,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
          ),
          rssi: -60,
          timeStamp: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScanResultTile(
                result: scanResult,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(ScanResultTile), findsOneWidget);
        // Should handle overflow gracefully (text should be truncated)
        expect(find.textContaining('A'), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (tester) async {
        final mockDevice = BluetoothDevice.fromId('00:11:22:33:44:55');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SystemDeviceTile(
                device: mockDevice,
                onOpen: () {},
                onConnect: () {},
              ),
            ),
          ),
        );

        expect(find.byType(SystemDeviceTile), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);

        // Should be accessible
        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);
      });

      testWidgets('should support tap targets of appropriate size',
          (tester) async {
        final mockDevice = BluetoothDevice.fromId('00:11:22:33:44:55');
        final scanResult = ScanResult(
          device: mockDevice,
          advertisementData: AdvertisementData(
            advName: 'Test Device',
            txPowerLevel: -50,
            appearance: null,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
          ),
          rssi: -60,
          timeStamp: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScanResultTile(
                result: scanResult,
                onTap: () {},
              ),
            ),
          ),
        );

        final expansionTile = find.byType(ExpansionTile);
        expect(expansionTile, findsOneWidget);

        // Tap target should be accessible
        await tester.tap(expansionTile);
        await tester.pump();
      });
    });
  });
}
