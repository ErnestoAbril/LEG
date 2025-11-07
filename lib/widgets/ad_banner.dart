import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _handleTap() async {
    if (onTap != null) {
      onTap!();
      return;
    }

    if (targetUrl != null && targetUrl!.isNotEmpty) {
      try {
        final uri = Uri.parse(targetUrl!);
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
    // Si no hay imagen ni texto, no mostrar nada
    if ((imageUrl == null || imageUrl!.isEmpty) && 
        (localImagePath == null || localImagePath!.isEmpty) &&
        (fallbackText == null || fallbackText!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
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

  Widget _buildContent() {
    // Prioridad: imagen local > imagen URL > texto fallback
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          localImagePath!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback();
          },
        ),
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl!,
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
          fallbackText ?? 'Espacio publicitario',
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