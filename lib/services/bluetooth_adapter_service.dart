import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/logging_service.dart';

/// Abstract interface for Bluetooth adapter operations
/// This allows us to mock Bluetooth functionality in tests
abstract class BluetoothAdapterInterface {
  /// Stream of adapter state changes
  Stream<BluetoothAdapterState> get adapterStateStream;

  /// Get current adapter state
  BluetoothAdapterState get currentState;

  /// Set log level for Bluetooth operations
  void setLogLevel(LogLevel level);
}

/// Production implementation using flutter_blue_plus
class FlutterBluePlusAdapter implements BluetoothAdapterInterface {
  BluetoothAdapterState _currentState = BluetoothAdapterState.unknown;

  @override
  Stream<BluetoothAdapterState> get adapterStateStream {
    return FlutterBluePlus.adapterState.map((state) {
      _currentState = state;
      return state;
    });
  }

  @override
  BluetoothAdapterState get currentState => _currentState;

  @override
  void setLogLevel(LogLevel level) {
    FlutterBluePlus.setLogLevel(level).onError(handleBluetoothError);
  }

  FutureOr<void> handleBluetoothError(Object error, StackTrace stackTrace) {
    // In test or unsupported environments, flutter_blue_plus may throw exceptions
    // We can safely ignore these since logging level is not critical functionality
    LoggingService().warning('Unable to set bluetooth log level: $error');
  }
}

/// Mock implementation for testing
class MockBluetoothAdapter implements BluetoothAdapterInterface {
  final StreamController<BluetoothAdapterState> _stateController;
  BluetoothAdapterState _currentState;

  MockBluetoothAdapter({
    BluetoothAdapterState initialState = BluetoothAdapterState.on,
  })  : _currentState = initialState,
        _stateController = StreamController<BluetoothAdapterState>.broadcast();

  @override
  Stream<BluetoothAdapterState> get adapterStateStream =>
      _stateController.stream;

  @override
  BluetoothAdapterState get currentState => _currentState;

  @override
  void setLogLevel(LogLevel level) {
    // Mock implementation - do nothing
  }

  /// Test helper method to simulate state changes
  void simulateStateChange(BluetoothAdapterState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  /// Dispose resources
  void dispose() {
    _stateController.close();
  }
}
