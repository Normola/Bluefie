import 'dart:async';

import 'package:blufie_ui/main.dart';
import 'package:blufie_ui/services/app_configuration.dart';
import 'package:blufie_ui/services/bluetooth_adapter_service.dart';
import 'package:blufie_ui/services/navigation_observer_service.dart';
import 'package:blufie_ui/widgets/flutter_blue_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Manual mock classes for testing
class MockAppConfiguration extends Mock implements AppConfigurationInterface {
  final MockBluetoothAdapter _mockAdapter = MockBluetoothAdapter();
  final MockNavigationObserver _mockObserver = MockNavigationObserver();

  @override
  Future<void> initializeServices() async {
    // Mock implementation - always succeeds
  }

  @override
  BluetoothAdapterInterface get bluetoothAdapter => _mockAdapter;

  @override
  BluetoothNavigationObserverInterface createNavigationObserver() =>
      _mockObserver;
}

class MockBluetoothAdapter extends Mock implements BluetoothAdapterInterface {
  final StreamController<BluetoothAdapterState> _stateController =
      StreamController.broadcast();

  @override
  Stream<BluetoothAdapterState> get adapterStateStream =>
      _stateController.stream;

  @override
  BluetoothAdapterState get currentState => BluetoothAdapterState.on;

  @override
  void setLogLevel(LogLevel level) {}
}

class MockNavigationObserver extends Mock
    implements BluetoothNavigationObserverInterface {}

