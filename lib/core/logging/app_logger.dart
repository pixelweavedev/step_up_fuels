import 'package:logger/logger.dart';

/// Structured application logger.
///
/// Usage:
/// ```dart
/// AppLogger.info('Customer created', data: {'id': customer.id});
/// AppLogger.error('Failed to save', error: e, stackTrace: st);
/// ```
///
/// In production, replace [_logger] with a file or remote output.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.debug,
  );

  static void trace(String message, {Map<String, dynamic>? data}) {
    _logger.t(message, error: data);
  }

  static void debug(String message, {Map<String, dynamic>? data}) {
    _logger.d(message, error: data);
  }

  static void info(String message, {Map<String, dynamic>? data}) {
    _logger.i(message, error: data);
  }

  static void warning(String message, {Map<String, dynamic>? data}) {
    _logger.w(message, error: data);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
