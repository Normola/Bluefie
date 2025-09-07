#!/bin/bash

# Local CI Testing Script
# This script runs the same checks that GitHub Actions will run

set -e

echo "🧪 Running local CI checks..."
echo "================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Check formatting
echo "🎨 Checking code formatting..."
if ! dart format --output=none --set-exit-if-changed .; then
    echo "❌ Code formatting issues found. Run 'dart format .' to fix."
    exit 1
fi
echo "✅ Code formatting is correct"

# Run analysis
echo "🔍 Running code analysis..."
if ! flutter analyze --fatal-infos; then
    echo "❌ Code analysis failed"
    exit 1
fi
echo "✅ Code analysis passed"

# Check for outdated dependencies
echo "📋 Checking for outdated dependencies..."
flutter pub outdated

# Run tests
echo "🧪 Running tests..."
if ! flutter test --no-coverage; then
    echo "❌ Tests failed"
    exit 1
fi
echo "✅ Tests passed"

# Test debug build
echo "🏗️ Testing debug build..."
if ! flutter build apk --debug --quiet; then
    echo "❌ Debug build failed"
    exit 1
fi
echo "✅ Debug build successful"

# Check APK size
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(stat -c%s "$APK_PATH" 2>/dev/null || stat -f%z "$APK_PATH" 2>/dev/null || echo "unknown")
    if [ "$APK_SIZE" != "unknown" ]; then
        APK_SIZE_MB=$(echo "scale=2; $APK_SIZE / 1024 / 1024" | bc -l 2>/dev/null || echo "unknown")
        echo "📱 APK size: ${APK_SIZE_MB} MB"

        # Warn if APK is larger than 100MB
        if command -v bc &> /dev/null && [ "$APK_SIZE_MB" != "unknown" ]; then
            if (( $(echo "$APK_SIZE_MB > 100" | bc -l) )); then
                echo "⚠️  Warning: APK size (${APK_SIZE_MB} MB) is larger than 100MB"
            fi
        fi
    fi
fi

echo ""
echo "🎉 All local CI checks passed!"
echo "✅ Your code is ready for CI/CD pipeline"
echo ""
echo "Next steps:"
echo "  1. Commit your changes"
echo "  2. Push to GitHub"
echo "  3. CI will run automatically"
echo "  4. Create a PR for review"
