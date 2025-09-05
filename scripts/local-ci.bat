@echo off
REM Local CI Testing Script for Windows
REM This script runs the same checks that GitHub Actions will run

echo 🧪 Running local CI checks...
echo ================================

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed or not in PATH
    exit /b 1
)

for /f "tokens=*" %%i in ('flutter --version ^| findstr Flutter') do set FLUTTER_VERSION=%%i
echo ✅ Flutter found: %FLUTTER_VERSION%

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to get dependencies
    exit /b 1
)

REM Check formatting
echo 🎨 Checking code formatting...
dart format --output=none --set-exit-if-changed .
if %errorlevel% neq 0 (
    echo ❌ Code formatting issues found. Run 'dart format .' to fix.
    exit /b 1
)
echo ✅ Code formatting is correct

REM Run analysis
echo 🔍 Running code analysis...
flutter analyze --fatal-infos
if %errorlevel% neq 0 (
    echo ❌ Code analysis failed
    exit /b 1
)
echo ✅ Code analysis passed

REM Check for outdated dependencies
echo 📋 Checking for outdated dependencies...
flutter pub outdated

REM Run tests
echo 🧪 Running tests...
flutter test --no-coverage
if %errorlevel% neq 0 (
    echo ❌ Tests failed
    exit /b 1
)
echo ✅ Tests passed

REM Test debug build
echo 🏗️ Testing debug build...
flutter build apk --debug --quiet
if %errorlevel% neq 0 (
    echo ❌ Debug build failed
    exit /b 1
)
echo ✅ Debug build successful

REM Check APK size
set APK_PATH=build\app\outputs\flutter-apk\app-debug.apk
if exist "%APK_PATH%" (
    for %%A in ("%APK_PATH%") do set APK_SIZE=%%~zA
    set /a APK_SIZE_MB=%APK_SIZE% / 1048576
    echo 📱 APK size: approximately %APK_SIZE_MB% MB

    if %APK_SIZE_MB% gtr 50 (
        echo ⚠️  Warning: APK size (%APK_SIZE_MB% MB^) is larger than 50MB
    )
)

echo.
echo 🎉 All local CI checks passed!
echo ✅ Your code is ready for CI/CD pipeline
echo.
echo Next steps:
echo   1. Commit your changes
echo   2. Push to GitHub
echo   3. CI will run automatically
echo   4. Create a PR for review

pause
