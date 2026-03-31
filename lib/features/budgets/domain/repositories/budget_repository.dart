import '../entities/budget.dart';

// Abstract repository for budget operations following Clean Architecture
abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<Budget?> getBudgetById(String id);
  Future<Budget?> getActiveBudget();
  Future<void> saveBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
  Future<void> deleteAllBudgets();
  Future<void> setActiveBudget(String id);
  Future<void> deactivateAllBudgets();
  Future<List<Budget>> getBudgetsByPeriod(BudgetPeriod period);
  Future<double> getTotalBudgetAmount(String budgetId);
  Future<Map<String, double>> getCategoryBalances(String budgetId);
  Future<List<String>> getAllCategories();
  Future<double> getRemainingBudget(String budgetId, String category);
}