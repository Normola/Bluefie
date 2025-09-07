# OUI Download Issue Fix - Release APK Network Connectivity

## Problem
OUI database download works in debug APK but fails in release APK builds.

## Root Cause
The Android app was missing the `INTERNET` permission in `AndroidManifest.xml`. While debug builds often get some permissions automatically, release builds require explicit permission declarations.

## Fixed Files

### 1. android/app/src/main/AndroidManifest.xml
**Added:**
- `<uses-permission android:name="android.permission.INTERNET" />` - Required for HTTP/HTTPS requests
- `android:networkSecurityConfig="@xml/network_security_config"` - Reference to network security configuration

### 2. android/app/src/main/res/xml/network_security_config.xml (NEW FILE)
**Created network security configuration:**
- Explicitly allows HTTPS connections to `standards-oui.ieee.org`
- Enforces secure connections (no cleartext traffic)
- Uses system certificate authorities for SSL verification

### 3. lib/services/oui_service.dart
**Enhanced error handling and diagnostics:**
- Added User-Agent header for better server compatibility
- Improved error logging with stack traces
- Added specific error type detection (SocketException, HandshakeException, etc.)
- Added `testNetworkConnectivity()` method for diagnostics

### 4. lib/screens/settings_screen.dart
**Added network testing capability:**
- New "Test Network" button for debugging connectivity issues
- Shows success/failure messages for network tests
- Only visible in debug mode or when database is not loaded

## Testing Instructions

### 1. Build and Test Release APK
```bash
# Build release APK
flutter build apk --release

# Install on device
flutter install --release
```

### 2. Test Network Connectivity
1. Open Blufie app
2. Go to Settings
3. Enable "Show Manufacturer Names"
4. If download fails, use "Test Network" button to diagnose
5. Try "Download Database" button

### 3. Check Logs (if needed)
```bash
# View logs while testing
adb logcat | grep -E "(OUI|Network|Blufie)"
```

### Expected Log Messages (Success)
```
I/flutter: Testing network connectivity to IEEE OUI server...
I/flutter: Network test response: 200
I/flutter: Network connectivity test successful
I/flutter: Downloading OUI database from IEEE...
I/flutter: OUI download response: 200
I/flutter: OUI database downloaded and parsed successfully (XXXXX entries)
```

### Expected Log Messages (Failure - Before Fix)
```
I/flutter: Error downloading OUI database: SocketException: Failed to connect to standards-oui.ieee.org
I/flutter: Network connection error - check internet connectivity and firewall settings
```

## Additional Considerations

### Network Security
- The app now enforces HTTPS-only connections
- Uses system certificate authorities for SSL verification
- Blocks cleartext (HTTP) traffic for security

### Compatibility
- Works with Android API 21+ (existing requirement)
- No impact on existing functionality
- Backward compatible with existing installations

### Debugging Features
- Network connectivity test button (debug mode)
- Enhanced error messages with specific diagnostics
- User-Agent header for better server interaction

## Verification Checklist

- [ ] Release APK can download OUI database
- [ ] Network test button works in debug mode
- [ ] Error messages are informative if network fails
- [ ] HTTPS connections work properly
- [ ] No security warnings in logs
- [ ] App still works offline after successful download

## Common Issues & Solutions

### If download still fails:
1. **Check device internet connection** - Test with browser
2. **Corporate firewall** - May block HTTPS to non-standard domains
3. **VPN interference** - Try without VPN
4. **DNS issues** - Try using different DNS (8.8.8.8)

### If SSL/TLS errors occur:
1. **Check device date/time** - SSL certificates are time-sensitive
2. **Update device** - Older Android versions may lack modern certificates
3. **Check device certificate store** - May be corrupted

## Files Modified Summary
```
android/app/src/main/AndroidManifest.xml          - Added INTERNET permission
android/app/src/main/res/xml/network_security_config.xml  - NEW: Network security config
lib/services/oui_service.dart                     - Enhanced error handling & diagnostics
lib/screens/settings_screen.dart                  - Added network test button
```

The fix addresses the core issue while adding robust diagnostics for future troubleshooting.
