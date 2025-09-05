class BluetoothDeviceRecord {
  final int? id;
  final String deviceId;
  final String deviceName;
  final String macAddress;
  final int rssi;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final String? manufacturerData;
  final String? serviceUuids;
  final bool isConnectable;

  BluetoothDeviceRecord({
    this.id,
    required this.deviceId,
    required this.deviceName,
    required this.macAddress,
    required this.rssi,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.manufacturerData,
    this.serviceUuids,
    required this.isConnectable,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'macAddress': macAddress,
      'rssi': rssi,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'manufacturerData': manufacturerData,
      'serviceUuids': serviceUuids,
      'isConnectable': isConnectable ? 1 : 0,
    };
  }

  factory BluetoothDeviceRecord.fromMap(Map<String, dynamic> map) {
    return BluetoothDeviceRecord(
      id: map['id'],
      deviceId: map['deviceId'],
      deviceName: map['deviceName'],
      macAddress: map['macAddress'],
      rssi: map['rssi'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      manufacturerData: map['manufacturerData'],
      serviceUuids: map['serviceUuids'],
      isConnectable: map['isConnectable'] == 1,
    );
  }

  @override
  String toString() {
    return 'BluetoothDeviceRecord{id: $id, deviceName: $deviceName, macAddress: $macAddress, rssi: $rssi, lat: $latitude, lng: $longitude, timestamp: $timestamp}';
  }
}
