import 'package:flutter/material.dart';
import 'theme_settings.dart';
import 'currency_settings.dart';
import 'date_settings.dart';

/// Comprehensive app settings entity
class AppSettings {
  final ThemeSettings theme;
  final CurrencySettings currency;
  final DateSettings date;
  final LocaleSettings locale;
  final List<String> customCategories;
  final GeneralSettings general;

  const AppSettings({
    required this.theme,
    required this.currency,
    required this.date,
    required this.locale,
    required this.customCategories,
    required this.general,
  });

  /// Creates a copy with updated values
  AppSettings copyWith({
    ThemeSettings? theme,
    CurrencySettings? currency,
    DateSettings? date,
    LocaleSettings? locale,
    List<String>? customCategories,
    GeneralSettings? general,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      locale: locale ?? this.locale,
      customCategories: customCategories ?? this.customCategories,
      general: general ?? this.general,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'theme': theme.toJson(),
      'currency': currency.toJson(),
      'date': date.toJson(),
      'locale': locale.toJson(),
      'customCategories': customCategories,
      'general': general.toJson(),
    };
  }

  /// Create from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: ThemeSettings.fromJson(json['theme'] as Map<String, dynamic>? ?? {}),
      currency: CurrencySettings.fromJson(json['currency'] as Map<String, dynamic>? ?? {}),
      date: DateSettings.fromJson(json['date'] as Map<String, dynamic>? ?? {}),
      locale: LocaleSettings.fromJson(json['locale'] as Map<String, dynamic>? ?? {}),
      customCategories: List<String>.from(json['customCategories'] as List? ?? []),
      general: GeneralSettings.fromJson(json['general'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Create default settings
  factory AppSettings.defaultSettings() {
    return const AppSettings(
      theme: ThemeSettings(themeMode: ThemeMode.system),
      currency: CurrencySettings(
        symbol: '\$',
        decimalSeparator: '.',
        thousandSeparator: ',',
      ),
      date: DateSettings(
        dateFormat: 'dd/MM/yyyy',
        weekStart: WeekStart.monday,
      ),
      locale: LocaleSettings(languageCode: 'es'),
      customCategories: [],
      general: GeneralSettings(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.theme == theme &&
        other.currency == currency &&
        other.date == date &&
        other.locale == locale &&
        other.general == general;
  }

  @override
  int get hashCode {
    return theme.hashCode ^
        currency.hashCode ^
        date.hashCode ^
        locale.hashCode ^
        general.hashCode;
  }

  @override
  String toString() {
    return 'AppSettings(theme: $theme, currency: $currency, date: $date, locale: $locale, general: $general)';
  }
}

/// Entity for locale/language settings
class LocaleSettings {
  final String languageCode;
  final String? countryCode;

  const LocaleSettings({
    required this.languageCode,
    this.countryCode,
  });

  /// Get Locale object
  Locale get locale {
    return countryCode != null 
        ? Locale(languageCode, countryCode)
        : Locale(languageCode);
  }

  /// Creates a copy with updated values
  LocaleSettings copyWith({
    String? languageCode,
    String? countryCode,
  }) {
    return LocaleSettings(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'countryCode': countryCode,
    };
  }

  /// Create from JSON
  factory LocaleSettings.fromJson(Map<String, dynamic> json) {
    return LocaleSettings(
      languageCode: json['languageCode'] as String? ?? 'es',
      countryCode: json['countryCode'] as String?,
    );
  }

  /// Get display name for language
  String get displayName {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      default:
        return languageCode.toUpperCase();
    }
  }

  /// Available languages
  static const List<LocaleSettings> availableLanguages = [
    LocaleSettings(languageCode: 'es'),
    LocaleSettings(languageCode: 'en'),
    LocaleSettings(languageCode: 'fr'),
    LocaleSettings(languageCode: 'de'),
    LocaleSettings(languageCode: 'it'),
    LocaleSettings(languageCode: 'pt'),
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocaleSettings &&
        other.languageCode == languageCode &&
        other.countryCode == countryCode;
  }

  @override
  int get hashCode {
    return languageCode.hashCode ^ countryCode.hashCode;
  }

  @override
  String toString() {
    return 'LocaleSettings(languageCode: $languageCode, countryCode: $countryCode)';
  }
}

/// Entity for general app settings
class GeneralSettings {
  final bool enableNotifications;
  final bool enableBiometrics;
  final bool enableAnalytics;
  final String donationUrl;
  final int backupFrequencyDays;
  final bool autoBackup;

  const GeneralSettings({
    this.enableNotifications = true,
    this.enableBiometrics = false,
    this.enableAnalytics = true,
    this.donationUrl = 'https://example.com/donate',
    this.backupFrequencyDays = 7,
    this.autoBackup = false,
  });

  /// Creates a copy with updated values
  GeneralSettings copyWith({
    bool? enableNotifications,
    bool? enableBiometrics,
    bool? enableAnalytics,
    String? donationUrl,
    int? backupFrequencyDays,
    bool? autoBackup,
  }) {
    return GeneralSettings(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableBiometrics: enableBiometrics ?? this.enableBiometrics,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      donationUrl: donationUrl ?? this.donationUrl,
      backupFrequencyDays: backupFrequencyDays ?? this.backupFrequencyDays,
      autoBackup: autoBackup ?? this.autoBackup,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'enableNotifications': enableNotifications,
      'enableBiometrics': enableBiometrics,
      'enableAnalytics': enableAnalytics,
      'donationUrl': donationUrl,
      'backupFrequencyDays': backupFrequencyDays,
      'autoBackup': autoBackup,
    };
  }

  /// Create from JSON
  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    return GeneralSettings(
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enableBiometrics: json['enableBiometrics'] as bool? ?? false,
      enableAnalytics: json['enableAnalytics'] as bool? ?? true,
      donationUrl: json['donationUrl'] as String? ?? 'https://example.com/donate',
      backupFrequencyDays: json['backupFrequencyDays'] as int? ?? 7,
      autoBackup: json['autoBackup'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeneralSettings &&
        other.enableNotifications == enableNotifications &&
        other.enableBiometrics == enableBiometrics &&
        other.enableAnalytics == enableAnalytics &&
        other.donationUrl == donationUrl &&
        other.backupFrequencyDays == backupFrequencyDays &&
        other.autoBackup == autoBackup;
  }

  @override
  int get hashCode {
    return enableNotifications.hashCode ^
        enableBiometrics.hashCode ^
        enableAnalytics.hashCode ^
        donationUrl.hashCode ^
        backupFrequencyDays.hashCode ^
        autoBackup.hashCode;
  }

  @override
  String toString() {
    return 'GeneralSettings(notifications: $enableNotifications, biometrics: $enableBiometrics, analytics: $enableAnalytics, backup: $autoBackup)';
  }
}