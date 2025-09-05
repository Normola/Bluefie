import 'package:blufie_ui/main.dart';
import 'package:blufie_ui/services/app_configuration.dart';
import 'package:blufie_ui/services/bluetooth_adapter_service.dart';
import 'package:blufie_ui/services/navigation_observer_service.dart';
import 'package:blufie_ui/widgets/flutter_blue_app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockAppConfiguration extends Mock implements AppConfigurationInterface {
  final MockBluetoothAdapter _mockAdapter = MockBluetoothAdapter();
  final MockNavigationObserver _mockObserver = MockNavigationObserver();

  @override
  Future<void> initializeServices() async {
    // Mock implementation - do nothing
  }

  @override
  BluetoothAdapterInterface get bluetoothAdapter => _mockAdapter;

  @override
  BluetoothNavigationObserverInterface createNavigationObserver() => _mockObserver;
}

class MockBluetoothAdapter extends Mock implements BluetoothAdapterInterface {
  @override
  BluetoothAdapterState get currentState => BluetoothAdapterState.on;

  @override
  Stream<BluetoothAdapterState> get adapterStateStream => Stream.value(BluetoothAdapterState.on);
}

class MockNavigationObserver extends Mock implements BluetoothNavigationObserverInterface {}

void main() {
  group('Main Function Tests', () {
    test('should have main function defined', () {
      // Test that the main function exists
      expect(main, isA<Function>());
    });

    test('should create FlutterBlueApp widget', () {
      // Test that we can create the FlutterBlueApp widget with configuration
      final mockConfig = MockAppConfiguration();
      final app = FlutterBlueApp(appConfiguration: mockConfig);

      expect(app, isA<FlutterBlueApp>());
      expect(app.appConfiguration, equals(mockConfig));
    });

    test('should be a StatelessWidget', () {
      final mockConfig = MockAppConfiguration();
      final app = FlutterBlueApp(appConfiguration: mockConfig);

      expect(app, isA<StatelessWidget>());
    });

    testWidgets('should build FlutterBlueAppWidget', (WidgetTester tester) async {
      // Arrange
      final mockConfig = MockAppConfiguration();

      // Act
      await tester.pumpWidget(FlutterBlueApp(appConfiguration: mockConfig));

      // Assert - verify that the build method was called
      expect(find.byType(FlutterBlueAppWidget), findsOneWidget);
    });

    testWidgets('should pass configuration to FlutterBlueAppWidget', (WidgetTester tester) async {
      // Arrange
      final mockConfig = MockAppConfiguration();

      // Act
      await tester.pumpWidget(FlutterBlueApp(appConfiguration: mockConfig));

      // Assert - check that dependencies were passed correctly
      final flutterBlueAppWidget =
          tester.widget<FlutterBlueAppWidget>(find.byType(FlutterBlueAppWidget));
      expect(flutterBlueAppWidget.bluetoothAdapter, isNotNull);
      expect(flutterBlueAppWidget.navigationObserverFactory, isNotNull);
    });
  });
}
