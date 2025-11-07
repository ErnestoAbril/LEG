import 'package:shared_preferences/shared_preferences.dart';

class AdBannerConfig {
  final String? imageUrl;
  final String? targetUrl;
  final String? localImagePath;
  final bool isEnabled;
  final String fallbackText;

  const AdBannerConfig({
    this.imageUrl,
    this.targetUrl,
    this.localImagePath,
    this.isEnabled = true,
    this.fallbackText = 'Espacio publicitario',
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'targetUrl': targetUrl,
      'localImagePath': localImagePath,
      'isEnabled': isEnabled,
      'fallbackText': fallbackText,
    };
  }

  factory AdBannerConfig.fromJson(Map<String, dynamic> json) {
    return AdBannerConfig(
      imageUrl: json['imageUrl'],
      targetUrl: json['targetUrl'],
      localImagePath: json['localImagePath'],
      isEnabled: json['isEnabled'] ?? true,
      fallbackText: json['fallbackText'] ?? 'Espacio publicitario',
    );
  }
}

class AdBannerService {
  static const String _banner1Key = 'ad_banner_1';
  static const String _banner2Key = 'ad_banner_2';

  // Banner por defecto (vacío/deshabilitado)
  static const AdBannerConfig _defaultConfig = AdBannerConfig(
    isEnabled: false,
    fallbackText: 'Banner publicitario',
  );

  static Future<AdBannerConfig> getBanner1Config() async {
    return _getBannerConfig(_banner1Key);
  }

  static Future<AdBannerConfig> getBanner2Config() async {
    return _getBannerConfig(_banner2Key);
  }

  static Future<void> saveBanner1Config(AdBannerConfig config) async {
    await _saveBannerConfig(_banner1Key, config);
  }

  static Future<void> saveBanner2Config(AdBannerConfig config) async {
    await _saveBannerConfig(_banner2Key, config);
  }

  static Future<AdBannerConfig> _getBannerConfig(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString == null) return _defaultConfig;
      
      final json = Map<String, dynamic>.from(
        Uri.splitQueryString(jsonString)
          .map((k, v) => MapEntry(k, v)),
      );
      return AdBannerConfig.fromJson(json);
    } catch (_) {
      return _defaultConfig;
    }
  }

  static Future<void> _saveBannerConfig(String key, AdBannerConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = config.toJson();
      // Convertir a query string simple para evitar problemas de serialización
      final queryString = json.entries
          .where((e) => e.value != null)
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      await prefs.setString(key, queryString);
    } catch (_) {
      // Error al guardar - se ignora
    }
  }

  // Método de conveniencia para crear banners de ejemplo
  static AdBannerConfig createSampleBanner({
    required String sampleText,
    String? sampleUrl,
  }) {
    return AdBannerConfig(
      isEnabled: true,
      fallbackText: sampleText,
      targetUrl: sampleUrl ?? 'https://example.com',
    );
  }
}