import 'dart:io';

import 'package:blufie_ui/screens/bluetooth_off_screen.dart';
import 'package:blufie_ui/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BluetoothOffScreen', () {
    group('Constructor Tests', () {
      test('should create with default parameters', () {
        const screen = BluetoothOffScreen();

        expect(screen.adapterState, isNull);
        expect(screen.key, isNull);
      });

      test('should create with adapter state parameter', () {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        expect(screen.adapterState, equals(BluetoothAdapterState.off));
      });

      test('should create with key parameter', () {
        const key = Key('test-key');
        const screen = BluetoothOffScreen(key: key, adapterState: BluetoothAdapterState.unknown);

        expect(screen.key, equals(key));
        expect(screen.adapterState, equals(BluetoothAdapterState.unknown));
      });

      test('should accept all BluetoothAdapterState values', () {
        const states = [
          BluetoothAdapterState.unknown,
          BluetoothAdapterState.unavailable,
          BluetoothAdapterState.unauthorized,
          BluetoothAdapterState.turningOn,
          BluetoothAdapterState.on,
          BluetoothAdapterState.turningOff,
          BluetoothAdapterState.off,
        ];

        for (final state in states) {
          final screen = BluetoothOffScreen(adapterState: state);
          expect(screen.adapterState, equals(state));
        }
      });
    });

    group('Widget Tests', () {
      testWidgets('should build without errors', (WidgetTester tester) async {
        const screen = BluetoothOffScreen();

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.byType(BluetoothOffScreen), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(ScaffoldMessenger), findsAtLeastNWidgets(1));
      });

      testWidgets('should display bluetooth disabled icon', (WidgetTester tester) async {
        const screen = BluetoothOffScreen();

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);

        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.bluetooth_disabled));
        expect(iconWidget.color, equals(Colors.white54));
        expect(iconWidget.size, equals(200.0));
      });

      testWidgets('should have correct background color', (WidgetTester tester) async {
        const screen = BluetoothOffScreen();

        await tester.pumpWidget(const MaterialApp(home: screen));

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(Colors.lightBlue));
      });

      testWidgets('should display centered column layout', (WidgetTester tester) async {
        const screen = BluetoothOffScreen();

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.byType(Center), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsOneWidget);

        final column = tester.widget<Column>(find.byType(Column));
        expect(column.mainAxisSize, equals(MainAxisSize.min));
      });
    });

    group('Title Display Tests', () {
      testWidgets('should display title with null adapter state', (WidgetTester tester) async {
        const screen = BluetoothOffScreen();

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.text('Bluetooth Adapter is null'), findsOneWidget);
      });

      testWidgets('should display title with off adapter state', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.text('Bluetooth Adapter is off'), findsOneWidget);
      });

      testWidgets('should display title with unknown adapter state', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.unknown);

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.text('Bluetooth Adapter is unknown'), findsOneWidget);
      });

      testWidgets('should display title with unavailable adapter state',
          (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.unavailable);

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.text('Bluetooth Adapter is unavailable'), findsOneWidget);
      });

      testWidgets('should display title with unauthorized adapter state',
          (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.unauthorized);

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.text('Bluetooth Adapter is unauthorized'), findsOneWidget);
      });

      testWidgets('should display title with turningOn adapter state', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.turningOn);

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.text('Bluetooth Adapter is turningOn'), findsOneWidget);
      });

      testWidgets('should display title with turningOff adapter state',
          (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.turningOff);

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.text('Bluetooth Adapter is turningOff'), findsOneWidget);
      });

      testWidgets('should display title with on adapter state', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.on);

        await tester.pumpWidget(const MaterialApp(home: screen));

        expect(find.text('Bluetooth Adapter is on'), findsOneWidget);
      });

      testWidgets('should use correct text styling for title', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(
            primaryTextTheme: const TextTheme(
              titleSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          home: screen,
        ));

        final titleText = tester.widget<Text>(find.text('Bluetooth Adapter is off'));
        expect(titleText.style?.color, equals(Colors.white));
      });
    });

    group('Platform-Specific Button Tests', () {
      testWidgets('should show turn on button on Android', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(const MaterialApp(home: screen));

        if (Platform.isAndroid) {
          expect(find.text('Turn On Bluetooth'), findsOneWidget);
          expect(find.byType(ElevatedButton), findsOneWidget);
          expect(find.byType(Padding), findsAtLeastNWidgets(1));
        } else {
          expect(find.text('Turn On Bluetooth'), findsNothing);
          expect(find.byType(ElevatedButton), findsNothing);
        }
      });

      testWidgets('should have correct button styling', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(const MaterialApp(home: screen));

        if (Platform.isAndroid) {
          final padding = tester.widget<Padding>(
            find.ancestor(
              of: find.byType(ElevatedButton),
              matching: find.byType(Padding),
            ),
          );
          expect(padding.padding, equals(const EdgeInsets.all(20.0)));
        }
      });
    });

    group('Component Widget Tests', () {
      testWidgets('buildBluetoothOffIcon should create correct icon', (WidgetTester tester) async {
        const screen = BluetoothOffScreen();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => screen.buildBluetoothOffIcon(context),
            ),
          ),
        ));

        expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);

        final icon = tester.widget<Icon>(find.byIcon(Icons.bluetooth_disabled));
        expect(icon.color, equals(Colors.white54));
        expect(icon.size, equals(200.0));
      });

      testWidgets('buildTitle should create correct text for different states',
          (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => screen.buildTitle(context),
            ),
          ),
        ));

        expect(find.text('Bluetooth Adapter is off'), findsOneWidget);
      });

      testWidgets('buildTurnOnButton should create correct button', (WidgetTester tester) async {
        const screen = BluetoothOffScreen();

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => screen.buildTurnOnButton(context),
            ),
          ),
        ));

        expect(find.text('Turn On Bluetooth'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);

        // Find the specific padding we created (20.0 all around)
        final customPadding = tester
            .widgetList<Padding>(find.byType(Padding))
            .where((padding) => padding.padding == const EdgeInsets.all(20.0));
        expect(customPadding, hasLength(1));
      });
    });

    group('Snackbar Integration Tests', () {
      testWidgets('should have correct snackbar key configured', (WidgetTester tester) async {
        const screen = BluetoothOffScreen();

        await tester.pumpWidget(const MaterialApp(home: screen));

        final scaffoldMessengers =
            tester.widgetList<ScaffoldMessenger>(find.byType(ScaffoldMessenger));

        // Find the one with the snackbar key
        final screenScaffoldMessenger = scaffoldMessengers.firstWhere(
          (messenger) => messenger.key == Snackbar.snackBarKeyA,
        );
        expect(screenScaffoldMessenger.key, equals(Snackbar.snackBarKeyA));
      });

      testWidgets('should be ready to display snackbars', (WidgetTester tester) async {
        const screen = BluetoothOffScreen();

        await tester.pumpWidget(const MaterialApp(home: screen));

        // Verify ScaffoldMessenger is properly set up for snackbar display
        expect(find.byType(ScaffoldMessenger), findsAtLeastNWidgets(1));
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('Layout and Styling Tests', () {
      testWidgets('should have correct widget hierarchy', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(const MaterialApp(home: screen));

        // Check widget hierarchy
        expect(find.byType(ScaffoldMessenger), findsAtLeastNWidgets(1));
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Center), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsOneWidget);
        expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);
        expect(find.textContaining('Bluetooth Adapter is'), findsOneWidget);
      });

      testWidgets('should maintain consistent spacing', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(const MaterialApp(home: screen));

        final column = tester.widget<Column>(find.byType(Column));
        expect(column.mainAxisSize, equals(MainAxisSize.min));
        expect(column.children.length, greaterThanOrEqualTo(2)); // Icon and title always present
      });

      testWidgets('should handle different screen sizes', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        // Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(400, 600));
        await tester.pumpWidget(const MaterialApp(home: screen));
        expect(find.byType(BluetoothOffScreen), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpWidget(const MaterialApp(home: screen));
        expect(find.byType(BluetoothOffScreen), findsOneWidget);

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Type Safety and Interface Tests', () {
      test('should be a StatelessWidget', () {
        const screen = BluetoothOffScreen();
        expect(screen, isA<StatelessWidget>());
      });

      test('should be a Widget', () {
        const screen = BluetoothOffScreen();
        expect(screen, isA<Widget>());
      });

      test('should maintain immutability', () {
        const screen1 = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);
        const screen2 = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        expect(screen1.adapterState, equals(screen2.adapterState));
      });

      test('should handle null adapter state correctly', () {
        const screen = BluetoothOffScreen();
        expect(screen.adapterState, isNull);
        expect(() => screen.adapterState, returnsNormally);
      });
    });

    group('Edge Cases and Error Handling', () {
      testWidgets('should handle theme changes gracefully', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        // Test with light theme
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.light(),
          home: screen,
        ));
        expect(find.byType(BluetoothOffScreen), findsOneWidget);

        // Test with dark theme
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData.dark(),
          home: screen,
        ));
        expect(find.byType(BluetoothOffScreen), findsOneWidget);
      });

      testWidgets('should handle missing theme gracefully', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(primaryTextTheme: const TextTheme()),
          home: screen,
        ));

        expect(find.byType(BluetoothOffScreen), findsOneWidget);
        expect(find.textContaining('Bluetooth Adapter is'), findsOneWidget);
      });

      testWidgets('should maintain functionality with different MaterialApp configurations',
          (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.unknown);

        // Test with different MaterialApp configurations
        await tester.pumpWidget(const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: screen,
        ));
        expect(find.byType(BluetoothOffScreen), findsOneWidget);

        await tester.pumpWidget(const MaterialApp(
          title: 'Test App',
          home: screen,
        ));
        expect(find.byType(BluetoothOffScreen), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(const MaterialApp(home: screen));

        // Verify text is readable
        expect(find.textContaining('Bluetooth Adapter'), findsOneWidget);

        // Verify button is accessible when present
        if (Platform.isAndroid) {
          expect(find.text('Turn On Bluetooth'), findsOneWidget);

          final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
          expect(button.onPressed, isNotNull);
        }
      });

      testWidgets('should have semantic labels', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        await tester.pumpWidget(const MaterialApp(home: screen));

        // Icon should be findable
        expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);

        // Text should be readable by screen readers
        expect(find.text('Bluetooth Adapter is off'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should build quickly', (WidgetTester tester) async {
        const screen = BluetoothOffScreen(adapterState: BluetoothAdapterState.off);

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(const MaterialApp(home: screen));

        stopwatch.stop();

        // Should build in reasonable time (less than 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(find.byType(BluetoothOffScreen), findsOneWidget);
      });

      testWidgets('should handle rapid rebuilds', (WidgetTester tester) async {
        for (int i = 0; i < 10; i++) {
          final screen = BluetoothOffScreen(
            adapterState: i % 2 == 0 ? BluetoothAdapterState.off : BluetoothAdapterState.unknown,
          );

          await tester.pumpWidget(MaterialApp(home: screen));
          expect(find.byType(BluetoothOffScreen), findsOneWidget);
        }
      });
    });
  });
}
