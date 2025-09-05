# Pre-commit Hook for Dart Formatting

This document describes the pre-commit hook setup for automatically formatting Dart code before commits.

## Overview

The pre-commit hook automatically runs `dart format` on all staged Dart files before each commit, ensuring consistent code formatting across the project.

## Files

### Hook Files (in `.git/hooks/`)
- **`pre-commit`** - Unix/Linux/macOS shell script
- **`pre-commit.bat`** - Windows batch file
- **`README.md`** - Documentation for the hooks

### Setup Scripts (in `scripts/`)
- **`setup-pre-commit-hooks.sh`** - Bash setup script for Unix/Linux/macOS
- **`setup-pre-commit-hooks.ps1`** - PowerShell setup script for Windows

## How It Works

1. When you run `git commit`, the pre-commit hook is automatically triggered
2. The hook identifies all staged Dart files (*.dart)
3. It runs `dart format` on each file to check/fix formatting
4. If files need formatting, they are automatically formatted and re-staged
5. The commit proceeds with the properly formatted files

## Installation

The hooks are already installed and active in this repository. To verify:

```bash
# Check if hooks exist
ls -la .git/hooks/pre-commit*

# On Windows
dir .git\hooks\pre-commit*
```

### Manual Installation

If you need to reinstall the hooks:

**On Windows:**
```powershell
# Run the PowerShell setup script
powershell -ExecutionPolicy Bypass -File scripts/setup-pre-commit-hooks.ps1
```

**On Unix/Linux/macOS:**
```bash
# Run the bash setup script
chmod +x scripts/setup-pre-commit-hooks.sh
./scripts/setup-pre-commit-hooks.sh
```

## Usage

The hook runs automatically on every commit. No manual intervention is required.

### Example Output

```bash
$ git commit -m "Update battery monitor screen"
Running dart format on staged files...
Formatting the following files:
lib/screens/battery_monitor_screen.dart
✓ Dart files have been formatted and re-staged.
Pre-commit formatting check completed successfully.
[master abc123] Update battery monitor screen
```

## Bypassing the Hook

If you need to commit without running the formatting hook (not recommended):

```bash
git commit --no-verify -m "commit message"
```

## Troubleshooting

### Hook Not Running
- Ensure the files exist in `.git/hooks/`
- On Unix systems, ensure the script is executable: `chmod +x .git/hooks/pre-commit`
- Verify Git can find the hook: `git config --get core.hooksPath`

### Dart Not Found
- Ensure Dart/Flutter is installed and in your PATH
- Test with: `dart --version`
- If using Flutter: `flutter dart --version`

### Permission Issues (Unix/Linux/macOS)
```bash
chmod +x .git/hooks/pre-commit
```

### Hook Fails
- Check that all Dart files are valid and can be formatted
- Run manually: `dart format lib/`
- Check for syntax errors in your Dart files

## Testing the Hook

To test the pre-commit hook:

1. Make changes to a Dart file
2. Stage the changes: `git add .`
3. Commit: `git commit -m "test"`
4. Observe the hook output

## Configuration

The hook is configured to:
- Format all staged `.dart` files
- Re-stage formatted files automatically
- Continue with commit if formatting succeeds
- Abort commit if `dart format` fails

## Benefits

- **Consistent Formatting**: All committed code follows the same formatting rules
- **Automatic**: No need to remember to run `dart format` manually
- **Team Collaboration**: Reduces formatting-related diffs and conflicts
- **Code Quality**: Maintains clean, readable code standards

## Dependencies

- Git (obviously)
- Dart SDK (Flutter includes Dart)
- Unix/Linux/macOS: bash shell
- Windows: cmd.exe or PowerShell

## Integration with IDEs

This hook complements IDE formatting but doesn't replace it. Consider:
- Setting up format-on-save in your IDE
- Configuring your IDE to use the same Dart formatting rules
- Using the same formatting settings across your team

## Related Files

- `analysis_options.yaml` - Dart analysis and linting configuration
- `.gitignore` - Excludes formatted temporary files
- `pubspec.yaml` - Project dependencies including `flutter_lints`
