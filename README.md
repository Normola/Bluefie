# Blufie-UI - Enhanced Bluetooth Device Scanner

A comprehensive Flutter application for continuous Bluetooth device enumeration with GPS location tracking and database storage.

## Features

### Core Functionality
- **Continuous Bluetooth Scanning**: Automatically discovers nearby Bluetooth devices every 30 seconds
- **GPS Location Tracking**: Records the precise location where each device was discovered
- **Database Storage**: Stores all discovered devices with comprehensive metadata in a local SQLite database
- **Real-time Updates**: Live updates of scanning statistics and device counts
- **Device Watch List**: Monitor specific devices and receive audio alerts when they re-appear after leaving detection range

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
- **Watch List Screen**: Real-time monitoring of watched devices with event tracking and status updates
- **Statistics Dashboard**: Real-time scanning metrics and device counts
- **Settings Screen**: Configuration for scanning, battery optimization, and watch list management
- **Location Integration**: Current location display and tracking

## Recent Updates

### 🔔 Device Watch List Feature (September 2025)
- **Watch List Management**: Add specific devices to a watch list for monitoring
- **Audio Alerts**: Configurable sound notifications when watched devices re-appear after leaving detection range
- **Real-time Event Monitoring**: Dedicated screen for viewing watch list events and device status
- **Settings Integration**: Complete UI for managing watch list devices and alert preferences
- **Background Processing**: Automatic monitoring integrated with continuous scanning service

### 🧪 Testing Infrastructure (September 2025)
- **Comprehensive Unit Tests**: Added 38+ unit tests with ≥80% coverage requirement
- **Automated Testing**: CI/CD pipeline includes test validation and coverage reporting
- **Mock Framework**: Complete mocking infrastructure for platform dependencies
- **Test Categories**: Unit tests for models, services, utilities, and widget tests

### 🏗️ Service Architecture Improvements
- **Singleton Services**: Implemented proper singleton pattern for OUI and Settings services
- **Service Lifecycle Management**: Added AppLifecycleService for proper application state management
- **Configuration Service**: Centralized service initialization and management
- **Platform Exception Handling**: Robust error handling for platform-dependent operations

### 📱 Enhanced Device Identification
- **OUI Database Integration**: Manufacturer identification using IEEE OUI database
- **Device Metadata**: Enhanced device information with manufacturer details
- **Database Optimization**: Improved SQLite schema and query performance

### 🔧 Development Quality Improvements
- **Strict Coding Standards**: Enforced no-else statements and minimal nesting patterns
- **APK Size Monitoring**: CI validation ensures release APKs stay under 100MB
- **Automated Dependencies**: Monthly dependency updates with automated PR creation
- **Code Coverage**: Mandatory 80% unit test coverage for all new code

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
- **Quality Gates**: Enforces 80% unit test coverage requirement

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

### Using the Watch List Feature
1. **Enable Watch List**: Go to Settings → Device Watch List → Toggle "Enable Watch List"
2. **Add Devices**:
   - Tap "Watched Devices" in settings
   - Enter MAC address (format: XX:XX:XX:XX:XX:XX)
   - Click "Add Device" to add to watch list
3. **Configure Audio Alerts**: Toggle "Audio Alerts" in watch list settings for sound notifications
4. **Monitor Events**:
   - Tap the watch icon in the main scan screen
   - View real-time events when devices appear/disappear
   - See current status of all watched devices
5. **Remove Devices**: In the device management dialog, tap the delete icon next to any device

## Technical Architecture

### Core Services
- **AppConfiguration**: Central service initialization and lifecycle management
- **AppLifecycleService**: Application state monitoring and background/foreground transitions
- **BluetoothScanningService**: Manages continuous scanning and data processing
- **WatchListService**: Device watch list management with audio alerts and event tracking
- **LocationService**: Handles GPS tracking and permission management
- **SettingsService**: Centralized application settings and preferences management
- **BatteryService**: Battery level monitoring and optimization
- **OuiService**: IEEE OUI database for device manufacturer identification
- **DatabaseHelper**: SQLite database operations and data persistence

### Service Architecture
- **Singleton Pattern**: All services implement proper singleton pattern for consistent state
- **Dependency Injection**: Clean service initialization with proper dependency management
- **Error Handling**: Comprehensive platform exception handling and graceful degradation
- **Testing Support**: Full mocking infrastructure for reliable unit testing

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
5. **Maintain ≥80% unit test coverage** - run `flutter test --coverage` to verify

#### Testing Requirements
- **Minimum unit test coverage: 80%** - All changes must maintain or improve coverage
- Add unit tests for all new services, models, and utility functions
- Mock external dependencies (SharedPreferences, platform channels, etc.)
- Handle platform exceptions gracefully in test environments
- Run `flutter test --coverage` before submitting PRs

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

### Testing Standards
**Unit Test Coverage Requirement: ≥80%**

Before committing changes:
```bash
# Run tests with coverage
flutter test --coverage

# Check test results in coverage/lcov.info
# Use VS Code extensions: Flutter Coverage, Coverage Gutters
```

See detailed testing instructions in [test/README.md](test/README.md).

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
