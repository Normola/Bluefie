import 'dart:async';

import 'package:flutter/material.dart';

import '../services/watch_list_service.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  final WatchListService _watchListService = WatchListService();
  WatchListStatus? _status;
  final List<WatchListEvent> _recentEvents = [];
  StreamSubscription<WatchListEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _setupEventListener();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final status = await _watchListService.getStatus();
    setState(() {
      _status = status;
    });
  }

  void _setupEventListener() {
    _eventSubscription = _watchListService.eventStream.listen((event) {
      setState(() {
        _recentEvents.insert(0, event);
        // Keep only the last 50 events
        if (_recentEvents.length > 50) {
          _recentEvents.removeRange(50, _recentEvents.length);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Watch List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatus,
          ),
        ],
      ),
      body: _status == null
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (!_status!.enabled) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.watch_later_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Watch List Disabled',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enable the watch list in Settings to monitor devices',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStatusCard(),
        Expanded(
          child: _buildEventsList(),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.watch_later, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Watch List Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
                'Watched Devices', '${_status!.watchedDevices.length}'),
            _buildStatusRow(
                'Currently Detected', '${_status!.currentlyDetected.length}'),
            _buildStatusRow('Out of Range', '${_status!.outOfRange.length}'),
            _buildStatusRow('Audio Alerts',
                _status!.audioAlertsEnabled ? 'Enabled' : 'Disabled'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_recentEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Events Yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Watch list events will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recentEvents.length,
      itemBuilder: (context, index) {
        final event = _recentEvents[index];
        return _buildEventTile(event);
      },
    );
  }

  Widget _buildEventTile(WatchListEvent event) {
    IconData icon;
    Color color;
    String title;
    String subtitle;

    switch (event.type) {
      case WatchListEventType.deviceAdded:
        icon = Icons.add_circle;
        color = Colors.green;
        title = 'Device Added';
        subtitle = 'Added ${event.macAddress} to watch list';
        break;
      case WatchListEventType.deviceRemoved:
        icon = Icons.remove_circle;
        color = Colors.red;
        title = 'Device Removed';
        subtitle = 'Removed ${event.macAddress} from watch list';
        break;
      case WatchListEventType.deviceDetected:
        icon = Icons.visibility;
        color = Colors.blue;
        title = 'Device Detected';
        subtitle = '${event.deviceName ?? event.macAddress} came into range';
        break;
      case WatchListEventType.deviceReDetected:
        icon = Icons.notification_important;
        color = Colors.orange;
        title = 'Device Re-detected!';
        subtitle = '${event.deviceName ?? event.macAddress} returned to range';
        break;
      case WatchListEventType.deviceLeftRange:
        icon = Icons.visibility_off;
        color = Colors.grey;
        title = 'Device Left Range';
        subtitle = '${event.macAddress} is no longer detected';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            Text(
              _formatTime(event.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
