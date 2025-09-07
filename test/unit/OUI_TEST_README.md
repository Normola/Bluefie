# OUI Functionality Test Suite

This directory contains comprehensive unit tests for the OUI (Organizationally Unique Identifier) functionality in the Blufie application.

## Test Files

### 1. `oui_service_basic_test.dart`
Tests the core `OuiService` functionality:
- **Singleton Pattern**: Verifies the service maintains singleton behavior
- **MAC Address Parsing**: Tests various MAC address formats (colon-separated, dash-separated, unseparated)
- **State Management**: Tests service state properties and stream access
- **Database Operations**: Tests initialization, download, deletion, and update time queries
- **Error Handling**: Ensures the service handles errors gracefully without throwing exceptions

### 2. `app_settings_oui_test.dart`
Tests the `AppSettings` model OUI-related fields:
- **Default Values**: Tests default OUI database settings
- **Field Updates**: Tests setting OUI database enabled/disabled and last updated timestamp
- **CopyWith Method**: Tests updating OUI fields via copyWith method
- **JSON Serialization**: Tests converting OUI settings to/from JSON
- **Round-trip Consistency**: Verifies JSON serialization/deserialization maintains data integrity
- **Equality Comparison**: Tests equality comparison with OUI fields

### 3. `oui_functionality_test.dart`
Comprehensive integration tests for OUI functionality:
- **MAC Address Processing**: Tests various MAC address formats and edge cases
- **Service State**: Tests singleton behavior and initial state
- **Error Resilience**: Tests that all public methods never throw exceptions
- **AppSettings Integration**: Tests OUI functionality with settings model
- **Real-world Usage**: Tests common Bluetooth MAC addresses and formatting variations

## Test Coverage

The test suite covers:

✅ **Core Functionality**:
- MAC address parsing and manufacturer lookup
- Singleton pattern implementation
- State management (loading, downloading, database size)
- Stream interfaces for database updates and download progress

✅ **Data Model Integration**:
- AppSettings OUI field management
- JSON serialization/deserialization
- Setting persistence and retrieval

✅ **Error Handling**:
- Invalid MAC address formats
- Platform channel errors (path_provider in test environment)
- Rapid successive calls
- Edge case inputs

✅ **Real-world Scenarios**:
- Common Bluetooth device manufacturers
- Various MAC address formatting conventions
- Mixed case and separator variations
- Broadcast and null MAC addresses

## Known Test Environment Limitations

1. **Path Provider Plugin**: Tests run in an environment where `path_provider` plugin methods throw `MissingPluginException`. This is expected and handled gracefully by the service.

2. **Flutter Blue Plus**: Widget tests that use Flutter Blue Plus components fail in the test environment due to platform support limitations. Basic service tests work correctly.

3. **AppSettings CopyWith**: The current implementation of `copyWith` doesn't support clearing nullable fields by passing `null` - this is a limitation of the current model implementation.

## Running the Tests

To run all OUI functionality tests:
```bash
flutter test test/unit/services/oui_service_basic_test.dart test/unit/models/app_settings_oui_test.dart test/unit/oui_functionality_test.dart
```

To run individual test files:
```bash
flutter test test/unit/services/oui_service_basic_test.dart
flutter test test/unit/models/app_settings_oui_test.dart
flutter test test/unit/oui_functionality_test.dart
```

## Test Results

All tests pass successfully with expected error logging for platform channel limitations in the test environment.

Total Tests: 43 tests across 3 files
Status: ✅ All tests passing

## Future Improvements

1. **Mock Platform Channels**: Could add mocking for path_provider to test file system operations without platform dependencies.

2. **Widget Testing**: Create mock implementations for Flutter Blue Plus to enable widget testing in the test environment.

3. **Integration Testing**: Add integration tests that work with actual file system and network operations in a controlled environment.

4. **Performance Testing**: Add tests for large OUI database performance and memory usage.
