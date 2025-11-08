import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import '../../../../core/error/failures.dart';

/// Result wrapper for use case operations
class ExpenseResult {
  final List<Expense>? expenses;
  final Failure? failure;

  const ExpenseResult._({this.expenses, this.failure});

  factory ExpenseResult.success(List<Expense> expenses) => 
    ExpenseResult._(expenses: expenses);

  factory ExpenseResult.failure(Failure failure) => 
    ExpenseResult._(failure: failure);

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;
}

/// Use case for getting all expenses
/// 
/// This use case handles the business logic for retrieving expenses
/// with proper error handling and business rules.
class GetExpensesUseCase {
  final ExpenseRepository _repository;

  GetExpensesUseCase(this._repository);

  /// Execute the use case to get all expenses
  /// 
  /// Returns [ExpenseResult] with either expenses or failure
  Future<ExpenseResult> execute() async {
    try {
      final expenses = await _repository.getAllExpenses();
      
      // Business logic: Sort by date (most recent first)
      expenses.sort((a, b) => b.date.compareTo(a.date));
      
      return ExpenseResult.success(expenses);
    } catch (e) {
      // Repository should handle specific errors and throw appropriate exceptions
      return ExpenseResult.failure(
        const ServerFailure(message: 'Error al obtener los gastos')
      );
    }
  }

  /// Execute the use case to get expenses by category
  /// 
  /// Returns [ExpenseResult] with either expenses or failure
  Future<ExpenseResult> executeByCategory(String category) async {
    try {
      if (category.trim().isEmpty) {
        return ExpenseResult.failure(
          const ValidationFailure(message: 'La categoría no puede estar vacía')
        );
      }

      final expenses = await _repository.getExpensesByCategory(category);
      
      // Business logic: Sort by date (most recent first)
      expenses.sort((a, b) => b.date.compareTo(a.date));
      
      return ExpenseResult.success(expenses);
    } catch (e) {
      return ExpenseResult.failure(
        const ServerFailure(message: 'Error al obtener los gastos por categoría')
      );
    }
  }

  /// Execute the use case to get expenses by date range
  /// 
  /// Returns [ExpenseResult] with either expenses or failure
  Future<ExpenseResult> executeByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Business logic validation
      if (startDate.isAfter(endDate)) {
        return ExpenseResult.failure(
          const ValidationFailure(
            message: 'La fecha de inicio debe ser anterior a la fecha de fin'
          )
        );
      }

      // Validate date range is not too large (prevent memory issues)
      final daysDifference = endDate.difference(startDate).inDays;
      if (daysDifference > 365) {
        return ExpenseResult.failure(
          const ValidationFailure(
            message: 'El rango de fechas no puede ser mayor a un año'
          )
        );
      }

      final expenses = await _repository.getExpensesByDateRange(startDate, endDate);
      
      // Business logic: Sort by date (most recent first)
      expenses.sort((a, b) => b.date.compareTo(a.date));
      
      return ExpenseResult.success(expenses);
    } catch (e) {
      return ExpenseResult.failure(
        const ServerFailure(message: 'Error al obtener los gastos por fecha')
      );
    }
  }
}