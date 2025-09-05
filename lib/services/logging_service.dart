import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  late final Logger _logger;

  void initialize() {
    _logger = Logger(
      printer: PrettyPrinter(
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Show timestamps
      ),
      level: kDebugMode ? Level.debug : Level.info,
    );
  }

  // Convenience getters for different log levels
  Logger get logger => _logger;

  // Convenience methods
  void trace(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Special method for logging objects with structure
  void logObject(String label, dynamic object) {
    _logger.d('$label: $object');
  }

  // Method for performance logging
  void performance(String operation, Duration duration) {
    _logger.i('⚡ Performance: $operation took ${duration.inMilliseconds}ms');
  }

  // Method for user action logging
  void userAction(String action, [Map<String, dynamic>? context]) {
    final contextStr = context != null ? ' - Context: $context' : '';
    _logger.i('👤 User Action: $action$contextStr');
  }

  // Method for Bluetooth events
  void bluetooth(String event, [Map<String, dynamic>? data]) {
    final dataStr = data != null ? ' - Data: $data' : '';
    _logger.i('📱 Bluetooth: $event$dataStr');
  }

  // Method for location events
  void location(String event, [Map<String, dynamic>? data]) {
    final dataStr = data != null ? ' - Data: $data' : '';
    _logger.i('📍 Location: $event$dataStr');
  }

  // Method for database operations
  void database(String operation, [Map<String, dynamic>? data]) {
    final dataStr = data != null ? ' - Data: $data' : '';
    _logger.d('🗄️ Database: $operation$dataStr');
  }

  // Method for battery events
  void battery(String event, [Map<String, dynamic>? data]) {
    final dataStr = data != null ? ' - Data: $data' : '';
    _logger.i('🔋 Battery: $event$dataStr');
  }
}

// Global instance for easy access
final log = LoggingService();
