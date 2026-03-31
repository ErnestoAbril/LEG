import '../entities/app_settings.dart';
import '../entities/theme_settings.dart';
import '../entities/currency_settings.dart';
import '../entities/date_settings.dart';

/// Abstract repository for settings operations following Clean Architecture
abstract class SettingsRepository {
  /// Get all app settings
  Future<AppSettings> getAppSettings();

  /// Save all app settings
  Future<void> saveAppSettings(AppSettings settings);

  /// Theme settings operations
  Future<ThemeSettings> getThemeSettings();
  Future<void> saveThemeSettings(ThemeSettings settings);

  /// Currency settings operations
  Future<CurrencySettings> getCurrencySettings();
  Future<void> saveCurrencySettings(CurrencySettings settings);

  /// Date settings operations
  Future<DateSettings> getDateSettings();
  Future<void> saveDateSettings(DateSettings settings);

  /// Locale settings operations
  Future<LocaleSettings> getLocaleSettings();
  Future<void> saveLocaleSettings(LocaleSettings settings);

  /// Custom categories operations
  Future<List<String>> getCustomCategories();
  Future<void> saveCustomCategories(List<String> categories);
  Future<void> addCustomCategory(String category);
  Future<void> removeCustomCategory(String category);

  /// General settings operations
  Future<GeneralSettings> getGeneralSettings();
  Future<void> saveGeneralSettings(GeneralSettings settings);

  /// Backup and restore operations
  Future<Map<String, dynamic>> exportSettings();
  Future<void> importSettings(Map<String, dynamic> settings);

  /// Reset operations
  Future<void> resetToDefaults();
  Future<void> resetThemeSettings();
  Future<void> resetCurrencySettings();
  Future<void> resetDateSettings();

  /// Migration operations (for backward compatibility)
  Future<void> migrateLegacySettings();

  /// Settings validation
  Future<bool> validateSettings(AppSettings settings);

  /// Get app version and build info
  Future<Map<String, String>> getAppInfo();
}