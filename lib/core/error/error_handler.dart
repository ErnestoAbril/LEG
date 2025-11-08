import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_logger.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Central error handler for the application
/// 
/// This class provides consistent error handling across the entire app,
/// including logging, user notification, and recovery strategies.
abstract class ErrorHandler {
  /// Handle exceptions and convert them to failures
  Future<Failure> handleException(Exception exception, StackTrace? stackTrace);

  /// Handle errors that don't extend Exception
  Future<Failure> handleError(Object error, StackTrace? stackTrace);

  /// Log an error for debugging purposes
  Future<void> logError(Object error, StackTrace? stackTrace, {Map<String, dynamic>? context});

  /// Report critical errors to external services (in production)
  Future<void> reportError(Object error, StackTrace? stackTrace, {bool isFatal = false});

  /// Get user-friendly error message
  String getUserMessage(Object error);
}

/// Implementation of ErrorHandler
class ErrorHandlerImpl implements ErrorHandler {
  final AppLogger _logger;

  ErrorHandlerImpl(this._logger);

  @override
  Future<Failure> handleException(Exception exception, StackTrace? stackTrace) async {
    await logError(exception, stackTrace);

    // Convert known exceptions to appropriate failures
    if (exception is AppException) {
      return _mapAppExceptionToFailure(exception);
    }

    // Handle Flutter/Dart exceptions
    if (exception is FormatException) {
      return const ValidationFailure(
        message: 'Formato de datos inválido',
        code: 'FORMAT_ERROR',
      );
    }

    if (exception is ArgumentError) {
      return ValidationFailure(
        message: 'Argumento inválido: ${exception.toString()}',
        code: 'ARGUMENT_ERROR',
      );
    }

    // Default failure for unknown exceptions
    return GenericFailure(
      message: exception.toString(),
      code: 'UNKNOWN_EXCEPTION',
    );
  }

  @override
  Future<Failure> handleError(Object error, StackTrace? stackTrace) async {
    await logError(error, stackTrace);

    // Handle common Dart errors
    if (error is TypeError) {
      return const ValidationFailure(
        message: 'Error de tipo de datos',
        code: 'TYPE_ERROR',
      );
    }

    if (error is NoSuchMethodError) {
      return const GenericFailure(
        message: 'Funcionalidad no disponible',
        code: 'METHOD_ERROR',
      );
    }

    if (error is OutOfMemoryError) {
      return const GenericFailure(
        message: 'Memoria insuficiente',
        code: 'MEMORY_ERROR',
      );
    }

    // Default failure for unknown errors
    return GenericFailure(
      message: error.toString(),
      code: 'UNKNOWN_ERROR',
    );
  }

  @override
  Future<void> logError(Object error, StackTrace? stackTrace, {Map<String, dynamic>? context}) async {
    await _logger.error(
      error.toString(),
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  @override
  Future<void> reportError(Object error, StackTrace? stackTrace, {bool isFatal = false}) async {
    // In development, just log to console
    if (kDebugMode) {
      debugPrint('🔥 Error Report (Fatal: $isFatal): $error');
      if (stackTrace != null) {
        debugPrint('Stack Trace: $stackTrace');
      }
      return;
    }

    // In production, report to external services like Firebase Crashlytics
    // This would be implemented based on your error reporting service
    await _logger.fatal(
      'Critical error reported',
      error: error,
      stackTrace: stackTrace,
      context: {'isFatal': isFatal},
    );
  }

  @override
  String getUserMessage(Object error) {
    if (error is AppException) {
      return error.userMessage;
    }

    if (error is Failure) {
      return error.userMessage;
    }

    // Provide generic user-friendly messages for common errors
    if (error is FormatException) {
      return 'Error en el formato de datos';
    }

    if (error is TimeoutException) {
      return 'La operación tardó demasiado tiempo';
    }

    // Default generic message
    return 'Ha ocurrido un error inesperado';
  }

  /// Map AppException to appropriate Failure
  Failure _mapAppExceptionToFailure(AppException exception) {
    switch (exception.runtimeType) {
      case StorageException _:
        return StorageFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );

      case NetworkException _:
        return NetworkFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );

      case ValidationException _:
        final validationException = exception as ValidationException;
        return ValidationFailure(
          message: exception.message,
          code: exception.code,
          details: {
            'fieldErrors': validationException.fieldErrors,
            'originalError': exception.originalError,
          },
        );

      case BusinessLogicException _:
        return GenericFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );

      case ParseException _:
        return ValidationFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );

      case ExpenseException _:
        return ExpenseFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );

      case BudgetException _:
        return BudgetFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );

      case AnalyticsException _:
        return AnalyticsFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );

      case SettingsException _:
        return SettingsFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );

      case AdsException _:
        return AdsFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );

      default:
        return GenericFailure(
          message: exception.message,
          code: exception.code,
          details: {'originalError': exception.originalError},
        );
    }
  }
}

/// Provider for ErrorHandler
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final logger = ref.read(appLoggerProvider);
  return ErrorHandlerImpl(logger);
});

/// Helper extension for easy error handling in repositories
extension ErrorHandlerExtension on ErrorHandler {
  /// Execute a function and handle any errors that occur
  Future<T> execute<T>(
    Future<T> Function() operation, {
    Map<String, dynamic>? context,
  }) async {
    try {
      return await operation();
    } on Exception catch (e, stackTrace) {
      await logError(e, stackTrace, context: context);
      rethrow;
    } catch (e, stackTrace) {
      await logError(e, stackTrace, context: context);
      rethrow;
    }
  }

  /// Execute operation with automatic failure conversion
  Future<({T? data, Failure? failure})> executeWithFailure<T>(
    Future<T> Function() operation, {
    Map<String, dynamic>? context,
  }) async {
    try {
      final data = await operation();
      return (data: data, failure: null);
    } on Exception catch (e, stackTrace) {
      final failure = await handleException(e, stackTrace);
      return (data: null, failure: failure);
    } catch (e, stackTrace) {
      final failure = await handleError(e, stackTrace);
      return (data: null, failure: failure);
    }
  }
}