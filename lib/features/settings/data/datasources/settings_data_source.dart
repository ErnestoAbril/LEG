import 'package:flutter/material.dart';
import '../../../../shared/domain/repositories/storage_repository.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/theme_settings.dart';
import '../../domain/entities/currency_settings.dart';
import '../../domain/entities/date_settings.dart';

/// Data source for settings persistence using SharedPreferences
class SettingsDataSource {
  final StorageRepository _storage;

  // Storage keys
  static const String _themeKey = 'app_theme_settings';
  static const String _currencyKey = 'app_currency_settings';
  static const String _dateKey = 'app_date_settings';
  static const String _localeKey = 'app_locale_settings';
  static const String _categoriesKey = 'app_custom_categories';
  static const String _generalKey = 'app_general_settings';
  static const String _allSettingsKey = 'app_all_settings';

  // Legacy keys for migration
  static const String _legacyThemeModeKey = 'app_theme_mode';
  static const String _legacyCurrencyKey = 'app_currency';
  static const String _legacyDecimalSepKey = 'app_decimal_sep';
  static const String _legacyThousandSepKey = 'app_thousand_sep';
  static const String _legacyWeekStartKey = 'app_week_start';
  static const String _legacyDateFormatKey = 'app_date_format';

  const SettingsDataSource({required StorageRepository storage}) : _storage = storage;

  /// Save complete app settings
  Future<void> saveAppSettings(AppSettings settings) async {
    try {
      final json = settings.toJson();
      await _storage.saveString(_allSettingsKey, _encodeJson(json));
    } catch (e) {
      throw Exception('Failed to save app settings: $e');
    }
  }

