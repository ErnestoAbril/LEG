/// Entity representing currency formatting preferences
class CurrencySettings {
  final String symbol;
  final String decimalSeparator;
  final String thousandSeparator;
  final int decimalPlaces;
  final bool symbolBefore;

  const CurrencySettings({
    required this.symbol,
    required this.decimalSeparator,
    required this.thousandSeparator,
    this.decimalPlaces = 2,
    this.symbolBefore = true,
  });

  /// Creates a copy with updated values
  CurrencySettings copyWith({
    String? symbol,
    String? decimalSeparator,
    String? thousandSeparator,
    int? decimalPlaces,
    bool? symbolBefore,
  }) {
    return CurrencySettings(
      symbol: symbol ?? this.symbol,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      thousandSeparator: thousandSeparator ?? this.thousandSeparator,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      symbolBefore: symbolBefore ?? this.symbolBefore,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'decimalSeparator': decimalSeparator,
      'thousandSeparator': thousandSeparator,
      'decimalPlaces': decimalPlaces,
      'symbolBefore': symbolBefore,
    };
  }

  /// Create from JSON
  factory CurrencySettings.fromJson(Map<String, dynamic> json) {
    return CurrencySettings(
      symbol: json['symbol'] as String? ?? '\$',
      decimalSeparator: json['decimalSeparator'] as String? ?? '.',
      thousandSeparator: json['thousandSeparator'] as String? ?? ',',
      decimalPlaces: json['decimalPlaces'] as int? ?? 2,
      symbolBefore: json['symbolBefore'] as bool? ?? true,
    );
  }

  /// Create from legacy format (backward compatibility)
  factory CurrencySettings.fromLegacyMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const CurrencySettings(
        symbol: '\$',
        decimalSeparator: '.',
        thousandSeparator: ',',
      );
    }
    return CurrencySettings(
      symbol: map['symbol'] as String? ?? '\$',
      decimalSeparator: map['decimal'] as String? ?? '.',
      thousandSeparator: map['thousand'] as String? ?? ',',
      decimalPlaces: 2,
      symbolBefore: true,
    );
  }

  /// Format a number according to these currency settings
  String formatAmount(double amount) {
    final parts = amount.toStringAsFixed(decimalPlaces).split('.');
    String integer = parts[0];
    final decimals = parts.length > 1 ? parts[1] : '00';
    
    // Add thousand separators
    if (thousandSeparator.isNotEmpty && integer.length > 3) {
      final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
      integer = integer.replaceAllMapped(reg, (m) => thousandSeparator);
    }
    
    final formattedNumber = '$integer$decimalSeparator$decimals';
    
    return symbolBefore 
        ? '$symbol$formattedNumber'
        : '$formattedNumber$symbol';
  }

  /// Predefined currency presets
  static const CurrencySettings usd = CurrencySettings(
    symbol: '\$',
    decimalSeparator: '.',
    thousandSeparator: ',',
    decimalPlaces: 2,
    symbolBefore: true,
  );

  static const CurrencySettings eur = CurrencySettings(
    symbol: '€',
    decimalSeparator: ',',
    thousandSeparator: '.',
    decimalPlaces: 2,
    symbolBefore: false,
  );

  static const CurrencySettings mxn = CurrencySettings(
    symbol: '\$',
    decimalSeparator: '.',
    thousandSeparator: ',',
    decimalPlaces: 2,
    symbolBefore: true,
  );

  static const CurrencySettings cop = CurrencySettings(
    symbol: '\$',
    decimalSeparator: ',',
    thousandSeparator: '.',
    decimalPlaces: 0,
    symbolBefore: true,
  );

  /// Get list of predefined currencies
  static List<CurrencySettings> get presets => [usd, eur, mxn, cop];

  /// Get display name for currency
  String get displayName {
    if (this == usd) return 'Dólar Estadounidense (USD)';
    if (this == eur) return 'Euro (EUR)';
    if (this == mxn) return 'Peso Mexicano (MXN)';
    if (this == cop) return 'Peso Colombiano (COP)';
    return 'Personalizada ($symbol)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencySettings &&
        other.symbol == symbol &&
        other.decimalSeparator == decimalSeparator &&
        other.thousandSeparator == thousandSeparator &&
        other.decimalPlaces == decimalPlaces &&
        other.symbolBefore == symbolBefore;
  }

  @override
  int get hashCode {
    return symbol.hashCode ^
        decimalSeparator.hashCode ^
        thousandSeparator.hashCode ^
        decimalPlaces.hashCode ^
        symbolBefore.hashCode;
  }

  @override
  String toString() {
    return 'CurrencySettings(symbol: $symbol, decimal: $decimalSeparator, thousand: $thousandSeparator, places: $decimalPlaces, before: $symbolBefore)';
  }
}