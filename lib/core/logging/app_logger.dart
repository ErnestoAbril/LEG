import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Log levels for different types of messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Extension to get log level names and priorities
extension LogLevelExtension on LogLevel {
  String get name {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  int get priority {
    switch (this) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 1;
      case LogLevel.warning:
        return 2;
      case LogLevel.error:
        return 3;
      case LogLevel.fatal:
        return 4;
    }
  }

  String get emoji {
    switch (this) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💀';
    }
  }
}

/// Interface for application logging
abstract class AppLogger {
  /// Log a debug message
  Future<void> debug(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context});

  /// Log an info message
  Future<void> info(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context});

  /// Log a warning message
  Future<void> warning(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context});

  /// Log an error message
  Future<void> error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context});

  /// Log a fatal error message
  Future<void> fatal(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context});

  /// Log with custom level
  Future<void> log(LogLevel level, String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context});
}

/// Implementation of AppLogger for development and production
class AppLoggerImpl implements AppLogger {
  final LogLevel _minLevel;
  final bool _enableConsoleOutput;
  final bool _enableFileOutput;

  AppLoggerImpl({
    LogLevel minLevel = LogLevel.debug,
    bool enableConsoleOutput = true,
    bool enableFileOutput = false,
  })  : _minLevel = minLevel,
        _enableConsoleOutput = enableConsoleOutput,
        _enableFileOutput = enableFileOutput;

  @override
  Future<void> debug(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await log(LogLevel.debug, message, error: error, stackTrace: stackTrace, context: context);
  }

  @override
  Future<void> info(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await log(LogLevel.info, message, error: error, stackTrace: stackTrace, context: context);
  }

  @override
  Future<void> warning(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await log(LogLevel.warning, message, error: error, stackTrace: stackTrace, context: context);
  }

  @override
  Future<void> error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await log(LogLevel.error, message, error: error, stackTrace: stackTrace, context: context);
  }

  @override
  Future<void> fatal(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await log(LogLevel.fatal, message, error: error, stackTrace: stackTrace, context: context);
  }

  @override
  Future<void> log(LogLevel level, String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    // Check if we should log this level
    if (level.priority < _minLevel.priority) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final logEntry = _formatLogEntry(timestamp, level, message, error, stackTrace, context);

    // Output to console in debug mode or if enabled
    if (_enableConsoleOutput || kDebugMode) {
      _outputToConsole(level, logEntry);
    }

    // Output to file if enabled (for production logging)
    if (_enableFileOutput) {
      await _outputToFile(logEntry);
    }

    // Send to external logging service in production
    if (kReleaseMode && level.priority >= LogLevel.error.priority) {
      await _sendToExternalService(level, message, error, stackTrace, context);
    }
  }

  /// Format log entry for output
  String _formatLogEntry(
    String timestamp,
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ) {
    final buffer = StringBuffer();
    buffer.write('[$timestamp] ${level.emoji} ${level.name}: $message');

    if (error != null) {
      buffer.write('\n  Error: $error');
    }

    if (context != null && context.isNotEmpty) {
      buffer.write('\n  Context: $context');
    }

    if (stackTrace != null && (level.priority >= LogLevel.error.priority || kDebugMode)) {
      buffer.write('\n  Stack Trace:\n$stackTrace');
    }

    return buffer.toString();
  }

  /// Output log to console
  void _outputToConsole(LogLevel level, String logEntry) {
    switch (level) {
      case LogLevel.debug:
        debugPrint(logEntry);
        break;
      case LogLevel.info:
        debugPrint(logEntry);
        break;
      case LogLevel.warning:
        debugPrint(logEntry);
        break;
      case LogLevel.error:
        debugPrint(logEntry);
        break;
      case LogLevel.fatal:
        debugPrint(logEntry);
        break;
    }
  }

  /// Output log to file (placeholder for file logging implementation)
  Future<void> _outputToFile(String logEntry) async {
    // In a real implementation, this would write to a log file
    // For now, we'll just use debugPrint in debug mode
    if (kDebugMode) {
      debugPrint('[FILE LOG] $logEntry');
    }
  }

  /// Send logs to external service (placeholder for external logging)
  Future<void> _sendToExternalService(
    LogLevel level,
    String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ) async {
    // In a real implementation, this would send logs to services like:
    // - Firebase Crashlytics
    // - Sentry
    // - LogRocket
    // - Custom logging endpoints
    
    if (kDebugMode) {
      debugPrint('[EXTERNAL SERVICE] Would send: $level - $message');
    }
  }
}

/// Provider for AppLogger
final appLoggerProvider = Provider<AppLogger>((ref) {
  return AppLoggerImpl(
    minLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
    enableConsoleOutput: kDebugMode,
    enableFileOutput: kReleaseMode,
  );
});

/// Convenience methods for logging throughout the app
class AppLog {
  static AppLogger? _instance;

  static void init(AppLogger logger) {
    _instance = logger;
  }

  static Future<void> debug(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await _instance?.debug(message, error: error, stackTrace: stackTrace, context: context);
  }

  static Future<void> info(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await _instance?.info(message, error: error, stackTrace: stackTrace, context: context);
  }

  static Future<void> warning(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await _instance?.warning(message, error: error, stackTrace: stackTrace, context: context);
  }

  static Future<void> error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await _instance?.error(message, error: error, stackTrace: stackTrace, context: context);
  }

  static Future<void> fatal(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) async {
    await _instance?.fatal(message, error: error, stackTrace: stackTrace, context: context);
  }
}