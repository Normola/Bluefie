import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';

/// Service for managing Bluetooth SIG (Special Interest Group) assigned numbers
/// including services, characteristics, company identifiers, etc.
class SigService {
  static final SigService _instance = SigService._internal();
  factory SigService() => _instance;
  SigService._internal();

  // Well-known Bluetooth service UUIDs (fallback when remote data unavailable)
  static const Map<String, String> _wellKnownServices = {
    '1800': 'Generic Access',
    '1801': 'Generic Attribute',
    '1802': 'Immediate Alert',
    '1803': 'Link Loss',
    '1804': 'Tx Power',
    '1805': 'Current Time Service',
    '1806': 'Reference Time Update Service',
    '1807': 'Next DST Change Service',
    '1808': 'Glucose',
    '1809': 'Health Thermometer',
    '180a': 'Device Information',
    '180d': 'Heart Rate',
    '180e': 'Phone Alert Status Service',
    '180f': 'Battery Service',
    '1810': 'Blood Pressure',
    '1811': 'Alert Notification Service',
    '1812': 'Human Interface Device',
    '1813': 'Scan Parameters',
    '1814': 'Running Speed and Cadence',
    '1815': 'Automation IO',
    '1816': 'Cycling Speed and Cadence',
    '1818': 'Cycling Power',
    '1819': 'Location and Navigation',
    '181a': 'Environmental Sensing',
    '181b': 'Body Composition',
    '181c': 'User Data',
    '181d': 'Weight Scale',
    '181e': 'Bond Management',
    '181f': 'Continuous Glucose Monitoring',
    '1820': 'Internet Protocol Support',
    '1821': 'Indoor Positioning',
    '1822': 'Pulse Oximeter',
    '1823': 'HTTP Proxy',
    '1824': 'Transport Discovery',
    '1825': 'Object Transfer',
    '1826': 'Fitness Machine',
    '1827': 'Mesh Provisioning Service',
    '1828': 'Mesh Proxy Service',
    '1829': 'Reconnection Configuration',
    // 128-bit UUIDs (shortened for common services)
    '6e400001-b5a3-f393-e0a9-e50e24dcca9e': 'Nordic UART Service',
    '0000fee0-0000-1000-8000-00805f9b34fb': 'Mi Scale Service',
  };

  static const Map<String, String> _wellKnownCharacteristics = {
    '2a00': 'Device Name',
    '2a01': 'Appearance',
    '2a02': 'Peripheral Privacy Flag',
    '2a03': 'Reconnection Address',
    '2a04': 'Peripheral Preferred Connection Parameters',
    '2a05': 'Service Changed',
    '2a06': 'Alert Level',
    '2a07': 'Tx Power Level',
    '2a08': 'Date Time',
    '2a09': 'Day of Week',
    '2a0a': 'Day Date Time',
    '2a0c': 'Exact Time 256',
    '2a0d': 'DST Offset',
    '2a0e': 'Time Zone',
    '2a0f': 'Local Time Information',
    '2a11': 'Time with DST',
    '2a12': 'Time Accuracy',
    '2a13': 'Time Source',
    '2a14': 'Reference Time Information',
    '2a16': 'Time Update Control Point',
    '2a17': 'Time Update State',
    '2a18': 'Glucose Measurement',
    '2a19': 'Battery Level',
    '2a1c': 'Temperature Measurement',
    '2a1d': 'Temperature Type',
    '2a1e': 'Intermediate Temperature',
    '2a21': 'Measurement Interval',
    '2a22': 'Boot Keyboard Input Report',
    '2a23': 'System ID',
    '2a24': 'Model Number String',
    '2a25': 'Serial Number String',
    '2a26': 'Firmware Revision String',
    '2a27': 'Hardware Revision String',
    '2a28': 'Software Revision String',
    '2a29': 'Manufacturer Name String',
    '2a2a': 'IEEE 11073-20601 Regulatory Certification Data List',
    '2a2b': 'Current Time',
    '2a31': 'Scan Refresh',
    '2a32': 'Boot Keyboard Output Report',
    '2a33': 'Boot Mouse Input Report',
    '2a34': 'Glucose Measurement Context',
    '2a35': 'Blood Pressure Measurement',
    '2a36': 'Intermediate Cuff Pressure',
    '2a37': 'Heart Rate Measurement',
    '2a38': 'Body Sensor Location',
    '2a39': 'Heart Rate Control Point',
    '2a3a': 'Removable',
    '2a3b': 'Service Required',
    '2a3c': 'Scientific Temperature Celsius',
    '2a3d': 'String',
    '2a3e': 'Network Availability',
    '2a3f': 'Alert Status',
    '2a40': 'Ringer Control Point',
    '2a41': 'Ringer Setting',
    '2a42': 'Alert Category ID Bit Mask',
    '2a43': 'Alert Category ID',
    '2a44': 'Alert Notification Control Point',
    '2a45': 'Unread Alert Status',
    '2a46': 'New Alert',
    '2a47': 'Supported New Alert Category',
    '2a48': 'Supported Unread Alert Category',
    '2a49': 'Blood Pressure Feature',
    '2a4a': 'HID Information',
    '2a4b': 'Report Map',
    '2a4c': 'HID Control Point',
    '2a4d': 'Report',
    '2a4e': 'Protocol Mode',
    '2a4f': 'Scan Interval Window',
    '2a50': 'PnP ID',
    '2a51': 'Glucose Feature',
    '2a52': 'Record Access Control Point',
    '2a53': 'RSC Measurement',
    '2a54': 'RSC Feature',
    '2a55': 'SC Control Point',
  };

