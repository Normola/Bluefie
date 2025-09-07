import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/bluetooth_device_record.dart';
import '../services/battery_service.dart';
import '../services/bluetooth_scanning_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../utils/extra.dart';
import '../utils/snackbar.dart';
import '../widgets/scan_result_tile.dart';
import '../widgets/system_device_tile.dart';
import 'battery_monitor_screen.dart';
import 'device_history_screen.dart';
import 'device_screen.dart';
import 'settings_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  List<BluetoothDeviceRecord> _recentDevices = [];
  bool _isScanning = false;
  bool _continuousScanning = false;
  int _storedDeviceCount = 0;
  int _batteryLevel = 100;
  bool _isLowBattery = false;
  bool _isCharging = false;

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  StreamSubscription<int>? _deviceCountSubscription;
  StreamSubscription<List<BluetoothDeviceRecord>>? _recentDevicesSubscription;
  StreamSubscription<int>? _batteryLevelSubscription;
  StreamSubscription<bool>? _lowBatterySubscription;
  StreamSubscription<bool>? _chargingStateSubscription;

  final BluetoothScanningService _scanningService = BluetoothScanningService();
  final LocationService _locationService = LocationService();
  final SettingsService _settingsService = SettingsService();
  final BatteryService _batteryService = BatteryService();

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (!mounted) return;

      setState(() {});
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException('Scan Error:', e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (!mounted) return;

      setState(() {});
    });

    // Listen to device count updates from the scanning service
    _deviceCountSubscription =
        _scanningService.deviceCountStream.listen((count) {
      if (!mounted) return;

      setState(() {
        _storedDeviceCount = count;
      });
    });

    // Listen to recent devices from background scanning
    _recentDevicesSubscription =
        _scanningService.recentDevicesStream.listen((devices) {
      if (!mounted) return;

      setState(() {
        _recentDevices = devices;
      });
    });

    // Listen to battery level updates
    _batteryLevelSubscription =
        _batteryService.batteryLevelStream.listen((level) {
      if (!mounted) return;

      setState(() {
        _batteryLevel = level;
      });
    });

    // Listen to low battery alerts
    _lowBatterySubscription =
        _batteryService.lowBatteryStream.listen((isLowBattery) {
      if (!mounted) return;

      setState(() {
        _isLowBattery = isLowBattery;
      });
      if (isLowBattery && _continuousScanning) {
        Snackbar.show(ABC.b, 'Scanning stopped due to low battery',
            success: false);
        _continuousScanning = false;
      }
    });

    // Listen to charging state changes
    _chargingStateSubscription =
        _batteryService.chargingStateStream.listen((isCharging) {
      if (!mounted) return;

      setState(() {
        _isCharging = isCharging;
      });
    });

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Request location permissions
    final bool locationPermissionGranted =
        await _locationService.requestPermissions();
    if (!locationPermissionGranted) {
      Snackbar.show(
          ABC.b, 'Location permission required for accurate device tracking',
          success: false);
    }

    // Get initial values
    _storedDeviceCount = await _scanningService.getTotalDeviceCount();
    _batteryLevel = _batteryService.currentBatteryLevel;
    _isLowBattery = _batteryService.isLowBattery;
    _isCharging = _batteryService.isCharging;
    _continuousScanning = _scanningService.isServiceRunning;

    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    _deviceCountSubscription?.cancel();
    _recentDevicesSubscription?.cancel();
    _batteryLevelSubscription?.cancel();
    _lowBatterySubscription?.cancel();
    _chargingStateSubscription?.cancel();
    super.dispose();
  }

  Future onScanPressed() async {
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      final withServices = [Guid('180f')]; // Battery Level Service
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException('System Devices Error:', e),
          success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.b, prettyException('Start Scan Error:', e),
          success: false);
    }
    if (!mounted) return;

    setState(() {});
  }

  Future<void> onToggleContinuousScanning() async {
    if (_continuousScanning) {
      await _scanningService.stopContinuousScanning();
      _continuousScanning = false;
      await _settingsService.updateAutoScanning(false);
      Snackbar.show(ABC.b, 'Continuous scanning stopped', success: true);
      if (!mounted) return;
      setState(() {});
      return;
    }

    if (_batteryService.shouldStopScanning()) {
      Snackbar.show(ABC.b,
          'Cannot start scanning: Battery level too low ($_batteryLevel%)',
          success: false);
      return;
    }

    final bool started = await _scanningService.startContinuousScanning();
    if (started) {
      _continuousScanning = true;
      await _settingsService.updateAutoScanning(true);
      Snackbar.show(ABC.b, 'Continuous scanning started', success: true);
    }
    if (!started) {
      Snackbar.show(ABC.b, 'Failed to start continuous scanning',
          success: false);
    }
    if (!mounted) return;

    setState(() {});
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException('Stop Scan Error:', e),
          success: false);
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException('Connect Error:', e),
          success: false);
    });
    final MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DeviceScreen(device: device),
        settings: const RouteSettings(name: '/DeviceScreen'));
    Navigator.of(context).push(route);
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (!mounted) return Future.delayed(const Duration(milliseconds: 500));

    setState(() {});
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton.extended(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.stop),
        label: const Text('STOP'),
      );
    }

    return FloatingActionButton.extended(
        onPressed: onScanPressed,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.radar),
        label: const Text('SCAN'));
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Scanning status banner
            if (_isScanning || _continuousScanning)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: (_isScanning ? Colors.blue : Colors.green)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: _isScanning ? Colors.blue : Colors.green,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isScanning ? Colors.blue : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _isScanning
                            ? '🔍 Active Scan in Progress'
                            : '🔄 Continuous Scanning Active',
                        style: TextStyle(
                          color: _isScanning ? Colors.blue : Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      _storedDeviceCount.toString(),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                    ),
                    const Text('Devices Stored'),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // Show combined count: foreground scan results + recent background devices
                          (_scanResults.length + _recentDevices.length)
                              .toString(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                        // Add scanning icon next to current scan count
                        if (_isScanning) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.radar,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ],
                        // Add background scan indicator
                        if (_continuousScanning && !_isScanning) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.refresh,
                            color: Colors.green,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    Text(_isScanning
                        ? 'Active Scan'
                        : _continuousScanning
                            ? 'Background Scan'
                            : 'Current Scan'),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCharging
                              ? Icons.battery_charging_full
                              : _batteryLevel > 50
                                  ? Icons.battery_full
                                  : _batteryLevel > 20
                                      ? Icons.battery_std
                                      : Icons.battery_alert,
                          color: _isCharging
                              ? Colors.green
                              : _isLowBattery
                                  ? Colors.red
                                  : _batteryLevel > 50
                                      ? Colors.green
                                      : Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_batteryLevel%',
                          style: TextStyle(
                            color: _isLowBattery ? Colors.red : null,
                            fontWeight: _isLowBattery ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                    Text(_isCharging
                        ? 'Charging'
                        : _isLowBattery
                            ? 'Low Battery'
                            : 'Battery'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onToggleContinuousScanning,
                    icon: Icon(
                        _continuousScanning ? Icons.stop : Icons.play_arrow),
                    label: Text(_continuousScanning
                        ? 'Stop Auto Scan'
                        : 'Start Auto Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _continuousScanning
                          ? Colors.red
                          : _isLowBattery
                              ? Colors.grey
                              : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const DeviceHistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('View History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DeviceScreen(device: d),
                settings: const RouteSettings(name: '/DeviceScreen'),
              ),
            ),
            onConnect: () => onConnectPressed(d),
          ),
        )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }

  List<Widget> _buildRecentDeviceTiles(BuildContext context) {
    if (_recentDevices.isEmpty) return [];

    final List<Widget> tiles = [];

    // Add header for recent devices section
    tiles.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Row(
          children: [
            Icon(
              Icons.history,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _scanResults.isNotEmpty
                  ? 'Recent Background Devices (${_recentDevices.length})'
                  : 'Background Scan Results (${_recentDevices.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );

    // Add device tiles
    tiles.addAll(_recentDevices.map((device) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: ListTile(
          leading: Icon(
            device.isConnectable ? Icons.bluetooth : Icons.bluetooth_disabled,
            color: device.isConnectable ? Colors.blue : Colors.grey,
          ),
          title: Text(
            device.deviceName.isNotEmpty ? device.deviceName : 'Unknown Device',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MAC: ${device.macAddress}'),
              Text('RSSI: ${device.rssi} dBm'),
              Text('Found: ${_formatTimestamp(device.timestamp)}'),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi,
                color: device.rssi > -50
                    ? Colors.green
                    : device.rssi > -70
                        ? Colors.orange
                        : Colors.red,
              ),
              Text(
                '${device.rssi}',
                style: TextStyle(
                  fontSize: 12,
                  color: device.rssi > -50
                      ? Colors.green
                      : device.rssi > -70
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ],
          ),
          onTap: () {
            // Show device details
            Snackbar.show(ABC.b,
                'Background scan device: ${device.deviceName.isNotEmpty ? device.deviceName : device.macAddress}',
                success: true);
          },
        ),
      );
    }).toList());

    return tiles;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(
                child: Text(
                  'Blufie Scanner',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Active scanning indicator
              if (_isScanning || _continuousScanning)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isScanning ? Colors.blue : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _isScanning ? 'Scanning...' : 'Auto Scan',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isScanning ? Colors.blue : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            // Scanning status icon in the app bar
            if (_isScanning || _continuousScanning)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    child: Icon(
                      _isScanning ? Icons.radar : Icons.refresh,
                      color: _isScanning ? Colors.blue : Colors.green,
                      size: 24,
                    ),
                  ),
                  onPressed: () {
                    // Show scanning status info
                    final String message = _isScanning
                        ? 'Active scan in progress...'
                        : 'Continuous scanning enabled';
                    Snackbar.show(ABC.b, message, success: true);
                  },
                  tooltip: _isScanning ? 'Active Scan' : 'Continuous Scan',
                ),
              ),
            IconButton(
              icon: const Icon(Icons.battery_std),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const BatteryMonitorScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () async {
                final position = await _locationService.getCurrentLocation();
                if (position != null) {
                  Snackbar.show(ABC.b,
                      'Location: ${_locationService.getLocationString(position)}',
                      success: true);
                  return;
                }

                Snackbar.show(ABC.b, 'Could not get location', success: false);
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              _buildStatsCard(),
              ..._buildSystemDeviceTiles(context),
              ..._buildScanResultTiles(context),
              ..._buildRecentDeviceTiles(context),
            ],
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
