import 'package:shared_preferences/shared_preferences.dart';
import '../models/ad_banner_model.dart';
import '../../domain/entities/ad_banner.dart';

/// Data source for ad banner persistence using SharedPreferences
/// 
/// This class handles the low-level storage operations for ad banners.
class AdBannerDataSource {
  static const String _keyPrefix = 'ad_banner_';
  static const String _bannerListKey = 'ad_banner_list';

  /// Get banner by ID
  Future<AdBannerModel?> getBannerById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_keyPrefix$id');
      
      if (jsonString == null) return null;
      
      return AdBannerModel.fromQueryString(jsonString, id);
    } catch (e) {
      return null;
    }
  }

  /// Get all stored banner IDs
  Future<List<String>> getAllBannerIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_bannerListKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Get all banners
  Future<List<AdBannerModel>> getAllBanners() async {
    final ids = await getAllBannerIds();
    final List<AdBannerModel> banners = [];
    
    for (final id in ids) {
      final banner = await getBannerById(id);
      if (banner != null) {
        banners.add(banner);
      }
    }
    
    return banners;
  }

  /// Save banner
  Future<void> saveBanner(AdBannerModel banner) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save banner data
      final queryString = banner.toQueryString();
      await prefs.setString('$_keyPrefix${banner.id}', queryString);
      
      // Update banner list
      final ids = await getAllBannerIds();
      if (!ids.contains(banner.id)) {
        ids.add(banner.id);
        await prefs.setStringList(_bannerListKey, ids);
      }
    } catch (e) {
      // Log error in production
      rethrow;
    }
  }

  /// Delete banner
  Future<void> deleteBanner(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove banner data
      await prefs.remove('$_keyPrefix$id');
      
      // Update banner list
      final ids = await getAllBannerIds();
      ids.remove(id);
      await prefs.setStringList(_bannerListKey, ids);
    } catch (e) {
      // Log error in production
      rethrow;
    }
  }

  /// Clear all banners
  Future<void> clearAllBanners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = await getAllBannerIds();
      
      // Remove all banner data
      for (final id in ids) {
        await prefs.remove('$_keyPrefix$id');
      }
      
      // Clear banner list
      await prefs.remove(_bannerListKey);
    } catch (e) {
      // Log error in production
      rethrow;
    }
  }

  /// Create default banners for demo purposes
  Future<void> setupDefaultBanners() async {
    // Clear existing banners first
    await clearAllBanners();
    
    // Banner 1 - Main screen (bottom position)
    final banner1 = AdBannerModel(
      id: 'banner_1',
      isEnabled: true,
      fallbackText: '💳 ¡Tarjeta de Crédito sin Anualidad! - Banco Digital',
      targetUrl: 'https://flutter.dev',
      imageUrl: 'https://picsum.photos/350/80?random=1',
      position: AdBannerPosition.bottom,
      priority: 1,
    );

    // Banner 2 - Registration screen 
    final banner2 = AdBannerModel(
      id: 'banner_2',
      isEnabled: true,
      fallbackText: '🍕 Delivery Gratis en tu Primera Orden - App Food',
      targetUrl: 'https://dart.dev',
      imageUrl: 'https://picsum.photos/350/70?random=2',
      position: AdBannerPosition.top,
      priority: 1,
    );

    await saveBanner(banner1);
    await saveBanner(banner2);
  }

  /// Simulate refreshing banners from remote source
  /// In a real app, this would fetch from a remote API
  Future<void> refreshBannersFromRemote() async {
    // For now, just setup default banners
    // In production, this would:
    // 1. Fetch banner configurations from remote API
    // 2. Download and cache banner images
    // 3. Update local storage with new configurations
    await setupDefaultBanners();
  }
}