  /// Load complete app settings
  Future<AppSettings> loadAppSettings() async {
    try {
      final jsonString = await _storage.getString(_allSettingsKey);
      if (jsonString != null) {
        final json = _decodeJson(jsonString);
        return AppSettings.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading app settings: $e');
    }
    
    // Return default settings if loading fails
    return AppSettings.defaultSettings();
  }

  /// Save theme settings
  Future<void> saveThemeSettings(ThemeSettings settings) async {
    try {
      final json = settings.toJson();
      await _storage.saveString(_themeKey, _encodeJson(json));
      
      // Also save to legacy key for backward compatibility
      await _storage.saveInt(_legacyThemeModeKey, settings.themeMode.index);
    } catch (e) {
      throw Exception('Failed to save theme settings: $e');
    }
  }

  /// Load theme settings
  Future<ThemeSettings> loadThemeSettings() async {
    try {
      final jsonString = await _storage.getString(_themeKey);
      if (jsonString != null) {
        final json = _decodeJson(jsonString);
        return ThemeSettings.fromJson(json);
      }
      
      // Try legacy format
      final legacyThemeMode = await _storage.getInt(_legacyThemeModeKey);
      if (legacyThemeMode != null) {
        return ThemeSettings(
          themeMode: legacyThemeMode >= 0 && legacyThemeMode < 3 
              ? ThemeMode.values[legacyThemeMode] 
              : ThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error loading theme settings: $e');
    }
    
    return const ThemeSettings(themeMode: ThemeMode.system);
  }

  /// Save currency settings
  Future<void> saveCurrencySettings(CurrencySettings settings) async {
    try {
      final json = settings.toJson();
      await _storage.saveString(_currencyKey, _encodeJson(json));
      
      // Also save to legacy keys for backward compatibility
      await _storage.saveString(_legacyCurrencyKey, settings.symbol);
      await _storage.saveString(_legacyDecimalSepKey, settings.decimalSeparator);
      await _storage.saveString(_legacyThousandSepKey, settings.thousandSeparator);
    } catch (e) {
      throw Exception('Failed to save currency settings: $e');
    }
  }

  /// Load currency settings
  Future<CurrencySettings> loadCurrencySettings() async {
    try {
      final jsonString = await _storage.getString(_currencyKey);
      if (jsonString != null) {
        final json = _decodeJson(jsonString);
        return CurrencySettings.fromJson(json);
      }
      
      // Try legacy format
      final symbol = await _storage.getString(_legacyCurrencyKey);
      final decimal = await _storage.getString(_legacyDecimalSepKey);
      final thousand = await _storage.getString(_legacyThousandSepKey);
      
      if (symbol != null || decimal != null || thousand != null) {
        return CurrencySettings(
          symbol: symbol ?? '\$',
          decimalSeparator: decimal ?? '.',
          thousandSeparator: thousand ?? ',',
        );
      }
    } catch (e) {
      debugPrint('Error loading currency settings: $e');
    }
    
    return const CurrencySettings(
      symbol: '\$',
      decimalSeparator: '.',
      thousandSeparator: ',',
    );
  }

  /// Save date settings
  Future<void> saveDateSettings(DateSettings settings) async {
    try {
      final json = settings.toJson();
      await _storage.saveString(_dateKey, _encodeJson(json));
      
      // Also save to legacy keys for backward compatibility
      await _storage.saveString(_legacyWeekStartKey, settings.weekStart.toStorageString());
      await _storage.saveString(_legacyDateFormatKey, settings.dateFormat);
    } catch (e) {
      throw Exception('Failed to save date settings: $e');
    }
  }

  /// Load date settings
  Future<DateSettings> loadDateSettings() async {
    try {
      final jsonString = await _storage.getString(_dateKey);
      if (jsonString != null) {
        final json = _decodeJson(jsonString);
        return DateSettings.fromJson(json);
      }
      
      // Try legacy format
      final weekStart = await _storage.getString(_legacyWeekStartKey);
      final dateFormat = await _storage.getString(_legacyDateFormatKey);
      
      if (weekStart != null || dateFormat != null) {
        return DateSettings(
          weekStart: WeekStart.fromString(weekStart ?? 'monday'),
          dateFormat: dateFormat ?? 'dd/MM/yyyy',
        );
      }
    } catch (e) {
      debugPrint('Error loading date settings: $e');
    }
    
    return const DateSettings(
      dateFormat: 'dd/MM/yyyy',
      weekStart: WeekStart.monday,
    );
  }

  /// Save locale settings
  Future<void> saveLocaleSettings(LocaleSettings settings) async {
    try {
      final json = settings.toJson();
      await _storage.saveString(_localeKey, _encodeJson(json));
    } catch (e) {
      throw Exception('Failed to save locale settings: $e');
    }
  }

  /// Load locale settings
  Future<LocaleSettings> loadLocaleSettings() async {
    try {
      final jsonString = await _storage.getString(_localeKey);
      if (jsonString != null) {
        final json = _decodeJson(jsonString);
        return LocaleSettings.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading locale settings: $e');
    }
    
    return const LocaleSettings(languageCode: 'es');
  }

  /// Save custom categories
  Future<void> saveCustomCategories(List<String> categories) async {
    try {
      await _storage.saveStringList(_categoriesKey, categories);
    } catch (e) {
      throw Exception('Failed to save custom categories: $e');
    }
  }

  /// Load custom categories
  Future<List<String>> loadCustomCategories() async {
    try {
      final categories = await _storage.getStringList(_categoriesKey);
      return categories ?? [];
    } catch (e) {
      debugPrint('Error loading custom categories: $e');
      return [];
    }
  }

  /// Save general settings
  Future<void> saveGeneralSettings(GeneralSettings settings) async {
    try {
      final json = settings.toJson();
      await _storage.saveString(_generalKey, _encodeJson(json));
    } catch (e) {
      throw Exception('Failed to save general settings: $e');
    }
  }

  /// Load general settings
  Future<GeneralSettings> loadGeneralSettings() async {
    try {
      final jsonString = await _storage.getString(_generalKey);
      if (jsonString != null) {
        final json = _decodeJson(jsonString);
        return GeneralSettings.fromJson(json);
      }
    } catch (e) {
      debugPrint('Error loading general settings: $e');
    }
    
    return const GeneralSettings();
  }

  /// Clear all settings
  Future<void> clearAllSettings() async {
    try {
      await Future.wait([
        _storage.remove(_allSettingsKey),
        _storage.remove(_themeKey),
        _storage.remove(_currencyKey),
        _storage.remove(_dateKey),
        _storage.remove(_localeKey),
        _storage.remove(_categoriesKey),
        _storage.remove(_generalKey),
      ]);
    } catch (e) {
      throw Exception('Failed to clear settings: $e');
    }
  }

  /// Check if legacy settings exist for migration
  Future<bool> hasLegacySettings() async {
    try {
      final hasTheme = await _storage.containsKey(_legacyThemeModeKey);
      final hasCurrency = await _storage.containsKey(_legacyCurrencyKey);
      final hasDate = await _storage.containsKey(_legacyDateFormatKey);
      
      return hasTheme || hasCurrency || hasDate;
    } catch (e) {
      return false;
    }
  }

  /// Get all storage keys for debugging
  Future<Set<String>> getAllKeys() async {
    try {
      return await _storage.getKeys();
    } catch (e) {
      return {};
    }
  }

  // Helper methods for JSON encoding/decoding
  String _encodeJson(Map<String, dynamic> json) {
    // In a real app, you might use dart:convert
    // For now, this is a placeholder
    return json.toString();
  }

  Map<String, dynamic> _decodeJson(String jsonString) {
    // In a real app, you might use dart:convert
    // For now, this is a placeholder that returns empty map
    // You would implement proper JSON parsing here
    return {};
  }
}
