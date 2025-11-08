import 'package:flutter/material.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/theme_settings.dart';
import '../../domain/entities/currency_settings.dart';
import '../../domain/entities/date_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_data_source.dart';

/// Implementation of SettingsRepository following Clean Architecture
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _dataSource;

  const SettingsRepositoryImpl({
    required SettingsDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<AppSettings> getAppSettings() async {
    try {
      return await _dataSource.loadAppSettings();
    } catch (e) {
      throw Exception('Failed to get app settings: $e');
    }
  }

  @override
  Future<void> saveAppSettings(AppSettings settings) async {
    try {
      // Validate settings before saving
      final isValid = await validateSettings(settings);
      if (!isValid) {
        throw Exception('Invalid settings data');
      }

      await _dataSource.saveAppSettings(settings);
    } catch (e) {
      throw Exception('Failed to save app settings: $e');
    }
  }

  @override
  Future<ThemeSettings> getThemeSettings() async {
    try {
      return await _dataSource.loadThemeSettings();
    } catch (e) {
      throw Exception('Failed to get theme settings: $e');
    }
  }

  @override
  Future<void> saveThemeSettings(ThemeSettings settings) async {
    try {
      await _dataSource.saveThemeSettings(settings);
    } catch (e) {
      throw Exception('Failed to save theme settings: $e');
    }
  }

  @override
  Future<CurrencySettings> getCurrencySettings() async {
    try {
      return await _dataSource.loadCurrencySettings();
    } catch (e) {
      throw Exception('Failed to get currency settings: $e');
    }
  }

  @override
  Future<void> saveCurrencySettings(CurrencySettings settings) async {
    try {
      await _dataSource.saveCurrencySettings(settings);
    } catch (e) {
      throw Exception('Failed to save currency settings: $e');
    }
  }

  @override
  Future<DateSettings> getDateSettings() async {
    try {
      return await _dataSource.loadDateSettings();
    } catch (e) {
      throw Exception('Failed to get date settings: $e');
    }
  }

  @override
  Future<void> saveDateSettings(DateSettings settings) async {
    try {
      await _dataSource.saveDateSettings(settings);
    } catch (e) {
      throw Exception('Failed to save date settings: $e');
    }
  }

  @override
  Future<LocaleSettings> getLocaleSettings() async {
    try {
      return await _dataSource.loadLocaleSettings();
    } catch (e) {
      throw Exception('Failed to get locale settings: $e');
    }
  }

  @override
  Future<void> saveLocaleSettings(LocaleSettings settings) async {
    try {
      await _dataSource.saveLocaleSettings(settings);
    } catch (e) {
      throw Exception('Failed to save locale settings: $e');
    }
  }

  @override
  Future<List<String>> getCustomCategories() async {
    try {
      return await _dataSource.loadCustomCategories();
    } catch (e) {
      throw Exception('Failed to get custom categories: $e');
    }
  }

  @override
  Future<void> saveCustomCategories(List<String> categories) async {
    try {
      await _dataSource.saveCustomCategories(categories);
    } catch (e) {
      throw Exception('Failed to save custom categories: $e');
    }
  }

  @override
  Future<void> addCustomCategory(String category) async {
    try {
      final categories = await getCustomCategories();
      if (!categories.contains(category)) {
        categories.add(category);
        await saveCustomCategories(categories);
      }
    } catch (e) {
      throw Exception('Failed to add custom category: $e');
    }
  }

  @override
  Future<void> removeCustomCategory(String category) async {
    try {
      final categories = await getCustomCategories();
      categories.remove(category);
      await saveCustomCategories(categories);
    } catch (e) {
      throw Exception('Failed to remove custom category: $e');
    }
  }

  @override
  Future<GeneralSettings> getGeneralSettings() async {
    try {
      return await _dataSource.loadGeneralSettings();
    } catch (e) {
      throw Exception('Failed to get general settings: $e');
    }
  }

  @override
  Future<void> saveGeneralSettings(GeneralSettings settings) async {
    try {
      await _dataSource.saveGeneralSettings(settings);
    } catch (e) {
      throw Exception('Failed to save general settings: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final settings = await getAppSettings();
      return {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'settings': settings.toJson(),
      };
    } catch (e) {
      throw Exception('Failed to export settings: $e');
    }
  }

  @override
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      final settingsData = settings['settings'] as Map<String, dynamic>?;
      if (settingsData == null) {
        throw Exception('Invalid settings format');
      }

      final appSettings = AppSettings.fromJson(settingsData);
      await saveAppSettings(appSettings);
    } catch (e) {
      throw Exception('Failed to import settings: $e');
    }
  }

  @override
  Future<void> resetToDefaults() async {
    try {
      await _dataSource.clearAllSettings();
      final defaultSettings = AppSettings.defaultSettings();
      await saveAppSettings(defaultSettings);
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }

  @override
  Future<void> resetThemeSettings() async {
    try {
      final defaultTheme = ThemeSettings(themeMode: ThemeMode.system);
      await saveThemeSettings(defaultTheme);
    } catch (e) {
      throw Exception('Failed to reset theme settings: $e');
    }
  }

  @override
  Future<void> resetCurrencySettings() async {
    try {
      const defaultCurrency = CurrencySettings(
        symbol: '\$',
        decimalSeparator: '.',
        thousandSeparator: ',',
      );
      await saveCurrencySettings(defaultCurrency);
    } catch (e) {
      throw Exception('Failed to reset currency settings: $e');
    }
  }

  @override
  Future<void> resetDateSettings() async {
    try {
      const defaultDate = DateSettings(
        dateFormat: 'dd/MM/yyyy',
        weekStart: WeekStart.monday,
      );
      await saveDateSettings(defaultDate);
    } catch (e) {
      throw Exception('Failed to reset date settings: $e');
    }
  }

  @override
  Future<void> migrateLegacySettings() async {
    try {
      final hasLegacy = await _dataSource.hasLegacySettings();
      if (!hasLegacy) return;

      // Load all legacy settings
      final theme = await _dataSource.loadThemeSettings();
      final currency = await _dataSource.loadCurrencySettings();
      final date = await _dataSource.loadDateSettings();
      final locale = await _dataSource.loadLocaleSettings();
      final categories = await _dataSource.loadCustomCategories();
      final general = await _dataSource.loadGeneralSettings();

      // Create new app settings
      final appSettings = AppSettings(
        theme: theme,
        currency: currency,
        date: date,
        locale: locale,
        customCategories: categories,
        general: general,
      );

      // Save in new format
      await saveAppSettings(appSettings);
    } catch (e) {
      throw Exception('Failed to migrate legacy settings: $e');
    }
  }

  @override
  Future<bool> validateSettings(AppSettings settings) async {
    try {
      // Validate currency settings
      if (settings.currency.symbol.isEmpty) return false;
      if (settings.currency.decimalSeparator.isEmpty) return false;
      if (settings.currency.decimalPlaces < 0 || settings.currency.decimalPlaces > 4) return false;

      // Validate date settings
      if (settings.date.dateFormat.isEmpty) return false;

      // Validate locale settings
      if (settings.locale.languageCode.isEmpty) return false;

      // Validate general settings
      if (settings.general.backupFrequencyDays < 1) return false;
      if (settings.general.donationUrl.isEmpty) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, String>> getAppInfo() async {
    try {
      // In a real app, you'd get this from package_info_plus
      return {
        'appName': 'Luz en el Gasto',
        'version': '1.0.0',
        'buildNumber': '1',
        'packageName': 'com.example.luz_en_el_gasto',
      };
    } catch (e) {
      throw Exception('Failed to get app info: $e');
    }
  }
}