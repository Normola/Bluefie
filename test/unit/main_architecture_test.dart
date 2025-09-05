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

// Mock classes for testing
class MockAppConfiguration extends Mock implements AppConfigurationInterface {}

class MockBluetoothAdapter extends Mock implements BluetoothAdapterInterface {}

class MockNavigationObserver extends Mock implements BluetoothNavigationObserverInterface {}

void main() {
  group('New Architecture Tests', () {
    late MockAppConfiguration mockAppConfig;
    late MockBluetoothAdapter mockBluetoothAdapter;
    late MockNavigationObserver mockNavigationObserver;

    setUp(() {
      mockAppConfig = MockAppConfiguration();
      mockBluetoothAdapter = MockBluetoothAdapter();
      mockNavigationObserver = MockNavigationObserver();

      // Set up mock returns
      when(mockAppConfig.bluetoothAdapter).thenReturn(mockBluetoothAdapter);
      when(mockAppConfig.createNavigationObserver()).thenReturn(mockNavigationObserver);
      when(mockBluetoothAdapter.currentState).thenReturn(BluetoothAdapterState.on);
      when(mockBluetoothAdapter.adapterStateStream).thenAnswer(
        (_) => Stream.value(BluetoothAdapterState.on),
      );
    });

    testWidgets('FlutterBlueApp should use dependency injection', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(FlutterBlueApp(appConfiguration: mockAppConfig));

      // Assert
      verify(mockAppConfig.bluetoothAdapter).called(1);
      verify(mockAppConfig.createNavigationObserver()).called(1);
    });

    testWidgets('FlutterBlueApp should delegate to FlutterBlueAppWidget',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(FlutterBlueApp(appConfiguration: mockAppConfig));

      // Assert
      expect(find.byType(FlutterBlueAppWidget), findsOneWidget);
    });

    testWidgets('FlutterBlueApp should pass dependencies correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(FlutterBlueApp(appConfiguration: mockAppConfig));

      // Assert - Find the FlutterBlueAppWidget and verify its dependencies
      final flutterBlueAppWidget = tester.widget<FlutterBlueAppWidget>(
        find.byType(FlutterBlueAppWidget),
      );

      expect(flutterBlueAppWidget.bluetoothAdapter, equals(mockBluetoothAdapter));

      // Verify navigation observer factory works
      final observer = flutterBlueAppWidget.navigationObserverFactory();
      expect(observer, equals(mockNavigationObserver));
    });

    group('FlutterBlueAppWidget Tests', () {
      testWidgets('should initialize with current adapter state', (WidgetTester tester) async {
        // Arrange
        when(mockBluetoothAdapter.currentState).thenReturn(BluetoothAdapterState.off);
        when(mockBluetoothAdapter.adapterStateStream).thenAnswer(
          (_) => Stream.value(BluetoothAdapterState.off),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: FlutterBlueAppWidget(
              bluetoothAdapter: mockBluetoothAdapter,
              navigationObserverFactory: () => mockNavigationObserver,
            ),
          ),
        );

        // Assert
        verify(mockBluetoothAdapter.currentState).called(1);
        verify(mockBluetoothAdapter.adapterStateStream).called(1);
      });

      testWidgets('should show ScanScreen when Bluetooth is on', (WidgetTester tester) async {
        // Arrange
        when(mockBluetoothAdapter.currentState).thenReturn(BluetoothAdapterState.on);
        when(mockBluetoothAdapter.adapterStateStream).thenAnswer(
          (_) => Stream.value(BluetoothAdapterState.on),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: FlutterBlueAppWidget(
              bluetoothAdapter: mockBluetoothAdapter,
              navigationObserverFactory: () => mockNavigationObserver,
            ),
          ),
        );

        // Assert
        expect(find.text('Scan'), findsOneWidget);
      });

      testWidgets('should show BluetoothOffScreen when Bluetooth is off',
          (WidgetTester tester) async {
        // Arrange
        when(mockBluetoothAdapter.currentState).thenReturn(BluetoothAdapterState.off);
        when(mockBluetoothAdapter.adapterStateStream).thenAnswer(
          (_) => Stream.value(BluetoothAdapterState.off),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: FlutterBlueAppWidget(
              bluetoothAdapter: mockBluetoothAdapter,
              navigationObserverFactory: () => mockNavigationObserver,
            ),
          ),
        );

        // Assert
        expect(find.text('Bluetooth Adapter is OFF'), findsOneWidget);
      });

      testWidgets('should update UI when adapter state changes', (WidgetTester tester) async {
        // Arrange
        final stateController = StreamController<BluetoothAdapterState>();
        when(mockBluetoothAdapter.currentState).thenReturn(BluetoothAdapterState.off);
        when(mockBluetoothAdapter.adapterStateStream).thenAnswer((_) => stateController.stream);

        // Act - Initial render with Bluetooth off
        await tester.pumpWidget(
          MaterialApp(
            home: FlutterBlueAppWidget(
              bluetoothAdapter: mockBluetoothAdapter,
              navigationObserverFactory: () => mockNavigationObserver,
            ),
          ),
        );

        // Assert - Should show off screen
        expect(find.text('Bluetooth Adapter is OFF'), findsOneWidget);

        // Act - Change to Bluetooth on
        stateController.add(BluetoothAdapterState.on);
        await tester.pump();

        // Assert - Should now show scan screen
        expect(find.text('Scan'), findsOneWidget);
        expect(find.text('Bluetooth Adapter is OFF'), findsNothing);

        // Cleanup
        await stateController.close();
      });

      testWidgets('should create navigation observer on init', (WidgetTester tester) async {
        // Arrange
        var observerCreated = false;
        when(mockBluetoothAdapter.currentState).thenReturn(BluetoothAdapterState.on);
        when(mockBluetoothAdapter.adapterStateStream).thenAnswer(
          (_) => Stream.value(BluetoothAdapterState.on),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: FlutterBlueAppWidget(
              bluetoothAdapter: mockBluetoothAdapter,
              navigationObserverFactory: () {
                observerCreated = true;
                return mockNavigationObserver;
              },
            ),
          ),
        );

        // Assert
        expect(observerCreated, isTrue);
      });

      testWidgets('should dispose navigation observer and subscription',
          (WidgetTester tester) async {
        // Arrange
        when(mockBluetoothAdapter.currentState).thenReturn(BluetoothAdapterState.on);
        when(mockBluetoothAdapter.adapterStateStream).thenAnswer(
          (_) => Stream.value(BluetoothAdapterState.on),
        );

        // Act - Create widget
        await tester.pumpWidget(
          MaterialApp(
            home: FlutterBlueAppWidget(
              bluetoothAdapter: mockBluetoothAdapter,
              navigationObserverFactory: () => mockNavigationObserver,
            ),
          ),
        );

        // Act - Dispose widget
        await tester.pumpWidget(Container());

        // Assert
        verify(mockNavigationObserver.dispose()).called(1);
      });
    });

    group('ScreenSelector Tests', () {
      test('should select ScanScreen when Bluetooth is on', () {
        // Act
        final screen = ScreenSelector.selectScreen(BluetoothAdapterState.on);

        // Assert
        expect(screen.runtimeType.toString(), contains('ScanScreen'));
      });

      test('should select BluetoothOffScreen when Bluetooth is off', () {
        // Act
        final screen = ScreenSelector.selectScreen(BluetoothAdapterState.off);

        // Assert
        expect(screen.runtimeType.toString(), contains('BluetoothOffScreen'));
      });

      test('should select BluetoothOffScreen when Bluetooth is unknown', () {
        // Act
        final screen = ScreenSelector.selectScreen(BluetoothAdapterState.unknown);

        // Assert
        expect(screen.runtimeType.toString(), contains('BluetoothOffScreen'));
      });

      test('isBluetoothOn should return true only for on state', () {
        expect(ScreenSelector.isBluetoothOn(BluetoothAdapterState.on), isTrue);
        expect(ScreenSelector.isBluetoothOn(BluetoothAdapterState.off), isFalse);
        expect(ScreenSelector.isBluetoothOn(BluetoothAdapterState.unknown), isFalse);
        expect(ScreenSelector.isBluetoothOn(BluetoothAdapterState.unauthorized), isFalse);
        expect(ScreenSelector.isBluetoothOn(BluetoothAdapterState.turningOn), isFalse);
        expect(ScreenSelector.isBluetoothOn(BluetoothAdapterState.turningOff), isFalse);
        expect(ScreenSelector.isBluetoothOn(BluetoothAdapterState.unavailable), isFalse);
      });
    });
  });
}
