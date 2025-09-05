# GitHub Actions Quick Reference

## 🚀 Available Workflows

### 1. **CI** (`ci.yml`)
**When it runs**: Every push/PR to main branches
```yaml
Triggers: push, pull_request
Duration: ~3-5 minutes
Artifacts: debug-apk (7 days)
```
**What it does**:
- ✅ Code formatting & analysis
- 🧪 Unit & widget tests
- 🏗️ Debug build validation
- 📊 Coverage reporting
- 🔒 Security dependency check

### 2. **Android Build Pipeline** (`android-build.yml`)
**When it runs**: Push/PR + manual trigger
```yaml
Triggers: push, pull_request, workflow_dispatch
Duration: ~8-12 minutes
Artifacts: debug/release/profile APKs (30-90 days)
```
**What it does**:
- 🧪 Full test suite
- 🏗️ Multi-build (debug/release/profile)
- 📏 APK size analysis
- 🔍 Security scanning
- 📦 Artifact management

### 3. **Android Release** (`android-release.yml`)
**When it runs**: Manual trigger only
```yaml
Triggers: workflow_dispatch
Duration: ~10-15 minutes
Artifacts: Signed APK/AAB + GitHub Release
```
**What it does**:
- 🔢 Version bumping (patch/minor/major)
- 🏗️ Signed release builds
- 📦 GitHub release creation
- 🎯 Optional Play Store deployment
- 📬 Team notifications

### 4. **Flutter Compatibility** (`flutter-compatibility.yml`)
**When it runs**: Weekly + manual trigger
```yaml
Triggers: schedule (weekly), workflow_dispatch
Duration: ~15-20 minutes
Artifacts: Compatibility reports
```
**What it does**:
- 🧪 Test multiple Flutter versions
- 📊 Compatibility matrix
- 🚨 Issue creation on failures
- 📋 Detailed compatibility reports

### 5. **Dependency Updates** (`dependency-updates.yml`)
**When it runs**: Monthly + manual trigger
```yaml
Triggers: schedule (monthly), workflow_dispatch
Duration: ~5-8 minutes
Artifacts: Dependency reports + PRs
```
**What it does**:
- 📦 Check for outdated packages
- 🔄 Automatic dependency updates
- 🧪 Test after updates
- 📝 Create update PRs
- 🔒 Security audit

## 🎯 Manual Workflow Triggers

### Start a Build
1. Go to **Actions** tab
2. Select **Android Build Pipeline**
3. Click **Run workflow**
4. Choose build type: `debug` | `release` | `profile`

### Create a Release
1. Go to **Actions** tab
2. Select **Android Release**
3. Click **Run workflow**
4. Configure:
   - Version bump: `patch` | `minor` | `major`
   - Release notes (optional)
   - Deploy to Play Store: ☑️ (optional)

### Check Compatibility
1. Go to **Actions** tab
2. Select **Flutter Compatibility Matrix**
3. Click **Run workflow**
4. Optionally specify Flutter versions

### Update Dependencies
1. Go to **Actions** tab
2. Select **Dependency Updates**
3. Click **Run workflow**
4. Choose update type: `patch` | `minor` | `major`

## 📊 Artifacts & Retention

| Artifact Type | Retention | Workflow | Use Case |
|---------------|-----------|----------|----------|
| Debug APK | 7-30 days | CI, Build Pipeline | Development testing |
| Profile APK | 30 days | Build Pipeline | Performance testing |
| Release APK/AAB | 90 days | Build Pipeline, Release | Production deployment |
| Coverage Reports | 30 days | CI | Code coverage analysis |
| Security Reports | 30 days | All | Security monitoring |
| Dependency Reports | 7-30 days | Dependency Updates | Update tracking |

## 🔧 Required Secrets

### For Release Builds
```
KEYSTORE_BASE64      # Base64 encoded keystore
KEYSTORE_PASSWORD    # Keystore password
KEY_ALIAS           # Key alias
KEY_PASSWORD        # Key password
```

### For Play Store Deployment (Optional)
```
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON  # Service account JSON
```

## 🚨 Common Issues & Solutions

### Build Fails - Signing Issues
```bash
# Check secrets are set correctly
# Verify keystore is properly base64 encoded
base64 -i your-keystore.jks
```

### Tests Fail on CI
```bash
# Run local CI script first
./scripts/local-ci.sh  # Linux/macOS
scripts\local-ci.bat   # Windows
```

### APK Too Large
```bash
# Use split APKs
flutter build apk --split-per-abi
# Enable R8 shrinking in build.gradle
```

### Dependency Conflicts
```bash
# Check compatibility
flutter pub deps
# Resolve conflicts manually
flutter pub upgrade --major-versions
```

## 📈 Status Badges

Add these to your README:

```markdown
[![CI](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/CI/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/ci.yml)

[![Android Build](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/Android%20Build%20Pipeline/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/android-build.yml)

[![codecov](https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO/branch/main/graph/badge.svg)](https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO)
```

## 🔗 Useful Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console](https://play.google.com/console)

## ⚡ Quick Commands

### Local Testing
```bash
# Run all CI checks locally
./scripts/local-ci.sh

# Run specific checks
flutter analyze
flutter test
dart format --set-exit-if-changed .
flutter build apk --debug
```

### Manual Version Bump
```bash
# Update version in pubspec.yaml
version: 1.2.3+4  # version+build

# Commit and tag
git add pubspec.yaml
git commit -m "chore: bump version to 1.2.3+4"
git tag v1.2.3
git push --tags
```

### Emergency Rollback
```bash
# Revert last release
git revert HEAD
git push origin main

# Or reset to previous version
git reset --hard HEAD~1
git push --force origin main
```
