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

## CI/CD Pipeline

This project includes comprehensive GitHub Actions workflows for automated testing, building, and deployment:

### 🔄 Continuous Integration (`ci.yml`)
- **Triggers**: Push to main branches, Pull Requests
- **Features**: Code analysis, testing, debug builds, security checks
- **Coverage**: Automatic test coverage reporting via Codecov

### 🏗️ Android Build Pipeline (`android-build.yml`)
- **Triggers**: Push, PR, Manual dispatch
- **Builds**: Debug, Profile, Release APKs and AABs
- **Features**: Size analysis, security scanning, artifact management

### 🚀 Release Pipeline (`android-release.yml`)
- **Triggers**: Manual dispatch only
- **Features**: Version bumping, GitHub releases, optional Play Store deployment
- **Automation**: Automatic changelog generation and team notifications

### 🔧 Additional Workflows
- **Flutter Compatibility**: Weekly testing across multiple Flutter versions
- **Dependency Updates**: Monthly automated dependency updates with PR creation
- **Security Audits**: Regular security scanning and vulnerability checks

### Setup Instructions
For detailed setup instructions including signing configuration and Play Store deployment, see:
📖 **[GitHub Actions Setup Guide](docs/GITHUB_ACTIONS_SETUP.md)**

### Quick Start for Contributors
1. Fork the repository
2. Make your changes
3. Push to your fork - CI will automatically run
4. Create a pull request - additional validation builds will run
5. Maintainers can create releases using the release workflow

[![CI](https://github.com/Normola/Bluefie/workflows/CI/badge.svg)](https://github.com/Normola/Bluefie/actions/workflows/ci.yml)
[![Android Build](https://github.com/Normola/Bluefie/workflows/Android%20Build%20Pipeline/badge.svg)](https://github.com/Normola/Bluefie/actions/workflows/android-build.yml)

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

### Coding Style Guidelines

This project follows strict coding style rules for consistency and readability:

#### Core Principles
- **NO ELSE STATEMENTS**: Always use early returns instead of else clauses
- **MINIMAL NESTING**: Keep code flat with maximum 2 levels of nesting
- **EARLY RETURNS**: Use guard clauses and early returns for cleaner code flow

#### Before Contributing
1. Read `.ai-instructions.md` for detailed coding standards
2. Ensure your IDE follows the settings in `.vscode/settings.json`
3. Run `flutter analyze` to check for style violations
4. All new code must follow the no-else, minimal-nesting pattern

#### Example Code Patterns

✅ **Good - Early Return Pattern**
```dart
if (!isValid) return;
if (data == null) return;
if (!mounted) return;

processData(data);
```

❌ **Bad - Nested/Else Pattern**
```dart
if (isValid) {
  if (data != null) {
    if (mounted) {
      processData(data);
    }
  }
}
```

### Contribution Process
1. Fork the repository
2. Create a feature branch
3. Follow coding style guidelines
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the BSD-style license found in the LICENSE file.
Simple UI for Blufie
## Development

### Code Formatting
This project uses automatic code formatting to maintain consistent code style.

**Pre-commit Hook**: A pre-commit hook automatically runs `dart format` on all staged Dart files before each commit. This ensures all committed code follows consistent formatting standards.

- Hook files are located in `.git/hooks/`
- Setup scripts are available in `scripts/`
- The hook runs automatically - no manual intervention required
- To bypass (not recommended): `git commit --no-verify`

For detailed information, see: 📖 **[Pre-commit Hook Setup Guide](docs/PRE_COMMIT_HOOK_SETUP.md)**

### Manual Formatting
To manually format all Dart files:
```bash
dart format .
```

### CI/CD Pipeline
Comprehensive CI/CD pipeline with automated formatting checks, testing, and building. See the [GitHub Actions Setup Guide](docs/GITHUB_ACTIONS_SETUP.md) for details.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
