import '../entities/analytics_data.dart';
import '../entities/chart_config.dart';
import '../../../expenses/domain/entities/expense.dart';

/// Abstract repository for analytics operations
/// Following Clean Architecture principles
abstract class AnalyticsRepository {
  /// Get analytics data for a specific period
  Future<PeriodAnalytics> getAnalyticsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get category breakdown analytics for a list of expenses
  Future<List<CategoryAnalytics>> getCategoryAnalytics(List<Expense> expenses);

  /// Get the preferred chart type from user settings
  Future<ChartType> getPreferredChartType();

  /// Save the preferred chart type to user settings
  Future<void> savePreferredChartType(ChartType chartType);

  /// Get analytics for the current month
  Future<PeriodAnalytics> getCurrentMonthAnalytics();

  /// Get analytics for the current week
  Future<PeriodAnalytics> getCurrentWeekAnalytics();

  /// Get analytics for the current year
  Future<PeriodAnalytics> getCurrentYearAnalytics();

  /// Get top spending categories for a period
  Future<List<CategoryAnalytics>> getTopCategories({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  });

  /// Get spending trends over time
  Future<List<PeriodAnalytics>> getSpendingTrends({
    required AnalyticsPeriod period,
    required int numberOfPeriods,
  });

  /// Calculate expense analytics from raw expense data
  Future<PeriodAnalytics> calculateAnalyticsFromExpenses({
    required List<Expense> expenses,
    required DateTime startDate,
    required DateTime endDate,
  });
}