import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'app_lifecycle_service.dart';
import 'battery_service.dart';
import 'bluetooth_adapter_service.dart';
import 'bluetooth_scanning_service.dart';
import 'logging_service.dart';
import 'navigation_observer_service.dart';
import 'oui_service.dart';
import 'settings_service.dart';

/// Interface for app initialization and configuration
abstract class AppConfigurationInterface {
  Future<void> initializeServices();
  BluetoothAdapterInterface get bluetoothAdapter;
  BluetoothNavigationObserverInterface createNavigationObserver();
}

/// Production implementation of app configuration
class AppConfiguration implements AppConfigurationInterface {
  late final BluetoothAdapterInterface _bluetoothAdapter;

  AppConfiguration() {
    _bluetoothAdapter = FlutterBluePlusAdapter();
  }

  @override
  Future<void> initializeServices() async {
    // Initialize logging first
    LoggingService().initialize();
    log.info('🚀 Blufie app starting up...');

    // Initialize core services
    await SettingsService().initialize();
    await BatteryService().initialize();
    await BluetoothScanningService().initialize();
    await OuiService().initialize();

    // Initialize app lifecycle monitoring
    AppLifecycleService().initialize();

    _bluetoothAdapter.setLogLevel(LogLevel.verbose);
    log.info('✅ All services initialized successfully');
  }

  @override
  BluetoothAdapterInterface get bluetoothAdapter => _bluetoothAdapter;

  @override
  BluetoothNavigationObserverInterface createNavigationObserver() {
    return BluetoothAdapterStateObserver(bluetoothAdapter: _bluetoothAdapter);
  }

  void dispose() {
    AppLifecycleService().dispose();

    // Only log if the logging service has been initialized
    try {
      log.info('🔄 App services disposed');
    } catch (e) {
      // Logging service not initialized, ignore
    }
  }
}

/// Mock implementation for testing
class MockAppConfiguration implements AppConfigurationInterface {
  final MockBluetoothAdapter _mockBluetoothAdapter;
  bool _servicesInitialized = false;

  MockAppConfiguration({
    BluetoothAdapterState initialBluetoothState = BluetoothAdapterState.on,
  }) : _mockBluetoothAdapter =
            MockBluetoothAdapter(initialState: initialBluetoothState);

  @override
  Future<void> initializeServices() async {
    // Mock initialization - just set flag
    _servicesInitialized = true;
  }

  @override
  BluetoothAdapterInterface get bluetoothAdapter => _mockBluetoothAdapter;

  @override
  BluetoothNavigationObserverInterface createNavigationObserver() {
    return MockBluetoothNavigationObserver();
  }

  /// Test helper properties
  bool get servicesInitialized => _servicesInitialized;
  MockBluetoothAdapter get mockBluetoothAdapter => _mockBluetoothAdapter;

  void dispose() {
    _mockBluetoothAdapter.dispose();
  }
}
