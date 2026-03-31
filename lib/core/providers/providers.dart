import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/datasources/storage_datasource.dart';
import '../../shared/data/repositories/storage_repository_impl.dart';
import '../../shared/domain/repositories/storage_repository.dart';
import '../error/error_handler.dart';
import '../logging/app_logger.dart';
import '../network/retry_service.dart';

// Core providers for dependency injection following Clean Architecture

// Storage providers
final storageDataSourceProvider = Provider<StorageDataSource>((ref) {
  return StorageDataSourceImpl();
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  final dataSource = ref.watch(storageDataSourceProvider);
  return StorageRepositoryImpl(dataSource);
});

// Logger provider
final appLoggerProvider = Provider<AppLogger>((ref) {
  return AppLoggerImpl();
});

// Error handling provider
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final logger = ref.watch(appLoggerProvider);
  return ErrorHandlerImpl(logger);
});

// Retry service provider
final retryServiceProvider = Provider<RetryService>((ref) {
  final logger = ref.watch(appLoggerProvider);
  return RetryServiceImpl(logger);
});
