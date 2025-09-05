import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/scan_config.dart';
import '../services/logging_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  final StreamController<Position?> _locationController = StreamController<Position?>.broadcast();

  Stream<Position?> get locationStream => _locationController.stream;
  Position? get currentPosition => _currentPosition;

  Future<bool> requestPermissions() async {
    final locationPermission = await Permission.location.request();

    if (locationPermission.isDenied) {
      return false;
    }

    // Check if location services are enabled
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // For Android 12+ devices, check if we have precise location access
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      try {
        // Try to get a test location to verify we have precise location access
        final testPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            timeLimit: Duration(seconds: 5),
          ),
        );

        // Log the precision we're getting
        log.info('Location precision check: accuracy = ${testPosition.accuracy}m');

        // If accuracy is very poor (>1000m), user might have selected "approximate location"
        if (testPosition.accuracy > 1000) {
          log.warning(
              'Location accuracy is poor (${testPosition.accuracy}m). User may have selected approximate location.');
        }
      } catch (e) {
        log.warning('Could not verify location precision: $e');
      }
    }

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      if (!await requestPermissions()) {
        return null;
      }

      const LocationSettings locationSettings = LocationSettings(
        timeLimit: ScanConfig.locationTimeout,
      );

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      // Log location accuracy for debugging
      log.info(
          'Location obtained with accuracy: ${_currentPosition?.accuracy ?? 'unknown'} meters');

      _locationController.add(_currentPosition);
      return _currentPosition;
    } catch (e) {
      log.error('Error getting current location', e);
      return null;
    }
  }

  Future<void> startLocationTracking() async {
    if (!await requestPermissions()) {
      return;
    }

    final LocationSettings locationSettings = LocationSettings(
      distanceFilter: ScanConfig.minLocationUpdateDistance.round(),
      timeLimit: ScanConfig.locationTimeout,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;

        // Log location updates with accuracy info
        log.info(
            'Location updated: ${position.latitude.toStringAsFixed(8)}, ${position.longitude.toStringAsFixed(8)} (accuracy: ${position.accuracy}m)');

        _locationController.add(position);
      },
      onError: (error) {
        log.error('Location tracking error', error);
        _locationController.add(null);
      },
    );
  }

  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<double> getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  String getLocationString(Position? position) {
    if (position == null) return 'Unknown location';
    return '${position.latitude.toStringAsFixed(8)}, ${position.longitude.toStringAsFixed(8)} (±${position.accuracy.toStringAsFixed(1)}m)';
  }

  void dispose() {
    stopLocationTracking();
    _locationController.close();
  }
}
