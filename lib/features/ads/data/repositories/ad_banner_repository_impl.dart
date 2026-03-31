import '../../domain/entities/ad_banner.dart';
import '../../domain/repositories/ad_banner_repository.dart';
import '../datasources/ad_banner_datasource.dart';
import '../models/ad_banner_model.dart';

/// Implementation of AdBannerRepository
/// 
/// This class implements the domain repository interface and coordinates
/// data operations with the data source.
class AdBannerRepositoryImpl implements AdBannerRepository {
  final AdBannerDataSource dataSource;

  AdBannerRepositoryImpl(this.dataSource);

  @override
  Future<AdBanner?> getBannerById(String id) async {
    final model = await dataSource.getBannerById(id);
    return model?.toDomain();
  }

  @override
  Future<List<AdBanner>> getBannersByPosition(AdBannerPosition position) async {
    final models = await dataSource.getAllBanners();
    return models
        .where((model) => model.position == position)
        .map((model) => model.toDomain())
        .toList();
  }

  @override
  Future<List<AdBanner>> getActiveBanners() async {
    final models = await dataSource.getAllBanners();
    return models
        .map((model) => model.toDomain())
        .where((banner) => banner.isDisplayable)
        .toList();
  }

  @override
  Future<void> saveBanner(AdBanner banner) async {
    final model = AdBannerModel.fromDomain(banner);
    await dataSource.saveBanner(model);
  }

  @override
  Future<void> deleteBanner(String id) async {
    await dataSource.deleteBanner(id);
  }

  @override
  Future<void> clearAllBanners() async {
    await dataSource.clearAllBanners();
  }

  @override
  Future<void> setupDefaultBanners() async {
    await dataSource.setupDefaultBanners();
  }

  @override
  Future<void> refreshBannersFromRemote() async {
    await dataSource.refreshBannersFromRemote();
  }
}