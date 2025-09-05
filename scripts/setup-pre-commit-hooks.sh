#!/bin/bash
#
# Setup script for pre-commit hooks
# Run this script to install and configure pre-commit hooks for Dart formatting
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Setting up pre-commit hooks for Dart formatting...${NC}"

# Check if we're in a Git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: Not in a Git repository. Please run this script from the root of your Git project.${NC}"
    exit 1
fi

# Check if Dart is available
if ! command -v dart &> /dev/null; then
    echo -e "${RED}❌ Error: 'dart' command not found. Please ensure Dart/Flutter is installed and in your PATH.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Dart found: $(dart --version 2>&1)${NC}"

# Create hooks directory if it doesn't exist
if [ ! -d ".git/hooks" ]; then
    mkdir -p .git/hooks
    echo -e "${GREEN}✓ Created .git/hooks directory${NC}"
fi

# Make the pre-commit hook executable (Unix/Linux/macOS)
if [ -f ".git/hooks/pre-commit" ]; then
    chmod +x .git/hooks/pre-commit
    echo -e "${GREEN}✓ Made pre-commit hook executable${NC}"
else
    echo -e "${YELLOW}⚠ Warning: pre-commit hook not found${NC}"
fi

# Test the hook
echo -e "${BLUE}🧪 Testing the pre-commit hook...${NC}"

# Check if there are any Dart files to test with
DART_FILES=$(find . -name "*.dart" -type f | head -5)
if [ -n "$DART_FILES" ]; then
    echo -e "${GREEN}✓ Found Dart files for testing${NC}"
    
    # Run dart format on a few files to see if it works
    echo -e "${YELLOW}Running dart format test...${NC}"
    echo "$DART_FILES" | head -1 | xargs dart format --output=none
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Dart format test successful${NC}"
    else
        echo -e "${RED}❌ Dart format test failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ No Dart files found for testing${NC}"
fi

echo -e "${GREEN}🎉 Pre-commit hook setup completed successfully!${NC}"
echo -e "${BLUE}ℹ  The hook will now automatically format your Dart files before each commit.${NC}"
echo -e "${BLUE}ℹ  To bypass the hook, use: git commit --no-verify${NC}"
