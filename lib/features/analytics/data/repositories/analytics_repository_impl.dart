import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/chart_config.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../datasources/analytics_data_source.dart';

/// Implementation of AnalyticsRepository following Clean Architecture
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsDataSource _dataSource;
  final ExpenseRepository _expenseRepository;

  const AnalyticsRepositoryImpl({
    required AnalyticsDataSource dataSource,
    required ExpenseRepository expenseRepository,
  })  : _dataSource = dataSource,
        _expenseRepository = expenseRepository;

  @override
  Future<ChartType> getPreferredChartType() async {
    return await _dataSource.getPreferredChartType();
  }

  @override
  Future<void> savePreferredChartType(ChartType chartType) async {
    await _dataSource.savePreferredChartType(chartType);
  }

  @override
  Future<PeriodAnalytics> getAnalyticsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get expenses for the period
      final expenses = await _expenseRepository.getExpensesByDateRange(
        startDate,
        endDate,
      );

      return await calculateAnalyticsFromExpenses(
        expenses: expenses,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get analytics for period: $e');
    }
  }

  @override
  Future<List<CategoryAnalytics>> getCategoryAnalytics(List<Expense> expenses) async {
    if (expenses.isEmpty) {
      return [];
    }

    try {
      // Group expenses by category
      final Map<String, List<Expense>> groupedExpenses = {};
      for (final expense in expenses) {
        if (!groupedExpenses.containsKey(expense.category)) {
          groupedExpenses[expense.category] = [];
        }
        groupedExpenses[expense.category]!.add(expense);
      }

      // Calculate total amount for percentage calculation
      final totalAmount = expenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );

      // Create analytics for each category
      final List<CategoryAnalytics> categoryAnalytics = [];
      for (final entry in groupedExpenses.entries) {
        final categoryExpenses = entry.value;
        final categoryTotal = categoryExpenses.fold<double>(
          0.0,
          (sum, expense) => sum + expense.amount,
        );
        final percentage = totalAmount > 0 ? (categoryTotal / totalAmount) * 100 : 0.0;
        
        // Find the most recent expense date for this category
        DateTime? lastExpenseDate;
        if (categoryExpenses.isNotEmpty) {
          lastExpenseDate = categoryExpenses
              .map((e) => e.date)
              .reduce((a, b) => a.isAfter(b) ? a : b);
        }

        categoryAnalytics.add(CategoryAnalytics(
          categoryName: entry.key,
          totalAmount: categoryTotal,
          expenseCount: categoryExpenses.length,
          percentage: percentage,
          lastExpenseDate: lastExpenseDate,
        ));
      }

      // Sort by total amount (highest first)
      categoryAnalytics.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

      return categoryAnalytics;
    } catch (e) {
      throw Exception('Failed to calculate category analytics: $e');
    }
  }

  @override
  Future<PeriodAnalytics> getCurrentMonthAnalytics() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return await getAnalyticsForPeriod(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  @override
  Future<PeriodAnalytics> getCurrentWeekAnalytics() async {
    final now = DateTime.now();
    final weekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return await getAnalyticsForPeriod(
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    );
  }

  @override
  Future<PeriodAnalytics> getCurrentYearAnalytics() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);

    return await getAnalyticsForPeriod(
      startDate: startOfYear,
      endDate: endOfYear,
    );
  }

  @override
  Future<List<CategoryAnalytics>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    try {
      final expenses = await _expenseRepository.getExpensesByDateRange(
        startDate,
        endDate,
      );

      final categoryAnalytics = await getCategoryAnalytics(expenses);
      
      // Return top categories limited by the specified limit
      return categoryAnalytics.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get top categories: $e');
    }
  }

  @override
  Future<List<PeriodAnalytics>> getSpendingTrends({
    required AnalyticsPeriod period,
    required int numberOfPeriods,
  }) async {
    try {
      final List<PeriodAnalytics> trends = [];
      final now = DateTime.now();

      for (int i = numberOfPeriods - 1; i >= 0; i--) {
        DateTime startDate;
        DateTime endDate;

        switch (period) {
          case AnalyticsPeriod.daily:
            final targetDate = now.subtract(Duration(days: i));
            startDate = DateTime(targetDate.year, targetDate.month, targetDate.day);
            endDate = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);
            break;
          case AnalyticsPeriod.weekly:
            final weekStart = now.subtract(Duration(days: (i * 7) + now.weekday - 1));
            startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
            endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
            break;
          case AnalyticsPeriod.monthly:
            final monthDate = DateTime(now.year, now.month - i, 1);
            startDate = monthDate;
            endDate = DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);
            break;
          case AnalyticsPeriod.yearly:
            final yearDate = DateTime(now.year - i, 1, 1);
            startDate = yearDate;
            endDate = DateTime(yearDate.year, 12, 31, 23, 59, 59);
            break;
        }

        final periodAnalytics = await getAnalyticsForPeriod(
          startDate: startDate,
          endDate: endDate,
        );

        trends.add(periodAnalytics);
      }

      return trends;
    } catch (e) {
      throw Exception('Failed to get spending trends: $e');
    }
  }

  @override
  Future<PeriodAnalytics> calculateAnalyticsFromExpenses({
    required List<Expense> expenses,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (expenses.isEmpty) {
        return PeriodAnalytics(
          startDate: startDate,
          endDate: endDate,
          totalAmount: 0.0,
          totalExpenses: 0,
          categoryBreakdown: [],
          averageExpenseAmount: 0.0,
          topCategory: '',
        );
      }

      // Calculate total amount
      final totalAmount = expenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );

      // Calculate average expense amount
      final averageExpenseAmount = totalAmount / expenses.length;

      // Get category breakdown
      final categoryBreakdown = await getCategoryAnalytics(expenses);

      // Find top category
      final topCategory = categoryBreakdown.isNotEmpty 
          ? categoryBreakdown.first.categoryName 
          : '';

      return PeriodAnalytics(
        startDate: startDate,
        endDate: endDate,
        totalAmount: totalAmount,
        totalExpenses: expenses.length,
        categoryBreakdown: categoryBreakdown,
        averageExpenseAmount: averageExpenseAmount,
        topCategory: topCategory,
      );
    } catch (e) {
      throw Exception('Failed to calculate analytics from expenses: $e');
    }
  }
}