  // Remote repository URLs (when available)
  static const String _baseUrl =
      'https://bitbucket.org/bluetooth-SIG/public/raw/main/assigned_numbers';
  static const String _servicesUrl = '$_baseUrl/service_uuids.yaml';
  static const String _characteristicsUrl =
      '$_baseUrl/characteristic_uuids.yaml';
  static const String _descriptorsUrl = '$_baseUrl/descriptor_uuids.yaml';
  static const String _companyIdentifiersUrl =
      '$_baseUrl/company_identifiers.yaml';

  // Local file names for caching
  static const String _servicesFileName = 'sig_services.json';
  static const String _characteristicsFileName = 'sig_characteristics.json';
  static const String _descriptorsFileName = 'sig_descriptors.json';
  static const String _companyIdentifiersFileName =
      'sig_company_identifiers.json';

  // In-memory databases
  final Map<String, String> _services = {};
  final Map<String, String> _characteristics = {};
  final Map<String, String> _descriptors = {};
  final Map<String, String> _companyIdentifiers = {};

  bool _isLoaded = false;
  bool _isDownloading = false;

  // Stream controllers for real-time updates
  final StreamController<Map<String, String>> _servicesController =
      StreamController<Map<String, String>>.broadcast();
  final StreamController<Map<String, String>> _characteristicsController =
      StreamController<Map<String, String>>.broadcast();
  final StreamController<double> _downloadProgressController =
      StreamController<double>.broadcast();

  // Getters
  Stream<Map<String, String>> get servicesStream => _servicesController.stream;
  Stream<Map<String, String>> get characteristicsStream =>
      _characteristicsController.stream;
  Stream<double> get downloadProgressStream =>
      _downloadProgressController.stream;

  bool get isLoaded => _isLoaded;
  bool get isDownloading => _isDownloading;
  int get servicesCount => _services.length;
  int get characteristicsCount => _characteristics.length;
  int get descriptorsCount => _descriptors.length;
  int get companyIdentifiersCount => _companyIdentifiers.length;

  /// Initialize the service by loading cached data or using well-known values
  Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      await _loadFromDisk();

      // If no cached data found, use well-known values as fallback
      if (_services.isEmpty && _characteristics.isEmpty) {
        _services.addAll(_wellKnownServices);
        _characteristics.addAll(_wellKnownCharacteristics);
        debugPrint('Initialized SIG service with well-known UUIDs');
        debugPrint(
            'Services: ${_services.length}, Characteristics: ${_characteristics.length}');
      }

