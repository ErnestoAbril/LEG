import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/ad_banner.dart' as domain;
import '../providers/ad_banner_providers.dart';

/// Professional ad banner widget with Clean Architecture
/// 
/// This widget displays advertisement banners with support for images,
/// fallback text, and click actions. It integrates with the ads feature
/// providers for state management.
class AdBannerWidget extends ConsumerWidget {
  final String bannerId;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showLoadingIndicator;

  const AdBannerWidget({
    super.key,
    required this.bannerId,
    this.height,
    this.margin,
    this.padding,
    this.onTap,
    this.showLoadingIndicator = true,
  });

  /// Create a banner widget for a specific position
  AdBannerWidget.forPosition({
    super.key,
    required domain.AdBannerPosition position,
    this.height,
    this.margin,
    this.padding,
    this.onTap,
    this.showLoadingIndicator = true,
  }) : bannerId = '${position.name}_banner';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAsync = ref.watch(adBannerProvider(bannerId));

    return bannerAsync.when(
      data: (banner) {
        if (banner == null || !banner.isDisplayable) {
          return const SizedBox.shrink();
        }
        return _AdBannerContent(
          banner: banner,
          height: height,
          margin: margin,
          padding: padding,
          onTap: onTap,
        );
      },
      loading: () => showLoadingIndicator
          ? _buildLoadingState()
          : const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: height ?? 80,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal widget for displaying banner content
class _AdBannerContent extends StatelessWidget {
  final domain.AdBanner banner;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const _AdBannerContent({
    required this.banner,
    this.height,
    this.margin,
    this.padding,
    this.onTap,
  });

  Future<void> _handleTap() async {
    if (onTap != null) {
      onTap!();
      return;
    }

    if (banner.targetUrl?.isNotEmpty == true) {
      try {
        final uri = Uri.parse(banner.targetUrl!);
        if (uri.hasScheme && (uri.scheme == 'https' || uri.scheme == 'http')) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        // Error al abrir URL - se ignora silenciosamente
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? _getDefaultHeight();
    final effectiveMargin = margin ?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);

    return Container(
      height: effectiveHeight,
      margin: effectiveMargin,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: (banner.targetUrl?.isNotEmpty == true) ? _handleTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  double _getDefaultHeight() {
    switch (banner.position) {
      case domain.AdBannerPosition.top:
        return 70;
      case domain.AdBannerPosition.bottom:
        return 80;
      case domain.AdBannerPosition.middle:
        return 100;
      case domain.AdBannerPosition.floating:
        return 60;
    }
  }

  Widget _buildContent() {
    // Prioridad: imagen local > imagen URL > texto fallback
    if (banner.localImagePath?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          banner.localImagePath!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback();
          },
        ),
      );
    }

    if (banner.imageUrl?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          banner.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback();
          },
        ),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          banner.fallbackText,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Legacy adapter widget for backward compatibility
/// 
/// This widget provides the same interface as the old AdBanner widget
/// but uses the new Clean Architecture implementation underneath.
@Deprecated('Use AdBannerWidget instead')
class AdBanner extends StatelessWidget {
  final String? imageUrl;
  final String? targetUrl;
  final String? localImagePath;
  final double height;
  final String? fallbackText;
  final VoidCallback? onTap;

  const AdBanner({
    super.key,
    this.imageUrl,
    this.targetUrl,
    this.localImagePath,
    this.height = 100.0,
    this.fallbackText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Create a temporary banner entity for legacy compatibility
    final domainBanner = domain.AdBanner(
      id: 'legacy_${DateTime.now().millisecondsSinceEpoch}',
      imageUrl: imageUrl,
      targetUrl: targetUrl,
      localImagePath: localImagePath,
      isEnabled: true,
      fallbackText: fallbackText ?? 'Espacio publicitario',
    );

    return _AdBannerContent(
      banner: domainBanner,
      height: height,
      onTap: onTap,
    );
  }
}