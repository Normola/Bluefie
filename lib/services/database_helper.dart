import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/bluetooth_device_record.dart';
import '../services/logging_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'bluetooth_devices.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bluetooth_devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deviceId TEXT NOT NULL,
        deviceName TEXT NOT NULL,
        macAddress TEXT NOT NULL,
        rssi INTEGER NOT NULL,
        latitude REAL,
        longitude REAL,
        timestamp INTEGER NOT NULL,
        manufacturerData TEXT,
        serviceUuids TEXT,
        isConnectable INTEGER NOT NULL,
        UNIQUE(deviceId, macAddress, timestamp)
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_timestamp ON bluetooth_devices(timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_mac_address ON bluetooth_devices(macAddress)
    ''');
  }

  Future<int> insertDevice(BluetoothDeviceRecord device) async {
    final db = await database;
    try {
      return await db.insert(
        'bluetooth_devices',
        device.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      log.error('Error inserting device', e);
      return -1;
    }
  }

  Future<List<BluetoothDeviceRecord>> getAllDevices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bluetooth_devices',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return BluetoothDeviceRecord.fromMap(maps[i]);
    });
  }

  Future<List<BluetoothDeviceRecord>> getDevicesByDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bluetooth_devices',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return BluetoothDeviceRecord.fromMap(maps[i]);
    });
  }

  Future<List<BluetoothDeviceRecord>> getUniqueDevices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM bluetooth_devices d1
      WHERE d1.timestamp = (
        SELECT MAX(d2.timestamp)
        FROM bluetooth_devices d2
        WHERE d2.macAddress = d1.macAddress
      )
      ORDER BY d1.timestamp DESC
    ''');

    return List.generate(maps.length, (i) {
      return BluetoothDeviceRecord.fromMap(maps[i]);
    });
  }

  Future<List<BluetoothDeviceRecord>> getDevicesByMacAddress(
      String macAddress) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bluetooth_devices',
      where: 'macAddress = ?',
      whereArgs: [macAddress],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return BluetoothDeviceRecord.fromMap(maps[i]);
    });
  }

  Future<int> getDeviceCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM bluetooth_devices');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getUniqueDeviceCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(DISTINCT macAddress) as count FROM bluetooth_devices');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get the database file size in bytes
  Future<int> getDatabaseSize() async {
    try {
      final String path =
          join(await getDatabasesPath(), 'bluetooth_devices.db');
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      LoggingService().error('Error getting database size: $e');
      return 0;
    }
  }

  /// Get the database file size as a formatted string (e.g., "1.2 MB")
  Future<String> getFormattedDatabaseSize() async {
    final sizeInBytes = await getDatabaseSize();
    return _formatFileSize(sizeInBytes);
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';

    const List<String> units = ['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(size >= 100 ? 0 : 1)} ${units[unitIndex]}';
  }

  Future<void> deleteOldRecords(DateTime beforeDate) async {
    final db = await database;
    await db.delete(
      'bluetooth_devices',
      where: 'timestamp < ?',
      whereArgs: [beforeDate.millisecondsSinceEpoch],
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('bluetooth_devices');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
