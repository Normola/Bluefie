import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_screen.dart';
import 'device_history_screen.dart';
import 'settings_screen.dart';
import '../utils/snackbar.dart';
import '../widgets/system_device_tile.dart';
import '../widgets/scan_result_tile.dart';
import '../utils/extra.dart';
import '../services/bluetooth_scanning_service.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../services/battery_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _continuousScanning = false;
  int _storedDeviceCount = 0;
  int _batteryLevel = 100;
  bool _isLowBattery = false;
  
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  StreamSubscription<int>? _deviceCountSubscription;
  StreamSubscription<int>? _batteryLevelSubscription;
  StreamSubscription<bool>? _lowBatterySubscription;
  
  final BluetoothScanningService _scanningService = BluetoothScanningService();
  final LocationService _locationService = LocationService();
  final SettingsService _settingsService = SettingsService();
  final BatteryService _batteryService = BatteryService();

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });

    // Listen to device count updates from the scanning service
    _deviceCountSubscription = _scanningService.deviceCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _storedDeviceCount = count;
        });
      }
    });

    // Listen to battery level updates
    _batteryLevelSubscription = _batteryService.batteryLevelStream.listen((level) {
      if (mounted) {
        setState(() {
          _batteryLevel = level;
        });
      }
    });

    // Listen to low battery alerts
    _lowBatterySubscription = _batteryService.lowBatteryStream.listen((isLowBattery) {
      if (mounted) {
        setState(() {
          _isLowBattery = isLowBattery;
        });
        if (isLowBattery && _continuousScanning) {
          Snackbar.show(ABC.b, "Scanning stopped due to low battery", success: false);
          _continuousScanning = false;
        }
      }
    });

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Request location permissions
    bool locationPermissionGranted = await _locationService.requestPermissions();
    if (!locationPermissionGranted) {
      Snackbar.show(ABC.b, "Location permission required for accurate device tracking", success: false);
    }

    // Get initial values
    _storedDeviceCount = await _scanningService.getTotalDeviceCount();
    _batteryLevel = _batteryService.currentBatteryLevel;
    _isLowBattery = _batteryService.isLowBattery;
    _continuousScanning = _scanningService.isServiceRunning;
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    _deviceCountSubscription?.cancel();
    _batteryLevelSubscription?.cancel();
    _lowBatterySubscription?.cancel();
    super.dispose();
  }

  Future onScanPressed() async {
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      var withServices = [Guid("180f")]; // Battery Level Service
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e),
          success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onToggleContinuousScanning() async {
    if (_continuousScanning) {
      await _scanningService.stopContinuousScanning();
      _continuousScanning = false;
      await _settingsService.updateAutoScanning(false);
      Snackbar.show(ABC.b, "Continuous scanning stopped", success: true);
    } else {
      if (_batteryService.shouldStopScanning()) {
        Snackbar.show(ABC.b, 
          "Cannot start scanning: Battery level too low ($_batteryLevel%)", 
          success: false);
        return;
      }
      
      bool started = await _scanningService.startContinuousScanning();
      if (started) {
        _continuousScanning = true;
        await _settingsService.updateAutoScanning(true);
        Snackbar.show(ABC.b, "Continuous scanning started", success: true);
      } else {
        Snackbar.show(ABC.b, "Failed to start continuous scanning", success: false);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e),
          success: false);
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e),
          success: false);
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DeviceScreen(device: device),
        settings: RouteSettings(name: '/DeviceScreen'));
    Navigator.of(context).push(route);
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
          onPressed: onScanPressed, child: const Text("SCAN"));
    }
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      _storedDeviceCount.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const Text('Devices Stored'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _scanResults.length.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Current Scan'),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _batteryLevel > 50 ? Icons.battery_full :
                          _batteryLevel > 20 ? Icons.battery_std :
                          Icons.battery_alert,
                          color: _isLowBattery ? Colors.red : 
                                 _batteryLevel > 50 ? Colors.green : Colors.orange,
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
                    Text(_isLowBattery ? 'Low Battery' : 'Battery'),
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
                    icon: Icon(_continuousScanning ? Icons.stop : Icons.play_arrow),
                    label: Text(_continuousScanning ? 'Stop Auto Scan' : 'Start Auto Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _continuousScanning ? Colors.red : 
                                      _isLowBattery ? Colors.grey : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const DeviceHistoryScreen()),
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
                settings: RouteSettings(name: '/DeviceScreen'),
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blufie Scanner'),
          actions: [
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () async {
                var position = await _locationService.getCurrentLocation();
                if (position != null) {
                  Snackbar.show(ABC.b, 
                    "Location: ${_locationService.getLocationString(position)}", 
                    success: true);
                } else {
                  Snackbar.show(ABC.b, "Could not get location", success: false);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
            ],
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
