import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/datasources/expense_datasource.dart';

// Expense providers following Clean Architecture

// Data source provider
final expenseDataSourceProvider = Provider<ExpenseDataSource>((ref) {
  final storageRepository = ref.watch(storageRepositoryProvider);
  return ExpenseDataSourceImpl(storageRepository);
});

// Repository provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dataSource = ref.watch(expenseDataSourceProvider);
  final errorHandler = ref.watch(errorHandlerProvider);
  final retryService = ref.watch(retryServiceProvider);
  return ExpenseRepositoryImpl(
    dataSource,
    errorHandler,
    retryService,
  );
});

// Use case providers
final addExpenseUseCaseProvider = Provider<AddExpenseUseCase>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return AddExpenseUseCase(repository);
});

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return GetExpensesUseCase(repository);
});

// State providers for expenses
final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<List<Expense>>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ExpensesNotifier(repository);
});

final selectedExpenseProvider = StateProvider<Expense?>((ref) => null);

final expenseFormProvider = StateNotifierProvider<ExpenseFormNotifier, ExpenseFormState>((ref) {
  return ExpenseFormNotifier();
});

// Expense state notifier
class ExpensesNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseRepository _repository;

  ExpensesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      state = const AsyncValue.loading();
      final expenses = await _repository.getAllExpenses();
      state = AsyncValue.data(expenses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _repository.saveExpense(expense);
      await loadExpenses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _repository.updateExpense(expense);
      await loadExpenses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Expense form state
class ExpenseFormState {
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final bool isValid;

  const ExpenseFormState({
    this.description = '',
    this.amount = 0.0,
    this.category = '',
    required this.date,
    this.isValid = false,
  });

  ExpenseFormState copyWith({
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    bool? isValid,
  }) {
    return ExpenseFormState(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isValid: isValid ?? this.isValid,
    );
  }
}

// Expense form notifier
class ExpenseFormNotifier extends StateNotifier<ExpenseFormState> {
  ExpenseFormNotifier() : super(ExpenseFormState(date: DateTime.now()));

  void updateDescription(String description) {
    state = state.copyWith(
      description: description,
      isValid: _validateForm(description, state.amount, state.category),
    );
  }

  void updateAmount(double amount) {
    state = state.copyWith(
      amount: amount,
      isValid: _validateForm(state.description, amount, state.category),
    );
  }

  void updateCategory(String category) {
    state = state.copyWith(
      category: category,
      isValid: _validateForm(state.description, state.amount, category),
    );
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void reset() {
    state = ExpenseFormState(date: DateTime.now());
  }

  bool _validateForm(String description, double amount, String category) {
    return description.isNotEmpty && amount > 0 && category.isNotEmpty;
  }

  Expense toExpense() {
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: state.description,
      amount: state.amount,
      category: state.category,
      date: state.date,
    );
  }
}
