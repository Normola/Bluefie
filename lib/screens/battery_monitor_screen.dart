import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

import '../services/battery_service.dart';
import '../services/bluetooth_scanning_service.dart';
import '../services/settings_service.dart';
import '../utils/snackbar.dart';

class BatteryMonitorScreen extends StatefulWidget {
  const BatteryMonitorScreen({super.key});

  @override
  State<BatteryMonitorScreen> createState() => _BatteryMonitorScreenState();
}

class _BatteryMonitorScreenState extends State<BatteryMonitorScreen>
    with TickerProviderStateMixin {
  // Services
  final BatteryService _batteryService = BatteryService();
  final BluetoothScanningService _scanningService = BluetoothScanningService();
  final SettingsService _settingsService = SettingsService();

  // State variables
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.unknown;
  bool _isLowBattery = false;
  bool _isCharging = false;
  bool _isScanning = false;

  // Battery monitoring data
  final List<BatteryReading> _batteryHistory = [];
  Timer? _historyTimer;

  // Animation controllers
  late AnimationController _batteryAnimationController;
  late AnimationController _scanningAnimationController;
  late Animation<double> _batteryAnimation;
  late Animation<double> _scanningAnimation;

  // Streams
  StreamSubscription<int>? _batteryLevelSubscription;
  StreamSubscription<bool>? _lowBatterySubscription;
  StreamSubscription<bool>? _chargingStateSubscription;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupStreams();
    _initializeData();
    _startHistoryTracking();
  }

  void _setupAnimations() {
    _batteryAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanningAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _batteryAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _batteryAnimationController, curve: Curves.easeInOut),
    );
    _scanningAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _scanningAnimationController, curve: Curves.easeInOut),
    );

    _batteryAnimationController.forward();
  }

  void _setupStreams() {
    _batteryLevelSubscription =
        _batteryService.batteryLevelStream.listen((level) {
      setState(() {
        _batteryLevel = level;
      });
    });

    _lowBatterySubscription = _batteryService.lowBatteryStream.listen((isLow) {
      setState(() {
        _isLowBattery = isLow;
      });
      if (isLow) {
        Snackbar.show(ABC.c, 'Low battery detected! Scanning may be limited.',
            success: false);
      }
    });

    _chargingStateSubscription =
        _batteryService.chargingStateStream.listen((isCharging) {
      setState(() {
        _isCharging = isCharging;
      });
    });
  }

  void _initializeData() {
    _batteryLevel = _batteryService.currentBatteryLevel;
    _batteryState = _batteryService.currentBatteryState;
    _isLowBattery = _batteryService.isLowBattery;
    _isCharging = _batteryService.isCharging;
    _isScanning = _scanningService.isScanning;

    if (_isScanning) {
      _scanningAnimationController.repeat();
    }
  }

  void _startHistoryTracking() {
    // Record initial reading
    _recordBatteryReading();

    // Record every 2 minutes
    _historyTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _recordBatteryReading();
    });
  }

  void _recordBatteryReading() {
    final reading = BatteryReading(
      timestamp: DateTime.now(),
      batteryLevel: _batteryLevel,
      isScanning: _isScanning,
      isCharging: _isCharging,
    );

    setState(() {
      _batteryHistory.add(reading);

      // Keep only last 2 hours of data (60 readings at 2-minute intervals)
      if (_batteryHistory.length > 60) {
        _batteryHistory.removeAt(0);
      }
    });
  }

  @override
  void dispose() {
    _batteryAnimationController.dispose();
    _scanningAnimationController.dispose();
    _batteryLevelSubscription?.cancel();
    _lowBatterySubscription?.cancel();
    _chargingStateSubscription?.cancel();
    _historyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Snackbar.snackBarKeyC,
      appBar: AppBar(
        title: const Text('Battery Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBatteryStatusCard(),
              const SizedBox(height: 16),
              _buildScanningStatusCard(),
              const SizedBox(height: 16),
              _buildBatteryOptimizationCard(),
              const SizedBox(height: 16),
              _buildBatteryHistoryCard(),
              const SizedBox(height: 16),
              _buildPowerConsumptionTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getBatteryIcon(),
                  color: _getBatteryColor(),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Battery Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _batteryAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    _buildBatteryLevelIndicator(),
                    const SizedBox(height: 12),
                    _buildBatteryDetails(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryLevelIndicator() {
    final displayLevel = (_batteryLevel * _batteryAnimation.value).round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$displayLevel%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _getBatteryColor(),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              _getBatteryStateText(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _isCharging ? Colors.green : null,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: displayLevel / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getBatteryColor()),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildBatteryDetails() {
    return Column(
      children: [
        if (_isLowBattery)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Low battery mode active. Scanning may be limited.',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ],
            ),
          ),
        if (_isCharging)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.electrical_services,
                    color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Device is charging. Scanning restrictions lifted.',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScanningStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _scanningAnimation,
                  builder: (context, child) {
                    return Icon(
                      Icons.bluetooth_searching,
                      color: _isScanning
                          ? Color.lerp(Colors.blue, Colors.blueAccent,
                              _scanningAnimation.value)
                          : Colors.grey,
                      size: 28,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  'Scanning Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bluetooth Scanning:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  _isScanning ? 'Active' : 'Inactive',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _isScanning ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Battery Impact:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  _getScanningBatteryImpact(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _getScanningImpactColor(),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            if (_isScanning && _isLowBattery)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scanning with low battery may drain power quickly.',
                        style: TextStyle(color: Colors.orange[700]),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryOptimizationCard() {
    final settings = _settingsService.currentSettings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Battery Optimization',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Optimization Enabled:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  settings.batteryOptimizationEnabled ? 'Yes' : 'No',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: settings.batteryOptimizationEnabled
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low Battery Threshold:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${settings.batteryThresholdPercent}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Auto-scan when plugged:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  settings.autoScanWhenPluggedIn ? 'Yes' : 'No',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: settings.autoScanWhenPluggedIn
                            ? Colors.green
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryHistoryCard() {
    if (_batteryHistory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.history, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Battery History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('No battery history data available yet.'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Battery History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildBatteryChart(),
            ),
            const SizedBox(height: 16),
            _buildHistoryLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryChart() {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: BatteryChartPainter(_batteryHistory),
    );
  }

  Widget _buildHistoryLegend() {
    return Row(
      children: [
        _buildLegendItem(Colors.blue, 'Battery Level'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.green, 'Scanning Active'),
        const SizedBox(width: 16),
        _buildLegendItem(Colors.orange, 'Charging'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPowerConsumptionTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Power Saving Tips',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTip(
                'Enable battery optimization to pause scanning when battery is low'),
            _buildTip('Use continuous scanning only when necessary'),
            _buildTip(
                'Keep the device plugged in during extended scanning sessions'),
            _buildTip(
                'Lower the scan frequency in settings to reduce power consumption'),
            _buildTip('Close other apps while scanning to preserve battery'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chevron_right, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    // Refresh battery data
    await _batteryService.initialize();

    // Update state
    setState(() {
      _batteryLevel = _batteryService.currentBatteryLevel;
      _batteryState = _batteryService.currentBatteryState;
      _isLowBattery = _batteryService.isLowBattery;
      _isCharging = _batteryService.isCharging;
      _isScanning = _scanningService.isScanning;
    });

    // Update animation state
    if (_isScanning && !_scanningAnimationController.isAnimating) {
      _scanningAnimationController.repeat();
    } else if (!_isScanning && _scanningAnimationController.isAnimating) {
      _scanningAnimationController.stop();
    }

    // Record current reading
    _recordBatteryReading();

    Snackbar.show(ABC.c, 'Battery data refreshed', success: true);
  }

  IconData _getBatteryIcon() {
    if (_isCharging) return Icons.battery_charging_full;

    if (_batteryLevel >= 90) return Icons.battery_full;
    if (_batteryLevel >= 60) return Icons.battery_6_bar;
    if (_batteryLevel >= 50) return Icons.battery_5_bar;
    if (_batteryLevel >= 30) return Icons.battery_3_bar;
    if (_batteryLevel >= 20) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  Color _getBatteryColor() {
    if (_isCharging) return Colors.green;
    if (_batteryLevel <= 20) return Colors.red;
    if (_batteryLevel <= 30) return Colors.orange;
    return Colors.green;
  }

  String _getBatteryStateText() {
    switch (_batteryState) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.connectedNotCharging:
        return 'Connected';
      case BatteryState.unknown:
        return 'Unknown';
    }
  }

  String _getScanningBatteryImpact() {
    if (!_isScanning) return 'None';
    if (_isCharging) return 'Low (Charging)';
    if (_batteryLevel > 50) return 'Moderate';
    if (_batteryLevel > 20) return 'High';
    return 'Very High';
  }

  Color _getScanningImpactColor() {
    if (!_isScanning) return Colors.grey;
    if (_isCharging) return Colors.green;
    if (_batteryLevel > 50) return Colors.orange;
    if (_batteryLevel > 20) return Colors.red;
    return Colors.red[900]!;
  }
}

class BatteryReading {
  final DateTime timestamp;
  final int batteryLevel;
  final bool isScanning;
  final bool isCharging;

  BatteryReading({
    required this.timestamp,
    required this.batteryLevel,
    required this.isScanning,
    required this.isCharging,
  });
}

class BatteryChartPainter extends CustomPainter {
  final List<BatteryReading> readings;

  BatteryChartPainter(this.readings);

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final scanningPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final chargingPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw battery level line
    paint.color = Colors.blue;
    final batteryPath = Path();

    for (int i = 0; i < readings.length; i++) {
      final x = (i / (readings.length - 1)) * size.width;
      final y = size.height - (readings[i].batteryLevel / 100) * size.height;

      if (i == 0) {
        batteryPath.moveTo(x, y);
      } else {
        batteryPath.lineTo(x, y);
      }
    }

    canvas.drawPath(batteryPath, paint);

    // Draw scanning indicators
    for (int i = 0; i < readings.length - 1; i++) {
      if (readings[i].isScanning) {
        final x1 = (i / (readings.length - 1)) * size.width;
        final x2 = ((i + 1) / (readings.length - 1)) * size.width;
        final rect = Rect.fromLTRB(x1, 0, x2, size.height);
        canvas.drawRect(rect, scanningPaint);
      }
    }

    // Draw charging indicators
    for (int i = 0; i < readings.length - 1; i++) {
      if (readings[i].isCharging) {
        final x1 = (i / (readings.length - 1)) * size.width;
        final x2 = ((i + 1) / (readings.length - 1)) * size.width;
        final rect = Rect.fromLTRB(x1, size.height * 0.9, x2, size.height);
        canvas.drawRect(rect, chargingPaint);
      }
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
