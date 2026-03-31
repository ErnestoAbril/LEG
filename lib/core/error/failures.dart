import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// 
/// Failures represent expected error states that can occur during
/// normal operation and should be handled gracefully.
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  /// Get user-friendly message
  String get userMessage => message;

  /// Check if this failure is recoverable
  bool get isRecoverable => true;

  /// Get suggested action for the user
  String? get suggestedAction => null;

  @override
  List<Object?> get props => [message, code, details];

  @override
  String toString() {
    return '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Storage-related failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Error al acceder a los datos almacenados';

  @override
  String? get suggestedAction => 'Intenta cerrar y abrir la aplicación';
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Sin conexión a internet';

  @override
  String? get suggestedAction => 'Verifica tu conexión e intenta nuevamente';
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Error del servidor';

  @override
  String? get suggestedAction => 'Intenta nuevamente en unos momentos';
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Datos inválidos';

  @override
  String? get suggestedAction => 'Verifica la información ingresada';
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Error en el cache local';

  @override
  String? get suggestedAction => 'Los datos se actualizarán automáticamente';
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Permisos insuficientes';

  @override
  bool get isRecoverable => false;

  @override
  String? get suggestedAction => 'Otorga los permisos necesarios en configuración';
}

/// Generic failure for unknown errors
class GenericFailure extends Failure {
  const GenericFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Ha ocurrido un error inesperado';

  @override
  String? get suggestedAction => 'Intenta nuevamente en unos momentos';
}

/// Feature-specific failures
class ExpenseFailure extends Failure {
  const ExpenseFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Error al procesar el gasto';
}

class BudgetFailure extends Failure {
  const BudgetFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Error en el presupuesto';
}

class AnalyticsFailure extends Failure {
  const AnalyticsFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Error al generar el reporte';
}

class SettingsFailure extends Failure {
  const SettingsFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Error en la configuración';
}

class AdsFailure extends Failure {
  const AdsFailure({
    required super.message,
    super.code,
    super.details,
  });

  @override
  String get userMessage => 'Error al cargar anuncios';

  @override
  String? get suggestedAction => 'El contenido principal funciona normalmente';
}