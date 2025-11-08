import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../data/datasources/budget_datasource.dart';

// Budget providers following Clean Architecture

// Data source provider
final budgetDataSourceProvider = Provider<BudgetDataSource>((ref) {
  final storageRepository = ref.watch(storageRepositoryProvider);
  return BudgetDataSourceImpl(storageRepository);
});

// Repository provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final dataSource = ref.watch(budgetDataSourceProvider);
  return BudgetRepositoryImpl(dataSource);
});

// State providers for budgets
final budgetsProvider = StateNotifierProvider<BudgetsNotifier, AsyncValue<List<Budget>>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return BudgetsNotifier(repository);
});

final activeBudgetProvider = StateNotifierProvider<ActiveBudgetNotifier, AsyncValue<Budget?>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return ActiveBudgetNotifier(repository);
});

final selectedBudgetProvider = StateProvider<Budget?>((ref) => null);

final budgetFormProvider = StateNotifierProvider<BudgetFormNotifier, BudgetFormState>((ref) {
  return BudgetFormNotifier();
});

// Budget state notifier
class BudgetsNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  final BudgetRepository _repository;

  BudgetsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      state = const AsyncValue.loading();
      final budgets = await _repository.getAllBudgets();
      state = AsyncValue.data(budgets);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _repository.saveBudget(budget);
      await loadBudgets(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _repository.updateBudget(budget);
      await loadBudgets(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _repository.deleteBudget(id);
      await loadBudgets(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setActiveBudget(String id) async {
    try {
      await _repository.setActiveBudget(id);
      await loadBudgets(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Active budget notifier
class ActiveBudgetNotifier extends StateNotifier<AsyncValue<Budget?>> {
  final BudgetRepository _repository;

  ActiveBudgetNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadActiveBudget();
  }

  Future<void> loadActiveBudget() async {
    try {
      state = const AsyncValue.loading();
      final activeBudget = await _repository.getActiveBudget();
      state = AsyncValue.data(activeBudget);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setActiveBudget(String id) async {
    try {
      await _repository.setActiveBudget(id);
      await loadActiveBudget(); // Refresh active budget
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deactivateAll() async {
    try {
      await _repository.deactivateAllBudgets();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Budget form state
class BudgetFormState {
  final String name;
  final Map<String, double> categories;
  final BudgetPeriod period;
  final String description;
  final bool isValid;

  const BudgetFormState({
    this.name = '',
    this.categories = const {},
    this.period = BudgetPeriod.monthly,
    this.description = '',
    this.isValid = false,
  });

  BudgetFormState copyWith({
    String? name,
    Map<String, double>? categories,
    BudgetPeriod? period,
    String? description,
    bool? isValid,
  }) {
    return BudgetFormState(
      name: name ?? this.name,
      categories: categories ?? Map<String, double>.from(this.categories),
      period: period ?? this.period,
      description: description ?? this.description,
      isValid: isValid ?? this.isValid,
    );
  }

  double get totalAmount {
    return categories.values.fold<double>(0.0, (sum, amount) => sum + amount);
  }
}

// Budget form notifier
class BudgetFormNotifier extends StateNotifier<BudgetFormState> {
  BudgetFormNotifier() : super(const BudgetFormState());

  void updateName(String name) {
    state = state.copyWith(
      name: name,
      isValid: _validateForm(name, state.categories),
    );
  }

  void updateCategories(Map<String, double> categories) {
    state = state.copyWith(
      categories: categories,
      isValid: _validateForm(state.name, categories),
    );
  }

  void addCategory(String category, double amount) {
    final newCategories = Map<String, double>.from(state.categories);
    newCategories[category] = amount;
    state = state.copyWith(
      categories: newCategories,
      isValid: _validateForm(state.name, newCategories),
    );
  }

  void removeCategory(String category) {
    final newCategories = Map<String, double>.from(state.categories);
    newCategories.remove(category);
    state = state.copyWith(
      categories: newCategories,
      isValid: _validateForm(state.name, newCategories),
    );
  }

  void updateCategoryAmount(String category, double amount) {
    final newCategories = Map<String, double>.from(state.categories);
    newCategories[category] = amount;
    state = state.copyWith(
      categories: newCategories,
      isValid: _validateForm(state.name, newCategories),
    );
  }

  void updatePeriod(BudgetPeriod period) {
    state = state.copyWith(period: period);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void reset() {
    state = const BudgetFormState();
  }

  void loadBudget(Budget budget) {
    state = BudgetFormState(
      name: budget.name,
      categories: Map<String, double>.from(budget.categories),
      period: budget.period,
      description: budget.description ?? '',
      isValid: true,
    );
  }

  bool _validateForm(String name, Map<String, double> categories) {
    return name.isNotEmpty && categories.isNotEmpty && 
           categories.values.every((amount) => amount > 0);
  }

  Budget toBudget() {
    return Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: state.name,
      categories: Map<String, double>.from(state.categories),
      period: state.period,
      createdAt: DateTime.now(),
      description: state.description.isNotEmpty ? state.description : null,
    );
  }

  Budget updateExistingBudget(Budget existing) {
    return existing.copyWith(
      name: state.name,
      categories: Map<String, double>.from(state.categories),
      period: state.period,
      description: state.description.isNotEmpty ? state.description : null,
      updatedAt: DateTime.now(),
    );
  }
}