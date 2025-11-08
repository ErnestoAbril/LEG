import 'package:flutter/foundation.dart';
import '../../../../shared/domain/repositories/storage_repository.dart';
import '../../domain/entities/chart_config.dart';

/// Data source for analytics settings and cached data
/// Handles persistence using SharedPreferences
class AnalyticsDataSource {
  final StorageRepository _storageRepository;

  static const String _chartTypeKey = 'preferred_chart_type';
  static const String _lastAnalyticsUpdateKey = 'last_analytics_update';

  const AnalyticsDataSource({
    required StorageRepository storageRepository,
  }) : _storageRepository = storageRepository;

  /// Get the preferred chart type from storage
  Future<ChartType> getPreferredChartType() async {
    try {
      final chartTypeString = await _storageRepository.getString(_chartTypeKey);
      if (chartTypeString != null) {
        return ChartType.fromString(chartTypeString);
      }
    } catch (e) {
      // If there's an error reading, return default
      debugPrint('Error reading preferred chart type: $e');
    }
    return ChartType.bar; // Default chart type
  }

  /// Save the preferred chart type to storage
  Future<void> savePreferredChartType(ChartType chartType) async {
    try {
      await _storageRepository.saveString(
        _chartTypeKey,
        chartType.toStorageString(),
      );
    } catch (e) {
      debugPrint('Error saving preferred chart type: $e');
      throw Exception('Failed to save chart type preference');
    }
  }

  /// Get the last time analytics were updated
  Future<DateTime?> getLastAnalyticsUpdate() async {
    try {
      final timestamp = await _storageRepository.getString(_lastAnalyticsUpdateKey);
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      debugPrint('Error reading last analytics update: $e');
    }
    return null;
  }

  /// Save the last analytics update timestamp
  Future<void> saveLastAnalyticsUpdate(DateTime timestamp) async {
    try {
      await _storageRepository.saveString(
        _lastAnalyticsUpdateKey,
        timestamp.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving last analytics update: $e');
    }
  }

  /// Clear all analytics cached data
  Future<void> clearAnalyticsCache() async {
    try {
      await _storageRepository.remove(_lastAnalyticsUpdateKey);
    } catch (e) {
      debugPrint('Error clearing analytics cache: $e');
    }
  }

  /// Check if analytics data should be refreshed
  /// Returns true if data is older than the specified duration
  Future<bool> shouldRefreshAnalytics({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    final lastUpdate = await getLastAnalyticsUpdate();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final age = now.difference(lastUpdate);
    return age > maxAge;
  }
}