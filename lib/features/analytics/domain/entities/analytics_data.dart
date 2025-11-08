/// Represents analytics data for expenses by category
class CategoryAnalytics {
  final String categoryName;
  final double totalAmount;
  final int expenseCount;
  final double percentage;
  final DateTime? lastExpenseDate;

  const CategoryAnalytics({
    required this.categoryName,
    required this.totalAmount,
    required this.expenseCount,
    required this.percentage,
    this.lastExpenseDate,
  });

  /// Creates a copy with updated values
  CategoryAnalytics copyWith({
    String? categoryName,
    double? totalAmount,
    int? expenseCount,
    double? percentage,
    DateTime? lastExpenseDate,
  }) {
    return CategoryAnalytics(
      categoryName: categoryName ?? this.categoryName,
      totalAmount: totalAmount ?? this.totalAmount,
      expenseCount: expenseCount ?? this.expenseCount,
      percentage: percentage ?? this.percentage,
      lastExpenseDate: lastExpenseDate ?? this.lastExpenseDate,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'totalAmount': totalAmount,
      'expenseCount': expenseCount,
      'percentage': percentage,
      'lastExpenseDate': lastExpenseDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CategoryAnalytics.fromJson(Map<String, dynamic> json) {
    return CategoryAnalytics(
      categoryName: json['categoryName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      expenseCount: json['expenseCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      lastExpenseDate: json['lastExpenseDate'] != null
          ? DateTime.parse(json['lastExpenseDate'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryAnalytics &&
        other.categoryName == categoryName &&
        other.totalAmount == totalAmount &&
        other.expenseCount == expenseCount &&
        other.percentage == percentage &&
        other.lastExpenseDate == lastExpenseDate;
  }

  @override
  int get hashCode {
    return categoryName.hashCode ^
        totalAmount.hashCode ^
        expenseCount.hashCode ^
        percentage.hashCode ^
        lastExpenseDate.hashCode;
  }

  @override
  String toString() {
    return 'CategoryAnalytics(categoryName: $categoryName, totalAmount: $totalAmount, expenseCount: $expenseCount, percentage: $percentage, lastExpenseDate: $lastExpenseDate)';
  }
}

/// Represents analytics data for a time period
class PeriodAnalytics {
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final int totalExpenses;
  final List<CategoryAnalytics> categoryBreakdown;
  final double averageExpenseAmount;
  final String topCategory;

  const PeriodAnalytics({
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.totalExpenses,
    required this.categoryBreakdown,
    required this.averageExpenseAmount,
    required this.topCategory,
  });

  /// Creates a copy with updated values
  PeriodAnalytics copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmount,
    int? totalExpenses,
    List<CategoryAnalytics>? categoryBreakdown,
    double? averageExpenseAmount,
    String? topCategory,
  }) {
    return PeriodAnalytics(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalAmount: totalAmount ?? this.totalAmount,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      averageExpenseAmount: averageExpenseAmount ?? this.averageExpenseAmount,
      topCategory: topCategory ?? this.topCategory,
    );
  }

  /// Get the duration of this period in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Get daily average spending
  double get dailyAverage {
    final days = durationInDays;
    return days > 0 ? totalAmount / days : 0.0;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalAmount': totalAmount,
      'totalExpenses': totalExpenses,
      'categoryBreakdown': categoryBreakdown.map((e) => e.toJson()).toList(),
      'averageExpenseAmount': averageExpenseAmount,
      'topCategory': topCategory,
    };
  }

  /// Create from JSON
  factory PeriodAnalytics.fromJson(Map<String, dynamic> json) {
    return PeriodAnalytics(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalExpenses: json['totalExpenses'] as int,
      categoryBreakdown: (json['categoryBreakdown'] as List)
          .map((e) => CategoryAnalytics.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageExpenseAmount: (json['averageExpenseAmount'] as num).toDouble(),
      topCategory: json['topCategory'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PeriodAnalytics &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.totalAmount == totalAmount &&
        other.totalExpenses == totalExpenses &&
        other.averageExpenseAmount == averageExpenseAmount &&
        other.topCategory == topCategory;
  }

  @override
  int get hashCode {
    return startDate.hashCode ^
        endDate.hashCode ^
        totalAmount.hashCode ^
        totalExpenses.hashCode ^
        averageExpenseAmount.hashCode ^
        topCategory.hashCode;
  }

  @override
  String toString() {
    return 'PeriodAnalytics(startDate: $startDate, endDate: $endDate, totalAmount: $totalAmount, totalExpenses: $totalExpenses, topCategory: $topCategory)';
  }
}