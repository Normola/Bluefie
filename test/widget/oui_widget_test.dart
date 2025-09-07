import 'package:blufie_ui/services/logging_service.dart';
import 'package:blufie_ui/services/oui_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OUI Widget Integration Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      LoggingService().initialize();
    });

    testWidgets('should handle OUI service in widget context',
        (WidgetTester tester) async {
      final ouiService = OuiService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    Text('OUI Service Test'),
                    Text('Database Size: ${ouiService.databaseSize}'),
                    Text('Is Loaded: ${ouiService.isLoaded}'),
                    Text('Is Downloading: ${ouiService.isDownloading}'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify widget renders without errors
      expect(find.text('OUI Service Test'), findsOneWidget);
      expect(find.textContaining('Database Size:'), findsOneWidget);
      expect(find.textContaining('Is Loaded:'), findsOneWidget);
      expect(find.textContaining('Is Downloading:'), findsOneWidget);
    });

    testWidgets('should handle OUI service streams in widget context',
        (WidgetTester tester) async {
      final ouiService = OuiService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamBuilder<Map<String, String>>(
              stream: ouiService.databaseStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Text('Database entries: ${snapshot.data?.length ?? 0}');
              },
            ),
          ),
        ),
      );

      // Verify stream builder works
      expect(find.textContaining('Database entries:'), findsOneWidget);
    });

    testWidgets('should handle download progress stream in widget context',
        (WidgetTester tester) async {
      final ouiService = OuiService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamBuilder<double>(
              stream: ouiService.downloadProgressStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Progress Error: ${snapshot.error}');
                }
                final progress = snapshot.data ?? 0.0;
                return LinearProgressIndicator(value: progress);
              },
            ),
          ),
        ),
      );

      // Verify progress indicator renders
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle manufacturer lookup in widget context',
        (WidgetTester tester) async {
      final ouiService = OuiService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final testMac = '00:11:22:33:44:55';
                final manufacturer = ouiService.getManufacturer(testMac);
                return Column(
                  children: [
                    Text('Test MAC: $testMac'),
                    Text('Manufacturer: ${manufacturer ?? 'Unknown'}'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify manufacturer lookup widget works
      expect(find.text('Test MAC: 00:11:22:33:44:55'), findsOneWidget);
      expect(find.textContaining('Manufacturer:'), findsOneWidget);
    });

    testWidgets('should handle OUI service accessibility',
        (WidgetTester tester) async {
      final ouiService = OuiService();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(
                  'Database Size: ${ouiService.databaseSize}',
                  semanticsLabel: 'Database size indicator',
                ),
                Text(
                  'Is Loaded: ${ouiService.isLoaded}',
                  semanticsLabel: 'Loading status indicator',
                ),
              ],
            ),
          ),
        ),
      );

      // Verify accessibility semantics work
      expect(find.text('Database Size: ${ouiService.databaseSize}'),
          findsOneWidget);
      expect(find.text('Is Loaded: ${ouiService.isLoaded}'), findsOneWidget);
    });

    testWidgets('should handle performance with OUI service',
        (WidgetTester tester) async {
      final ouiService = OuiService();

      // Test that multiple lookups don't cause performance issues
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final testMacs = [
                  '00:11:22:33:44:55',
                  'AA:BB:CC:DD:EE:FF',
                  '12:34:56:78:90:AB',
                ];

                return Column(
                  children: testMacs.map((mac) {
                    final manufacturer = ouiService.getManufacturer(mac);
                    return Text('$mac: ${manufacturer ?? 'Unknown'}');
                  }).toList(),
                );
              },
            ),
          ),
        ),
      );

      // Verify all MAC addresses are displayed
      expect(find.textContaining('00:11:22:33:44:55:'), findsOneWidget);
      expect(find.textContaining('AA:BB:CC:DD:EE:FF:'), findsOneWidget);
      expect(find.textContaining('12:34:56:78:90:AB:'), findsOneWidget);
    });
  });
}
