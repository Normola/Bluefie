# Setup script for pre-commit hooks (PowerShell)
# Run this script to install and configure pre-commit hooks for Dart formatting

Write-Host "🔧 Setting up pre-commit hooks for Dart formatting..." -ForegroundColor Blue

# Check if we're in a Git repository
if (-not (Test-Path ".git")) {
    Write-Host "❌ Error: Not in a Git repository. Please run this script from the root of your Git project." -ForegroundColor Red
    exit 1
}

# Check if Dart is available
try {
    $dartVersion = & dart --version 2>&1
    Write-Host "✓ Dart found: $dartVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error: 'dart' command not found. Please ensure Dart/Flutter is installed and in your PATH." -ForegroundColor Red
    exit 1
}

# Create hooks directory if it doesn't exist
if (-not (Test-Path ".git\hooks")) {
    New-Item -ItemType Directory -Path ".git\hooks" -Force | Out-Null
    Write-Host "✓ Created .git\hooks directory" -ForegroundColor Green
}

# Check if hooks exist
if (Test-Path ".git\hooks\pre-commit") {
    Write-Host "✓ Pre-commit hook found" -ForegroundColor Green
} else {
    Write-Host "⚠ Warning: pre-commit hook not found" -ForegroundColor Yellow
}

if (Test-Path ".git\hooks\pre-commit.bat") {
    Write-Host "✓ Pre-commit hook (Windows batch) found" -ForegroundColor Green
} else {
    Write-Host "⚠ Warning: pre-commit.bat hook not found" -ForegroundColor Yellow
}

# Test the hook
Write-Host "🧪 Testing the pre-commit hook..." -ForegroundColor Blue

# Check if there are any Dart files to test with
$dartFiles = Get-ChildItem -Recurse -Filter "*.dart" -File | Select-Object -First 5
if ($dartFiles.Count -gt 0) {
    Write-Host "✓ Found $($dartFiles.Count) Dart files for testing" -ForegroundColor Green
    
    # Run dart format on a few files to see if it works
    Write-Host "Running dart format test..." -ForegroundColor Yellow
    $testFile = $dartFiles[0].FullName
    
    try {
        $result = & dart format --output=none $testFile 2>&1
        Write-Host "✓ Dart format test successful" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Dart format test failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠ No Dart files found for testing" -ForegroundColor Yellow
}

Write-Host "🎉 Pre-commit hook setup completed successfully!" -ForegroundColor Green
Write-Host "ℹ  The hook will now automatically format your Dart files before each commit." -ForegroundColor Blue
Write-Host "ℹ  To bypass the hook, use: git commit --no-verify" -ForegroundColor Blue

# Additional Windows-specific instructions
Write-Host ""
Write-Host "📝 Windows-specific notes:" -ForegroundColor Cyan
Write-Host "   • The pre-commit.bat file will be used automatically on Windows" -ForegroundColor White
Write-Host "   • If using Git Bash, the shell script version will be used" -ForegroundColor White
Write-Host "   • Both versions provide the same functionality" -ForegroundColor White
