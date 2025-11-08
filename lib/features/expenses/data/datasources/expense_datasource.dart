import '../../../../shared/domain/repositories/storage_repository.dart';
import '../../domain/entities/expense.dart';
import 'dart:convert';

// Abstract data source for expense operations
abstract class ExpenseDataSource {
  Future<List<Expense>> getAllExpenses();
  Future<Expense?> getExpenseById(String id);
  Future<void> saveExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> deleteAllExpenses();
}

// Implementation using StorageRepository
class ExpenseDataSourceImpl implements ExpenseDataSource {
  final StorageRepository _storageRepository;
  static const String _expensesKey = 'expenses';

  ExpenseDataSourceImpl(this._storageRepository);

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      final expensesJson = await _storageRepository.getString(_expensesKey);
      if (expensesJson == null) return [];
      
      final List<dynamic> expensesList = json.decode(expensesJson);
      return expensesList.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load expenses: $e');
    }
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    try {
      final expenses = await getAllExpenses();
      final matchingExpenses = expenses.where((expense) => expense.id == id);
      return matchingExpenses.isNotEmpty ? matchingExpenses.first : null;
    } catch (e) {
      throw Exception('Failed to get expense by id: $e');
    }
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    try {
      final expenses = await getAllExpenses();
      expenses.add(expense);
      await _saveExpenses(expenses);
    } catch (e) {
      throw Exception('Failed to save expense: $e');
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      final expenses = await getAllExpenses();
      final index = expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        expenses[index] = expense;
        await _saveExpenses(expenses);
      } else {
        throw Exception('Expense not found');
      }
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      final expenses = await getAllExpenses();
      expenses.removeWhere((expense) => expense.id == id);
      await _saveExpenses(expenses);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  @override
  Future<void> deleteAllExpenses() async {
    try {
      await _storageRepository.remove(_expensesKey);
    } catch (e) {
      throw Exception('Failed to delete all expenses: $e');
    }
  }

  Future<void> _saveExpenses(List<Expense> expenses) async {
    final expensesJson = json.encode(expenses.map((e) => e.toJson()).toList());
    await _storageRepository.saveString(_expensesKey, expensesJson);
  }
}
