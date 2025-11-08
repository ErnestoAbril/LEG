import '../entities/expense.dart';

// Abstract repository for expense operations following Clean Architecture
abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<List<Expense>> getExpensesByCategory(String category);
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<Expense?> getExpenseById(String id);
  Future<void> saveExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> deleteAllExpenses();
  Future<double> getTotalExpenses();
  Future<double> getTotalExpensesByCategory(String category);
  Future<double> getTotalExpensesByDateRange(DateTime start, DateTime end);
  Future<List<String>> getAllCategories();
  Future<Map<String, double>> getExpensesSummaryByCategory();
}
