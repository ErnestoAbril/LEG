import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import '../../../../core/error/failures.dart';

/// Use case for adding a new expense
/// 
/// This use case handles the business logic for adding expenses,
/// including validation and error handling.
class AddExpenseUseCase {
  final ExpenseRepository _repository;

  AddExpenseUseCase(this._repository);

  /// Execute the use case to add a new expense
  /// 
  /// Returns [Failure] if the operation fails, null if successful
  Future<Failure?> execute(Expense expense) async {
    try {
      // Business logic validation
      if (expense.amount <= 0) {
        return const ValidationFailure(message: 'El monto debe ser mayor a cero');
      }

      if (expense.description.trim().isEmpty) {
        return const ValidationFailure(message: 'La descripción no puede estar vacía');
      }

      if (expense.category.trim().isEmpty) {
        return const ValidationFailure(message: 'Debe seleccionar una categoría');
      }

      // Delegate to repository
      await _repository.saveExpense(expense);
      return null; // Success
    } catch (e) {
      // Let the repository handle the error and return appropriate failure
      return const ServerFailure(message: 'Error al agregar el gasto');
    }
  }
}