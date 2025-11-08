import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_logger.dart';
import '../error/exceptions.dart';

/// Configuration for retry behavior
class RetryConfig {
  final int maxAttempts;
  final Duration baseDelay;
  final Duration maxDelay;
  final double exponentialBase;
  final double jitterFactor;
  final bool Function(Object error)? retryIf;

  const RetryConfig({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.exponentialBase = 2.0,
    this.jitterFactor = 0.1,
    this.retryIf,
  });

  /// Default retry config for network operations
  static const network = RetryConfig(
    maxAttempts: 3,
    baseDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 10),
    exponentialBase: 2.0,
    jitterFactor: 0.1,
  );

  /// Default retry config for storage operations
  static const storage = RetryConfig(
    maxAttempts: 2,
    baseDelay: Duration(milliseconds: 250),
    maxDelay: Duration(seconds: 5),
    exponentialBase: 1.5,
    jitterFactor: 0.05,
  );

  /// Default retry config for business operations
  static const business = RetryConfig(
    maxAttempts: 1,
    baseDelay: Duration.zero,
    maxDelay: Duration.zero,
  );
}

/// Result of a retry operation
class RetryResult<T> {
  final T? data;
  final Object? error;
  final int attempts;
  final bool succeeded;

  const RetryResult({
    this.data,
    this.error,
    required this.attempts,
    required this.succeeded,
  });

  factory RetryResult.success(T data, int attempts) {
    return RetryResult(
      data: data,
      attempts: attempts,
      succeeded: true,
    );
  }

  factory RetryResult.failure(Object error, int attempts) {
    return RetryResult(
      error: error,
      attempts: attempts,
      succeeded: false,
    );
  }
}

/// Service for handling retry logic with exponential backoff
abstract class RetryService {
  /// Execute an operation with retry logic
  Future<RetryResult<T>> execute<T>(
    Future<T> Function() operation, {
    RetryConfig? config,
    String? operationName,
  });

  /// Execute an operation with automatic retry on specific conditions
  Future<T> executeWithAutoRetry<T>(
    Future<T> Function() operation, {
    RetryConfig? config,
    String? operationName,
  });
}

/// Implementation of RetryService
class RetryServiceImpl implements RetryService {
  final AppLogger _logger;
  final Random _random = Random();

  RetryServiceImpl(this._logger);

  @override
  Future<RetryResult<T>> execute<T>(
    Future<T> Function() operation, {
    RetryConfig? config,
    String? operationName,
  }) async {
    final retryConfig = config ?? const RetryConfig();
    final opName = operationName ?? 'operation';
    
    Object? lastError;
    
    for (int attempt = 1; attempt <= retryConfig.maxAttempts; attempt++) {
      try {
        await _logger.debug('Executing $opName (attempt $attempt/${retryConfig.maxAttempts})');
        
        final result = await operation();
        
        await _logger.info('$opName succeeded on attempt $attempt');
        return RetryResult.success(result, attempt);
        
      } catch (error, stackTrace) {
        lastError = error;
        
        await _logger.warning(
          '$opName failed on attempt $attempt: $error',
          error: error,
          stackTrace: stackTrace,
        );

        // Check if we should retry this error
        if (!_shouldRetry(error, retryConfig)) {
          await _logger.info('$opName will not be retried due to error type');
          return RetryResult.failure(error, attempt);
        }

        // If this is the last attempt, don't wait
        if (attempt == retryConfig.maxAttempts) {
          await _logger.error('$opName failed after $attempt attempts');
          return RetryResult.failure(error, attempt);
        }

        // Calculate delay for next attempt
        final delay = _calculateDelay(attempt, retryConfig);
        await _logger.debug('Waiting ${delay.inMilliseconds}ms before retry');
        
        await Future.delayed(delay);
      }
    }

    // This should never be reached, but just in case
    return RetryResult.failure(lastError ?? Exception('Unknown error'), retryConfig.maxAttempts);
  }

  @override
  Future<T> executeWithAutoRetry<T>(
    Future<T> Function() operation, {
    RetryConfig? config,
    String? operationName,
  }) async {
    final result = await execute(operation, config: config, operationName: operationName);
    
    if (result.succeeded) {
      return result.data!;
    } else {
      throw result.error!;
    }
  }

  /// Check if an error should trigger a retry
  bool _shouldRetry(Object error, RetryConfig config) {
    // Use custom retry condition if provided
    if (config.retryIf != null) {
      return config.retryIf!(error);
    }

    // Default retry logic
    if (error is AppException) {
      switch (error.runtimeType) {
        case NetworkException _:
        case StorageException _:
          return true;
        case ValidationException _:
        case BusinessLogicException _:
        case AuthException _:
          return false;
        default:
          return true;
      }
    }

    // Retry for common transient errors
    if (error is TimeoutException ||
        error is SocketException ||
        error is HttpException) {
      return true;
    }

    // Don't retry argument/format errors
    if (error is ArgumentError || error is FormatException) {
      return false;
    }

    // Default: retry unknown errors
    return true;
  }

  /// Calculate delay with exponential backoff and jitter
  Duration _calculateDelay(int attempt, RetryConfig config) {
    if (config.baseDelay == Duration.zero) {
      return Duration.zero;
    }

    // Calculate exponential backoff
    final exponentialDelay = config.baseDelay.inMilliseconds * 
        pow(config.exponentialBase, attempt - 1);

    // Apply jitter to avoid thundering herd
    final jitter = exponentialDelay * config.jitterFactor * _random.nextDouble();
    final delayWithJitter = exponentialDelay + jitter;

    // Cap at maximum delay
    final finalDelay = Duration(
      milliseconds: min(delayWithJitter.round(), config.maxDelay.inMilliseconds),
    );

    return finalDelay;
  }
}

/// Provider for RetryService
final retryServiceProvider = Provider<RetryService>((ref) {
  final logger = ref.read(appLoggerProvider);
  return RetryServiceImpl(logger);
});

/// Convenience methods for common retry patterns
class Retry {
  static RetryService? _instance;

  static void init(RetryService service) {
    _instance = service;
  }

  /// Retry a network operation
  static Future<T> network<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    return await _instance!.executeWithAutoRetry(
      operation,
      config: RetryConfig.network,
      operationName: operationName ?? 'network operation',
    );
  }

  /// Retry a storage operation
  static Future<T> storage<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    return await _instance!.executeWithAutoRetry(
      operation,
      config: RetryConfig.storage,
      operationName: operationName ?? 'storage operation',
    );
  }

  /// Execute with custom retry configuration
  static Future<T> custom<T>(
    Future<T> Function() operation, {
    required RetryConfig config,
    String? operationName,
  }) async {
    return await _instance!.executeWithAutoRetry(
      operation,
      config: config,
      operationName: operationName ?? 'custom operation',
    );
  }
}

/// Additional imports for common exception types
class SocketException implements Exception {
  final String message;
  SocketException(this.message);
  @override
  String toString() => 'SocketException: $message';
}

class HttpException implements Exception {
  final String message;
  final int? statusCode;
  HttpException(this.message, [this.statusCode]);
  @override
  String toString() => 'HttpException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}