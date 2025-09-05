import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../models/bluetooth_device_record.dart';
import '../services/database_helper.dart';
import '../services/location_service.dart';
import '../services/logging_service.dart';

class DeviceLocationMapScreen extends StatefulWidget {
  final String deviceName;
  final String macAddress;

  const DeviceLocationMapScreen({
    super.key,
    required this.deviceName,
    required this.macAddress,
  });

  @override
  State<DeviceLocationMapScreen> createState() => _DeviceLocationMapScreenState();
}

class _DeviceLocationMapScreenState extends State<DeviceLocationMapScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  List<BluetoothDeviceRecord> _deviceDetections = [];
  List<Marker> _markers = [];
  bool _isLoading = true;
  LatLng? _centerLocation;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _loadDeviceDetections();
  }

  Future<void> _loadDeviceDetections() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get all detections for this device
      final detections = await _databaseHelper.getDevicesByMacAddress(widget.macAddress);

      // Filter out detections without location data
      final detectionsWithLocation =
          detections.where((d) => d.latitude != null && d.longitude != null).toList();

      if (detectionsWithLocation.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create markers for each detection
      final markers = <Marker>[];
      for (int i = 0; i < detectionsWithLocation.length; i++) {
        final detection = detectionsWithLocation[i];
        final marker = Marker(
          point: LatLng(detection.latitude!, detection.longitude!),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showDetectionDetails(detection),
            child: Container(
              decoration: BoxDecoration(
                color: _getMarkerColor(i, detectionsWithLocation.length),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
        markers.add(marker);
      }

      // Calculate center location (most recent detection)
      final mostRecent = detectionsWithLocation.first;
      final centerLocation = LatLng(mostRecent.latitude!, mostRecent.longitude!);

      setState(() {
        _deviceDetections = detectionsWithLocation;
        _markers = markers;
        _centerLocation = centerLocation;
        _isLoading = false;
      });
    } catch (e) {
      log.error('Error loading device detections for map', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<double> _calculateTotalDistance() async {
    if (_deviceDetections.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < _deviceDetections.length; i++) {
      final prev = _deviceDetections[i - 1];
      final current = _deviceDetections[i];
      if (prev.latitude != null &&
          prev.longitude != null &&
          current.latitude != null &&
          current.longitude != null) {
        final distance = await _locationService.getDistanceBetween(
          prev.latitude!,
          prev.longitude!,
          current.latitude!,
          current.longitude!,
        );
        totalDistance += distance;
      }
    }
    return totalDistance;
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    }
    return '${(meters / 1000).toStringAsFixed(2)}km';
  }

  Duration _getTotalTimeSpan() {
    if (_deviceDetections.length < 2) return Duration.zero;
    return _deviceDetections.first.timestamp.difference(_deviceDetections.last.timestamp);
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  Color _getMarkerColor(int index, int total) {
    // Gradient from red (oldest) to green (newest)
    final double ratio = total > 1 ? index / (total - 1) : 0.0;
    return Color.lerp(Colors.red, Colors.green, ratio) ?? Colors.blue;
  }

  void _showDetectionDetails(BluetoothDeviceRecord detection) {
    // Calculate signal strength context
    final allRssi = _deviceDetections.map((d) => d.rssi).toList();
    final minRssi = allRssi.reduce((a, b) => a < b ? a : b);
    final maxRssi = allRssi.reduce((a, b) => a > b ? a : b);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Detection Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Device Name', detection.deviceName),
            _buildDetailRow('MAC Address', detection.macAddress),
            _buildDetailRow(
                'RSSI', '${detection.rssi} dBm (${_getRssiDescription(detection.rssi)})'),
            _buildDetailRow('Signal Range', '$maxRssi to $minRssi dBm across all detections'),
            _buildDetailRow('Time', _dateFormatter.format(detection.timestamp)),
            _buildDetailRow('Location',
                '${detection.latitude!.toStringAsFixed(6)}, ${detection.longitude!.toStringAsFixed(6)}'),
            if (detection.manufacturerData != null)
              _buildDetailRow('Manufacturer Data', detection.manufacturerData!),
            if (detection.serviceUuids != null)
              _buildDetailRow('Service UUIDs', detection.serviceUuids!),
            _buildDetailRow('Connectable', detection.isConnectable ? 'Yes' : 'No'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRssiDescription(int rssi) {
    if (rssi > -50) return 'Excellent';
    if (rssi > -60) return 'Good';
    if (rssi > -70) return 'Fair';
    if (rssi > -80) return 'Poor';
    return 'Very Poor';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _centerOnCurrentLocation() async {
    final currentPosition = await _locationService.getCurrentLocation();
    if (currentPosition == null || !mounted) return;

    _mapController.move(
      LatLng(currentPosition.latitude, currentPosition.longitude),
      15.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.deviceName),
            Text(
              '${_deviceDetections.length} detections',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnCurrentLocation,
            tooltip: 'Center on current location',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeviceDetections,
            tooltip: 'Refresh detections',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deviceDetections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No location data found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This device has no recorded detections with location data.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _centerLocation!,
                        initialZoom: 15.0,
                        minZoom: 3.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.blufie',
                        ),
                        MarkerLayer(
                          markers: _markers,
                        ),
                        if (_markers.length > 1)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _deviceDetections
                                    .map((d) => LatLng(d.latitude!, d.longitude!))
                                    .toList(),
                                strokeWidth: 2.0,
                                color: Theme.of(context).primaryColor.withOpacity(0.6),
                                pattern: StrokePattern.dashed(segments: const [5.0, 5.0]),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.analytics_outlined,
                                      size: 16, color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Movement Summary',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<double>(
                                future: _calculateTotalDistance(),
                                builder: (context, snapshot) {
                                  final distance = snapshot.data ?? 0.0;
                                  final timeSpan = _getTotalTimeSpan();
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_deviceDetections.length} detections • ${_formatDistance(distance)} total movement',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      Text(
                                        'From ${_dateFormatter.format(_deviceDetections.last.timestamp)} '
                                        'to ${_dateFormatter.format(_deviceDetections.first.timestamp)} '
                                        '(${_formatDuration(timeSpan)})',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      if (_markers.length > 1)
                                        Text(
                                          'Red markers = oldest, Green = newest • Dashed line shows movement path',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
