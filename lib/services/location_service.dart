import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/scan_config.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  final StreamController<Position?> _locationController =
      StreamController<Position?>.broadcast();

  Stream<Position?> get locationStream => _locationController.stream;
  Position? get currentPosition => _currentPosition;

  Future<bool> requestPermissions() async {
    final locationPermission = await Permission.location.request();
    
    if (locationPermission.isDenied) {
      return false;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
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

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      if (!await requestPermissions()) {
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: ScanConfig.locationTimeout,
      );
      
      _locationController.add(_currentPosition);
      return _currentPosition;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Future<void> startLocationTracking() async {
    if (!await requestPermissions()) {
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: ScanConfig.minLocationUpdateDistance,
      timeLimit: ScanConfig.locationTimeout,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;
        _locationController.add(position);
      },
      onError: (error) {
        print('Location tracking error: $error');
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
    return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
  }

  void dispose() {
    stopLocationTracking();
    _locationController.close();
  }
}
