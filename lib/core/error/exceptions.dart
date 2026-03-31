/// Base class for all application exceptions
/// 
/// This provides a common interface for all exceptions in the app,
/// making error handling consistent and predictable.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  /// Get user-friendly message for display
  String get userMessage => message;

  /// Check if this is a recoverable error
  bool get isRecoverable => true;

  /// Get suggested user action
  String? get suggestedAction => null;

  @override
  String toString() {
    return '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Storage related exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error al acceder al almacenamiento local';

  @override
  String? get suggestedAction => 'Verifica el espacio disponible e intenta nuevamente';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error de conexión';

  @override
  String? get suggestedAction => 'Verifica tu conexión a internet e intenta nuevamente';
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error de validación';

  @override
  bool get isRecoverable => true;

  @override
  String? get suggestedAction => 'Corrige los datos ingresados';
}

/// Business logic exceptions
class BusinessLogicException extends AppException {
  const BusinessLogicException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => message;

  @override
  bool get isRecoverable => true;
}

/// Parsing/serialization exceptions
class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error al procesar datos';

  @override
  String? get suggestedAction => 'Intenta actualizar la información';
}

/// Authentication/authorization exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error de autenticación';

  @override
  bool get isRecoverable => false;

  @override
  String? get suggestedAction => 'Inicia sesión nuevamente';
}

/// Feature-specific exceptions
class ExpenseException extends AppException {
  const ExpenseException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error en el registro de gastos';
}

class BudgetException extends AppException {
  const BudgetException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error en la gestión de presupuestos';
}

class AnalyticsException extends AppException {
  const AnalyticsException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error al generar análisis';
}

class SettingsException extends AppException {
  const SettingsException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error en la configuración';
}

class AdsException extends AppException {
  const AdsException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage => 'Error en el sistema de publicidad';

  @override
  bool get isRecoverable => true;

  @override
  String? get suggestedAction => 'El contenido principal sigue disponible';
}