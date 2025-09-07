class AppSettings {
  final bool autoScanningEnabled;
  final bool batteryOptimizationEnabled;
  final bool backgroundScanningEnabled;
  final int batteryThresholdPercent;
  final int scanIntervalSeconds;
  final int dataRetentionDays;
  final bool locationTrackingEnabled;
  final bool verboseLoggingEnabled;
  final bool showNotifications;
  final bool autoScanWhenPluggedIn;
  final bool ouiDatabaseEnabled;
  final DateTime? ouiDatabaseLastUpdated;
  final bool watchListEnabled;
  final bool watchListAudioAlertsEnabled;
  final List<String> watchListDevices;
  final bool sigDatabaseEnabled;
  final DateTime? sigDatabaseLastUpdated;

  const AppSettings({
    this.autoScanningEnabled = false,
    this.batteryOptimizationEnabled =
        false, // Changed to false for background scanning
    this.backgroundScanningEnabled = true,
    this.batteryThresholdPercent = 20,
    this.scanIntervalSeconds = 30,
    this.dataRetentionDays = 30,
    this.locationTrackingEnabled = true,
    this.verboseLoggingEnabled = false,
    this.showNotifications = true,
    this.autoScanWhenPluggedIn = false,
    this.ouiDatabaseEnabled = false,
    this.ouiDatabaseLastUpdated,
    this.watchListEnabled = false,
    this.watchListAudioAlertsEnabled = true,
    this.watchListDevices = const [],
    this.sigDatabaseEnabled = false,
    this.sigDatabaseLastUpdated,
  });

  AppSettings copyWith({
    bool? autoScanningEnabled,
    bool? batteryOptimizationEnabled,
    bool? backgroundScanningEnabled,
    int? batteryThresholdPercent,
    int? scanIntervalSeconds,
    int? dataRetentionDays,
    bool? locationTrackingEnabled,
    bool? verboseLoggingEnabled,
    bool? showNotifications,
    bool? autoScanWhenPluggedIn,
    bool? ouiDatabaseEnabled,
    DateTime? ouiDatabaseLastUpdated,
    bool? watchListEnabled,
    bool? watchListAudioAlertsEnabled,
    List<String>? watchListDevices,
    bool? sigDatabaseEnabled,
    DateTime? sigDatabaseLastUpdated,
  }) {
    return AppSettings(
      autoScanningEnabled: autoScanningEnabled ?? this.autoScanningEnabled,
      batteryOptimizationEnabled:
          batteryOptimizationEnabled ?? this.batteryOptimizationEnabled,
      backgroundScanningEnabled:
          backgroundScanningEnabled ?? this.backgroundScanningEnabled,
      batteryThresholdPercent:
          batteryThresholdPercent ?? this.batteryThresholdPercent,
      scanIntervalSeconds: scanIntervalSeconds ?? this.scanIntervalSeconds,
      dataRetentionDays: dataRetentionDays ?? this.dataRetentionDays,
      locationTrackingEnabled:
          locationTrackingEnabled ?? this.locationTrackingEnabled,
      verboseLoggingEnabled:
          verboseLoggingEnabled ?? this.verboseLoggingEnabled,
      showNotifications: showNotifications ?? this.showNotifications,
      autoScanWhenPluggedIn:
          autoScanWhenPluggedIn ?? this.autoScanWhenPluggedIn,
      ouiDatabaseEnabled: ouiDatabaseEnabled ?? this.ouiDatabaseEnabled,
      ouiDatabaseLastUpdated:
          ouiDatabaseLastUpdated ?? this.ouiDatabaseLastUpdated,
      watchListEnabled: watchListEnabled ?? this.watchListEnabled,
      watchListAudioAlertsEnabled:
          watchListAudioAlertsEnabled ?? this.watchListAudioAlertsEnabled,
      watchListDevices: watchListDevices ?? this.watchListDevices,
      sigDatabaseEnabled: sigDatabaseEnabled ?? this.sigDatabaseEnabled,
      sigDatabaseLastUpdated:
          sigDatabaseLastUpdated ?? this.sigDatabaseLastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoScanningEnabled': autoScanningEnabled,
      'batteryOptimizationEnabled': batteryOptimizationEnabled,
      'backgroundScanningEnabled': backgroundScanningEnabled,
      'batteryThresholdPercent': batteryThresholdPercent,
      'scanIntervalSeconds': scanIntervalSeconds,
      'dataRetentionDays': dataRetentionDays,
      'locationTrackingEnabled': locationTrackingEnabled,
      'verboseLoggingEnabled': verboseLoggingEnabled,
      'showNotifications': showNotifications,
      'autoScanWhenPluggedIn': autoScanWhenPluggedIn,
      'ouiDatabaseEnabled': ouiDatabaseEnabled,
      'ouiDatabaseLastUpdated': ouiDatabaseLastUpdated?.millisecondsSinceEpoch,
      'watchListEnabled': watchListEnabled,
      'watchListAudioAlertsEnabled': watchListAudioAlertsEnabled,
      'watchListDevices': watchListDevices,
      'sigDatabaseEnabled': sigDatabaseEnabled,
      'sigDatabaseLastUpdated': sigDatabaseLastUpdated?.millisecondsSinceEpoch,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      autoScanningEnabled: json['autoScanningEnabled'] ?? false,
      batteryOptimizationEnabled:
          json['batteryOptimizationEnabled'] ?? false, // Changed default
      backgroundScanningEnabled: json['backgroundScanningEnabled'] ?? true,
      batteryThresholdPercent: json['batteryThresholdPercent'] ?? 20,
      scanIntervalSeconds: json['scanIntervalSeconds'] ?? 30,
      dataRetentionDays: json['dataRetentionDays'] ?? 30,
      locationTrackingEnabled: json['locationTrackingEnabled'] ?? true,
      verboseLoggingEnabled: json['verboseLoggingEnabled'] ?? false,
      showNotifications: json['showNotifications'] ?? true,
      autoScanWhenPluggedIn: json['autoScanWhenPluggedIn'] ?? false,
      ouiDatabaseEnabled: json['ouiDatabaseEnabled'] ?? false,
      ouiDatabaseLastUpdated: json['ouiDatabaseLastUpdated'] != null
          ? (json['ouiDatabaseLastUpdated'] is int
              ? DateTime.fromMillisecondsSinceEpoch(
                  json['ouiDatabaseLastUpdated'])
              : DateTime.parse(json['ouiDatabaseLastUpdated']))
          : null,
      watchListEnabled: json['watchListEnabled'] ?? false,
      watchListAudioAlertsEnabled: json['watchListAudioAlertsEnabled'] ?? true,
      watchListDevices: List<String>.from(json['watchListDevices'] ?? []),
      sigDatabaseEnabled: json['sigDatabaseEnabled'] ?? false,
      sigDatabaseLastUpdated: json['sigDatabaseLastUpdated'] != null
          ? (json['sigDatabaseLastUpdated'] is int
              ? DateTime.fromMillisecondsSinceEpoch(
                  json['sigDatabaseLastUpdated'])
              : DateTime.parse(json['sigDatabaseLastUpdated']))
          : null,
    );
  }

  @override
  String toString() {
    return 'AppSettings('
        'autoScanningEnabled: $autoScanningEnabled, '
        'batteryOptimizationEnabled: $batteryOptimizationEnabled, '
        'backgroundScanningEnabled: $backgroundScanningEnabled, '
        'batteryThresholdPercent: $batteryThresholdPercent, '
        'scanIntervalSeconds: $scanIntervalSeconds, '
        'dataRetentionDays: $dataRetentionDays, '
        'locationTrackingEnabled: $locationTrackingEnabled, '
        'verboseLoggingEnabled: $verboseLoggingEnabled, '
        'showNotifications: $showNotifications, '
        'autoScanWhenPluggedIn: $autoScanWhenPluggedIn, '
        'ouiDatabaseEnabled: $ouiDatabaseEnabled, '
        'ouiDatabaseLastUpdated: $ouiDatabaseLastUpdated, '
        'watchListEnabled: $watchListEnabled, '
        'watchListAudioAlertsEnabled: $watchListAudioAlertsEnabled, '
        'watchListDevices: $watchListDevices'
        ')';
  }
}
