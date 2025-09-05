import 'package:blufie_ui/screens/battery_monitor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BatteryMonitorScreen Widget Tests', () {
    testWidgets('should display battery monitor screen with key components',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: BatteryMonitorScreen(),
        ),
      );

      // Wait for initial state to settle
      await tester.pumpAndSettle();

      // Verify the screen loads
      expect(find.byType(BatteryMonitorScreen), findsOneWidget);

      // Verify app bar
      expect(find.text('Battery Monitor'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Verify main cards are present
      expect(find.text('Battery Status'), findsOneWidget);
      expect(find.text('Scanning Status'), findsOneWidget);
      expect(find.text('Battery Optimization'), findsOneWidget);
      expect(find.text('Battery History'), findsOneWidget);
      expect(find.text('Power Saving Tips'), findsOneWidget);
    });

    testWidgets('should show refresh functionality', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BatteryMonitorScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the refresh button
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // The screen should still be present after refresh
      expect(find.byType(BatteryMonitorScreen), findsOneWidget);
    });

    testWidgets('should display battery level indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BatteryMonitorScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should have battery level display (percentage and progress indicator)
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Should show some battery related text
      expect(find.textContaining('%'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show power saving tips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BatteryMonitorScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify power saving tips are shown
      expect(find.text('Power Saving Tips'), findsOneWidget);
      expect(find.text('Enable battery optimization to pause scanning when battery is low'),
          findsOneWidget);
    });

    testWidgets('should support pull-to-refresh', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BatteryMonitorScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify RefreshIndicator is present
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Simply test that the screen remains stable
      expect(find.byType(BatteryMonitorScreen), findsOneWidget);
    });
  });
}
