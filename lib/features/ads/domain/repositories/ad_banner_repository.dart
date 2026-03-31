import '../entities/ad_banner.dart';

/// Repository interface for ad banner operations
/// 
/// This interface defines the contract for ad banner data operations
/// following the repository pattern.
abstract class AdBannerRepository {
  /// Get banner configuration by ID
  Future<AdBanner?> getBannerById(String id);
  
  /// Get all banners for a specific position
  Future<List<AdBanner>> getBannersByPosition(AdBannerPosition position);
  
  /// Get all active banners
  Future<List<AdBanner>> getActiveBanners();
  
  /// Save or update a banner configuration
  Future<void> saveBanner(AdBanner banner);
  
  /// Delete a banner
  Future<void> deleteBanner(String id);
  
  /// Clear all banners
  Future<void> clearAllBanners();
  
  /// Setup demo/default banners
  Future<void> setupDefaultBanners();
  
  /// Refresh banner configurations from remote source
  Future<void> refreshBannersFromRemote();
}