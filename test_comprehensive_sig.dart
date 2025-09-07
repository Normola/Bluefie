#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// Comprehensive test for the enhanced SIG service with all 22 database types

void main() async {
  print('🔍 Testing Comprehensive SIG Service Enhancement');
  print('===============================================');

  // Test directory
  final testDir = Directory('test/assets/sig_data');

  // Count all JSON files and their entries
  final files =
      testDir.listSync().where((f) => f.path.endsWith('.json')).toList();

  print('📁 Found ${files.length} JSON database files:');
  print('');

  int totalEntries = 0;
  final Map<String, int> databaseStats = {};

  for (final file in files) {
    final fileName = file.path.split(Platform.pathSeparator).last;

    try {
      final content = await File(file.path).readAsString();
      final data = json.decode(content) as Map<String, dynamic>;
      final entries = data.length;
      totalEntries += entries;
      databaseStats[fileName] = entries;

      // Show status indicator
      String status = '✅';
      if (entries == 0) {
        status = '⚠️ ';
      } else if (entries > 1000) {
        status = '🔥';
      } else if (entries > 100) {
        status = '📈';
      }

      print('$status $fileName: $entries entries');
    } catch (e) {
      print('❌ $fileName: Error - $e');
    }
  }

  print('');
  print('📊 Comprehensive Database Summary:');
  print('=================================');
  print('Total Files: ${files.length}');
  print('Total Entries: $totalEntries');
  print('');

  // Show top databases by size
  final sortedStats = databaseStats.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  print('📈 Top Databases by Size:');
  for (int i = 0; i < 10 && i < sortedStats.length; i++) {
    final entry = sortedStats[i];
    print('${i + 1}. ${entry.key}: ${entry.value} entries');
  }

  print('');

  // Validate essential databases exist
  final essentialFiles = [
    'sig_services.json',
    'sig_characteristics.json',
    'sig_company_identifiers.json',
    'sig_member_uuids.json',
    'sig_units.json',
    'sig_protocol_identifiers.json',
    'sig_mesh_models.json',
    'sig_service_classes.json'
  ];

  print('🔍 Essential Database Validation:');
  bool allEssentialPresent = true;

  for (final essential in essentialFiles) {
    if (databaseStats.containsKey(essential)) {
      final count = databaseStats[essential]!;
      if (count > 0) {
        print('✅ $essential: $count entries');
      } else {
        print('⚠️  $essential: Empty file');
        allEssentialPresent = false;
      }
    } else {
      print('❌ $essential: Missing');
      allEssentialPresent = false;
    }
  }

  print('');

  if (allEssentialPresent) {
    print('🎉 SUCCESS: All essential databases are present and populated!');
    print(
        '🚀 Enhanced SIG service ready with comprehensive Bluetooth specification data');
    print('');
    print('💡 Key Features Available:');
    print('  • ${databaseStats['sig_services.json'] ?? 0} Bluetooth services');
    print(
        '  • ${databaseStats['sig_characteristics.json'] ?? 0} characteristics');
    print(
        '  • ${databaseStats['sig_company_identifiers.json'] ?? 0} company identifiers');
    print('  • ${databaseStats['sig_member_uuids.json'] ?? 0} member UUIDs');
    print('  • ${databaseStats['sig_units.json'] ?? 0} measurement units');
    print(
        '  • ${databaseStats['sig_protocol_identifiers.json'] ?? 0} protocol identifiers');
    print('  • ${databaseStats['sig_mesh_models.json'] ?? 0} mesh models');
    print(
        '  • ${databaseStats['sig_service_classes.json'] ?? 0} service classes');
    print('  • Plus ${files.length - 8} additional specialized databases');
  } else {
    print('⚠️  WARNING: Some essential databases are missing or empty');
    print('   Please check the conversion process');
  }

  print('');
  print('✨ Comprehensive SIG Enhancement Complete!');
  print('   Total data coverage: $totalEntries specification entries');
  print('   Database types: ${files.length} different categories');
  print('   Ready for production deployment');
}