      _isLoaded = true;
      _servicesController.add(_services);
      _characteristicsController.add(_characteristics);
    } catch (e) {
      debugPrint('Error initializing SIG service: $e');
      // Fallback to well-known values even on error
      _services.addAll(_wellKnownServices);
      _characteristics.addAll(_wellKnownCharacteristics);
      _isLoaded = true;
      _servicesController.add(_services);
      _characteristicsController.add(_characteristics);
    }
  }

  /// Download all SIG databases
  Future<bool> downloadDatabase({bool forceUpdate = false}) async {
    if (_isDownloading) return false;

    if (!forceUpdate) {
      final shouldSkip = await _shouldSkipUpdate();
      if (shouldSkip) return true;
    }

    _isDownloading = true;
    _downloadProgressController.add(0.0);

    try {
      const totalDatabases = 4;
      var completedDatabases = 0;

      // Clear existing data
      _services.clear();
      _characteristics.clear();
      _descriptors.clear();
      _companyIdentifiers.clear();

      // Start with well-known values as fallback
      _services.addAll(_wellKnownServices);
      _characteristics.addAll(_wellKnownCharacteristics);

      // Try downloading from remote sources (this may fail due to authentication/format issues)
      await _downloadAndParseYaml(
          _servicesUrl, _servicesFileName, _services, 'services');
      completedDatabases++;
      _downloadProgressController
          .add(completedDatabases / totalDatabases * 0.8);

      await _downloadAndParseYaml(_characteristicsUrl, _characteristicsFileName,
          _characteristics, 'characteristics');
      completedDatabases++;
      _downloadProgressController
          .add(completedDatabases / totalDatabases * 0.8);

      await _downloadAndParseYaml(
          _descriptorsUrl, _descriptorsFileName, _descriptors, 'descriptors');
      completedDatabases++;
      _downloadProgressController
          .add(completedDatabases / totalDatabases * 0.8);

      await _downloadAndParseYaml(
          _companyIdentifiersUrl,
          _companyIdentifiersFileName,
          _companyIdentifiers,
          'company_identifiers');
      completedDatabases++;
      _downloadProgressController
          .add(completedDatabases / totalDatabases * 0.8);

      // Save all databases to disk
      await _saveToDisk();

      _isLoaded = true;
      _servicesController.add(_services);
      _characteristicsController.add(_characteristics);

      _downloadProgressController.add(1.0);
      debugPrint('SIG databases download completed');
      debugPrint(
          'Services: ${_services.length}, Characteristics: ${_characteristics.length}');
      debugPrint(
          'Descriptors: ${_descriptors.length}, Company IDs: ${_companyIdentifiers.length}');

      return true;
    } catch (e) {
      debugPrint('Error downloading SIG databases: $e');
      // Ensure we have at least the well-known values
      if (_services.isEmpty) _services.addAll(_wellKnownServices);
      if (_characteristics.isEmpty)
        _characteristics.addAll(_wellKnownCharacteristics);
      return false;
    } finally {
      _isDownloading = false;
    }
  }

  /// Download and parse a single YAML file
  Future<void> _downloadAndParseYaml(String url, String fileName,
      Map<String, String> database, String type) async {
    try {
      debugPrint('Attempting to download $type from $url...');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint('Failed to download $type: HTTP ${response.statusCode}');
        return;
      }

      await _parseYamlData(response.body, database, type);
      debugPrint('Successfully parsed ${database.length} $type entries');
    } catch (e) {
      debugPrint('Error downloading $type: $e');
      // Continue with other downloads even if one fails
    }
  }

  /// Parse YAML data into the database map
  Future<void> _parseYamlData(
      String yamlData, Map<String, String> database, String type) async {
    try {
      final yamlDoc = loadYaml(yamlData);

      if (yamlDoc is! Map) {
        debugPrint('Invalid YAML structure for $type');
        return;
      }

      // Different YAML structures may exist, try common patterns
      if (yamlDoc.containsKey('uuids')) {
        final uuids = yamlDoc['uuids'];
        if (uuids is List) {
          for (final item in uuids) {
            if (item is Map &&
                item.containsKey('uuid') &&
                item.containsKey('name')) {
              final uuid = _normalizeUuid(item['uuid']?.toString() ?? '');
              final name = item['name']?.toString() ?? '';
              if (uuid.isNotEmpty && name.isNotEmpty) {
                database[uuid] = name;
              }
            }
          }
        }
      } else if (yamlDoc.containsKey('services') ||
          yamlDoc.containsKey('characteristics')) {
        // Handle other possible structures
        final key =
            yamlDoc.containsKey('services') ? 'services' : 'characteristics';
        final items = yamlDoc[key];
        if (items is Map) {
          items.forEach((k, v) {
            final uuid = _normalizeUuid(k.toString());
            final name = v.toString();
            if (uuid.isNotEmpty && name.isNotEmpty) {
              database[uuid] = name;
            }
          });
        }
      }

      debugPrint('Parsed ${database.length} entries from $type YAML');
    } catch (e) {
      debugPrint('Error parsing YAML for $type: $e');
    }
  }

  /// Check if we should skip the update
  Future<bool> _shouldSkipUpdate() async {
    try {
      final file =
          File('${(await _getDataDirectory()).path}/$_servicesFileName');
      if (!await file.exists()) return false;

      final lastModified = await file.lastModified();
      final daysSinceUpdate = DateTime.now().difference(lastModified).inDays;

      if (daysSinceUpdate < 30) {
        debugPrint(
            'SIG databases are recent ($daysSinceUpdate days old), skipping download');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking update time: $e');
      return false;
    }
  }

  /// Load databases from disk
  Future<void> _loadFromDisk() async {
    try {
      final dataDir = await _getDataDirectory();

      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_servicesFileName'), _services);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_characteristicsFileName'), _characteristics);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_descriptorsFileName'), _descriptors);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_companyIdentifiersFileName'),
          _companyIdentifiers);

      if (_services.isNotEmpty || _characteristics.isNotEmpty) {
        debugPrint('Loaded SIG databases from disk');
        debugPrint(
            'Services: ${_services.length}, Characteristics: ${_characteristics.length}');
      }
    } catch (e) {
      debugPrint('Error loading SIG databases from disk: $e');
    }
  }

  /// Save databases to disk
  Future<void> _saveToDisk() async {
    try {
      final dataDir = await _getDataDirectory();

      await _saveDatabaseToFile(
          File('${dataDir.path}/$_servicesFileName'), _services);
      await _saveDatabaseToFile(
          File('${dataDir.path}/$_characteristicsFileName'), _characteristics);
      await _saveDatabaseToFile(
          File('${dataDir.path}/$_descriptorsFileName'), _descriptors);
      await _saveDatabaseToFile(
          File('${dataDir.path}/$_companyIdentifiersFileName'),
          _companyIdentifiers);

      debugPrint('Saved SIG databases to disk');
    } catch (e) {
      debugPrint('Error saving SIG databases to disk: $e');
    }
  }

  /// Load a single database from file
  Future<void> _loadDatabaseFromFile(
      File file, Map<String, String> database) async {
    if (!await file.exists()) return;

    try {
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);
      database.clear();
      data.forEach((key, value) {
        database[key] = value.toString();
      });
    } catch (e) {
      debugPrint('Error loading database from ${file.path}: $e');
    }
  }

  /// Save a single database to file
  Future<void> _saveDatabaseToFile(
      File file, Map<String, String> database) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(database));
    } catch (e) {
      debugPrint('Error saving database to ${file.path}: $e');
    }
  }

  /// Get the data directory for SIG files
  Future<Directory> _getDataDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/sig_data');
  }

  /// Delete all SIG databases
  Future<bool> deleteDatabase() async {
    try {
      final dataDir = await _getDataDirectory();
      if (await dataDir.exists()) {
        await dataDir.delete(recursive: true);
      }

      _services.clear();
      _characteristics.clear();
      _descriptors.clear();
      _companyIdentifiers.clear();

      // Restore well-known values
      _services.addAll(_wellKnownServices);
      _characteristics.addAll(_wellKnownCharacteristics);

      _isLoaded = true;
      _servicesController.add(_services);
      _characteristicsController.add(_characteristics);

      debugPrint('SIG database deleted, restored well-known UUIDs');
      return true;
    } catch (e) {
      debugPrint('Error deleting SIG database: $e');
      return false;
    }
  }

  /// Get the last update time
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final file =
          File('${(await _getDataDirectory()).path}/$_servicesFileName');
      if (await file.exists()) {
        return await file.lastModified();
      }
    } catch (e) {
      debugPrint('Error getting last update time: $e');
    }
    return null;
  }

  /// Get service name from UUID
  String? getServiceName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _services[normalizedUuid];
  }

  /// Get characteristic name from UUID
  String? getCharacteristicName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _characteristics[normalizedUuid];
  }

  /// Get descriptor name from UUID
  String? getDescriptorName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _descriptors[normalizedUuid];
  }

  /// Get company name from identifier
  String? getCompanyName(String identifier) {
    if (!_isLoaded) return null;
    return _companyIdentifiers[identifier.toLowerCase()];
  }

  /// Normalize UUID to lowercase, remove hyphens and 0x prefix
  /// Also convert 128-bit UUIDs to 16-bit form if they follow the standard pattern
  String _normalizeUuid(String uuid) {
    String normalized = uuid
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll('0x', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .trim();

    // Convert 128-bit UUID to 16-bit if it follows the standard Bluetooth pattern
    // 0000XXXX-0000-1000-8000-00805F9B34FB -> XXXX
    if (normalized.length == 32 &&
        normalized.startsWith('0000') &&
        normalized.endsWith('00001000800000805f9b34fb')) {
      normalized = normalized.substring(4, 8);
    }

    return normalized;
  }

  /// Dispose of resources
  void dispose() {
    _servicesController.close();
    _characteristicsController.close();
    _downloadProgressController.close();
  }
}
