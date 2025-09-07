import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/app_lifecycle_service.dart';
import '../services/battery_service.dart';
import '../services/bluetooth_scanning_service.dart';
import '../services/data_export_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final BatteryService _batteryService = BatteryService();
  final BluetoothScanningService _scanningService = BluetoothScanningService();
  final DataExportService _exportService = DataExportService();
  final AppLifecycleService _lifecycleService = AppLifecycleService();

  AppSettings _settings = const AppSettings();
  int _currentBatteryLevel = 100;
  String _batteryStatusText = '';
  AppLifecycleState _currentLifecycleState = AppLifecycleState.resumed;

  StreamSubscription<AppSettings>? _settingsSubscription;
  StreamSubscription<int>? _batteryLevelSubscription;
  StreamSubscription<AppLifecycleState>? _lifecycleSubscription;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupStreams();
  }

  void _initializeData() {
    _settings = _settingsService.currentSettings;
    _currentBatteryLevel = _batteryService.currentBatteryLevel;
    _batteryStatusText = _batteryService.getBatteryStatusText();
    _currentLifecycleState = _lifecycleService.currentState;
  }

  void _setupStreams() {
    _settingsSubscription = _settingsService.settingsStream.listen((settings) {
      if (!mounted) return;

      setState(() {
        _settings = settings;
      });
    });

    _batteryLevelSubscription =
        _batteryService.batteryLevelStream.listen((level) {
      if (!mounted) return;

      setState(() {
        _currentBatteryLevel = level;
        _batteryStatusText = _batteryService.getBatteryStatusText();
      });
    });

    _lifecycleSubscription = _lifecycleService.lifecycleStream.listen((state) {
      if (!mounted) return;

      setState(() {
        _currentLifecycleState = state;
      });
    });
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _batteryLevelSubscription?.cancel();
    _lifecycleSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _initializeData();
              setState(() {});
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset to defaults'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAppStatusCard(),
          const SizedBox(height: 16),
          _buildBatteryStatusCard(),
          const SizedBox(height: 16),
          _buildScanningSettingsCard(),
          const SizedBox(height: 16),
          _buildBatteryOptimizationCard(),
          const SizedBox(height: 16),
          _buildAdvancedSettingsCard(),
          const SizedBox(height: 16),
          _buildDataManagementCard(),
        ],
      ),
    );
  }

  Widget _buildAppStatusCard() {
    final String lifecycleText = switch (_currentLifecycleState) {
      AppLifecycleState.resumed => 'Active',
      AppLifecycleState.paused => 'Background',
      AppLifecycleState.inactive => 'Inactive',
      AppLifecycleState.detached => 'Detached',
      AppLifecycleState.hidden => 'Hidden',
    };

    final Color statusColor = switch (_currentLifecycleState) {
      AppLifecycleState.resumed => Colors.green,
      AppLifecycleState.paused => Colors.orange,
      AppLifecycleState.inactive => Colors.yellow,
      AppLifecycleState.detached => Colors.red,
      AppLifecycleState.hidden => Colors.grey,
    };

    final IconData statusIcon = switch (_currentLifecycleState) {
      AppLifecycleState.resumed => Icons.smartphone,
      AppLifecycleState.paused => Icons.pause_circle,
      AppLifecycleState.inactive => Icons.pause,
      AppLifecycleState.detached => Icons.power_off,
      AppLifecycleState.hidden => Icons.visibility_off,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $lifecycleText',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      _currentLifecycleState == AppLifecycleState.paused
                          ? 'Background monitoring ${_settings.batteryOptimizationEnabled ? 'disabled' : 'enabled'}'
                          : 'Foreground monitoring active',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryStatusCard() {
    final Color batteryColor = _currentBatteryLevel > 50
        ? Colors.green
        : _currentBatteryLevel > 20
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Battery Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.battery_full,
                  color: batteryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _batteryStatusText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: batteryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_batteryService.isLowBattery)
                      Text(
                        'Low battery mode active',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scanning Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto Scanning'),
              subtitle: Text(_settings.autoScanningEnabled
                  ? 'Automatically scan for devices'
                  : 'Manual scanning only'),
              value: _settings.autoScanningEnabled,
              onChanged: (value) async {
                await _settingsService.updateAutoScanning(value);
                if (value) {
                  _scanningService.startContinuousScanning();
                  return;
                }

                _scanningService.stopContinuousScanning();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Auto Scan When Plugged In'),
              subtitle: Text(_settings.autoScanWhenPluggedIn
                  ? 'Automatically start scanning when device is charging'
                  : 'Manual control only'),
              value: _settings.autoScanWhenPluggedIn,
              onChanged: (value) async {
                await _settingsService.updateAutoScanWhenPluggedIn(value);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Scan Interval'),
              subtitle: Text('${_settings.scanIntervalSeconds} seconds'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showScanIntervalDialog(),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Location Tracking'),
              subtitle: const Text('Record GPS coordinates with discoveries'),
              value: _settings.locationTrackingEnabled,
              onChanged: (value) {
                _settingsService.updateLocationTracking(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryOptimizationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Battery Optimization',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto-disable at low battery'),
              subtitle: Text(_settings.batteryOptimizationEnabled
                  ? 'Stop scanning when battery is low'
                  : 'Continue scanning regardless of battery'),
              value: _settings.batteryOptimizationEnabled,
              onChanged: (value) {
                _settingsService.updateBatteryOptimization(value, null);
              },
            ),
            if (_settings.batteryOptimizationEnabled) ...[
              const Divider(),
              ListTile(
                title: const Text('Battery Threshold'),
                subtitle: Text(
                    'Stop scanning at ${_settings.batteryThresholdPercent}% battery'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${_settings.batteryThresholdPercent}%'),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => _showBatteryThresholdDialog(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Verbose Logging'),
              subtitle: const Text('Enable detailed debug output'),
              value: _settings.verboseLoggingEnabled,
              onChanged: (value) {
                _settingsService.updateVerboseLogging(value);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Show scanning status notifications'),
              value: _settings.showNotifications,
              onChanged: (value) {
                _settingsService.updateNotifications(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Data Retention'),
              subtitle:
                  Text('Keep data for ${_settings.dataRetentionDays} days'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDataRetentionDialog(),
            ),
            const Divider(),
            ListTile(
              title: const Text('Export Data'),
              subtitle: const Text('Export all data to JSON file'),
              leading: const Icon(Icons.download),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showExportDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showScanIntervalDialog() {
    int currentInterval = _settings.scanIntervalSeconds;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Scan Interval'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How often should the app scan for devices?'),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: currentInterval,
                isExpanded: true,
                items: [1, 2, 5, 10, 15, 30, 60, 120, 300].map((seconds) {
                  final String label = seconds < 60
                      ? '$seconds seconds'
                      : '${seconds ~/ 60} minute${seconds ~/ 60 > 1 ? 's' : ''}';
                  return DropdownMenuItem(value: seconds, child: Text(label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      currentInterval = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _settingsService.updateScanInterval(currentInterval);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatteryThresholdDialog() {
    int currentThreshold = _settings.batteryThresholdPercent;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Battery Threshold'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Stop scanning when battery level drops below:'),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: currentThreshold,
                isExpanded: true,
                items: [5, 10, 15, 20, 25, 30].map((percent) {
                  return DropdownMenuItem(
                      value: percent, child: Text('$percent%'));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      currentThreshold = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _settingsService.updateBatteryOptimization(
                    true, currentThreshold);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataRetentionDialog() {
    int currentRetention = _settings.dataRetentionDays;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Data Retention'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How long should device data be kept?'),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: currentRetention,
                isExpanded: true,
                items: [7, 14, 30, 60, 90, 180, 365].map((days) {
                  final String label = days < 30
                      ? '$days days'
                      : days < 365
                          ? '${days ~/ 30} month${days ~/ 30 > 1 ? 's' : ''}'
                          : '1 year';
                  return DropdownMenuItem(value: days, child: Text(label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      currentRetention = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _settingsService.updateDataRetention(currentRetention);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _settingsService.resetToDefaults();
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
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
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed')),
        );
        return;
      }

      if (!mounted) return;

      // Show success dialog with sharing option
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
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _exportService.shareExportedFile(filePath);
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error sharing file: $e')),
                    );
                  }
                }
              },
              child: const Text('Share'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export error: $e')),
      );
    }
  }
}
