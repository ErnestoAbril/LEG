import '../entities/ad_banner.dart';
import '../repositories/ad_banner_repository.dart';

/// Use case for getting banner by ID
class GetBannerById {
  final AdBannerRepository repository;

  GetBannerById(this.repository);

  Future<AdBanner?> call(String id) async {
    final banner = await repository.getBannerById(id);
    return banner?.isDisplayable == true ? banner : null;
  }
}

/// Use case for getting banners by position
class GetBannersByPosition {
  final AdBannerRepository repository;

  GetBannersByPosition(this.repository);

  Future<List<AdBanner>> call(AdBannerPosition position) async {
    final banners = await repository.getBannersByPosition(position);
    return banners.where((banner) => banner.isDisplayable).toList()
      ..sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
  }
}

/// Use case for saving banner configuration
class SaveBanner {
  final AdBannerRepository repository;

  SaveBanner(this.repository);

  Future<void> call(AdBanner banner) async {
    await repository.saveBanner(banner);
  }
}

/// Use case for setting up default banners
class SetupDefaultBanners {
  final AdBannerRepository repository;

  SetupDefaultBanners(this.repository);

  Future<void> call() async {
    await repository.setupDefaultBanners();
  }
}

/// Use case for refreshing banners from remote
class RefreshBannersFromRemote {
  final AdBannerRepository repository;

  RefreshBannersFromRemote(this.repository);

  Future<void> call() async {
    await repository.refreshBannersFromRemote();
  }
}