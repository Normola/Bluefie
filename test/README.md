# Testing Configuration for Blufie

## Test Structure

```
test/
├── unit/                     # Unit tests
│   ├── models/              # Model tests
│   ├── services/            # Service tests
│   └── utils/               # Utility tests
├── widget/                  # Widget tests
├── integration/             # Integration tests
├── mocks/                   # Mock definitions
├── test_helpers.dart        # Test utilities
└── widget_test.dart         # Main widget test
```

## Running Tests

### Using Test Scripts (Recommended)

**Windows:**
```bat
# Run all tests
.\run_tests.bat all

# Run specific categories
.\run_tests.bat unit        # All unit tests (29 tests)
.\run_tests.bat widget      # All widget tests (9 tests)
.\run_tests.bat models      # Model tests only (14 tests)
.\run_tests.bat utils       # Utils tests only (5 tests)
.\run_tests.bat services    # Service tests only (10 tests)
.\run_tests.bat coverage    # Tests with coverage
```

**Linux/macOS:**
```bash
# Run all tests
./run_tests.sh all

# Run specific categories
./run_tests.sh unit         # All unit tests (29 tests)
./run_tests.sh widget       # All widget tests (9 tests)
./run_tests.sh models       # Model tests only (14 tests)
./run_tests.sh utils        # Utils tests only (5 tests)
./run_tests.sh services     # Service tests only (10 tests)
./run_tests.sh coverage     # Tests with coverage
```

### Direct Flutter Commands

### All Tests (38 total)
```bash
flutter test
```

### Unit Tests Only (29 tests)
```bash
flutter test test/unit/
```

### Widget Tests Only (9 tests)
```bash
flutter test test/widget/
flutter test test/widget_test.dart
```

### Specific Test File
```bash
flutter test test/unit/models/app_settings_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

## Test Coverage Setup

### Prerequisites
Install these VS Code extensions:
1. **Flutter Coverage** (`Flutterando.flutter-coverage`)
2. **Coverage Gutters** (`ryanluker.vscode-coverage-gutters`)

### Generating Coverage Reports

**Using Scripts:**
```bat
# Windows
.\run_tests.bat coverage

# Linux/macOS
./run_tests.sh coverage
```

**Using Flutter directly:**
```bash
flutter test --coverage
```

**Using VS Code Tasks:**
1. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
2. Type "Tasks: Run Task"
3. Select "Flutter: Test with Coverage"

### Viewing Coverage in VS Code

After generating coverage, you have multiple options:

#### Option 1: Coverage Gutters (Recommended)
1. Open any Dart file in your project
2. Press `Ctrl+Shift+P` (`Cmd+Shift+P` on macOS)
3. Type "Coverage Gutters: Display Coverage"
4. Select the command
5. Coverage indicators will appear in the gutter:
   - 🟢 **Green**: Covered lines
   - 🔴 **Red**: Uncovered lines
   - 🟡 **Yellow**: Partially covered lines

#### Option 2: Flutter Coverage Extension
1. Open any Dart file
2. Coverage should automatically display if enabled
3. Use Command Palette: "Flutter Coverage: Toggle"

#### Option 3: VS Code Status Bar
- Coverage percentage shows in the status bar
- Click to toggle coverage display

### Coverage Configuration

The project is configured with:
- **Coverage file**: `coverage/lcov.info`
- **Gutter indicators**: Enabled
- **Line highlighting**: Enabled
- **Ruler indicators**: Enabled
- **Auto-refresh**: On file save

### Coverage Reports Location
- **LCOV report**: `coverage/lcov.info`
- **Human-readable**: Use extensions above or online LCOV viewers

### Keyboard Shortcuts
- **Toggle Coverage**: `Ctrl+Shift+7` (or set custom shortcut)
- **Generate + Display**: Run the "Coverage: Display in VS Code" task

## Test Status: ✅ All Working

**Total Tests: 38 passing**

### Unit Tests ✅ (29 tests)
- ✅ Model tests (14 tests): Serialization, deserialization, validation
- ✅ Service tests (10 tests): Business logic, settings management, streams
- ✅ Utility tests (5 tests): Stream controllers, helper functions

### Widget Tests ✅ (9 tests)
- ✅ Component tests (6 tests): ScanResultTile behavior, mocking, interactions
- ✅ App-level tests (3 tests): Basic structure, title, screen instantiation
- Widget state management
- Layout rendering

### Integration Tests 📋
- End-to-end workflows
- Database operations
- Bluetooth scanning
- Location services
- Settings persistence

## Mock Generation

To generate mocks for testing:

```bash
flutter packages pub run build_runner build
```

This will generate mock files in `test/mocks/` based on the annotations in `test/mocks/mocks.dart`.

## Testing Best Practices

1. **Follow AAA Pattern**: Arrange, Act, Assert
2. **Use descriptive test names**: `should_return_false_when_mac_address_is_invalid`
3. **Test edge cases**: null values, empty strings, extreme numbers
4. **Mock external dependencies**: databases, HTTP calls, platform services
5. **Use test helpers**: Create reusable test data and assertions
6. **Group related tests**: Use `group()` to organize tests logically

## Coverage Goals

- **Unit Tests**: >90% code coverage
- **Critical Paths**: 100% coverage (settings, database, scanning)
- **Widget Tests**: All user-facing components
- **Integration Tests**: Key user workflows

## Continuous Integration

Tests should be run automatically on:
- Every commit
- Pull requests
- Release builds

Example CI command:
```bash
flutter test --reporter github
```
