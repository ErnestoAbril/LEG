import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/theme_settings.dart';
import '../domain/entities/currency_settings.dart';
import '../domain/entities/date_settings.dart';
import '../domain/repositories/settings_repository.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../data/datasources/settings_data_source.dart';
import '../../../core/providers/providers.dart';

/// Data Source Provider
final settingsDataSourceProvider = Provider<SettingsDataSource>((ref) {
  final storage = ref.watch(storageRepositoryProvider);
  return SettingsDataSource(storage: storage);
});

/// Repository Provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsDataSourceProvider);
  return SettingsRepositoryImpl(dataSource: dataSource);
});

/// Settings State Notifier
class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      state = const AsyncValue.loading();
      final settings = await _repository.getAppSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAppSettings(AppSettings settings) async {
    try {
      await _repository.saveAppSettings(settings);
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateThemeSettings(ThemeSettings theme) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final newSettings = currentSettings.copyWith(theme: theme);
      await updateAppSettings(newSettings);
    }
  }

  Future<void> updateCurrencySettings(CurrencySettings currency) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final newSettings = currentSettings.copyWith(currency: currency);
      await updateAppSettings(newSettings);
    }
  }

  Future<void> updateDateSettings(DateSettings date) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final newSettings = currentSettings.copyWith(date: date);
      await updateAppSettings(newSettings);
    }
  }

  Future<void> updateLocaleSettings(LocaleSettings locale) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final newSettings = currentSettings.copyWith(locale: locale);
      await updateAppSettings(newSettings);
    }
  }

  Future<void> updateCustomCategories(List<String> categories) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final newSettings = currentSettings.copyWith(customCategories: categories);
      await updateAppSettings(newSettings);
    }
  }

  Future<void> addCustomCategory(String category) async {
    try {
      await _repository.addCustomCategory(category);
      await _loadSettings(); // Reload to get updated state
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeCustomCategory(String category) async {
    try {
      await _repository.removeCustomCategory(category);
      await _loadSettings(); // Reload to get updated state
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateGeneralSettings(GeneralSettings general) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final newSettings = currentSettings.copyWith(general: general);
      await updateAppSettings(newSettings);
    }
  }

  Future<void> resetToDefaults() async {
    try {
      await _repository.resetToDefaults();
      await _loadSettings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetThemeSettings() async {
    try {
      await _repository.resetThemeSettings();
      await _loadSettings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetCurrencySettings() async {
    try {
      await _repository.resetCurrencySettings();
      await _loadSettings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetDateSettings() async {
    try {
      await _repository.resetDateSettings();
      await _loadSettings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Map<String, dynamic>> exportSettings() async {
    return await _repository.exportSettings();
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      await _repository.importSettings(settings);
      await _loadSettings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> migrateLegacySettings() async {
    try {
      await _repository.migrateLegacySettings();
      await _loadSettings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Map<String, String>> getAppInfo() async {
    return await _repository.getAppInfo();
  }
}

/// Main Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

/// Specific Settings Providers (for convenience)
final themeSettingsProvider = Provider<ThemeSettings?>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.value?.theme;
});

final currencySettingsProvider = Provider<CurrencySettings?>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.value?.currency;
});

final dateSettingsProvider = Provider<DateSettings?>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.value?.date;
});

final localeSettingsProvider = Provider<LocaleSettings?>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.value?.locale;
});

final customCategoriesProvider = Provider<List<String>>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.value?.customCategories ?? [];
});

final generalSettingsProvider = Provider<GeneralSettings?>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.value?.general;
});

/// Theme Mode Provider (for Material App)
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeSettings = ref.watch(themeSettingsProvider);
  return themeSettings?.themeMode ?? ThemeMode.system;
});

/// Formatted Currency Provider (for display purposes)
final formattedCurrencyProvider = Provider.family<String, double>((ref, amount) {
  final currencySettings = ref.watch(currencySettingsProvider);
  if (currencySettings == null) return amount.toString();
  
  return currencySettings.formatAmount(amount);
});

/// App Info Provider
final appInfoProvider = FutureProvider<Map<String, String>>((ref) async {
  final settingsNotifier = ref.read(settingsProvider.notifier);
  return await settingsNotifier.getAppInfo();
});