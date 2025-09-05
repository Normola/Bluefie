import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/scan_config.dart';
import '../models/bluetooth_device_record.dart';
import '../services/bluetooth_scanning_service.dart';
import '../services/data_export_service.dart';
import '../services/location_service.dart';
import '../services/logging_service.dart';
import 'device_location_map_screen.dart';

class DeviceHistoryScreen extends StatefulWidget {
  const DeviceHistoryScreen({super.key});

  @override
  State<DeviceHistoryScreen> createState() => _DeviceHistoryScreenState();
}

class _DeviceHistoryScreenState extends State<DeviceHistoryScreen> with TickerProviderStateMixin {
  final BluetoothScanningService _scanningService = BluetoothScanningService();
  final LocationService _locationService = LocationService();
  final DataExportService _exportService = DataExportService();

  late TabController _tabController;

  List<BluetoothDeviceRecord> _allDevices = [];
  List<BluetoothDeviceRecord> _uniqueDevices = [];
  List<BluetoothDeviceRecord> _recentDevices = [];

  int _totalDeviceCount = 0;
  int _uniqueDeviceCount = 0;
  bool _isLoading = true;

  StreamSubscription<int>? _deviceCountSubscription;
  StreamSubscription<List<BluetoothDeviceRecord>>? _recentDevicesSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
    _setupStreams();
  }

  void _setupStreams() {
    _deviceCountSubscription = _scanningService.deviceCountStream.listen((count) {
      if (!mounted) return;

      setState(() {
        _totalDeviceCount = count;
      });
    });

    _recentDevicesSubscription = _scanningService.recentDevicesStream.listen((devices) {
      if (!mounted) return;

      setState(() {
        _recentDevices = devices;
      });
    });
  }

  Future<void> _initializeData() async {
    try {
      final results = await Future.wait([
        _scanningService.getAllStoredDevices(),
        _scanningService.getUniqueDevices(),
        _scanningService.getTotalDeviceCount(),
        _scanningService.getUniqueDeviceCount(),
      ]);

      setState(() {
        _allDevices = results[0] as List<BluetoothDeviceRecord>;
        _uniqueDevices = results[1] as List<BluetoothDeviceRecord>;
        _totalDeviceCount = results[2] as int;
        _uniqueDeviceCount = results[3] as int;
        _isLoading = false;
      });
    } catch (e) {
      log.error('Error loading data', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _deviceCountSubscription?.cancel();
    _recentDevicesSubscription?.cancel();
    super.dispose();
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scanning Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Scans', _totalDeviceCount.toString()),
                _buildStatItem('Unique Devices', _uniqueDeviceCount.toString()),
                _buildStatItem('Scanning', _scanningService.isScanning ? 'Active' : 'Inactive'),
              ],
            ),
            const SizedBox(height: 16),
            if (_locationService.currentPosition != null)
              Text(
                'Current Location: ${_locationService.getLocationString(_locationService.currentPosition)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDeviceList(List<BluetoothDeviceRecord> devices) {
    if (devices.isEmpty) {
      return const Center(
        child: Text('No devices found'),
      );
    }

    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildDeviceCard(BluetoothDeviceRecord device) {
    final formatter = DateFormat('MMM dd, yyyy HH:mm:ss');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ExpansionTile(
        title: Text(
          device.deviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MAC: ${device.macAddress}'),
            Text('RSSI: ${device.rssi} dBm'),
            Text('Time: ${formatter.format(device.timestamp)}'),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: _getRssiColor(device.rssi),
          child: Text(
            device.rssi.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (device.latitude != null && device.longitude != null)
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () => _openDeviceMap(device),
                tooltip: 'View locations on map',
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Device ID', device.deviceId),
                _buildDetailRow('Connectable', device.isConnectable ? 'Yes' : 'No'),
                if (device.latitude != null && device.longitude != null)
                  _buildDetailRow('Location',
                      '${device.latitude!.toStringAsFixed(6)}, ${device.longitude!.toStringAsFixed(6)}'),
                if (device.manufacturerData != null)
                  _buildDetailRow('Manufacturer Data', device.manufacturerData!),
                if (device.serviceUuids != null)
                  _buildDetailRow('Service UUIDs', device.serviceUuids!),
                const SizedBox(height: 12),
                if (device.latitude != null && device.longitude != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openDeviceMap(device),
                      icon: const Icon(Icons.map),
                      label: const Text('View All Locations'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDeviceMap(BluetoothDeviceRecord device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeviceLocationMapScreen(
          deviceName: device.deviceName,
          macAddress: device.macAddress,
        ),
      ),
    );
  }

  void _showAllDeviceLocationsMap() {
    // Find the device with the most recent location data
    BluetoothDeviceRecord? deviceWithLocation;
    for (final device in _uniqueDevices) {
      if (device.latitude != null && device.longitude != null) {
        deviceWithLocation = device;
        break;
      }
    }

    if (deviceWithLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No devices with location data found'),
        ),
      );
      return;
    }

    // For now, open the most recent device with location data
    // In the future, this could open a combined map view
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeviceLocationMapScreen(
          deviceName: 'All Devices',
          macAddress: deviceWithLocation!.macAddress,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getRssiColor(int rssi) {
    if (rssi > -50) return Colors.green;
    if (rssi > -70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Device History'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'All Devices'),
            Tab(text: 'Unique'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _initializeData();
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_all_locations',
                child: Row(
                  children: [
                    Icon(Icons.map),
                    SizedBox(width: 8),
                    Text('View All Locations'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_data',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export to JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cleanup_old',
                child: Text('Clean old data (${ScanConfig.cleanupDataRetentionDays}+ days)'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all data'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDeviceList(_recentDevices),
                _buildDeviceList(_allDevices),
                _buildDeviceList(_uniqueDevices),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuSelection(String value) async {
    switch (value) {
      case 'view_all_locations':
        _showAllDeviceLocationsMap();
        break;
      case 'export_data':
        _showExportDialog();
        break;
      case 'clear_all':
        _showClearDataDialog();
        break;
      case 'cleanup_old':
        await _scanningService.cleanupOldData(daysToKeep: ScanConfig.cleanupDataRetentionDays);
        _initializeData();
        break;
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
            'Are you sure you want to delete all stored device data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _scanningService.clearAllData();
              _initializeData();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export all Bluetooth device data to a JSON file.'),
            SizedBox(height: 16),
            Text('The export will include:'),
            Text('• All device scan records'),
            Text('• Device statistics'),
            Text('• App settings'),
            Text('• System information'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performDataExport();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDataExport() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting data...'),
            ],
          ),
        ),
      );

      // Perform the export
      final String? filePath = await _exportService.exportAllDataToJson();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (filePath == null) {
        _showExportError('Export failed');
        return;
      }

      _showExportSuccess(filePath);
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      // Show error message
      _showExportError('Export error: $e');
    }
  }

  void _showExportSuccess(String filePath) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data exported successfully!'),
            const SizedBox(height: 8),
            Text('File: ${filePath.split('/').last}'),
            const SizedBox(height: 8),
            Text('Location: $filePath'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () => _shareExportedFile(filePath),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareExportedFile(String filePath) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _exportService.shareExportedFile(filePath);
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text('Error sharing file: $e')),
      );
    }
  }

  void _showExportError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
