@echo off
REM Test Runner Script for Blufie (Windows)
REM Usage: run_tests.bat [test_type]

echo 🧪 Blufie Test Runner
echo ====================

if "%1"=="models" (
    echo 📋 Running Model tests...
    flutter test test/unit/models/
    echo ✅ Model tests completed successfully!
    goto :end
)

if "%1"=="utils" (
    echo � Running Utils tests...
    flutter test test/unit/utils/
    echo ✅ Utils tests completed successfully!
    goto :end
)

if "%1"=="services" (
    echo �️ Running Service tests...
    flutter test test/unit/services/
    echo ✅ Service tests completed successfully!
    goto :end
)

if "%1"=="unit" (
    echo 📋 Running all Unit tests...
    flutter test test/unit/
    echo ✅ All unit tests completed successfully!
    goto :end
)

if "%1"=="widget" (
    echo 🎨 Running Widget tests...
    flutter test test/widget/
    flutter test test/widget_test.dart
    echo ✅ Widget tests completed successfully!
    goto :end
)

if "%1"=="coverage" (
    echo 📊 Running tests with coverage...
    flutter test --coverage
    echo Coverage report generated in coverage/lcov.info
    echo 💡 To view in VS Code:
    echo    1. Open any Dart file
    echo    2. Press Ctrl+Shift+P
    echo    3. Type "Coverage Gutters: Display Coverage"
    echo    4. Coverage will show in the gutter
    goto :end
)

REM Default case (all or no argument)
echo 🚀 Running complete test suite...
echo.
echo 📋 Running Model tests...
flutter test test/unit/models/
echo.
echo � Running Utils tests...
flutter test test/unit/utils/
echo.
echo 🛠️ Running Service tests...
flutter test test/unit/services/
echo.
echo 🎨 Running Widget component tests...
flutter test test/widget/
echo.
echo 🎨 Running App-level widget tests...
flutter test test/widget_test.dart
echo.
echo ✨ Complete test suite completed successfully!

:end
echo 🎉 Test run completed!