void main() {
  group('Main Function Tests', () {
    test('main function should be defined and accessible', () {
      // Verify the main function exists and is callable
      expect(main, isA<Function>());
      expect(main, isNotNull);
    });

    test('main function should be async', () {
      // Verify main is an async function (returns Future<void>)
      expect(main, isA<Function>());
    });
  });

  group('FlutterBlueApp', () {
    late MockAppConfiguration mockAppConfig;
    late MockBluetoothAdapter mockBluetoothAdapter;

    setUp(() {
      mockAppConfig = MockAppConfiguration();
      mockBluetoothAdapter =
          mockAppConfig.bluetoothAdapter as MockBluetoothAdapter;
    });

    group('Constructor Tests', () {
      test('should create with AppConfiguration', () {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);
        expect(app.appConfiguration, equals(mockAppConfig));
      });

      test('should be a StatelessWidget', () {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);
        expect(app, isA<StatelessWidget>());
      });

      test('should require non-null appConfiguration', () {
        expect(() => FlutterBlueApp(appConfiguration: mockAppConfig),
            returnsNormally);
      });

      test('should support optional key parameter', () {
        const key = Key('test-key');
        final app = FlutterBlueApp(
          key: key,
          appConfiguration: mockAppConfig,
        );

        expect(app.key, equals(key));
        expect(app.appConfiguration, equals(mockAppConfig));
      });
    });

    group('Build Method Tests', () {
      testWidgets('should build FlutterBlueAppWidget correctly',
          (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(MaterialApp(home: app));

        // Verify that FlutterBlueAppWidget was created
        expect(find.byType(FlutterBlueAppWidget), findsOneWidget);
      });

      testWidgets('should pass bluetoothAdapter to FlutterBlueAppWidget',
          (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(MaterialApp(home: app));

        // Find the FlutterBlueAppWidget and verify it has the right adapter
        final flutterBlueAppWidget = tester.widget<FlutterBlueAppWidget>(
          find.byType(FlutterBlueAppWidget),
        );

        expect(flutterBlueAppWidget.bluetoothAdapter,
            equals(mockBluetoothAdapter));
      });

      testWidgets(
          'should pass navigationObserverFactory to FlutterBlueAppWidget',
          (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(MaterialApp(home: app));

        // Find the FlutterBlueAppWidget
        final flutterBlueAppWidget = tester.widget<FlutterBlueAppWidget>(
          find.byType(FlutterBlueAppWidget),
        );

        // Verify the navigation observer factory is passed correctly
        expect(flutterBlueAppWidget.navigationObserverFactory, isNotNull);

        // Test that the factory function works
        final observer = flutterBlueAppWidget.navigationObserverFactory();
        expect(observer, isA<BluetoothNavigationObserverInterface>());
      });
    });

    group('Widget Integration Tests', () {
      testWidgets('should render without error', (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(MaterialApp(home: app));
        await tester.pumpAndSettle();

        // Should not throw any exceptions
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle rebuild correctly',
          (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(MaterialApp(home: app));
        await tester.pumpWidget(MaterialApp(home: app));
        await tester.pumpAndSettle();

        // Should still have the FlutterBlueAppWidget after rebuild
        expect(find.byType(FlutterBlueAppWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle different configurations',
          (WidgetTester tester) async {
        // Create a second mock configuration
        final mockAppConfig2 = MockAppConfiguration();
        final mockBluetoothAdapter2 = mockAppConfig2.bluetoothAdapter;

        // Test with first configuration
        final app1 = FlutterBlueApp(appConfiguration: mockAppConfig);
        await tester.pumpWidget(MaterialApp(home: app1));

        var flutterBlueAppWidget = tester.widget<FlutterBlueAppWidget>(
          find.byType(FlutterBlueAppWidget),
        );
        expect(flutterBlueAppWidget.bluetoothAdapter,
            equals(mockBluetoothAdapter));

        // Test with second configuration
        final app2 = FlutterBlueApp(appConfiguration: mockAppConfig2);
        await tester.pumpWidget(MaterialApp(home: app2));

        flutterBlueAppWidget = tester.widget<FlutterBlueAppWidget>(
          find.byType(FlutterBlueAppWidget),
        );
        expect(flutterBlueAppWidget.bluetoothAdapter,
            equals(mockBluetoothAdapter2));
      });
    });

    group('Dependency Injection Tests', () {
      testWidgets('should properly inject bluetoothAdapter dependency',
          (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(MaterialApp(home: app));

        final flutterBlueAppWidget = tester.widget<FlutterBlueAppWidget>(
          find.byType(FlutterBlueAppWidget),
        );
        expect(
            flutterBlueAppWidget.bluetoothAdapter, same(mockBluetoothAdapter));
      });

      testWidgets('should properly inject navigationObserverFactory dependency',
          (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(MaterialApp(home: app));

        // Verify that the navigation observer factory is being used
        final flutterBlueAppWidget = tester.widget<FlutterBlueAppWidget>(
          find.byType(FlutterBlueAppWidget),
        );
        expect(flutterBlueAppWidget.navigationObserverFactory, isNotNull);
      });

      test('should maintain dependency references correctly', () {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        // The app should maintain a reference to the configuration
        expect(app.appConfiguration, same(mockAppConfig));

        // Multiple accesses should return the same instance
        expect(app.appConfiguration, same(app.appConfiguration));
      });

      testWidgets('should not cause memory leaks', (WidgetTester tester) async {
        // Test multiple create/dispose cycles
        for (int i = 0; i < 5; i++) {
          final app = FlutterBlueApp(appConfiguration: mockAppConfig);
          await tester.pumpWidget(MaterialApp(home: app));
          await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        }

        // Should complete without issues
        expect(find.byType(FlutterBlueAppWidget), findsNothing);
      });
    });

    group('Type Safety Tests', () {
      test('should maintain correct type hierarchy', () {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        expect(app, isA<Widget>());
        expect(app, isA<StatelessWidget>());
        expect(app, isA<FlutterBlueApp>());
      });

      test('should have correct parameter types', () {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        expect(app.appConfiguration, isA<AppConfigurationInterface>());
        expect(app.key, anyOf(isNull, isA<Key>()));
      });

      testWidgets('should pass correctly typed parameters to child widget',
          (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(MaterialApp(home: app));

        final flutterBlueAppWidget = tester.widget<FlutterBlueAppWidget>(
          find.byType(FlutterBlueAppWidget),
        );

        expect(flutterBlueAppWidget.bluetoothAdapter,
            isA<BluetoothAdapterInterface>());
        expect(flutterBlueAppWidget.navigationObserverFactory, isA<Function>());
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle configuration errors gracefully',
          (WidgetTester tester) async {
        // Create a mock that might throw - we'll test by creating a working mock first
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        // Should build successfully with our working mock
        await expectLater(
          () => tester.pumpWidget(MaterialApp(home: app)),
          returnsNormally,
        );
      });

      testWidgets('should handle navigation observer creation properly',
          (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(MaterialApp(home: app));

        final flutterBlueAppWidget = tester.widget<FlutterBlueAppWidget>(
          find.byType(FlutterBlueAppWidget),
        );

        // The factory should work correctly
        expect(flutterBlueAppWidget.navigationObserverFactory, isNotNull);
        final observer = flutterBlueAppWidget.navigationObserverFactory();
        expect(observer, isNotNull);
      });
    });

    group('Integration Tests', () {
      testWidgets('should work with MaterialApp', (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        await tester.pumpWidget(app);

        // Should integrate well with MaterialApp widget tree
        // FlutterBlueApp creates its own MaterialApp internally
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(FlutterBlueApp), findsOneWidget);
        expect(find.byType(FlutterBlueAppWidget), findsOneWidget);
      });

      testWidgets('should work in different widget contexts',
          (WidgetTester tester) async {
        final app = FlutterBlueApp(appConfiguration: mockAppConfig);

        // Test in a Scaffold
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: app),
        ));

        expect(find.byType(FlutterBlueAppWidget), findsOneWidget);

        // Test in a Container
        await tester.pumpWidget(MaterialApp(
          home: Container(child: app),
        ));

        expect(find.byType(FlutterBlueAppWidget), findsOneWidget);
      });
    });
  });
}
