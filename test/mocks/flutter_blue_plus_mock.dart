import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mockito/mockito.dart';

// Mock classes for FlutterBluePlus
class MockFlutterBluePlus extends Mock {
  static StreamController<BluetoothAdapterState>? _adapterStateController;

  static Stream<BluetoothAdapterState> get adapterState {
    _adapterStateController ??= StreamController<BluetoothAdapterState>.broadcast();
    return _adapterStateController!.stream;
  }

  static void setMockAdapterState(BluetoothAdapterState state) {
    _adapterStateController ??= StreamController<BluetoothAdapterState>.broadcast();
    _adapterStateController!.add(state);
  }

  static void dispose() {
    _adapterStateController?.close();
    _adapterStateController = null;
  }

  static void setLogLevel(LogLevel level) {
    // Mock implementation - do nothing
  }
}

// Utility class to setup Bluetooth mocking
class BluetoothMockSetup {
  static void setupMocks() {
    // Setup mock responses for common Bluetooth operations
    MockFlutterBluePlus.setMockAdapterState(BluetoothAdapterState.on);
  }

  static void teardownMocks() {
    MockFlutterBluePlus.dispose();
  }

  static void setAdapterState(BluetoothAdapterState state) {
    MockFlutterBluePlus.setMockAdapterState(state);
  }
}
