import '../../../../shared/domain/repositories/storage_repository.dart';
import '../../domain/entities/budget.dart';
import 'dart:convert';

// Abstract data source for budget operations
abstract class BudgetDataSource {
  Future<List<Budget>> getAllBudgets();
  Future<Budget?> getBudgetById(String id);
  Future<void> saveBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
  Future<void> deleteAllBudgets();
  Future<String?> getActiveBudgetId();
  Future<void> setActiveBudgetId(String id);
  Future<void> removeActiveBudgetId();
}

// Implementation using StorageRepository
class BudgetDataSourceImpl implements BudgetDataSource {
  final StorageRepository _storageRepository;
  static const String _budgetsKey = 'budgets';
  static const String _activeBudgetKey = 'active_budget_id';

  BudgetDataSourceImpl(this._storageRepository);

  @override
  Future<List<Budget>> getAllBudgets() async {
    try {
      final budgetsJson = await _storageRepository.getString(_budgetsKey);
      if (budgetsJson == null) return [];
      
      final List<dynamic> budgetsList = json.decode(budgetsJson);
      return budgetsList.map((json) => Budget.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load budgets: $e');
    }
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    try {
      final budgets = await getAllBudgets();
      final matchingBudgets = budgets.where((budget) => budget.id == id);
      return matchingBudgets.isNotEmpty ? matchingBudgets.first : null;
    } catch (e) {
      throw Exception('Failed to get budget by id: $e');
    }
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    try {
      final budgets = await getAllBudgets();
      budgets.add(budget);
      await _saveBudgets(budgets);
    } catch (e) {
      throw Exception('Failed to save budget: $e');
    }
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    try {
      final budgets = await getAllBudgets();
      final index = budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        budgets[index] = budget;
        await _saveBudgets(budgets);
      } else {
        throw Exception('Budget not found');
      }
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    try {
      final budgets = await getAllBudgets();
      budgets.removeWhere((budget) => budget.id == id);
      await _saveBudgets(budgets);
      
      // If deleted budget was active, remove active reference
      final activeBudgetId = await getActiveBudgetId();
      if (activeBudgetId == id) {
        await removeActiveBudgetId();
      }
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }

  @override
  Future<void> deleteAllBudgets() async {
    try {
      await _storageRepository.remove(_budgetsKey);
      await removeActiveBudgetId();
    } catch (e) {
      throw Exception('Failed to delete all budgets: $e');
    }
  }

  @override
  Future<String?> getActiveBudgetId() async {
    try {
      return await _storageRepository.getString(_activeBudgetKey);
    } catch (e) {
      throw Exception('Failed to get active budget id: $e');
    }
  }

  @override
  Future<void> setActiveBudgetId(String id) async {
    try {
      await _storageRepository.saveString(_activeBudgetKey, id);
    } catch (e) {
      throw Exception('Failed to set active budget id: $e');
    }
  }

  @override
  Future<void> removeActiveBudgetId() async {
    try {
      await _storageRepository.remove(_activeBudgetKey);
    } catch (e) {
      throw Exception('Failed to remove active budget id: $e');
    }
  }

  Future<void> _saveBudgets(List<Budget> budgets) async {
    final budgetsJson = json.encode(budgets.map((b) => b.toJson()).toList());
    await _storageRepository.saveString(_budgetsKey, budgetsJson);
  }
}