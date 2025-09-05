#!/usr/bin/env dart
// Script to help replace print statements with proper logging
// Run with: dart tools/replace_prints.dart

import 'package:blufie_ui/services/logging_service.dart';

void main() {
  log.info('🔍 Scanning for print statements to replace...\n');

  final printPatterns = {
    // Bluetooth scanning service
    r"print\('Bluetooth is off'\);": "log.warning('Bluetooth is off');",
    r"print\('Error starting scan: \$e'\);":
        "log.error('Error starting scan', e);",
    r"print\('Scan started with timeout: \${scanDuration}ms'\);":
        "log.bluetooth('Scan started', {'timeout_ms': scanDuration});",
    r"print\('Scan stopped - timeout reached'\);":
        "log.bluetooth('Scan stopped - timeout reached');",
    r"print\('Error stopping scan: \$e'\);":
        "log.error('Error stopping scan', e);",
    r"print\('Scan timeout reached'\);":
        "log.bluetooth('Scan timeout reached');",
    r"print\('Error in scan result: \$e'\);":
        "log.error('Error in scan result', e);",
    r"print\('Device already exists in database, updating: \$deviceId'\);":
        "log.database('Device already exists, updating', {'deviceId': deviceId});",
    r"print\('Error storing device: \$e'\);":
        "log.error('Error storing device', e);",
    r"print\('Error processing scan result: \$e'\);":
        "log.error('Error processing scan result', e);",
    r"print\('Error in scan stream: \$e'\);":
        "log.error('Error in scan stream', e);",

    // Location service
    r"print\('Error getting current location: \$e'\);":
        "log.error('Error getting current location', e);",
    r"print\('Location tracking error: \$error'\);":
        "log.error('Location tracking error', error);",

    // Database helper
    r"print\('Database error: \$e'\);": "log.error('Database error', e);",

    // Settings service
    r"print\('Error loading settings: \$e'\);":
        "log.error('Error loading settings', e);",
    r"print\('Error saving settings: \$e'\);":
        "log.error('Error saving settings', e);",

    // Device history screen
    r"print\('Error loading device history: \$e'\);":
        "log.error('Error loading device history', e);",
  };

  log.info('📋 Suggested replacements:');
  log.info('=' * 50);

  for (final entry in printPatterns.entries) {
    log.info('FROM: ${entry.key}');
    log.info('TO:   ${entry.value}');
    log.info('');
  }

  log.info('🎯 Remember to:');
  log.info('1. Add import: import "../services/logging_service.dart";');
  log.info('2. Replace print() calls with appropriate log methods');
  log.info('3. Use structured logging with context maps where helpful');
  log.info('4. Consider log levels: debug, info, warning, error');
}
