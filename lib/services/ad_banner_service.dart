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
    // Manejar conversión de string a bool para valores que vienen de query string
    bool isEnabledValue = false;
    if (json['isEnabled'] != null) {
      if (json['isEnabled'] is bool) {
        isEnabledValue = json['isEnabled'];
      } else if (json['isEnabled'] is String) {
        isEnabledValue = json['isEnabled'].toLowerCase() == 'true';
      }
    }
    
    return AdBannerConfig(
      imageUrl: json['imageUrl'],
      targetUrl: json['targetUrl'],
      localImagePath: json['localImagePath'],
      isEnabled: isEnabledValue,
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
      
      if (jsonString == null) {
        return _defaultConfig;
      }
      
      final json = Map<String, dynamic>.from(
        Uri.splitQueryString(jsonString)
          .map((k, v) => MapEntry(k, v)),
      );
      
      final config = AdBannerConfig.fromJson(json);
      
      return config;
    } catch (e) {
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
    } catch (e) {
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

  // Método para configurar banners de demostración
  static Future<void> setupDemoBanners() async {
    // Banner 1 - Página principal (imagen publicitaria real)
    final banner1 = AdBannerConfig(
      isEnabled: true,
      fallbackText: '💳 ¡Tarjeta de Crédito sin Anualidad! - Banco Digital',
      targetUrl: 'https://flutter.dev',
      imageUrl: 'https://picsum.photos/350/80?random=1',
    );

    // Banner 2 - Página de registro (imagen publicitaria real)
    final banner2 = AdBannerConfig(
      isEnabled: true,
      fallbackText: '🍕 Delivery Gratis en tu Primera Orden - App Food',
      targetUrl: 'https://dart.dev',
      imageUrl: 'https://picsum.photos/350/70?random=2',
    );

    await saveBanner1Config(banner1);
    await saveBanner2Config(banner2);
  }
}
