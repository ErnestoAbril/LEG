// Budget period enum following Clean Architecture principles
enum BudgetPeriod { daily, weekly, biweekly, monthly, yearly }

extension BudgetPeriodExt on BudgetPeriod {
  /// Returns an internal non-localized name (enum name) for storage or logic.
  String get nameLabel {
    switch (this) {
      case BudgetPeriod.daily:
        return 'Daily';
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.biweekly:
        return 'Biweekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }

  /// Returns the enum name for JSON serialization
  String get value {
    switch (this) {
      case BudgetPeriod.daily:
        return 'daily';
      case BudgetPeriod.weekly:
        return 'weekly';
      case BudgetPeriod.biweekly:
        return 'biweekly';
      case BudgetPeriod.monthly:
        return 'monthly';
      case BudgetPeriod.yearly:
        return 'yearly';
    }
  }

  /// Create enum from string value
  static BudgetPeriod fromValue(String value) {
    switch (value) {
      case 'daily':
        return BudgetPeriod.daily;
      case 'weekly':
        return BudgetPeriod.weekly;
      case 'biweekly':
        return BudgetPeriod.biweekly;
      case 'monthly':
        return BudgetPeriod.monthly;
      case 'yearly':
        return BudgetPeriod.yearly;
      default:
        return BudgetPeriod.monthly; // default fallback
    }
  }
}

// Budget entity following Clean Architecture principles
class Budget {
  final String id;
  final String name;
  final Map<String, double> categories;
  final BudgetPeriod period;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? description;

  const Budget({
    required this.id,
    required this.name,
    required this.categories,
    required this.period,
    required this.createdAt,
    this.updatedAt,
    this.isActive = false,
    this.description,
  });

  // Factory constructor for JSON serialization
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      name: json['name'] as String,
      categories: Map<String, double>.from(
        (json['categories'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      period: BudgetPeriodExt.fromValue(json['period'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? false,
      description: json['description'] as String?,
    );
  }

  // Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categories': categories,
      'period': period.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'description': description,
    };
  }

  // Copy with method for immutability
  Budget copyWith({
    String? id,
    String? name,
    Map<String, double>? categories,
    BudgetPeriod? period,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? description,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      categories: categories ?? Map<String, double>.from(this.categories),
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }

  // Get total budget amount
  double get totalAmount {
    return categories.values.fold<double>(0.0, (sum, amount) => sum + amount);
  }

  // Get categories as list
  List<String> get categoryNames {
    return categories.keys.toList()..sort();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.name == name &&
        _mapsEqual(other.categories, categories) &&
        other.period == period &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      categories,
      period,
      createdAt,
      updatedAt,
      isActive,
      description,
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, name: $name, categories: $categories, period: $period, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, description: $description)';
  }

  // Helper method to compare maps
  bool _mapsEqual(Map<String, double> map1, Map<String, double> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }
}