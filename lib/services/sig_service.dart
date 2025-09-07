import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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

  // Local file names for caching
  static const String _servicesFileName = 'sig_services.json';
  static const String _characteristicsFileName = 'sig_characteristics.json';
  static const String _descriptorsFileName = 'sig_descriptors.json';
  static const String _companyIdentifiersFileName =
      'sig_company_identifiers.json';
  // Additional enhanced data files
  static const String _memberUuidsFileName = 'sig_member_uuids.json';
  static const String _appearanceValuesFileName = 'sig_appearance_values.json';
  static const String _adTypesFileName = 'sig_ad_types.json';
  static const String _codingFormatsFileName = 'sig_coding_formats.json';
  static const String _meshBeaconsFileName = 'sig_mesh_beacons.json';
  static const String _uriSchemesFileName = 'sig_uri_schemes.json';
  static const String _diacsFileName = 'sig_diacs.json';
  // Comprehensive additional data files
  static const String _classOfDeviceFileName = 'sig_class_of_device.json';
  static const String _pcmFormatsFileName = 'sig_pcm_formats.json';
  static const String _transportLayersFileName = 'sig_transport_layers.json';
  static const String _protocolIdentifiersFileName =
      'sig_protocol_identifiers.json';
  static const String _unitsFileName = 'sig_units.json';
  static const String _declarationsFileName = 'sig_declarations.json';
  static const String _objectTypesFileName = 'sig_object_types.json';
  static const String _browseGroupsFileName = 'sig_browse_groups.json';
  static const String _serviceClassesFileName = 'sig_service_classes.json';
  static const String _meshModelsFileName = 'sig_mesh_models.json';
  static const String _meshProfileUuidsFileName = 'sig_mesh_profile_uuids.json';

  // In-memory databases
  final Map<String, String> _services = {};
  final Map<String, String> _characteristics = {};
  final Map<String, String> _descriptors = {};
  final Map<String, String> _companyIdentifiers = {};
  // Additional enhanced databases
  final Map<String, String> _memberUuids = {};
  final Map<String, String> _appearanceValues = {};
  final Map<String, String> _adTypes = {};
  final Map<String, String> _codingFormats = {};
  final Map<String, String> _meshBeacons = {};
  final Map<String, String> _uriSchemes = {};
  final Map<String, String> _diacs = {};
  // Comprehensive additional databases
  final Map<String, String> _classOfDevice = {};
  final Map<String, String> _pcmFormats = {};
  final Map<String, String> _transportLayers = {};
  final Map<String, String> _protocolIdentifiers = {};
  final Map<String, String> _units = {};
  final Map<String, String> _declarations = {};
  final Map<String, String> _objectTypes = {};
  final Map<String, String> _browseGroups = {};
  final Map<String, String> _serviceClasses = {};
  final Map<String, String> _meshModels = {};
  final Map<String, String> _meshProfileUuids = {};

  bool _isLoaded = false;

  // Stream controllers for real-time updates
  final StreamController<Map<String, String>> _servicesController =
      StreamController<Map<String, String>>.broadcast();
  final StreamController<Map<String, String>> _characteristicsController =
      StreamController<Map<String, String>>.broadcast();

  // Download progress tracking (for compatibility with OUI service)
  final StreamController<double> _downloadProgressController =
      StreamController<double>.broadcast();
  bool _isDownloading = false;

  // Getters
  Stream<Map<String, String>> get servicesStream => _servicesController.stream;
  Stream<Map<String, String>> get characteristicsStream =>
      _characteristicsController.stream;

  bool get isLoaded => _isLoaded;
  int get servicesCount => _services.length;
  int get characteristicsCount => _characteristics.length;
  int get descriptorsCount => _descriptors.length;
  int get companyIdentifiersCount => _companyIdentifiers.length;
  int get memberUuidsCount => _memberUuids.length;
  int get appearanceValuesCount => _appearanceValues.length;
  int get adTypesCount => _adTypes.length;
  int get codingFormatsCount => _codingFormats.length;
  int get meshBeaconsCount => _meshBeacons.length;
  int get uriSchemesCount => _uriSchemes.length;
  int get diacsCount => _diacs.length;
  // Comprehensive additional getters
  int get classOfDeviceCount => _classOfDevice.length;
  int get pcmFormatsCount => _pcmFormats.length;
  int get transportLayersCount => _transportLayers.length;
  int get protocolIdentifiersCount => _protocolIdentifiers.length;
  int get unitsCount => _units.length;
  int get declarationsCount => _declarations.length;
  int get objectTypesCount => _objectTypes.length;
  int get browseGroupsCount => _browseGroups.length;
  int get serviceClassesCount => _serviceClasses.length;
  int get meshModelsCount => _meshModels.length;
  int get meshProfileUuidsCount => _meshProfileUuids.length;

  // Download compatibility getters (for compatibility with OUI service)
  bool get isDownloading => _isDownloading;
  Stream<double> get downloadProgressStream =>
      _downloadProgressController.stream;

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

  /// Manually refresh databases from disk (call this after adding new files)
  Future<bool> refreshDatabases() async {
    try {
      // Clear existing data
      _services.clear();
      _characteristics.clear();
      _descriptors.clear();
      _companyIdentifiers.clear();

      // Load from disk
      await _loadFromDisk();

      // If no data loaded, use well-known values as fallback
      if (_services.isEmpty && _characteristics.isEmpty) {
        _services.addAll(_wellKnownServices);
        _characteristics.addAll(_wellKnownCharacteristics);
        debugPrint('No extended databases found, using well-known UUIDs');
      }

      _isLoaded = true;
      _servicesController.add(_services);
      _characteristicsController.add(_characteristics);

      debugPrint('Refreshed SIG databases');
      debugPrint(
          'Services: ${_services.length}, Characteristics: ${_characteristics.length}');
      debugPrint(
          'Descriptors: ${_descriptors.length}, Company IDs: ${_companyIdentifiers.length}');

      return true;
    } catch (e) {
      debugPrint('Error refreshing SIG databases: $e');
      return false;
    }
  }

  /// Download databases (compatibility method - SIG service loads from bundled assets)
  Future<bool> downloadDatabase({bool forceUpdate = false}) async {
    if (_isDownloading) return false;

    _isDownloading = true;
    _downloadProgressController.add(0.0);

    try {
      // Simulate download progress for compatibility
      await Future.delayed(const Duration(milliseconds: 100));
      _downloadProgressController.add(0.3);

      // Refresh databases from bundled assets
      await Future.delayed(const Duration(milliseconds: 100));
      _downloadProgressController.add(0.7);

      final success = await refreshDatabases();

      await Future.delayed(const Duration(milliseconds: 100));
      _downloadProgressController.add(1.0);

      return success;
    } catch (e) {
      debugPrint('Error in downloadDatabase: $e');
      return false;
    } finally {
      _isDownloading = false;
    }
  }

  /// Load databases from disk or bundled assets
  Future<void> _loadFromDisk() async {
    try {
      // First try to load from bundled assets
      final success = await _loadFromAssets();
      if (success) {
        debugPrint('Loaded SIG databases from bundled assets');
        return;
      }

      // Fallback to loading from local storage
      final dataDir = await _getDataDirectory();

      // Load core databases
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_servicesFileName'), _services);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_characteristicsFileName'), _characteristics);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_descriptorsFileName'), _descriptors);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_companyIdentifiersFileName'),
          _companyIdentifiers);

      // Load enhanced databases (optional)
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_memberUuidsFileName'), _memberUuids);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_appearanceValuesFileName'),
          _appearanceValues);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_adTypesFileName'), _adTypes);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_codingFormatsFileName'), _codingFormats);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_meshBeaconsFileName'), _meshBeacons);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_uriSchemesFileName'), _uriSchemes);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_diacsFileName'), _diacs);

      // Load comprehensive additional databases (optional)
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_classOfDeviceFileName'), _classOfDevice);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_pcmFormatsFileName'), _pcmFormats);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_transportLayersFileName'), _transportLayers);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_protocolIdentifiersFileName'),
          _protocolIdentifiers);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_unitsFileName'), _units);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_declarationsFileName'), _declarations);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_objectTypesFileName'), _objectTypes);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_browseGroupsFileName'), _browseGroups);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_serviceClassesFileName'), _serviceClasses);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_meshModelsFileName'), _meshModels);
      await _loadDatabaseFromFile(
          File('${dataDir.path}/$_meshProfileUuidsFileName'),
          _meshProfileUuids);

      if (_services.isNotEmpty || _characteristics.isNotEmpty) {
        debugPrint('Loaded SIG databases from disk');
        debugPrint(
            'Services: ${_services.length}, Characteristics: ${_characteristics.length}');
        debugPrint(
            'Enhanced data - Member UUIDs: ${_memberUuids.length}, Appearances: ${_appearanceValues.length}, AD Types: ${_adTypes.length}');
        final totalCount = _services.length +
            _characteristics.length +
            _descriptors.length +
            _companyIdentifiers.length +
            _memberUuids.length +
            _appearanceValues.length +
            _adTypes.length +
            _codingFormats.length +
            _meshBeacons.length +
            _uriSchemes.length +
            _diacs.length +
            _classOfDevice.length +
            _pcmFormats.length +
            _transportLayers.length +
            _protocolIdentifiers.length +
            _units.length +
            _declarations.length +
            _objectTypes.length +
            _browseGroups.length +
            _serviceClasses.length +
            _meshModels.length +
            _meshProfileUuids.length;
        debugPrint('Total comprehensive database entries: $totalCount');
      }
    } catch (e) {
      debugPrint('Error loading SIG databases from disk: $e');
    }
  }

  /// Load databases from bundled assets
  Future<bool> _loadFromAssets() async {
    try {
      // Load core databases from assets
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_servicesFileName', _services);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_characteristicsFileName', _characteristics);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_descriptorsFileName', _descriptors);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_companyIdentifiersFileName',
          _companyIdentifiers);

      // Load enhanced databases from assets
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_memberUuidsFileName', _memberUuids);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_appearanceValuesFileName', _appearanceValues);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_adTypesFileName', _adTypes);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_codingFormatsFileName', _codingFormats);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_meshBeaconsFileName', _meshBeacons);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_uriSchemesFileName', _uriSchemes);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_diacsFileName', _diacs);

      // Load comprehensive additional databases from assets
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_classOfDeviceFileName', _classOfDevice);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_pcmFormatsFileName', _pcmFormats);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_transportLayersFileName', _transportLayers);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_protocolIdentifiersFileName',
          _protocolIdentifiers);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_unitsFileName', _units);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_declarationsFileName', _declarations);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_objectTypesFileName', _objectTypes);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_browseGroupsFileName', _browseGroups);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_serviceClassesFileName', _serviceClasses);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_meshModelsFileName', _meshModels);
      await _loadDatabaseFromAsset(
          'converted_sig_data/$_meshProfileUuidsFileName', _meshProfileUuids);

      // Check if we successfully loaded data
      final hasData = _services.isNotEmpty ||
          _characteristics.isNotEmpty ||
          _descriptors.isNotEmpty ||
          _companyIdentifiers.isNotEmpty;

      if (hasData) {
        debugPrint('Successfully loaded SIG databases from bundled assets');
        debugPrint(
            'Services: ${_services.length}, Characteristics: ${_characteristics.length}');
        debugPrint(
            'Descriptors: ${_descriptors.length}, Company IDs: ${_companyIdentifiers.length}');
        debugPrint(
            'Enhanced data - Member UUIDs: ${_memberUuids.length}, Appearances: ${_appearanceValues.length}, AD Types: ${_adTypes.length}');

        final totalCount = _services.length +
            _characteristics.length +
            _descriptors.length +
            _companyIdentifiers.length +
            _memberUuids.length +
            _appearanceValues.length +
            _adTypes.length +
            _codingFormats.length +
            _meshBeacons.length +
            _uriSchemes.length +
            _diacs.length +
            _classOfDevice.length +
            _pcmFormats.length +
            _transportLayers.length +
            _protocolIdentifiers.length +
            _units.length +
            _declarations.length +
            _objectTypes.length +
            _browseGroups.length +
            _serviceClasses.length +
            _meshModels.length +
            _meshProfileUuids.length;
        debugPrint('Total comprehensive database entries: $totalCount');
      }

      return hasData;
    } catch (e) {
      debugPrint('Error loading SIG databases from assets: $e');
      return false;
    }
  }

  /// Load a single database from Flutter asset
  Future<void> _loadDatabaseFromAsset(
      String assetPath, Map<String, String> database) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> data = jsonDecode(content);
      data.forEach((key, value) {
        database[key] = value.toString();
      });
    } catch (e) {
      debugPrint('Error loading database from asset $assetPath: $e');
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
      _memberUuids.clear();
      _appearanceValues.clear();
      _adTypes.clear();
      _codingFormats.clear();
      _meshBeacons.clear();
      _uriSchemes.clear();
      _diacs.clear();
      // Clear comprehensive additional databases
      _classOfDevice.clear();
      _pcmFormats.clear();
      _transportLayers.clear();
      _protocolIdentifiers.clear();
      _units.clear();
      _declarations.clear();
      _objectTypes.clear();
      _browseGroups.clear();
      _serviceClasses.clear();
      _meshModels.clear();
      _meshProfileUuids.clear();

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

  /// Get the path where SIG database files should be placed
  Future<String> getDatabasePath() async {
    final dataDir = await _getDataDirectory();
    return dataDir.path;
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

  /// Development helper: Check if extended databases are available
  Future<Map<String, bool>> checkDatabaseFiles() async {
    final result = <String, bool>{};
    try {
      final dataDir = await _getDataDirectory();

      final filesToCheck = {
        'services': _servicesFileName,
        'characteristics': _characteristicsFileName,
        'descriptors': _descriptorsFileName,
        'company_identifiers': _companyIdentifiersFileName,
        'member_uuids': _memberUuidsFileName,
        'appearance_values': _appearanceValuesFileName,
        'ad_types': _adTypesFileName,
        'coding_formats': _codingFormatsFileName,
        'mesh_beacons': _meshBeaconsFileName,
        'uri_schemes': _uriSchemesFileName,
        'diacs': _diacsFileName,
      };

      for (final entry in filesToCheck.entries) {
        final file = File('${dataDir.path}/${entry.value}');
        result[entry.key] = await file.exists();
      }
    } catch (e) {
      debugPrint('Error checking database files: $e');
    }
    return result;
  }

  /// Get service name from UUID
  String? getServiceName(String uuid) {
    final normalizedUuid = _normalizeUuid(uuid);

    // First try the loaded database if available
    if (_isLoaded) {
      final serviceName = _services[normalizedUuid];
      if (serviceName != null) return serviceName;
    }

    // Fall back to well-known services
    return _wellKnownServices[normalizedUuid];
  }

  /// Get characteristic name from UUID
  String? getCharacteristicName(String uuid) {
    final normalizedUuid = _normalizeUuid(uuid);

    // First try the loaded database if available
    if (_isLoaded) {
      final characteristicName = _characteristics[normalizedUuid];
      if (characteristicName != null) return characteristicName;
    }

    // Fall back to well-known characteristics
    return _wellKnownCharacteristics[normalizedUuid];
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

  /// Get appearance name from UUID
  String? getAppearanceName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _appearanceValues[normalizedUuid];
  }

  /// Get advertisement data type name from UUID
  String? getAdTypeName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _adTypes[normalizedUuid];
  }

  /// Get member UUID name
  String? getMemberUuidName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _memberUuids[normalizedUuid];
  }

  /// Get coding format name from identifier
  String? getCodingFormatName(String identifier) {
    if (!_isLoaded) return null;
    final normalizedId = _normalizeUuid(identifier);
    return _codingFormats[normalizedId];
  }

  /// Get mesh beacon type name from identifier
  String? getMeshBeaconTypeName(String identifier) {
    if (!_isLoaded) return null;
    final normalizedId = _normalizeUuid(identifier);
    return _meshBeacons[normalizedId];
  }

  /// Get URI scheme name from identifier
  String? getUriSchemeName(String identifier) {
    if (!_isLoaded) return null;
    final normalizedId = _normalizeUuid(identifier);
    return _uriSchemes[normalizedId];
  }

  /// Get DIAC (Device Identification and Configuration) name from identifier
  String? getDiacName(String identifier) {
    if (!_isLoaded) return null;
    final normalizedId = _normalizeUuid(identifier);
    return _diacs[normalizedId];
  }

  /// Get class of device service name from bit number
  String? getClassOfDeviceName(String bitNumber) {
    if (!_isLoaded) return null;
    return _classOfDevice[bitNumber];
  }

  /// Get PCM data format name from identifier
  String? getPcmFormatName(String identifier) {
    if (!_isLoaded) return null;
    final normalizedId = _normalizeUuid(identifier);
    return _pcmFormats[normalizedId];
  }

  /// Get transport layer name from identifier
  String? getTransportLayerName(String identifier) {
    if (!_isLoaded) return null;
    final normalizedId = _normalizeUuid(identifier);
    return _transportLayers[normalizedId];
  }

  /// Get protocol identifier name from UUID
  String? getProtocolIdentifierName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _protocolIdentifiers[normalizedUuid];
  }

  /// Get unit name from UUID
  String? getUnitName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _units[normalizedUuid];
  }

  /// Get declaration name from UUID
  String? getDeclarationName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _declarations[normalizedUuid];
  }

  /// Get object type name from UUID
  String? getObjectTypeName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _objectTypes[normalizedUuid];
  }

  /// Get browse group name from UUID
  String? getBrowseGroupName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _browseGroups[normalizedUuid];
  }

  /// Get service class name from UUID
  String? getServiceClassName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _serviceClasses[normalizedUuid];
  }

  /// Get mesh model name from UUID
  String? getMeshModelName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _meshModels[normalizedUuid];
  }

  /// Get mesh profile UUID name
  String? getMeshProfileUuidName(String uuid) {
    if (!_isLoaded) return null;
    final normalizedUuid = _normalizeUuid(uuid);
    return _meshProfileUuids[normalizedUuid];
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

  /// Get information about the current database state and any issues
  String getDatabaseStatus() {
    final buffer = StringBuffer();
    buffer.writeln('SIG Database Status:');
    buffer.writeln('  Services: ${_services.length}');
    buffer.writeln('  Characteristics: ${_characteristics.length}');
    buffer.writeln('  Descriptors: ${_descriptors.length}');
    buffer.writeln('  Company IDs: ${_companyIdentifiers.length}');
    buffer.writeln('  Member UUIDs: ${_memberUuids.length}');
    buffer.writeln('  Appearance Values: ${_appearanceValues.length}');
    buffer.writeln('  AD Types: ${_adTypes.length}');
    buffer.writeln('  Coding Formats: ${_codingFormats.length}');
    buffer.writeln('  Mesh Beacons: ${_meshBeacons.length}');
    buffer.writeln('  URI Schemes: ${_uriSchemes.length}');
    buffer.writeln('  DIACs: ${_diacs.length}');
    buffer.writeln('  Class of Device: ${_classOfDevice.length}');
    buffer.writeln('  PCM Formats: ${_pcmFormats.length}');
    buffer.writeln('  Transport Layers: ${_transportLayers.length}');
    buffer.writeln('  Protocol Identifiers: ${_protocolIdentifiers.length}');
    buffer.writeln('  Units: ${_units.length}');
    buffer.writeln('  Declarations: ${_declarations.length}');
    buffer.writeln('  Object Types: ${_objectTypes.length}');
    buffer.writeln('  Browse Groups: ${_browseGroups.length}');
    buffer.writeln('  Service Classes: ${_serviceClasses.length}');
    buffer.writeln('  Mesh Models: ${_meshModels.length}');
    buffer.writeln('  Mesh Profile UUIDs: ${_meshProfileUuids.length}');
    buffer.writeln('  Loaded: $_isLoaded');

    if (_services.length == _wellKnownServices.length &&
        _characteristics.length == _wellKnownCharacteristics.length) {
      buffer.writeln();
      buffer.writeln('INFO: Using well-known UUIDs only.');
      buffer.writeln('Extended database files not found in local storage.');
      buffer.writeln();
      buffer.writeln('To add more UUIDs:');
      buffer.writeln(
          '  1. Manually download Bluetooth SIG assigned numbers files');
      buffer.writeln('  2. Place YAML/JSON files in the app data directory');
      buffer.writeln(
          '  3. For now, the app will use ${_wellKnownServices.length} built-in services');
    } else {
      buffer.writeln();
      buffer.writeln('SUCCESS: Extended database loaded from local files.');
    }

    return buffer.toString();
  }

  /// Dispose of resources
  void dispose() {
    _servicesController.close();
    _characteristicsController.close();
    _downloadProgressController.close();
  }
}
