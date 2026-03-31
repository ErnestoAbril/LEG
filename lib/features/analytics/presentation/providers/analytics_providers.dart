import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../domain/entities/analytics_data.dart';
import '../../domain/entities/chart_config.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../data/datasources/analytics_data_source.dart';
import '../../data/repositories/analytics_repository_impl.dart';

/// Provider for AnalyticsDataSource
final analyticsDataSourceProvider = Provider<AnalyticsDataSource>((ref) {
  final storageRepository = ref.watch(storageRepositoryProvider);
  return AnalyticsDataSource(storageRepository: storageRepository);
});

/// Provider for AnalyticsRepository
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final dataSource = ref.watch(analyticsDataSourceProvider);
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  return AnalyticsRepositoryImpl(
    dataSource: dataSource,
    expenseRepository: expenseRepository,
  );
});

/// Provider for the preferred chart type
final chartTypeProvider = StateNotifierProvider<ChartTypeNotifier, AsyncValue<ChartType>>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return ChartTypeNotifier(repository);
});

/// StateNotifier for managing chart type state
class ChartTypeNotifier extends StateNotifier<AsyncValue<ChartType>> {
  final AnalyticsRepository _repository;

  ChartTypeNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadChartType();
  }

  /// Load the preferred chart type from storage
  Future<void> _loadChartType() async {
    try {
      final chartType = await _repository.getPreferredChartType();
      state = AsyncValue.data(chartType);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Change the chart type and save preference
  Future<void> setChartType(ChartType chartType) async {
    try {
      state = const AsyncValue.loading();
      await _repository.savePreferredChartType(chartType);
      state = AsyncValue.data(chartType);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      // Reload the previous value
      _loadChartType();
    }
  }

  /// Toggle between chart types
  Future<void> toggleChartType() async {
    final currentType = state.value ?? ChartType.bar;
    final newType = currentType == ChartType.bar ? ChartType.pie : ChartType.bar;
    await setChartType(newType);
  }

  /// Refresh the chart type from storage
  Future<void> refresh() async {
    await _loadChartType();
  }
}

/// Provider for current month analytics
final currentMonthAnalyticsProvider = FutureProvider<PeriodAnalytics>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return await repository.getCurrentMonthAnalytics();
});

/// Provider for current week analytics
final currentWeekAnalyticsProvider = FutureProvider<PeriodAnalytics>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return await repository.getCurrentWeekAnalytics();
});

/// Provider for current year analytics
final currentYearAnalyticsProvider = FutureProvider<PeriodAnalytics>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return await repository.getCurrentYearAnalytics();
});

/// Provider for analytics data for a specific period
final analyticsForPeriodProvider = FutureProvider.family<PeriodAnalytics, ({DateTime start, DateTime end})>(
  (ref, period) async {
    final repository = ref.watch(analyticsRepositoryProvider);
    return await repository.getAnalyticsForPeriod(
      startDate: period.start,
      endDate: period.end,
    );
  },
);

/// Provider for top categories
final topCategoriesProvider = FutureProvider.family<List<CategoryAnalytics>, ({DateTime start, DateTime end, int limit})>(
  (ref, params) async {
    final repository = ref.watch(analyticsRepositoryProvider);
    return await repository.getTopCategories(
      startDate: params.start,
      endDate: params.end,
      limit: params.limit,
    );
  },
);

/// Provider for spending trends
final spendingTrendsProvider = FutureProvider.family<List<PeriodAnalytics>, ({AnalyticsPeriod period, int numberOfPeriods})>(
  (ref, params) async {
    final repository = ref.watch(analyticsRepositoryProvider);
    return await repository.getSpendingTrends(
      period: params.period,
      numberOfPeriods: params.numberOfPeriods,
    );
  },
);

/// Provider for analytics dashboard data (combines multiple analytics)
final analyticsDashboardProvider = FutureProvider<AnalyticsDashboard>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  
  try {
    // Get analytics data for different periods in parallel
    final currentMonth = repository.getCurrentMonthAnalytics();
    final currentWeek = repository.getCurrentWeekAnalytics();
    final topCategories = repository.getTopCategories(
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      limit: 5,
    );
    final monthlyTrends = repository.getSpendingTrends(
      period: AnalyticsPeriod.monthly,
      numberOfPeriods: 6,
    );

    // Wait for all analytics to complete
    final results = await Future.wait([
      currentMonth,
      currentWeek,
      topCategories,
      monthlyTrends,
    ]);

    return AnalyticsDashboard(
      currentMonth: results[0] as PeriodAnalytics,
      currentWeek: results[1] as PeriodAnalytics,
      topCategories: results[2] as List<CategoryAnalytics>,
      monthlyTrends: results[3] as List<PeriodAnalytics>,
    );
  } catch (e) {
    throw Exception('Failed to load analytics dashboard: $e');
  }
});

/// Data class for analytics dashboard
class AnalyticsDashboard {
  final PeriodAnalytics currentMonth;
  final PeriodAnalytics currentWeek;
  final List<CategoryAnalytics> topCategories;
  final List<PeriodAnalytics> monthlyTrends;

  const AnalyticsDashboard({
    required this.currentMonth,
    required this.currentWeek,
    required this.topCategories,
    required this.monthlyTrends,
  });
}