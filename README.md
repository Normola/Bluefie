# Blufie-UI - Enhanced Bluetooth Device Scanner

A comprehensive Flutter application for continuous Bluetooth device enumeration with GPS location tracking and database storage.

## Features

### Core Functionality
- **Continuous Bluetooth Scanning**: Automatically discovers nearby Bluetooth devices every 30 seconds
- **GPS Location Tracking**: Records the precise location where each device was discovered
- **Database Storage**: Stores all discovered devices with comprehensive metadata in a local SQLite database
- **Real-time Updates**: Live updates of scanning statistics and device counts

### Data Collection
Each discovered device is stored with the following information:
- Device name and MAC address
- Signal strength (RSSI)
- GPS coordinates (latitude/longitude)
- Timestamp of discovery
- Manufacturer data (if available)
- Service UUIDs
- Connectivity status
- Device ID

### User Interface
- **Scan Screen**: Main interface with manual and automatic scanning controls
- **Device History**: Comprehensive view of all discovered devices
- **Statistics Dashboard**: Real-time scanning metrics and device counts
- **Location Integration**: Current location display and tracking

## Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd Blufie-UI
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure permissions** (already included in AndroidManifest.xml):
   - Bluetooth scanning permissions
   - Location access permissions
   - Background location permissions

4. **Run the application**:
   ```bash
   flutter run
   ```

## Usage

### Starting Continuous Scanning
1. Open the app and ensure Bluetooth is enabled
2. Grant location permissions when prompted
3. Tap "Start Auto Scan" to begin continuous device enumeration
4. The app will scan for devices every 30 seconds automatically

### Viewing Stored Data
1. Tap "View History" to see all discovered devices
2. Browse through three tabs:
   - **Recent**: Latest 50 discovered devices
   - **All Devices**: Complete chronological list
   - **Unique**: Latest discovery for each unique device

### Managing Data
- **Refresh**: Pull down to refresh device lists
- **Clear Data**: Remove all stored device records
- **Cleanup**: Remove records older than 7 days

## Technical Architecture

### Services
- **BluetoothScanningService**: Manages continuous scanning and data processing
- **LocationService**: Handles GPS tracking and permission management
- **DatabaseHelper**: SQLite database operations and data persistence

### Models
- **BluetoothDeviceRecord**: Data model for discovered devices

### Database Schema
```sql
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
  isConnectable INTEGER NOT NULL
);
```

## Permissions Required

### Android
- `BLUETOOTH_SCAN`: For discovering nearby devices
- `BLUETOOTH_CONNECT`: For device connectivity checks
- `ACCESS_FINE_LOCATION`: For precise GPS coordinates
- `ACCESS_COARSE_LOCATION`: For general location access
- `ACCESS_BACKGROUND_LOCATION`: For continuous location tracking

## Key Dependencies

- `flutter_blue_plus`: Bluetooth Low Energy communication
- `geolocator`: GPS location services
- `sqflite`: Local SQLite database
- `permission_handler`: Runtime permission management
- `intl`: Date/time formatting

## Privacy Considerations

- All data is stored locally on the device
- No data is transmitted to external servers
- Location data is only used for device discovery context
- Users can clear all data at any time

## Performance Notes

- Scanning occurs every 30 seconds to balance battery life and data collection
- Database is optimized with indexes for fast queries
- Location updates are filtered to every 10 meters to reduce battery usage
- Old data cleanup functionality prevents excessive storage usage

## Troubleshooting

1. **Bluetooth permissions denied**: Check app permissions in device settings
2. **Location not working**: Ensure location services are enabled
3. **No devices found**: Check if Bluetooth is enabled and try manual scan
4. **App crashes on startup**: Ensure all dependencies are properly installed

## Future Enhancements

- Export data to CSV/JSON formats
- Device filtering and search capabilities
- Heat map visualization of device locations
- Background service for 24/7 monitoring
- Data synchronization across devices
- Advanced analytics and reporting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the BSD-style license found in the LICENSE file.
Simple UI for Blufie

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
