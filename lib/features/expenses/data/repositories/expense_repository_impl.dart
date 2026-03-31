import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_datasource.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/retry_service.dart';

// Concrete implementation of Expense Repository with error handling
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDataSource _dataSource;
  final ErrorHandler _errorHandler;
  final RetryService _retryService;

  ExpenseRepositoryImpl(
    this._dataSource,
    this._errorHandler,
    this._retryService,
  );

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      return await _retryService.executeWithAutoRetry(
        () => _dataSource.getAllExpenses(),
        config: RetryConfig.storage,
        operationName: 'getAllExpenses',
      );
    } catch (error, stackTrace) {
      await _errorHandler.logError(error, stackTrace, context: {
        'operation': 'getAllExpenses',
        'repository': 'ExpenseRepositoryImpl',
      });
      
      throw ExpenseException(
        message: 'Error al obtener gastos',
        code: 'GET_ALL_EXPENSES_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String category) async {
    try {
      return await _retryService.executeWithAutoRetry(
        () async {
          final expenses = await _dataSource.getAllExpenses();
          return expenses.where((expense) => expense.category == category).toList();
        },
        config: RetryConfig.storage,
        operationName: 'getExpensesByCategory',
      );
    } catch (error, stackTrace) {
      await _errorHandler.logError(error, stackTrace, context: {
        'operation': 'getExpensesByCategory',
        'repository': 'ExpenseRepositoryImpl',
        'category': category,
      });
      
      throw ExpenseException(
        message: 'Error al obtener gastos por categoría',
        code: 'GET_EXPENSES_BY_CATEGORY_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final expenses = await _dataSource.getAllExpenses();
    return expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    return await _dataSource.getExpenseById(id);
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    await _dataSource.saveExpense(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await _dataSource.updateExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _dataSource.deleteExpense(id);
  }

  @override
  Future<void> deleteAllExpenses() async {
    await _dataSource.deleteAllExpenses();
  }

  @override
  Future<double> getTotalExpenses() async {
    final expenses = await _dataSource.getAllExpenses();
    return expenses.fold<double>(0.0, (total, expense) => total + expense.amount);
  }

  @override
  Future<double> getTotalExpensesByCategory(String category) async {
    final expenses = await getExpensesByCategory(category);
    return expenses.fold<double>(0.0, (total, expense) => total + expense.amount);
  }

  @override
  Future<double> getTotalExpensesByDateRange(DateTime start, DateTime end) async {
    final expenses = await getExpensesByDateRange(start, end);
    return expenses.fold<double>(0.0, (total, expense) => total + expense.amount);
  }

  @override
  Future<List<String>> getAllCategories() async {
    final expenses = await _dataSource.getAllExpenses();
    final categories = expenses.map((expense) => expense.category).toSet();
    return categories.toList()..sort();
  }

  @override
  Future<Map<String, double>> getExpensesSummaryByCategory() async {
    final expenses = await _dataSource.getAllExpenses();
    final Map<String, double> summary = {};
    
    for (final expense in expenses) {
      summary[expense.category] = (summary[expense.category] ?? 0.0) + expense.amount;
    }
    
    return summary;
  }
}
