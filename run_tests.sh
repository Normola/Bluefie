#!/bin/bash

# Test Runner Script for Blufie
# Usage: ./run_tests.sh [test_type]

set -e

echo "🧪 Blufie Test Runner"
echo "===================="

# Function to run specific test categories
run_tests() {
    local test_path=$1
    local test_name=$2

    echo "📋 Running $test_name tests..."
    flutter test "$test_path"
    echo "✅ $test_name tests completed successfully!"
    echo ""
}

# Check arguments
case "${1:-all}" in
    "models")
        run_tests "test/unit/models/" "Model"
        ;;
    "utils")
        run_tests "test/unit/utils/" "Utils"
        ;;
    "services")
        run_tests "test/unit/services/" "Service"
        ;;
    "unit")
        echo "📋 Running all Unit tests..."
        flutter test test/unit/
        echo "✅ All unit tests completed successfully!"
        echo ""
        ;;
    "widget")
        echo "🎨 Running Widget tests..."
        flutter test test/widget/
        flutter test test/widget_test.dart
        echo "✅ Widget tests completed successfully!"
        echo ""
        ;;
    "coverage")
        echo "📊 Running tests with coverage..."
        flutter test --coverage
        echo "Coverage report generated in coverage/lcov.info"
        echo "💡 To view in VS Code:"
        echo "   1. Open any Dart file"
        echo "   2. Press Ctrl+Shift+P (Cmd+Shift+P on Mac)"
        echo "   3. Type 'Coverage Gutters: Display Coverage'"
        echo "   4. Coverage will show in the gutter"
        ;;
    "all")
        echo "🚀 Running complete test suite..."
        echo ""
        run_tests "test/unit/models/" "Model"
        run_tests "test/unit/utils/" "Utils"
        run_tests "test/unit/services/" "Service"
        echo "🎨 Running Widget component tests..."
        flutter test test/widget/
        echo "✅ Widget component tests completed successfully!"
        echo ""
        echo "🎨 Running App-level widget tests..."
        flutter test test/widget_test.dart
        echo "✅ App-level widget tests completed successfully!"
        echo ""
        echo "✨ Complete test suite completed successfully!"
        ;;
    *)
        echo "Usage: $0 [models|utils|services|unit|widget|coverage|all]"
        echo ""
        echo "Available test categories:"
        echo "  models     - Run model tests only"
        echo "  utils      - Run utility tests only"
        echo "  services   - Run service tests only"
        echo "  unit       - Run all unit tests"
        echo "  widget     - Run all widget tests"
        echo "  coverage   - Run tests with coverage"
        echo "  all        - Run complete test suite (default)"
        exit 1
        ;;
esac

echo "🎉 Test run completed!"
