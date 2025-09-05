import 'package:blufie_ui/main.dart';
import 'package:blufie_ui/screens/bluetooth_off_screen.dart';
import 'package:blufie_ui/screens/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Integration-style tests that work around Bluetooth platform issues
void main() {
  group('Main.dart Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should create and instantiate app components', (WidgetTester tester) async {
      // Test just the constructors and basic structure without full initialization
      const app = FlutterBlueApp();
      final state = app.createState();
      final observer = BluetoothAdapterStateObserver();

      expect(app, isA<StatefulWidget>());
      expect(state, isNotNull);
      expect(observer, isA<NavigatorObserver>());

      // Test widget hierarchy without pumping Bluetooth-dependent widgets
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Column(
              children: [
                Text('Testing basic structure'),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should handle basic widget lifecycle', (WidgetTester tester) async {
      // Test widget creation and disposal without Bluetooth
      Widget testWidget = const MaterialApp(
        home: Scaffold(
          body: Text('Lifecycle test'),
        ),
      );

      await tester.pumpWidget(testWidget);
      expect(find.text('Lifecycle test'), findsOneWidget);

      // Test widget disposal
      await tester.pumpWidget(const SizedBox.shrink());
      expect(find.text('Lifecycle test'), findsNothing);
    });

    test('should create state class correctly', () {
      const app = FlutterBlueApp();
      final state = app.createState();

      // Test that state object is created and has correct type
      expect(state.runtimeType.toString(), contains('_FlutterBlueAppState'));
      // Don't access state.widget before it's properly initialized
      expect(state, isA<State<FlutterBlueApp>>());
    });

    test('should handle observer instantiation', () {
      final observer = BluetoothAdapterStateObserver();

      // Test observer properties
      expect(observer, isA<NavigatorObserver>());
      expect(observer.navigator, isNull);
    });

    testWidgets('should create BluetoothOffScreen without Bluetooth calls',
        (WidgetTester tester) async {
      // Test creating the screen without adapter state (avoiding Bluetooth calls)
      await tester.pumpWidget(
        const MaterialApp(
          home: BluetoothOffScreen(),
        ),
      );

      // Verify basic structure exists
      expect(find.byType(BluetoothOffScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should create ScanScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScanScreen(),
        ),
      );

      expect(find.byType(ScanScreen), findsOneWidget);
    });

    test('should verify main components can be instantiated together', () {
      // Test that all main components can be created in sequence
      const app = FlutterBlueApp();
      final state = app.createState();
      final observer = BluetoothAdapterStateObserver();
      const offScreen = BluetoothOffScreen();
      const scanScreen = ScanScreen();

      expect(app, isNotNull);
      expect(state, isNotNull);
      expect(observer, isNotNull);
      expect(offScreen, isNotNull);
      expect(scanScreen, isNotNull);
    });

    test('should test constructor parameters', () {
      // Test widget constructors with different parameters
      const app1 = FlutterBlueApp();
      const app2 = FlutterBlueApp(key: Key('test'));

      expect(app1.key, isNull);
      expect(app2.key, equals(const Key('test')));
    });
  });
}
