import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class OuiService {
  static final OuiService _instance = OuiService._internal();
  factory OuiService() => _instance;
  OuiService._internal();

  static const String _ouiUrl = 'https://standards-oui.ieee.org/oui/oui.txt';
  static const String _fileName = 'oui_database.txt';

  final Map<String, String> _ouiDatabase = {};
  bool _isLoaded = false;
  bool _isDownloading = false;

  final StreamController<Map<String, String>> _databaseController =
      StreamController<Map<String, String>>.broadcast();
  final StreamController<double> _downloadProgressController =
      StreamController<double>.broadcast();

  Stream<Map<String, String>> get databaseStream => _databaseController.stream;
  Stream<double> get downloadProgressStream =>
      _downloadProgressController.stream;

  bool get isLoaded => _isLoaded;
  bool get isDownloading => _isDownloading;
  int get databaseSize => _ouiDatabase.length;

  Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      await _loadFromDisk();
      if (_ouiDatabase.isNotEmpty) {
        _isLoaded = true;
        _databaseController.add(_ouiDatabase);
      }
    } catch (e) {
      debugPrint('Error initializing OUI service: $e');
    }
  }

  Future<bool> downloadDatabase({bool forceUpdate = false}) async {
    if (_isDownloading) return false;

    try {
      _isDownloading = true;
      _downloadProgressController.add(0.0);

      final file = await _getOuiFile();

      // Check if we need to update
      if (!forceUpdate && await file.exists()) {
        final lastModified = await file.lastModified();
        final daysSinceUpdate = DateTime.now().difference(lastModified).inDays;
        if (daysSinceUpdate < 30) {
          debugPrint(
              'OUI database is recent ($daysSinceUpdate days old), skipping download');
          _isDownloading = false;
          return true;
        }
      }

      debugPrint('Downloading OUI database from IEEE...');

      final request = http.Request('GET', Uri.parse(_ouiUrl));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to download OUI database: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      var downloadedBytes = 0;
      final bytes = <int>[];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        downloadedBytes += chunk.length;

        if (contentLength > 0) {
          final progress = downloadedBytes / contentLength;
          _downloadProgressController.add(progress);
        }
      }

      // Write to file
      await file.writeAsBytes(bytes);

      // Parse the downloaded data
      final content = utf8.decode(bytes);
      await _parseOuiData(content);

      _isLoaded = true;
      _databaseController.add(_ouiDatabase);

      debugPrint(
          'OUI database downloaded and parsed successfully (${_ouiDatabase.length} entries)');
      return true;
    } catch (e) {
      debugPrint('Error downloading OUI database: $e');
      return false;
    } finally {
      _isDownloading = false;
      _downloadProgressController.add(1.0);
    }
  }

  String? getManufacturer(String macAddress) {
    if (!_isLoaded || macAddress.length < 6) return null;

    // Extract OUI (first 6 characters, remove separators)
    final cleanMac = macAddress.replaceAll(RegExp(r'[:-]'), '').toUpperCase();
    if (cleanMac.length < 6) return null;

    final oui = cleanMac.substring(0, 6);
    return _ouiDatabase[oui];
  }

  Future<File> _getOuiFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getOuiFile();
      if (!await file.exists()) return;

      final content = await file.readAsString();
      await _parseOuiData(content);

      debugPrint(
          'Loaded OUI database from disk (${_ouiDatabase.length} entries)');
    } catch (e) {
      debugPrint('Error loading OUI database from disk: $e');
    }
  }

  Future<void> _parseOuiData(String content) async {
    _ouiDatabase.clear();

    final lines = content.split('\n');
    String? currentOui;

    for (final line in lines) {
      final trimmedLine = line.trim();

      // Look for OUI assignment lines
      if (trimmedLine.contains('(hex)')) {
        final parts = trimmedLine.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          currentOui = parts[0].replaceAll('-', '');
          final manufacturerStart = trimmedLine.indexOf(parts[2]);
          if (manufacturerStart != -1) {
            final manufacturer =
                trimmedLine.substring(manufacturerStart).trim();
            _ouiDatabase[currentOui] = manufacturer;
          }
        }
      }
    }

    debugPrint('Parsed ${_ouiDatabase.length} OUI entries');
  }

  Future<DateTime?> getLastUpdateTime() async {
    try {
      final file = await _getOuiFile();
      if (await file.exists()) {
        return await file.lastModified();
      }
    } catch (e) {
      debugPrint('Error getting OUI file last modified time: $e');
    }
    return null;
  }

  Future<bool> deleteDatabase() async {
    try {
      final file = await _getOuiFile();
      if (await file.exists()) {
        await file.delete();
      }
      _ouiDatabase.clear();
      _isLoaded = false;
      _databaseController.add(_ouiDatabase);
      return true;
    } catch (e) {
      debugPrint('Error deleting OUI database: $e');
      return false;
    }
  }

  void dispose() {
    _databaseController.close();
    _downloadProgressController.close();
  }
}
