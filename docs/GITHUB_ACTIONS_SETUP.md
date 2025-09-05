# GitHub Actions Android Build Pipeline

This repository includes comprehensive GitHub Actions workflows for building, testing, and deploying your Flutter Android application.

## Workflows Overview

### 1. CI Workflow (`ci.yml`)
**Triggers**: Push to main branches, Pull Requests
- Code analysis and formatting checks
- Unit and widget tests with coverage reporting
- Debug APK builds for validation
- Security dependency checks
- APK size validation for PRs

### 2. Android Build Pipeline (`android-build.yml`)
**Triggers**: Push to main branches, Pull Requests, Manual dispatch
- Comprehensive testing suite
- Debug, Profile, and Release builds
- APK size analysis
- Security scanning
- Artifact upload with retention policies

### 3. Android Release (`android-release.yml`)
**Triggers**: Manual dispatch only
- Automatic version bumping
- GitHub release creation
- Optional Google Play Store deployment
- Team notifications

## Setup Instructions

### 1. Required Secrets

For release builds and Play Store deployment, configure these secrets in your repository settings:

#### Android Signing (Required for release builds)
```
KEYSTORE_BASE64          # Base64 encoded keystore file
KEYSTORE_PASSWORD        # Keystore password
KEY_ALIAS               # Key alias
KEY_PASSWORD            # Key password
```

#### Google Play Store (Optional)
```
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON  # Service account JSON for Play Store API
```

### 2. Setting up Android Signing

1. **Generate a keystore** (if you don't have one):
   ```bash
   keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
   ```

2. **Convert keystore to base64**:
   ```bash
   # On Linux/macOS
   base64 -i release-key.jks -o keystore.base64

   # On Windows
   certutil -encode release-key.jks keystore.base64
   ```

3. **Add the base64 content** to `KEYSTORE_BASE64` secret in GitHub

4. **Update android/app/build.gradle** to use signing config:
   ```gradle
   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile file(keystoreProperties['storeFile'])
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

### 3. Google Play Store Setup (Optional)

1. **Create a service account** in Google Cloud Console
2. **Enable Google Play Developer API**
3. **Download the service account JSON**
4. **Add JSON content** to `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret

## Usage

### Continuous Integration
The CI workflow runs automatically on:
- Push to `master`, `main`, or `develop` branches
- Pull requests to these branches

### Manual Builds
1. Go to **Actions** tab in your repository
2. Select **Android Build Pipeline**
3. Click **Run workflow**
4. Choose build type: `debug`, `release`, or `profile`

### Release Deployment
1. Go to **Actions** tab in your repository
2. Select **Android Release**
3. Click **Run workflow**
4. Configure:
   - **Version bump**: `patch`, `minor`, or `major`
   - **Release notes**: Optional description
   - **Deploy to Play Store**: Check to deploy automatically

## Build Artifacts

### Debug Builds
- **Retention**: 30 days
- **Use case**: Development and testing
- **Automatic**: Yes (on CI)

### Release Builds
- **Retention**: 90 days
- **Use case**: Production releases
- **Automatic**: On main branch pushes
- **Manual**: Via workflow dispatch

### Profile Builds
- **Retention**: 30 days
- **Use case**: Performance testing
- **Automatic**: On pull requests

## Coverage Reports

Test coverage is automatically uploaded to Codecov. To set up:

1. **Sign up at [codecov.io](https://codecov.io)**
2. **Connect your repository**
3. **Add coverage badge** to your README:
   ```markdown
   [![codecov](https://codecov.io/gh/yourusername/yourrepo/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/yourrepo)
   ```

## Customization

### Flutter Version
Update the `FLUTTER_VERSION` environment variable in workflow files:
```yaml
env:
  FLUTTER_VERSION: '3.24.3'  # Update this
```

### Java Version
Update the `JAVA_VERSION` environment variable:
```yaml
env:
  JAVA_VERSION: '11'  # Update this
```

### APK Size Limits
Modify the size check in `ci.yml`:
```bash
if (( $(echo "$APK_SIZE_MB > 50" | bc -l) )); then  # Change 50 to your limit
```

### Build Triggers
Modify the `on` section in workflow files to change trigger conditions:
```yaml
on:
  push:
    branches: [master, main, develop, feature/*]  # Add more branches
  pull_request:
    branches: [master, main]
```

## Troubleshooting

### Common Issues

1. **Build fails with signing errors**
   - Verify all signing secrets are set correctly
   - Check keystore file is properly base64 encoded
   - Ensure key.properties format is correct

2. **Tests fail on CI but pass locally**
   - Check for platform-specific test code
   - Verify all test dependencies are in pubspec.yaml
   - Check for hardcoded paths or environment-specific code

3. **APK size too large**
   - Use `flutter build apk --split-per-abi` for multiple APKs
   - Enable R8/ProGuard for better optimization
   - Remove unused dependencies

4. **Play Store upload fails**
   - Verify service account has proper permissions
   - Check package name matches exactly
   - Ensure version code is higher than current release

### Getting Help

1. **Check workflow logs** in the Actions tab
2. **Review Flutter doctor** output in CI logs
3. **Validate local builds** before pushing
4. **Check dependency compatibility** with `flutter pub deps`

## Security Best Practices

1. **Never commit keystore files** to repository
2. **Use secrets** for all sensitive data
3. **Regularly update** dependencies
4. **Monitor security** audit results
5. **Use least privilege** for service accounts

## Performance Optimization

1. **Enable caching** for dependencies (already configured)
2. **Use matrix builds** for multiple architectures if needed
3. **Parallelize jobs** where possible
4. **Optimize Docker layers** if using custom containers

## Next Steps

1. **Set up signing secrets** for release builds
2. **Configure Codecov** for coverage reporting
3. **Customize workflows** for your specific needs
4. **Set up notifications** (Slack, email, etc.)
5. **Add integration tests** if needed
6. **Configure automated deployment** to Play Store
