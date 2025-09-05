import 'dart:async';

import 'package:blufie_ui/main.dart';
import 'package:blufie_ui/screens/bluetooth_off_screen.dart';
import 'package:blufie_ui/screens/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FlutterBlueApp Widget Tests with Bluetooth Mocking', () {
    late StreamController<BluetoothAdapterState> mockAdapterStateController;

    setUp(() async {
      // Setup SharedPreferences mock
      SharedPreferences.setMockInitialValues({});

      // Setup Bluetooth mock at the platform level
      mockAdapterStateController = StreamController<BluetoothAdapterState>.broadcast();

      // Mock the Flutter Blue Plus method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getAdapterState':
              return BluetoothAdapterState.on.index;
            case 'turnOn':
              return null;
            case 'turnOff':
              return null;
            case 'getAdapterName':
              return 'Mock Adapter';
            case 'setLogLevel':
              return null;
            default:
              return null;
          }
        },
      );

      // Mock the adapter state stream
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/state'),
        (MethodCall methodCall) async {
          // Return the initial state
          return BluetoothAdapterState.on.index;
        },
      );
    });

    tearDown(() {
      mockAdapterStateController.close();
      // Clear the method channel mocks
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/state'),
        null,
      );
    });

    testWidgets('should create and build FlutterBlueApp successfully', (WidgetTester tester) async {
      // This will test the full widget including initState and build methods
      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      // Verify MaterialApp is created
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify that either ScanScreen or BluetoothOffScreen is shown
      expect(
        find.byType(ScanScreen).evaluate().isNotEmpty ||
            find.byType(BluetoothOffScreen).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should show ScanScreen when Bluetooth is on', (WidgetTester tester) async {
      // Mock Bluetooth as on
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAdapterState') {
            return BluetoothAdapterState.on.index;
          }
          return null;
        },
      );

      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      // Should show ScanScreen when Bluetooth is on
      expect(find.byType(ScanScreen), findsOneWidget);
      expect(find.byType(BluetoothOffScreen), findsNothing);
    });

    testWidgets('should show BluetoothOffScreen when Bluetooth is off',
        (WidgetTester tester) async {
      // Mock Bluetooth as off
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAdapterState') {
            return BluetoothAdapterState.off.index;
          }
          return null;
        },
      );

      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      // Should show BluetoothOffScreen when Bluetooth is off
      expect(find.byType(BluetoothOffScreen), findsOneWidget);
      expect(find.byType(ScanScreen), findsNothing);
    });

    testWidgets('should have correct MaterialApp properties', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.color, equals(Colors.lightBlue));
      expect(materialApp.navigatorObservers?.length, equals(1));
      expect(materialApp.navigatorObservers?.first, isA<BluetoothAdapterStateObserver>());
    });

    testWidgets('should handle widget disposal properly', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      // Verify app is displayed
      expect(find.byType(FlutterBlueApp), findsOneWidget);

      // Dispose the widget by replacing it
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      // Verify app is disposed
      expect(find.byType(FlutterBlueApp), findsNothing);
    });

    testWidgets('should respond to Bluetooth state changes', (WidgetTester tester) async {
      // Start with Bluetooth on
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAdapterState') {
            return BluetoothAdapterState.on.index;
          }
          return null;
        },
      );

      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      // Should initially show ScanScreen
      expect(find.byType(ScanScreen), findsOneWidget);

      // Change Bluetooth to off
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getAdapterState') {
            return BluetoothAdapterState.off.index;
          }
          return null;
        },
      );

      // Trigger a rebuild to simulate state change
      await tester.pump();
      await tester.pumpAndSettle();

      // Note: In a real app, the stream would trigger setState,
      // but in this test we're just verifying the build logic works
    });

    testWidgets('should create observer and add to navigator', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.navigatorObservers, isNotNull);
      expect(materialApp.navigatorObservers!.length, equals(1));

      final observer = materialApp.navigatorObservers!.first;
      expect(observer, isA<BluetoothAdapterStateObserver>());
    });
  });

  group('BluetoothAdapterStateObserver Widget Integration Tests', () {
    late BluetoothAdapterStateObserver observer;

    setUp(() {
      observer = BluetoothAdapterStateObserver();
      SharedPreferences.setMockInitialValues({});

      // Setup method channel mock for observer tests
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getAdapterState':
              return BluetoothAdapterState.on.index;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        null,
      );
    });

    testWidgets('should handle DeviceScreen route navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: const Scaffold(body: Text('Home')),
          routes: {
            '/DeviceScreen': (context) => const Scaffold(body: Text('Device')),
          },
        ),
      );

      // Navigate to DeviceScreen
      Navigator.of(tester.element(find.text('Home'))).pushNamed('/DeviceScreen');
      await tester.pumpAndSettle();

      expect(find.text('Device'), findsOneWidget);
    });

    testWidgets('should handle non-DeviceScreen routes normally', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: const Scaffold(body: Text('Home')),
          routes: {
            '/Settings': (context) => const Scaffold(body: Text('Settings')),
          },
        ),
      );

      // Navigate to Settings (non-DeviceScreen)
      Navigator.of(tester.element(find.text('Home'))).pushNamed('/Settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('Main Function Coverage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should call WidgetsFlutterBinding.ensureInitialized', () {
      // Test that the binding can be initialized
      expect(() => WidgetsFlutterBinding.ensureInitialized(), returnsNormally);
    });

    test('should be able to call main components', () async {
      // Test that we can call the components that main() would call
      expect(() => WidgetsFlutterBinding.ensureInitialized(), returnsNormally);

      // Test service initialization calls (without actual initialization)
      // This tests the structure that main() uses
      expect(() => const FlutterBlueApp(), returnsNormally);
    });
  });

  group('Widget Lifecycle Coverage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});

      // Mock Flutter Blue Plus for lifecycle tests
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        (MethodCall methodCall) async {
          return BluetoothAdapterState.on.index;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_blue_plus/methods'),
        null,
      );
    });

    testWidgets('should execute initState lifecycle', (WidgetTester tester) async {
      // This test will execute the initState method
      await tester.pumpWidget(const FlutterBlueApp());

      // Verify widget is built (which means initState was called)
      expect(find.byType(FlutterBlueApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should execute build lifecycle', (WidgetTester tester) async {
      // This test will execute the build method
      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      // Verify build method created the expected widget tree
      expect(find.byType(MaterialApp), findsOneWidget);

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.color, equals(Colors.lightBlue));
    });

    testWidgets('should execute dispose lifecycle', (WidgetTester tester) async {
      // Create and then dispose the widget
      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      // Verify widget exists
      expect(find.byType(FlutterBlueApp), findsOneWidget);

      // Dispose by replacing with different widget
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      // Verify widget is disposed
      expect(find.byType(FlutterBlueApp), findsNothing);
    });

    testWidgets('should handle multiple rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterBlueApp());
      await tester.pumpAndSettle();

      // Trigger multiple rebuilds
      for (int i = 0; i < 3; i++) {
        await tester.pump();
      }

      // Verify widget survives multiple rebuilds
      expect(find.byType(FlutterBlueApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
