import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ad_banner.dart';
import '../../domain/repositories/ad_banner_repository.dart';
import '../../domain/usecases/ad_banner_usecases.dart';
import '../../data/datasources/ad_banner_datasource.dart';
import '../../data/repositories/ad_banner_repository_impl.dart';

/// Data source provider
final adBannerDataSourceProvider = Provider<AdBannerDataSource>((ref) {
  return AdBannerDataSource();
});

/// Repository provider
final adBannerRepositoryProvider = Provider<AdBannerRepository>((ref) {
  final dataSource = ref.read(adBannerDataSourceProvider);
  return AdBannerRepositoryImpl(dataSource);
});

/// Use cases providers
final getBannerByIdProvider = Provider<GetBannerById>((ref) {
  final repository = ref.read(adBannerRepositoryProvider);
  return GetBannerById(repository);
});

final getBannersByPositionProvider = Provider<GetBannersByPosition>((ref) {
  final repository = ref.read(adBannerRepositoryProvider);
  return GetBannersByPosition(repository);
});

final saveBannerProvider = Provider<SaveBanner>((ref) {
  final repository = ref.read(adBannerRepositoryProvider);
  return SaveBanner(repository);
});

final setupDefaultBannersProvider = Provider<SetupDefaultBanners>((ref) {
  final repository = ref.read(adBannerRepositoryProvider);
  return SetupDefaultBanners(repository);
});

final refreshBannersFromRemoteProvider = Provider<RefreshBannersFromRemote>((ref) {
  final repository = ref.read(adBannerRepositoryProvider);
  return RefreshBannersFromRemote(repository);
});

/// State providers for banner management

/// Provider for a specific banner by ID
final adBannerProvider = FutureProvider.family<AdBanner?, String>((ref, bannerId) async {
  final useCase = ref.read(getBannerByIdProvider);
  return await useCase(bannerId);
});

/// Provider for banners by position
final bannersByPositionProvider = FutureProvider.family<List<AdBanner>, AdBannerPosition>((ref, position) async {
  final useCase = ref.read(getBannersByPositionProvider);
  return await useCase(position);
});

/// Provider for all active banners
final activeBannersProvider = FutureProvider<List<AdBanner>>((ref) async {
  final repository = ref.read(adBannerRepositoryProvider);
  return await repository.getActiveBanners();
});

/// State notifier for banner management
class AdBannerNotifier extends StateNotifier<AsyncValue<List<AdBanner>>> {
  final AdBannerRepository _repository;
  final SetupDefaultBanners _setupDefaultBanners;
  final RefreshBannersFromRemote _refreshBannersFromRemote;

  AdBannerNotifier(
    this._repository,
    this._setupDefaultBanners,
    this._refreshBannersFromRemote,
  ) : super(const AsyncValue.loading()) {
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      state = const AsyncValue.loading();
      final banners = await _repository.getActiveBanners();
      state = AsyncValue.data(banners);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> saveBanner(AdBanner banner) async {
    try {
      await _repository.saveBanner(banner);
      await _loadBanners(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await _repository.deleteBanner(id);
      await _loadBanners(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setupDefaultBanners() async {
    try {
      state = const AsyncValue.loading();
      await _setupDefaultBanners();
      await _loadBanners();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshFromRemote() async {
    try {
      state = const AsyncValue.loading();
      await _refreshBannersFromRemote();
      await _loadBanners();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadBanners();
  }
}

/// Provider for the banner management state notifier
final adBannerNotifierProvider = StateNotifierProvider<AdBannerNotifier, AsyncValue<List<AdBanner>>>((ref) {
  final repository = ref.read(adBannerRepositoryProvider);
  final setupDefaultBanners = ref.read(setupDefaultBannersProvider);
  final refreshBannersFromRemote = ref.read(refreshBannersFromRemoteProvider);
  
  return AdBannerNotifier(
    repository,
    setupDefaultBanners,
    refreshBannersFromRemote,
  );
});

/// Convenience providers for specific banner positions

/// Provider for main menu banner (bottom position)
final mainMenuBannerProvider = FutureProvider<AdBanner?>((ref) async {
  final banners = await ref.watch(bannersByPositionProvider(AdBannerPosition.bottom).future);
  return banners.isNotEmpty ? banners.first : null;
});

/// Provider for registration screen banner (top position)  
final registrationBannerProvider = FutureProvider<AdBanner?>((ref) async {
  final banners = await ref.watch(bannersByPositionProvider(AdBannerPosition.top).future);
  return banners.isNotEmpty ? banners.first : null;
});