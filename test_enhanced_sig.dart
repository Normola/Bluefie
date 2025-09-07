import 'dart:convert';
import 'dart:io';

void main() async {
  print('=== Enhanced SIG Database Test ===');

  final testAssetsDir = Directory('test/assets/sig_data');

  if (!testAssetsDir.existsSync()) {
    print('❌ Test assets directory not found: ${testAssetsDir.path}');
    return;
  }

  print('✅ Test assets directory found: ${testAssetsDir.path}');

  // List all JSON files in the test assets
  final jsonFiles = testAssetsDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList();

  print('\n📁 Found ${jsonFiles.length} JSON files:');

  for (final file in jsonFiles) {
    final filename = file.path.split('\\').last;
    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      print('  ✅ $filename - ${data.length} entries');

      // Show a few sample entries
      if (data.isNotEmpty) {
        final sampleKeys = data.keys.take(3).toList();
        for (final key in sampleKeys) {
          final value = data[key];
          final valueStr = value is String ? value : value.toString();
          final displayValue = valueStr.length > 50
              ? '${valueStr.substring(0, 50)}...'
              : valueStr;
          print('    $key: $displayValue');
        }
        if (data.length > 3) {
          print('    ... and ${data.length - 3} more entries');
        }
      }
    } catch (e) {
      print('  ❌ $filename - Error: $e');
    }
  }

  print('\n=== Summary ===');
  print('Enhanced SIG database files are ready for testing!');
  print('Total files: ${jsonFiles.length}');
  print('Files that should be loaded by SIG service:');
  print('  - sig_services.json');
  print('  - sig_characteristics.json');
  print('  - sig_descriptors.json');
  print('  - sig_company_identifiers.json');
  print('  - sig_member_uuids.json');
  print('  - sig_appearance_values.json');
  print('  - sig_ad_types.json');
}
