/// Enum for different chart types available in analytics
enum ChartType { 
  bar, 
  pie;

  /// Returns the display name for the chart type
  String get displayName {
    switch (this) {
      case ChartType.bar:
        return 'Barras';
      case ChartType.pie:
        return 'Pastel';
    }
  }

  /// Returns the icon name for the chart type
  String get iconName {
    switch (this) {
      case ChartType.bar:
        return 'bar_chart';
      case ChartType.pie:
        return 'pie_chart';
    }
  }

  /// Convert from string for storage/retrieval
  static ChartType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bar':
      case 'barras':
        return ChartType.bar;
      case 'pie':
      case 'pastel':
        return ChartType.pie;
      default:
        return ChartType.bar; // Default fallback
    }
  }

  /// Convert to string for storage
  String toStorageString() {
    switch (this) {
      case ChartType.bar:
        return 'bar';
      case ChartType.pie:
        return 'pie';
    }
  }
}

/// Enum for different time periods for analytics
enum AnalyticsPeriod {
  daily,
  weekly,
  monthly,
  yearly;

  /// Returns the display name for the period
  String get displayName {
    switch (this) {
      case AnalyticsPeriod.daily:
        return 'Diario';
      case AnalyticsPeriod.weekly:
        return 'Semanal';
      case AnalyticsPeriod.monthly:
        return 'Mensual';
      case AnalyticsPeriod.yearly:
        return 'Anual';
    }
  }

  /// Returns the number of days this period represents
  int get daysCount {
    switch (this) {
      case AnalyticsPeriod.daily:
        return 1;
      case AnalyticsPeriod.weekly:
        return 7;
      case AnalyticsPeriod.monthly:
        return 30;
      case AnalyticsPeriod.yearly:
        return 365;
    }
  }
}