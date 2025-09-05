class AppSettings {
  final bool autoScanningEnabled;
  final bool batteryOptimizationEnabled;
  final int batteryThresholdPercent;
  final int scanIntervalSeconds;
  final int dataRetentionDays;
  final bool locationTrackingEnabled;
  final bool verboseLoggingEnabled;
  final bool showNotifications;

  const AppSettings({
    this.autoScanningEnabled = false,
    this.batteryOptimizationEnabled = true,
    this.batteryThresholdPercent = 20,
    this.scanIntervalSeconds = 30,
    this.dataRetentionDays = 30,
    this.locationTrackingEnabled = true,
    this.verboseLoggingEnabled = false,
    this.showNotifications = true,
  });

  AppSettings copyWith({
    bool? autoScanningEnabled,
    bool? batteryOptimizationEnabled,
    int? batteryThresholdPercent,
    int? scanIntervalSeconds,
    int? dataRetentionDays,
    bool? locationTrackingEnabled,
    bool? verboseLoggingEnabled,
    bool? showNotifications,
  }) {
    return AppSettings(
      autoScanningEnabled: autoScanningEnabled ?? this.autoScanningEnabled,
      batteryOptimizationEnabled: batteryOptimizationEnabled ?? this.batteryOptimizationEnabled,
      batteryThresholdPercent: batteryThresholdPercent ?? this.batteryThresholdPercent,
      scanIntervalSeconds: scanIntervalSeconds ?? this.scanIntervalSeconds,
      dataRetentionDays: dataRetentionDays ?? this.dataRetentionDays,
      locationTrackingEnabled: locationTrackingEnabled ?? this.locationTrackingEnabled,
      verboseLoggingEnabled: verboseLoggingEnabled ?? this.verboseLoggingEnabled,
      showNotifications: showNotifications ?? this.showNotifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoScanningEnabled': autoScanningEnabled,
      'batteryOptimizationEnabled': batteryOptimizationEnabled,
      'batteryThresholdPercent': batteryThresholdPercent,
      'scanIntervalSeconds': scanIntervalSeconds,
      'dataRetentionDays': dataRetentionDays,
      'locationTrackingEnabled': locationTrackingEnabled,
      'verboseLoggingEnabled': verboseLoggingEnabled,
      'showNotifications': showNotifications,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      autoScanningEnabled: json['autoScanningEnabled'] ?? false,
      batteryOptimizationEnabled: json['batteryOptimizationEnabled'] ?? true,
      batteryThresholdPercent: json['batteryThresholdPercent'] ?? 20,
      scanIntervalSeconds: json['scanIntervalSeconds'] ?? 30,
      dataRetentionDays: json['dataRetentionDays'] ?? 30,
      locationTrackingEnabled: json['locationTrackingEnabled'] ?? true,
      verboseLoggingEnabled: json['verboseLoggingEnabled'] ?? false,
      showNotifications: json['showNotifications'] ?? true,
    );
  }

  Duration get scanInterval => Duration(seconds: scanIntervalSeconds);
  Duration get dataRetentionDuration => Duration(days: dataRetentionDays);

  @override
  String toString() {
    return 'AppSettings{autoScanningEnabled: $autoScanningEnabled, batteryThreshold: $batteryThresholdPercent%, scanInterval: ${scanIntervalSeconds}s}';
  }
}
