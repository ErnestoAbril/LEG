import '../../domain/entities/ad_banner.dart';

/// Data model for AdBanner entity
/// 
/// This model handles serialization/deserialization and conversion
/// between data layer and domain layer.
class AdBannerModel extends AdBanner {
  const AdBannerModel({
    required super.id,
    super.imageUrl,
    super.targetUrl,
    super.localImagePath,
    super.isEnabled,
    super.fallbackText,
    super.position,
    super.expiryDate,
    super.priority,
  });

  /// Create model from JSON map
  factory AdBannerModel.fromJson(Map<String, dynamic> json) {
    // Handle string to bool conversion for legacy compatibility
    bool isEnabledValue = false;
    if (json['isEnabled'] != null) {
      if (json['isEnabled'] is bool) {
        isEnabledValue = json['isEnabled'];
      } else if (json['isEnabled'] is String) {
        isEnabledValue = json['isEnabled'].toLowerCase() == 'true';
      }
    }

    // Parse position
    AdBannerPosition position = AdBannerPosition.bottom;
    if (json['position'] is String) {
      position = AdBannerPosition.values.firstWhere(
        (p) => p.name == json['position'],
        orElse: () => AdBannerPosition.bottom,
      );
    }

    // Parse expiry date
    DateTime? expiryDate;
    if (json['expiryDate'] is String) {
      try {
        expiryDate = DateTime.parse(json['expiryDate']);
      } catch (e) {
        // Invalid date format, ignore
      }
    }

    return AdBannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'],
      targetUrl: json['targetUrl'],
      localImagePath: json['localImagePath'],
      isEnabled: isEnabledValue,
      fallbackText: json['fallbackText'] ?? 'Espacio publicitario',
      position: position,
      expiryDate: expiryDate,
      priority: json['priority'],
    );
  }

  /// Create model from query string (for legacy compatibility)
  factory AdBannerModel.fromQueryString(String queryString, String id) {
    final Map<String, String> params = Uri.splitQueryString(queryString);
    return AdBannerModel.fromJson({
      'id': id,
      ...params,
    });
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'targetUrl': targetUrl,
      'localImagePath': localImagePath,
      'isEnabled': isEnabled,
      'fallbackText': fallbackText,
      'position': position.name,
      'expiryDate': expiryDate?.toIso8601String(),
      'priority': priority,
    };
  }

  /// Convert to query string (for legacy compatibility)
  String toQueryString() {
    final json = toJson();
    return json.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }

  /// Convert to domain entity
  AdBanner toDomain() {
    return AdBanner(
      id: id,
      imageUrl: imageUrl,
      targetUrl: targetUrl,
      localImagePath: localImagePath,
      isEnabled: isEnabled,
      fallbackText: fallbackText,
      position: position,
      expiryDate: expiryDate,
      priority: priority,
    );
  }

  /// Create model from domain entity
  factory AdBannerModel.fromDomain(AdBanner banner) {
    return AdBannerModel(
      id: banner.id,
      imageUrl: banner.imageUrl,
      targetUrl: banner.targetUrl,
      localImagePath: banner.localImagePath,
      isEnabled: banner.isEnabled,
      fallbackText: banner.fallbackText,
      position: banner.position,
      expiryDate: banner.expiryDate,
      priority: banner.priority,
    );
  }

  /// Create copy with updated values
  @override
  AdBannerModel copyWith({
    String? id,
    String? imageUrl,
    String? targetUrl,
    String? localImagePath,
    bool? isEnabled,
    String? fallbackText,
    AdBannerPosition? position,
    DateTime? expiryDate,
    int? priority,
  }) {
    return AdBannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      targetUrl: targetUrl ?? this.targetUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      isEnabled: isEnabled ?? this.isEnabled,
      fallbackText: fallbackText ?? this.fallbackText,
      position: position ?? this.position,
      expiryDate: expiryDate ?? this.expiryDate,
      priority: priority ?? this.priority,
    );
  }
}