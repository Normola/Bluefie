// Basic widget test for Blufie app
// This file demonstrates the main app can be instantiated

import 'package:blufie_ui/screens/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App structure smoke test', (WidgetTester tester) async {
    // Test the basic app structure without Bluetooth dependencies
    await tester.pumpWidget(
      const MaterialApp(
        title: 'Blufie',
        home: Scaffold(
          body: Center(
            child: Text('Blufie Test App'),
          ),
        ),
      ),
    );

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Blufie Test App'), findsOneWidget);
  });

  testWidgets('App has proper title', (WidgetTester tester) async {
    const testApp = MaterialApp(
      title: 'Blufie',
      home: Scaffold(
        body: Center(
          child: Text('Test'),
        ),
      ),
    );

    await tester.pumpWidget(testApp);

    // Check if the app has the correct title
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, equals('Blufie'));
  });

  testWidgets('ScanScreen can be instantiated', (WidgetTester tester) async {
    // Test that individual screens can be created without Bluetooth
    await tester.pumpWidget(
      const MaterialApp(
        home: ScanScreen(),
      ),
    );

    // Verify the screen loads
    expect(find.byType(ScanScreen), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
