import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_datasource.dart';

// Concrete implementation of Budget Repository
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetDataSource _dataSource;

  BudgetRepositoryImpl(this._dataSource);

  @override
  Future<List<Budget>> getAllBudgets() async {
    return await _dataSource.getAllBudgets();
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    return await _dataSource.getBudgetById(id);
  }

  @override
  Future<Budget?> getActiveBudget() async {
    final activeBudgetId = await _dataSource.getActiveBudgetId();
    if (activeBudgetId == null) return null;
    return await _dataSource.getBudgetById(activeBudgetId);
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    await _dataSource.saveBudget(budget);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _dataSource.updateBudget(budget);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _dataSource.deleteBudget(id);
  }

  @override
  Future<void> deleteAllBudgets() async {
    await _dataSource.deleteAllBudgets();
  }

  @override
  Future<void> setActiveBudget(String id) async {
    // First, deactivate all budgets
    await deactivateAllBudgets();
    
    // Then set the new active budget
    await _dataSource.setActiveBudgetId(id);
    
    // Update the budget entity to mark it as active
    final budget = await _dataSource.getBudgetById(id);
    if (budget != null) {
      final updatedBudget = budget.copyWith(
        isActive: true,
        updatedAt: DateTime.now(),
      );
      await _dataSource.updateBudget(updatedBudget);
    }
  }

  @override
  Future<void> deactivateAllBudgets() async {
    final budgets = await _dataSource.getAllBudgets();
    
    // Update all budgets to inactive
    for (final budget in budgets) {
      if (budget.isActive) {
        final updatedBudget = budget.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        await _dataSource.updateBudget(updatedBudget);
      }
    }
    
    // Remove active budget reference
    await _dataSource.removeActiveBudgetId();
  }

  @override
  Future<List<Budget>> getBudgetsByPeriod(BudgetPeriod period) async {
    final budgets = await _dataSource.getAllBudgets();
    return budgets.where((budget) => budget.period == period).toList();
  }

  @override
  Future<double> getTotalBudgetAmount(String budgetId) async {
    final budget = await _dataSource.getBudgetById(budgetId);
    return budget?.totalAmount ?? 0.0;
  }

  @override
  Future<Map<String, double>> getCategoryBalances(String budgetId) async {
    final budget = await _dataSource.getBudgetById(budgetId);
    if (budget == null) return {};
    
    // For now, return the original budget amounts
    // This would need to integrate with expense data to calculate actual balances
    return Map<String, double>.from(budget.categories);
  }

  @override
  Future<List<String>> getAllCategories() async {
    final budgets = await _dataSource.getAllBudgets();
    final categories = <String>{};
    
    for (final budget in budgets) {
      categories.addAll(budget.categoryNames);
    }
    
    return categories.toList()..sort();
  }

  @override
  Future<double> getRemainingBudget(String budgetId, String category) async {
    final budget = await _dataSource.getBudgetById(budgetId);
    if (budget == null) return 0.0;
    
    final budgetAmount = budget.categories[category] ?? 0.0;
    
    // For now, return the full budget amount
    // This would need to integrate with expense data to calculate spent amount
    return budgetAmount;
  }
}