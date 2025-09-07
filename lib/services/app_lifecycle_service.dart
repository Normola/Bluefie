import 'dart:async';

import 'package:flutter/widgets.dart';

import 'bluetooth_scanning_service.dart';
import 'settings_service.dart';

/// Centralized service for managing app lifecycle behavior
/// This service coordinates how different services behave when the app
/// goes to background, foreground, or is terminated
class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  final BluetoothScanningService _scanningService = BluetoothScanningService();
  final SettingsService _settingsService = SettingsService();

  AppLifecycleState _currentState = AppLifecycleState.resumed;
  bool _wasAutoScanningBeforeBackground = false;
  bool _isInitialized = false;

  // Stream controller for broadcasting lifecycle changes
  final StreamController<AppLifecycleState> _lifecycleController =
      StreamController<AppLifecycleState>.broadcast();

  Stream<AppLifecycleState> get lifecycleStream => _lifecycleController.stream;
  AppLifecycleState get currentState => _currentState;

  /// Initialize the lifecycle service
  /// This should be called once during app startup
  void initialize() {
    if (_isInitialized) return;

    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    debugPrint('AppLifecycleService initialized');
  }

  /// Clean up the lifecycle service
  void dispose() {
    if (!_isInitialized) return;

    WidgetsBinding.instance.removeObserver(this);
    _lifecycleController.close();
    _isInitialized = false;
    debugPrint('AppLifecycleService disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentState == state) return;

    final AppLifecycleState previousState = _currentState;
    _currentState = state;

    debugPrint('App lifecycle: $previousState -> $state');

    // Broadcast the lifecycle change
    _lifecycleController.add(state);

    // Handle the lifecycle change
    _handleLifecycleChange(state, previousState);
  }

  void _handleLifecycleChange(
      AppLifecycleState current, AppLifecycleState previous) {
    switch (current) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed(previous);
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
        // Don't change behavior for temporary interruptions
        break;
    }
  }

  void _handleAppPaused() {
    debugPrint('App entering background - adjusting services');

    // Remember scanning state - check if continuous timer is active
    _wasAutoScanningBeforeBackground = _scanningService.isScanning;

    final settings = _settingsService.currentSettings;

    if (!_scanningService.isScanning) return;

    if (settings.batteryOptimizationEnabled) {
      debugPrint(
          'Stopping scanning for background (battery optimization enabled)');
      _scanningService.stopContinuousScanning();
      return;
    }

    debugPrint(
        'Continuing background scanning (battery optimization disabled)');
    // Note: Future enhancement could implement reduced frequency scanning
  }

  void _handleAppResumed(AppLifecycleState previousState) {
    debugPrint('App returning to foreground from $previousState');

    if (!_wasAutoScanningBeforeBackground) return;

    final settings = _settingsService.currentSettings;
    if (!settings.autoScanningEnabled) return;

    debugPrint('Restoring automatic scanning');
    _scanningService.startContinuousScanning();
  }

  void _handleAppDetached() {
    debugPrint('App being terminated - stopping all services');

    // Stop all active operations
    _scanningService.stopContinuousScanning();

    // Dispose of services if needed
    // Note: Services should handle their own cleanup
  }

  /// Force refresh all services when app becomes active
  void refreshServices() {
    if (_currentState != AppLifecycleState.resumed) return;

    debugPrint('Refreshing services for active app');
    // Services can refresh their state here
    // Battery service updates automatically via streams
  }
}
