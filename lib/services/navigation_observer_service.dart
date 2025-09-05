import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'bluetooth_adapter_service.dart';

/// Interface for navigation observers that respond to Bluetooth state
abstract class BluetoothNavigationObserverInterface extends NavigatorObserver {
  void dispose();
}

/// Production implementation of Bluetooth-aware navigation observer
class BluetoothAdapterStateObserver extends BluetoothNavigationObserverInterface {
  final BluetoothAdapterInterface _bluetoothAdapter;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  BluetoothAdapterStateObserver({
    BluetoothAdapterInterface? bluetoothAdapter,
  }) : _bluetoothAdapter = bluetoothAdapter ?? FlutterBluePlusAdapter();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??= _bluetoothAdapter.adapterStateStream.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}

/// Mock implementation for testing
class MockBluetoothNavigationObserver extends BluetoothNavigationObserverInterface {
  final List<String> _pushedRoutes = [];
  final List<String> _poppedRoutes = [];
  bool _disposed = false;

  List<String> get pushedRoutes => List.unmodifiable(_pushedRoutes);
  List<String> get poppedRoutes => List.unmodifiable(_poppedRoutes);
  bool get isDisposed => _disposed;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _pushedRoutes.add(route.settings.name ?? 'unknown');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _poppedRoutes.add(route.settings.name ?? 'unknown');
  }

  @override
  void dispose() {
    _disposed = true;
  }
}
