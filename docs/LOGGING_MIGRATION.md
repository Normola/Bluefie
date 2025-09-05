# Logging Migration Guide for Blufie

## 🎯 Overview
We've implemented the `logger` package to replace all `print()` statements with structured, production-ready logging.

## 📦 Package Added
- **logger**: ^2.4.0 - Feature-rich logging framework

## 🔧 Implementation

### 1. LoggingService Created
- **File**: `lib/services/logging_service.dart`
- **Features**:
  - Different log levels (trace, debug, info, warning, error, fatal)
  - Colored output with emojis
  - Structured logging with context
  - Performance, user action, and domain-specific logging methods
  - Automatic debug vs production level switching

### 2. Integration
- Initialized in `main.dart`
- Available globally as `log` instance
- Already integrated in `battery_service.dart` as example

## 🚀 Usage Examples

### Basic Logging
```dart
import '../services/logging_service.dart';

// Error logging with exception
log.error('Error getting battery level', e);

// Info with context
log.info('User opened settings screen');

// Warning
log.warning('Bluetooth is disabled');
```

### Domain-Specific Logging
```dart
// Bluetooth events
log.bluetooth('Scan started', {'timeout_ms': 5000});
log.bluetooth('Device discovered', {'name': deviceName, 'rssi': rssi});

// Location events  
log.location('GPS location updated', {'lat': lat, 'lng': lng});

// Database operations
log.database('Device stored', {'deviceId': id, 'action': 'insert'});

// Battery events
log.battery('Low battery detected', {'level': 15, 'threshold': 20});

// Performance monitoring
log.performance('Database query', duration);

// User actions
log.userAction('Started scanning', {'manual': true});
```

## 📋 Migration Checklist

### Files to Update:
- [ ] `lib/services/bluetooth_scanning_service.dart` (15 print statements)
- [ ] `lib/services/location_service.dart` (2 print statements)  
- [ ] `lib/services/database_helper.dart` (1 print statement)
- [ ] `lib/services/settings_service.dart` (2 print statements)
- [ ] `lib/screens/device_history_screen.dart` (1 print statement)

### Migration Steps:
1. Add import: `import '../services/logging_service.dart';`
2. Replace `print('message')` with appropriate log level
3. Add structured context where helpful
4. Choose appropriate log level:
   - `debug()` - Development debugging info
   - `info()` - General information
   - `warning()` - Non-critical issues
   - `error()` - Errors that need attention
   - Domain methods for specific events

## 🎨 Log Level Guidelines

- **trace/debug**: Development debugging, verbose information
- **info**: Application flow, user actions, important events
- **warning**: Recoverable issues, deprecated usage
- **error**: Errors that need attention but don't crash app
- **fatal**: Critical errors that might crash app

## 🔧 Production Configuration

The logger automatically:
- Shows debug+ levels in debug builds
- Shows info+ levels in release builds
- Can be configured for file output, network logging, etc.

## 📊 Benefits

1. **Structured Data**: Log with context maps for better debugging
2. **Performance**: Minimal overhead in production
3. **Flexibility**: Easy to redirect logs to files, analytics, etc.
4. **Visual**: Colored output with emojis for easy scanning
5. **Production Ready**: Proper level management for releases

## 🚫 What Not to Log

- Sensitive user data (passwords, tokens)
- Large objects without summary
- In tight loops without throttling
- Personal location data in production logs
