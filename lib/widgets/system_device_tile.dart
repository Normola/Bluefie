import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/oui_service.dart';
import '../services/settings_service.dart';

class SystemDeviceTile extends StatefulWidget {
  final BluetoothDevice device;
  final VoidCallback onOpen;
  final VoidCallback onConnect;

  const SystemDeviceTile({
    required this.device,
    required this.onOpen,
    required this.onConnect,
    super.key,
  });

  @override
  State<SystemDeviceTile> createState() => _SystemDeviceTileState();
}

class _SystemDeviceTileState extends State<SystemDeviceTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) {
      _connectionState = state;
      if (!mounted) return;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    final manufacturer = _getManufacturerInfo();

    return ListTile(
      title: Text(widget.device.platformName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.device.remoteId.str),
          if (manufacturer != null)
            Text(
              manufacturer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
            ),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: isConnected ? widget.onOpen : widget.onConnect,
        child: isConnected ? const Text('OPEN') : const Text('CONNECT'),
      ),
    );
  }

  String? _getManufacturerInfo() {
    final settingsService = SettingsService();
    final ouiService = OuiService();

    if (!settingsService.currentSettings.ouiDatabaseEnabled ||
        !ouiService.isLoaded) {
      return null;
    }

    final macAddress = widget.device.remoteId.str;
    return ouiService.getManufacturer(macAddress);
  }
}
