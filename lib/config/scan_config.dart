class ScanConfig {
  // Default scanning intervals (can be overridden by settings)
  static const Duration defaultScanInterval = Duration(seconds: 30);
  static const Duration scanDuration = Duration(seconds: 25);

  // Location settings
  static const double minLocationUpdateDistance =
      5.0; // meters - reduced for more frequent updates
  static const Duration locationTimeout =
      Duration(seconds: 15); // increased timeout for better accuracy

  // Database settings
  static const int maxRecentDevices = 50;
  static const int defaultDataRetentionDays = 30;
  static const int cleanupDataRetentionDays = 7;

  // UI settings
  static const Duration refreshInterval = Duration(milliseconds: 500);

  // Bluetooth settings
  static const bool useAndroidFineLocation = true;
  static const List<String> requiredServiceUuids = [
    '180f'
  ]; // Battery Level Service

  // Performance settings
  static const int maxDatabaseRecords = 10000;
  static const bool enableBackgroundScanning = true;

  // Default battery settings
  static const int defaultBatteryThreshold = 20;
  static const bool defaultBatteryOptimization = true;
}
