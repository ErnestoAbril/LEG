import 'package:flutter/material.dart';
import '../error/failures.dart';
import '../error/exceptions.dart';

/// Widget to display errors in a user-friendly way
class ErrorDisplayWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final bool showDetails;
  final bool isFullScreen;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.showDetails = false,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo(error);

    if (isFullScreen) {
      return _buildFullScreenError(context, errorInfo);
    }

    return _buildInlineError(context, errorInfo);
  }

  /// Build full screen error display
  Widget _buildFullScreenError(BuildContext context, _ErrorInfo errorInfo) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                errorInfo.icon,
                size: 64,
                color: errorInfo.color,
              ),
              const SizedBox(height: 24),
              Text(
                errorInfo.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: errorInfo.color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                errorInfo.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (errorInfo.suggestion != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorInfo.suggestion!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Intentar nuevamente'),
                ),
              if (showDetails) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _showErrorDetails(context, error),
                  child: const Text('Ver detalles técnicos'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build inline error display
  Widget _buildInlineError(BuildContext context, _ErrorInfo errorInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: errorInfo.color.withValues(alpha: 0.1),
        border: Border.all(color: errorInfo.color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                errorInfo.icon,
                color: errorInfo.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorInfo.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: errorInfo.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorInfo.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (errorInfo.suggestion != null) ...[
            const SizedBox(height: 8),
            Text(
              errorInfo.suggestion!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorInfo.color,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get error information for display
  _ErrorInfo _getErrorInfo(Object error) {
    if (error is Failure) {
      return _getFailureInfo(error);
    }

    if (error is AppException) {
      return _getExceptionInfo(error);
    }

    // Default error info
    return _ErrorInfo(
      title: 'Error inesperado',
      message: 'Ha ocurrido un error inesperado',
      suggestion: 'Intenta nuevamente en unos momentos',
      icon: Icons.error_outline,
      color: Colors.red,
    );
  }

  /// Get failure-specific information
  _ErrorInfo _getFailureInfo(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure _:
        return _ErrorInfo(
          title: 'Sin conexión',
          message: failure.userMessage,
          suggestion: failure.suggestedAction,
          icon: Icons.wifi_off,
          color: Colors.orange,
        );

      case StorageFailure _:
        return _ErrorInfo(
          title: 'Error de almacenamiento',
          message: failure.userMessage,
          suggestion: failure.suggestedAction,
          icon: Icons.storage,
          color: Colors.red,
        );

      case ValidationFailure _:
        return _ErrorInfo(
          title: 'Datos inválidos',
          message: failure.userMessage,
          suggestion: failure.suggestedAction,
          icon: Icons.warning,
          color: Colors.amber,
        );

      case ServerFailure _:
        return _ErrorInfo(
          title: 'Error del servidor',
          message: failure.userMessage,
          suggestion: failure.suggestedAction,
          icon: Icons.cloud_off,
          color: Colors.red,
        );

      default:
        return _ErrorInfo(
          title: 'Error',
          message: failure.userMessage,
          suggestion: failure.suggestedAction,
          icon: Icons.error_outline,
          color: Colors.red,
        );
    }
  }

  /// Get exception-specific information
  _ErrorInfo _getExceptionInfo(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException _:
        return _ErrorInfo(
          title: 'Error de red',
          message: exception.userMessage,
          suggestion: exception.suggestedAction,
          icon: Icons.wifi_off,
          color: Colors.orange,
        );

      case StorageException _:
        return _ErrorInfo(
          title: 'Error de almacenamiento',
          message: exception.userMessage,
          suggestion: exception.suggestedAction,
          icon: Icons.storage,
          color: Colors.red,
        );

      case ValidationException _:
        return _ErrorInfo(
          title: 'Validación',
          message: exception.userMessage,
          suggestion: exception.suggestedAction,
          icon: Icons.warning,
          color: Colors.amber,
        );

      default:
        return _ErrorInfo(
          title: 'Error',
          message: exception.userMessage,
          suggestion: exception.suggestedAction,
          icon: Icons.error_outline,
          color: Colors.red,
        );
    }
  }

  /// Show detailed error information
  void _showErrorDetails(BuildContext context, Object error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del error'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tipo: ${error.runtimeType}'),
              const SizedBox(height: 8),
              Text('Mensaje: ${error.toString()}'),
              if (error is AppException && error.code != null) ...[
                const SizedBox(height: 8),
                Text('Código: ${error.code}'),
              ],
              if (error is Failure && error.details != null) ...[
                const SizedBox(height: 8),
                Text('Detalles: ${error.details}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

/// Internal class to hold error display information
class _ErrorInfo {
  final String title;
  final String message;
  final String? suggestion;
  final IconData icon;
  final Color color;

  const _ErrorInfo({
    required this.title,
    required this.message,
    this.suggestion,
    required this.icon,
    required this.color,
  });
}

/// Utility methods for error display
class ErrorDisplayUtils {
  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, Object error) {
    final messenger = ScaffoldMessenger.of(context);
    final errorInfo = _getErrorMessage(error);

    messenger.showSnackBar(
      SnackBar(
        content: Text(errorInfo),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(_getErrorMessage(error)),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Reintentar'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  static String _getErrorMessage(Object error) {
    if (error is Failure) {
      return error.userMessage;
    }
    if (error is AppException) {
      return error.userMessage;
    }
    return 'Ha ocurrido un error inesperado';
  }
}