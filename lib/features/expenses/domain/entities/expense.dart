// Expense entity following Clean Architecture principles
class Expense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final bool isRecurring;
  final String? recurringPattern; // daily, weekly, monthly, yearly

  const Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.isRecurring = false,
    this.recurringPattern,
  });

  // Factory constructor for JSON serialization
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringPattern: json['recurringPattern'] as String?,
    );
  }

  // Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
    };
  }

  // Copy with method for immutability
  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    bool? isRecurring,
    String? recurringPattern,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.category == category &&
        other.date == date &&
        other.notes == notes &&
        other.isRecurring == isRecurring &&
        other.recurringPattern == recurringPattern;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      description,
      amount,
      category,
      date,
      notes,
      isRecurring,
      recurringPattern,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, description: $description, amount: $amount, category: $category, date: $date, notes: $notes, isRecurring: $isRecurring, recurringPattern: $recurringPattern)';
  }
}
