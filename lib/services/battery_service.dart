import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class BatteryService {
  static final BatteryService _instance = BatteryService._internal();
  factory BatteryService() => _instance;
  BatteryService._internal();

  final Battery _battery = Battery();
  final SettingsService _settingsService = SettingsService();
  
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  Timer? _batteryLevelTimer;
  
  int _currentBatteryLevel = 100;
  BatteryState _currentBatteryState = BatteryState.unknown;
  bool _lowBatteryTriggered = false;
  
  final StreamController<int> _batteryLevelController = 
      StreamController<int>.broadcast();
  final StreamController<bool> _lowBatteryController = 
      StreamController<bool>.broadcast();

  // Streams for UI updates
  Stream<int> get batteryLevelStream => _batteryLevelController.stream;
  Stream<bool> get lowBatteryStream => _lowBatteryController.stream;
  
  int get currentBatteryLevel => _currentBatteryLevel;
  BatteryState get currentBatteryState => _currentBatteryState;
  bool get isLowBattery => _lowBatteryTriggered;

  Future<void> initialize() async {
    await _updateBatteryLevel();
    _startBatteryMonitoring();
  }

  void _startBatteryMonitoring() {
    // Monitor battery state changes
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((state) {
      _currentBatteryState = state;
      _checkLowBatteryCondition();
    });

    // Check battery level every 30 seconds
    _batteryLevelTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateBatteryLevel();
    });
  }

  Future<void> _updateBatteryLevel() async {
    try {
      _currentBatteryLevel = await _battery.batteryLevel;
      _batteryLevelController.add(_currentBatteryLevel);
      _checkLowBatteryCondition();
    } catch (e) {
      print('Error getting battery level: $e');
    }
  }

  void _checkLowBatteryCondition() {
    final settings = _settingsService.currentSettings;
    
    if (!settings.batteryOptimizationEnabled) {
      if (_lowBatteryTriggered) {
        _lowBatteryTriggered = false;
        _lowBatteryController.add(false);
      }
      return;
    }

    bool shouldTriggerLowBattery = _currentBatteryLevel <= settings.batteryThresholdPercent &&
                                   _currentBatteryState != BatteryState.charging;

    if (shouldTriggerLowBattery && !_lowBatteryTriggered) {
      _lowBatteryTriggered = true;
      _lowBatteryController.add(true);
      print('Low battery detected: ${_currentBatteryLevel}% - Threshold: ${settings.batteryThresholdPercent}%');
    } else if (!shouldTriggerLowBattery && _lowBatteryTriggered) {
      _lowBatteryTriggered = false;
      _lowBatteryController.add(false);
      print('Battery level recovered: ${_currentBatteryLevel}%');
    }
  }

  bool shouldStopScanning() {
    final settings = _settingsService.currentSettings;
    return settings.batteryOptimizationEnabled && 
           _currentBatteryLevel <= settings.batteryThresholdPercent &&
           _currentBatteryState != BatteryState.charging;
  }

  String getBatteryStatusText() {
    String stateText = '';
    switch (_currentBatteryState) {
      case BatteryState.charging:
        stateText = ' (Charging)';
        break;
      case BatteryState.discharging:
        stateText = ' (Discharging)';
        break;
      case BatteryState.full:
        stateText = ' (Full)';
        break;
      case BatteryState.unknown:
        stateText = '';
        break;
    }
    
    return '$_currentBatteryLevel%$stateText';
  }

  void dispose() {
    _batteryStateSubscription?.cancel();
    _batteryLevelTimer?.cancel();
    _batteryLevelController.close();
    _lowBatteryController.close();
  }
}
