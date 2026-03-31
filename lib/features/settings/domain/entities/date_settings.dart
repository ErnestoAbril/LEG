/// Enum for week start day preferences
enum WeekStart { 
  monday, 
  sunday;

  /// Get display name
  String get displayName {
    switch (this) {
      case WeekStart.monday:
        return 'Lunes';
      case WeekStart.sunday:
        return 'Domingo';
    }
  }

  /// Get weekday number (1-7, where 1 is Monday)
  int get weekdayNumber {
    switch (this) {
      case WeekStart.monday:
        return DateTime.monday;
      case WeekStart.sunday:
        return DateTime.sunday;
    }
  }

  /// Create from string for storage compatibility
  static WeekStart fromString(String value) {
    switch (value.toLowerCase()) {
      case 'sunday':
        return WeekStart.sunday;
      case 'monday':
      default:
        return WeekStart.monday;
    }
  }

  /// Convert to string for storage
  String toStorageString() {
    switch (this) {
      case WeekStart.monday:
        return 'monday';
      case WeekStart.sunday:
        return 'sunday';
    }
  }
}

/// Entity representing date and time formatting preferences
class DateSettings {
  final String dateFormat;
  final WeekStart weekStart;
  final bool use24HourFormat;
  final String timeZone;

  const DateSettings({
    required this.dateFormat,
    required this.weekStart,
    this.use24HourFormat = true,
    this.timeZone = 'America/Mexico_City',
  });

  /// Creates a copy with updated values
  DateSettings copyWith({
    String? dateFormat,
    WeekStart? weekStart,
    bool? use24HourFormat,
    String? timeZone,
  }) {
    return DateSettings(
      dateFormat: dateFormat ?? this.dateFormat,
      weekStart: weekStart ?? this.weekStart,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      timeZone: timeZone ?? this.timeZone,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'dateFormat': dateFormat,
      'weekStart': weekStart.toStorageString(),
      'use24HourFormat': use24HourFormat,
      'timeZone': timeZone,
    };
  }

  /// Create from JSON
  factory DateSettings.fromJson(Map<String, dynamic> json) {
    return DateSettings(
      dateFormat: json['dateFormat'] as String? ?? 'dd/MM/yyyy',
      weekStart: WeekStart.fromString(json['weekStart'] as String? ?? 'monday'),
      use24HourFormat: json['use24HourFormat'] as bool? ?? true,
      timeZone: json['timeZone'] as String? ?? 'America/Mexico_City',
    );
  }

  /// Format a DateTime according to these settings
  String formatDate(DateTime date) {
    // This is a simplified formatter - in a real app you'd use intl package
    switch (dateFormat.toLowerCase()) {
      case 'dd/mm/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'mm/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-mm-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'dd-mm-yyyy':
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      default:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  /// Format time according to these settings
  String formatTime(DateTime time) {
    if (use24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Predefined date format options
  static const List<String> dateFormatOptions = [
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
    'dd-MM-yyyy',
  ];

  /// Get display name for date format
  String get dateFormatDisplayName {
    final now = DateTime.now();
    return '${formatDate(now)} ($dateFormat)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateSettings &&
        other.dateFormat == dateFormat &&
        other.weekStart == weekStart &&
        other.use24HourFormat == use24HourFormat &&
        other.timeZone == timeZone;
  }

  @override
  int get hashCode {
    return dateFormat.hashCode ^
        weekStart.hashCode ^
        use24HourFormat.hashCode ^
        timeZone.hashCode;
  }

  @override
  String toString() {
    return 'DateSettings(dateFormat: $dateFormat, weekStart: $weekStart, use24HourFormat: $use24HourFormat, timeZone: $timeZone)';
  }
}