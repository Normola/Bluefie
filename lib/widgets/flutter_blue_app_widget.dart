import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../screens/bluetooth_off_screen.dart';
import '../screens/scan_screen.dart';
import '../services/bluetooth_adapter_service.dart';
import '../services/navigation_observer_service.dart';

/// Testable version of the main app widget
/// Accepts dependencies via constructor for easier testing
class FlutterBlueAppWidget extends StatefulWidget {
  final BluetoothAdapterInterface bluetoothAdapter;
  final BluetoothNavigationObserverInterface Function()
      navigationObserverFactory;

  const FlutterBlueAppWidget({
    super.key,
    required this.bluetoothAdapter,
    required this.navigationObserverFactory,
  });

  @override
  State<FlutterBlueAppWidget> createState() => _FlutterBlueAppWidgetState();
}

class _FlutterBlueAppWidgetState extends State<FlutterBlueAppWidget>
    with WidgetsBindingObserver {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;
  late BluetoothNavigationObserverInterface _navigationObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize state with current value
    _adapterState = widget.bluetoothAdapter.currentState;

    // Listen to state changes
    _adapterStateSubscription =
        widget.bluetoothAdapter.adapterStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _adapterState = state;
        });
      }
    });

    // Create navigation observer
    _navigationObserver = widget.navigationObserverFactory();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Log lifecycle changes for debugging
    debugPrint('App lifecycle changed to: $state');

    // Notify the navigation observer about lifecycle changes
    // This can be used to pause/resume global services
    switch (state) {
      case AppLifecycleState.paused:
        debugPrint('App entered background - global services may be paused');
        break;
      case AppLifecycleState.resumed:
        debugPrint('App returned to foreground - global services resumed');
        break;
      case AppLifecycleState.detached:
        debugPrint('App is being terminated');
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adapterStateSubscription.cancel();
    _navigationObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);

    return MaterialApp(
      color: Colors.lightBlue,
      home: screen,
      navigatorObservers: [_navigationObserver],
    );
  }
}

/// Screen selection logic separated for easier testing
class ScreenSelector {
  static Widget selectScreen(BluetoothAdapterState adapterState) {
    return adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: adapterState);
  }

  static bool isBluetoothOn(BluetoothAdapterState state) {
    return state == BluetoothAdapterState.on;
  }
}
