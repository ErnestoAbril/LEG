/// Domain entity representing an advertisement banner
/// 
/// This entity contains all the business logic related to ad banners,
/// including validation and display rules.
class AdBanner {
  final String id;
  final String? imageUrl;
  final String? targetUrl;
  final String? localImagePath;
  final bool isEnabled;
  final String fallbackText;
  final AdBannerPosition position;
  final DateTime? expiryDate;
  final int? priority;

  const AdBanner({
    required this.id,
    this.imageUrl,
    this.targetUrl,
    this.localImagePath,
    this.isEnabled = true,
    this.fallbackText = 'Espacio publicitario',
    this.position = AdBannerPosition.bottom,
    this.expiryDate,
    this.priority,
  });

  /// Check if banner is valid and should be displayed
  bool get isDisplayable {
    if (!isEnabled) return false;
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) return false;
    return hasValidContent;
  }

  /// Check if banner has any displayable content
  bool get hasValidContent {
    return imageUrl?.isNotEmpty == true || 
           localImagePath?.isNotEmpty == true || 
           fallbackText.isNotEmpty;
  }

  /// Get the display text for the banner
  String get displayText {
    return fallbackText.isNotEmpty ? fallbackText : 'Espacio publicitario';
  }

  /// Check if banner has a clickable action
  bool get isClickable {
    return targetUrl?.isNotEmpty == true;
  }

  /// Create a copy with modified properties
  AdBanner copyWith({
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
    return AdBanner(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdBanner &&
        other.id == id &&
        other.imageUrl == imageUrl &&
        other.targetUrl == targetUrl &&
        other.localImagePath == localImagePath &&
        other.isEnabled == isEnabled &&
        other.fallbackText == fallbackText &&
        other.position == position &&
        other.expiryDate == expiryDate &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      imageUrl,
      targetUrl,
      localImagePath,
      isEnabled,
      fallbackText,
      position,
      expiryDate,
      priority,
    );
  }

  @override
  String toString() {
    return 'AdBanner(id: $id, isEnabled: $isEnabled, position: $position)';
  }
}

/// Enum defining where the banner should be positioned
enum AdBannerPosition {
  top,
  bottom,
  middle,
  floating,
}