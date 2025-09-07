import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/snackbar.dart';
import 'descriptor_tile.dart';

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final String? characteristicName;

  const CharacteristicTile({
    super.key,
    required this.characteristic,
    required this.descriptorTiles,
    this.characteristicName,
  });
  // Removed duplicate constructor
  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  Widget buildName(BuildContext context) {
    if (widget.characteristicName != null &&
        widget.characteristicName!.isNotEmpty) {
      return Text(widget.characteristicName!,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue));
    }
    return const Text('Characteristic', style: TextStyle(color: Colors.blue));
  }

  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription =
        widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  Future onReadPressed() async {
    try {
      await c.read();
      Snackbar.show(ABC.c, 'Read: Success', success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException('Read Error:', e), success: false);
    }
  }

  Future onWritePressed() async {
    try {
      await c.write(_getRandomBytes(),
          withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, 'Write: Success', success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException('Write Error:', e), success: false);
    }
  }

  Future onSubscribePressed() async {
    try {
      final String op = c.isNotifying == false ? 'Subscribe' : 'Unubscribe';
      await c.setNotifyValue(c.isNotifying == false);
      Snackbar.show(ABC.c, '$op : Success', success: true);
      if (c.properties.read) {
        await c.read();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException('Subscribe Error:', e),
          success: false);
    }
  }

  Widget buildUuid(BuildContext context) {
    final String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}';
    return Text(uuid, style: const TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context) {
    final String data = _value.toString();
    return Text(data, style: const TextStyle(fontSize: 13, color: Colors.grey));
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: const Text('Read'),
        onPressed: () async {
          await onReadPressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildWriteButton(BuildContext context) {
    final bool withoutResp =
        widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
        child: Text(withoutResp ? 'WriteNoResp' : 'Write'),
        onPressed: () async {
          await onWritePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildSubscribeButton(BuildContext context) {
    final bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? 'Unsubscribe' : 'Subscribe'),
        onPressed: () async {
          await onSubscribePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildButtonRow(BuildContext context) {
    final bool read = widget.characteristic.properties.read;
    final bool write = widget.characteristic.properties.write;
    final bool notify = widget.characteristic.properties.notify;
    final bool indicate = widget.characteristic.properties.indicate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildName(context),
          buildUuid(context),
        ],
      ),
      children: [
        ...widget.descriptorTiles,
        buildValue(context),
        buildButtonRow(context),
      ],
    );
  }
}
