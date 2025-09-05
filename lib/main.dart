import 'package:flutter/material.dart';

import 'services/app_configuration.dart';
import 'widgets/flutter_blue_app_widget.dart';

// coverage:ignore-start
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create app configuration and initialize all services
  final appConfig = AppConfiguration();
  await appConfig.initializeServices();

  runApp(FlutterBlueApp(appConfiguration: appConfig));
}
// coverage:ignore-end

//
// Main app entry point - now uses dependency injection
//
class FlutterBlueApp extends StatelessWidget {
  final AppConfigurationInterface appConfiguration;

  const FlutterBlueApp({
    super.key,
    required this.appConfiguration,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterBlueAppWidget(
      bluetoothAdapter: appConfiguration.bluetoothAdapter,
      navigationObserverFactory: () => appConfiguration.createNavigationObserver(),
    );
  }
}
