# Battery Monitor Screen

## Overview

The Battery Monitor Screen provides comprehensive monitoring of device battery levels in relation to Bluetooth scanning activity. This screen helps users understand how scanning affects battery consumption and provides insights for optimizing power usage.

## Features

### Battery Status Monitoring
- **Real-time battery level display** with animated progress indicator
- **Charging state detection** (charging, discharging, full, connected)
- **Visual battery indicators** with color-coded status (green, orange, red)
- **Low battery warnings** with contextual alerts

### Scanning Correlation
- **Bluetooth scanning status** with animated indicators when active
- **Battery impact assessment** showing how scanning affects power consumption
- **Power consumption warnings** when scanning with low battery
- **Contextual advice** for different battery and scanning states

### Battery Optimization
- **Optimization settings display** showing current battery management configuration
- **Battery threshold information** showing when optimization kicks in
- **Auto-scan settings** for plugged-in devices
- **Power management recommendations**

### Historical Data
- **Battery history chart** showing battery levels over time (last 2 hours)
- **Scanning activity correlation** with visual indicators on the chart
- **Charging period highlighting** to show when device was plugged in
- **Data collection** every 2 minutes for detailed tracking

### Power Saving Tips
- **Educational content** with practical tips for extending battery life
- **Scanning optimization recommendations**
- **Best practices** for extended scanning sessions

## Technical Implementation

### Dependencies
- `battery_plus` - Battery level and state monitoring
- `flutter/material.dart` - UI components and animations
- Custom services integration:
  - `BatteryService` - Real-time battery monitoring
  - `BluetoothScanningService` - Scanning state management
  - `SettingsService` - Configuration management

### Architecture
- **Stateful widget** with animation controllers for smooth UI transitions
- **Stream subscriptions** for real-time battery and scanning updates
- **Timer-based data collection** for historical tracking
- **Custom painter** for battery history charts

### Key Components

#### Animation System
- Battery level animation with 2-second duration
- Scanning indicator animation (1.5-second pulsing when active)
- Smooth color transitions for status indicators

#### Data Collection
```dart
class BatteryReading {
  final DateTime timestamp;
  final int batteryLevel;
  final bool isScanning;
  final bool isCharging;
}
```

#### Chart Visualization
- Custom `BatteryChartPainter` for rendering battery history
- Visual overlays for scanning and charging periods
- Grid lines for easy reading of values

## Navigation

The Battery Monitor Screen is accessible from the main Scan Screen via a battery icon in the app bar. Users can navigate to it by tapping the battery icon (🔋) in the top navigation bar.

## User Interface

### Cards Layout
1. **Battery Status Card** - Current battery level, state, and warnings
2. **Scanning Status Card** - Bluetooth scanning activity and impact
3. **Battery Optimization Card** - Current optimization settings
4. **Battery History Card** - Historical data visualization
5. **Power Saving Tips Card** - Educational content and recommendations

### Visual Indicators
- **Green**: Good battery level (>30%), charging, or optimal conditions
- **Orange**: Moderate battery level (20-30%) or moderate impact
- **Red**: Low battery level (<20%) or high impact warnings
- **Blue**: Battery level line in charts and primary indicators

### Interactive Elements
- **Refresh button** in app bar for manual data updates
- **Pull-to-refresh** support for entire screen
- **Contextual cards** that adapt based on current battery and scanning state

## Testing

The screen includes comprehensive widget tests covering:
- Component rendering and layout
- Refresh functionality
- Battery level indicator display
- Power saving tips visibility
- Pull-to-refresh support

## Usage Scenarios

### Normal Operation
- Monitor battery during regular Bluetooth scanning
- Check scanning impact on battery consumption
- View optimization settings and their effectiveness

### Low Battery Situations
- Receive warnings about high power consumption during scanning
- Get recommendations for preserving battery life
- Understand when automatic optimizations activate

### Charging Mode
- See how charging affects scanning restrictions
- Monitor battery recovery during extended scanning sessions
- Track charging patterns and their correlation with usage

### Historical Analysis
- Review battery consumption patterns over recent hours
- Identify periods of high consumption relative to scanning activity
- Plan scanning schedules based on charging patterns

## Future Enhancements

Potential improvements could include:
- Longer historical data retention (days/weeks)
- Export functionality for battery usage reports
- Predictive battery life estimates based on current usage
- Integration with system battery optimization settings
- Customizable data collection intervals
- Additional chart types (daily/weekly views)
