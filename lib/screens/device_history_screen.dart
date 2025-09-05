import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bluetooth_device_record.dart';
import '../services/bluetooth_scanning_service.dart';
import '../services/location_service.dart';
import '../config/scan_config.dart';

class DeviceHistoryScreen extends StatefulWidget {
  const DeviceHistoryScreen({super.key});

  @override
  State<DeviceHistoryScreen> createState() => _DeviceHistoryScreenState();
}

class _DeviceHistoryScreenState extends State<DeviceHistoryScreen> with TickerProviderStateMixin {
  final BluetoothScanningService _scanningService = BluetoothScanningService();
  final LocationService _locationService = LocationService();
  
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
      if (mounted) {
        setState(() {
          _totalDeviceCount = count;
        });
      }
    });

    _recentDevicesSubscription = _scanningService.recentDevicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _recentDevices = devices;
        });
      }
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
      print('Error loading data: $e');
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Device ID', device.deviceId),
                _buildDetailRow('Connectable', device.isConnectable ? 'Yes' : 'No'),
                if (device.latitude != null && device.longitude != null)
                  _buildDetailRow('Location', '${device.latitude!.toStringAsFixed(6)}, ${device.longitude!.toStringAsFixed(6)}'),
                if (device.manufacturerData != null)
                  _buildDetailRow('Manufacturer Data', device.manufacturerData!),
                if (device.serviceUuids != null)
                  _buildDetailRow('Service UUIDs', device.serviceUuids!),
              ],
            ),
          ),
        ],
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
            onSelected: (value) async {
              switch (value) {
                case 'clear_all':
                  _showClearDataDialog();
                  break;
                case 'cleanup_old':
                  await _scanningService.cleanupOldData(daysToKeep: ScanConfig.cleanupDataRetentionDays);
                  _initializeData();
                  break;
              }
            },
            itemBuilder: (context) => [
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

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to delete all stored device data? This action cannot be undone.'),
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
}
