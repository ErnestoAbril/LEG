import 'package:flutter/material.dart';

/// Entity representing user theme preferences
class ThemeSettings {
  final ThemeMode themeMode;
  final bool useMaterialYou;
  final String? colorSchemeSeed;

  const ThemeSettings({
    required this.themeMode,
    this.useMaterialYou = true,
    this.colorSchemeSeed,
  });

  /// Creates a copy with updated values
  ThemeSettings copyWith({
    ThemeMode? themeMode,
    bool? useMaterialYou,
    String? colorSchemeSeed,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      colorSchemeSeed: colorSchemeSeed ?? this.colorSchemeSeed,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'useMaterialYou': useMaterialYou,
      'colorSchemeSeed': colorSchemeSeed,
    };
  }

  /// Create from JSON
  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      useMaterialYou: json['useMaterialYou'] as bool? ?? true,
      colorSchemeSeed: json['colorSchemeSeed'] as String?,
    );
  }

  /// Get display name for theme mode
  String get themeDisplayName {
    switch (themeMode) {
      case ThemeMode.system:
        return 'Sistema';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeSettings &&
        other.themeMode == themeMode &&
        other.useMaterialYou == useMaterialYou &&
        other.colorSchemeSeed == colorSchemeSeed;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        useMaterialYou.hashCode ^
        colorSchemeSeed.hashCode;
  }

  @override
  String toString() {
    return 'ThemeSettings(themeMode: $themeMode, useMaterialYou: $useMaterialYou, colorSchemeSeed: $colorSchemeSeed)';
  }
}