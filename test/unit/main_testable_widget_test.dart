import 'dart:async';

import 'package:blufie_ui/screens/bluetooth_off_screen.dart';
import 'package:blufie_ui/screens/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a testable version of the main app that doesn't depend on actual Bluetooth
class TestableFlutterBlueApp extends StatefulWidget {
  final Stream<BluetoothAdapterState>? mockAdapterStateStream;

  const TestableFlutterBlueApp({
    super.key,
    this.mockAdapterStateStream,
  });

  @override
  State<TestableFlutterBlueApp> createState() => _TestableFlutterBlueAppState();
}

class _TestableFlutterBlueAppState extends State<TestableFlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();

    // Use mock stream if provided, otherwise use a default stream
    final stream = widget.mockAdapterStateStream ?? Stream.value(BluetoothAdapterState.on);

    _adapterStateStateSubscription = stream.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);

    return MaterialApp(
      color: Colors.lightBlue,
      home: screen,
      navigatorObservers: [TestableBluetoothAdapterStateObserver()],
    );
  }
}

// Create a testable version of the observer that doesn't depend on actual Bluetooth
class TestableBluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  final Stream<BluetoothAdapterState>? mockStream;

  TestableBluetoothAdapterStateObserver({this.mockStream});

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Use mock stream if provided, otherwise use a default that doesn't trigger errors
      final stream = mockStream ?? Stream.value(BluetoothAdapterState.on);

      _adapterStateSubscription ??= stream.listen((state) {
        if (state != BluetoothAdapterState.on) {
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}

void main() {
  group('Testable FlutterBlueApp Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should create and build TestableFlutterBlueApp successfully',
        (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(TestableFlutterBlueApp), findsOneWidget);
    });

    testWidgets('should show ScanScreen when Bluetooth is on', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ScanScreen), findsOneWidget);
      expect(find.byType(BluetoothOffScreen), findsNothing);
    });

    testWidgets('should show BluetoothOffScreen when Bluetooth is off',
        (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.off);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(BluetoothOffScreen), findsOneWidget);
      expect(find.byType(ScanScreen), findsNothing);
    });

    testWidgets('should have correct MaterialApp properties', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.color, equals(Colors.lightBlue));
      expect(materialApp.navigatorObservers?.length, equals(1));
      expect(materialApp.navigatorObservers?.first, isA<TestableBluetoothAdapterStateObserver>());
    });

    testWidgets('should handle widget disposal properly', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TestableFlutterBlueApp), findsOneWidget);

      // Dispose the widget by replacing it
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      expect(find.byType(TestableFlutterBlueApp), findsNothing);
    });

    testWidgets('should respond to Bluetooth state changes', (WidgetTester tester) async {
      final controller = StreamController<BluetoothAdapterState>();

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: controller.stream,
      ));
      await tester.pump();

      // Start with Bluetooth on
      controller.add(BluetoothAdapterState.on);
      await tester.pumpAndSettle();
      expect(find.byType(ScanScreen), findsOneWidget);

      // Change to Bluetooth off
      controller.add(BluetoothAdapterState.off);
      await tester.pumpAndSettle();
      expect(find.byType(BluetoothOffScreen), findsOneWidget);

      // Clean up
      await controller.close();
    });

    testWidgets('should handle unknown adapter state', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.unknown);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      // Unknown state should show BluetoothOffScreen
      expect(find.byType(BluetoothOffScreen), findsOneWidget);
      expect(find.byType(ScanScreen), findsNothing);
    });

    testWidgets('should create observer and add to navigator', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.navigatorObservers, isNotNull);
      expect(materialApp.navigatorObservers!.length, equals(1));

      final observer = materialApp.navigatorObservers!.first;
      expect(observer, isA<TestableBluetoothAdapterStateObserver>());
    });
  });

  group('TestableBluetoothAdapterStateObserver Tests', () {
    late TestableBluetoothAdapterStateObserver observer;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should handle DeviceScreen route navigation', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);
      observer = TestableBluetoothAdapterStateObserver(mockStream: mockStream);

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
      observer = TestableBluetoothAdapterStateObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [observer],
          home: const Scaffold(body: Text('Home')),
          routes: {
            '/Settings': (context) => const Scaffold(body: Text('Settings')),
          },
        ),
      );

      Navigator.of(tester.element(find.text('Home'))).pushNamed('/Settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    test('should handle didPush and didPop for DeviceScreen', () {
      final mockStream = Stream.value(BluetoothAdapterState.on);
      observer = TestableBluetoothAdapterStateObserver(mockStream: mockStream);

      final route = MockRoute(const RouteSettings(name: '/DeviceScreen'));

      expect(() => observer.didPush(route, null), returnsNormally);
      expect(() => observer.didPop(route, null), returnsNormally);
    });

    test('should handle didPush and didPop for non-DeviceScreen', () {
      observer = TestableBluetoothAdapterStateObserver();

      final route = MockRoute(const RouteSettings(name: '/Settings'));

      expect(() => observer.didPush(route, null), returnsNormally);
      expect(() => observer.didPop(route, null), returnsNormally);
    });
  });

  group('Widget Lifecycle Coverage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should execute initState lifecycle', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));

      // Verify widget is built (which means initState was called)
      expect(find.byType(TestableFlutterBlueApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should execute build lifecycle', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      // Verify build method created the expected widget tree
      expect(find.byType(MaterialApp), findsOneWidget);

      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.color, equals(Colors.lightBlue));
    });

    testWidgets('should execute dispose lifecycle', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TestableFlutterBlueApp), findsOneWidget);

      // Dispose by replacing with different widget
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      expect(find.byType(TestableFlutterBlueApp), findsNothing);
    });

    testWidgets('should handle multiple rebuilds', (WidgetTester tester) async {
      final mockStream = Stream.value(BluetoothAdapterState.on);

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: mockStream,
      ));
      await tester.pumpAndSettle();

      // Trigger multiple rebuilds
      for (int i = 0; i < 3; i++) {
        await tester.pump();
      }

      expect(find.byType(TestableFlutterBlueApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should handle stream subscription lifecycle', (WidgetTester tester) async {
      final controller = StreamController<BluetoothAdapterState>();

      await tester.pumpWidget(TestableFlutterBlueApp(
        mockAdapterStateStream: controller.stream,
      ));
      await tester.pump();

      // Send multiple state changes
      controller.add(BluetoothAdapterState.on);
      await tester.pump();

      controller.add(BluetoothAdapterState.off);
      await tester.pump();

      controller.add(BluetoothAdapterState.on);
      await tester.pump();

      expect(find.byType(TestableFlutterBlueApp), findsOneWidget);

      // Clean up
      await controller.close();
    });
  });
}

// Mock Route class for testing using mockito
class MockRoute extends Mock implements Route<dynamic> {
  final RouteSettings _settings;

  MockRoute(this._settings);

  @override
  RouteSettings get settings => _settings;
}
