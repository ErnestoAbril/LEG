import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'category_repository.dart';

const String _kPrefThemeMode = 'app_theme_mode';
const String _kPrefCurrency = 'app_currency';
const String _kPrefDecimalSep = 'app_decimal_sep';
const String _kPrefThousandSep = 'app_thousand_sep';
const String _kPrefWeekStart = 'app_week_start';
const String _kPrefDateFormat = 'app_date_format';

/// Global notifier that holds the current app ThemeMode.
final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier(
  ThemeMode.system,
);

class CurrencySettings {
  final String symbol;
  final String decimalSeparator;
  final String thousandSeparator;

  const CurrencySettings({
    required this.symbol,
    required this.decimalSeparator,
    required this.thousandSeparator,
  });

  Map<String, String> toMap() => {
    'symbol': symbol,
    'decimal': decimalSeparator,
    'thousand': thousandSeparator,
  };

  static CurrencySettings fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const CurrencySettings(
        symbol: '\$',
        decimalSeparator: '.',
        thousandSeparator: ',',
      );
    }
    return CurrencySettings(
      symbol: map['symbol'] as String? ?? '\$',
      decimalSeparator: map['decimal'] as String? ?? '.',
      thousandSeparator: map['thousand'] as String? ?? ',',
    );
  }
}

final ValueNotifier<CurrencySettings> currencyNotifier = ValueNotifier(
  const CurrencySettings(
    symbol: '\$',
    decimalSeparator: '.',
    thousandSeparator: ',',
  ),
);

/// Global notifier that holds the current app Locale (null = follow system/device).
final ValueNotifier<Locale?> appLocaleNotifier = ValueNotifier<Locale?>(null);

/// Load saved language preference from storage and update [appLocaleNotifier].
Future<void> loadSavedLocale() async {
  final lang = await CategoryRepository.getLanguage();
  if (lang != null && lang.isNotEmpty) {
    appLocaleNotifier.value = Locale(lang);
  } else {
    appLocaleNotifier.value = null;
  }
}

Future<void> loadCurrencySettings() async {
  final prefs = await SharedPreferences.getInstance();
  final symbol = prefs.getString(_kPrefCurrency) ?? '\$';
  final dec = prefs.getString(_kPrefDecimalSep) ?? '.';
  final thou = prefs.getString(_kPrefThousandSep) ?? ',';
  currencyNotifier.value = CurrencySettings(
    symbol: symbol,
    decimalSeparator: dec,
    thousandSeparator: thou,
  );
}

Future<void> saveCurrencySettings(CurrencySettings s) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kPrefCurrency, s.symbol);
  await prefs.setString(_kPrefDecimalSep, s.decimalSeparator);
  await prefs.setString(_kPrefThousandSep, s.thousandSeparator);
  currencyNotifier.value = s;
}

enum WeekStart { monday, sunday }

final ValueNotifier<WeekStart> weekStartNotifier = ValueNotifier(
  WeekStart.monday,
);
final ValueNotifier<String> dateFormatNotifier = ValueNotifier('dd/MM/yyyy');

Future<void> loadDateSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final w = prefs.getString(_kPrefWeekStart) ?? 'monday';
  weekStartNotifier.value = w == 'sunday' ? WeekStart.sunday : WeekStart.monday;
  dateFormatNotifier.value = prefs.getString(_kPrefDateFormat) ?? 'dd/MM/yyyy';
}

Future<void> saveDateSettings(WeekStart weekStart, String dateFormat) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _kPrefWeekStart,
    weekStart == WeekStart.sunday ? 'sunday' : 'monday',
  );
  await prefs.setString(_kPrefDateFormat, dateFormat);
  weekStartNotifier.value = weekStart;
  dateFormatNotifier.value = dateFormat;
}

/// Load saved theme from SharedPreferences into [appThemeNotifier].
Future<void> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final idx = prefs.getInt(_kPrefThemeMode) ?? ThemeMode.system.index;
  if (idx >= 0 && idx < ThemeMode.values.length) {
    appThemeNotifier.value = ThemeMode.values[idx];
  } else {
    appThemeNotifier.value = ThemeMode.system;
  }
}

/// Save theme to SharedPreferences and update [appThemeNotifier].
Future<void> saveTheme(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_kPrefThemeMode, ThemeMode.values.indexOf(mode));
  appThemeNotifier.value = mode;
}
