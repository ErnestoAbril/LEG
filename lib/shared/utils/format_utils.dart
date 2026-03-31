import '../../app_settings.dart';

/// Returns a formatted currency string including symbol, using the app currency settings.
String formatCurrency(num valor) {
  final s = currencyNotifier.value;
  final parts = valor.toStringAsFixed(2).split('.');
  String integer = parts[0];
  final decimals = parts.length > 1 ? parts[1] : '00';
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  integer = integer.replaceAllMapped(reg, (m) => s.thousandSeparator);
  return '${s.symbol}$integer${s.decimalSeparator}$decimals';
}

/// Returns a formatted number suitable for input fields (no currency symbol).
String formatNumberForInput(num valor) {
  final s = currencyNotifier.value;
  final parts = valor.toStringAsFixed(2).split('.');
  String integer = parts[0];
  final decimals = parts.length > 1 ? parts[1] : '00';
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  integer = integer.replaceAllMapped(reg, (m) => s.thousandSeparator);
  return '$integer${s.decimalSeparator}$decimals';
}

String limpiarMonto(String texto) {
  return texto
      .replaceAll(RegExp(r'[^0-9,\.]'), '')
      .replaceAll('.', '')
      .replaceAll(',', '.');
}

/// Parse a user-entered amount using the app's currency settings.
/// Returns null if parsing fails.
double? parseMonto(String texto) {
  final s = currencyNotifier.value;
  var t = texto.replaceAll(s.symbol, '').replaceAll(' ', '');
  if (s.thousandSeparator.isNotEmpty) t = t.replaceAll(s.thousandSeparator, '');
  if (s.decimalSeparator != '.') t = t.replaceAll(s.decimalSeparator, '.');
  // keep only digits and dot
  t = t.replaceAll(RegExp(r'[^0-9\.]'), '');
  if (t.isEmpty) {
    return null;
  }
  return double.tryParse(t);
}

/// Map old cursor position in raw text to a reasonable new position in formatted text.
int mapCursorPosition(String raw, String formatted, int oldCursor) {
  if (oldCursor <= 0) {
    return 0;
  }
  final before = oldCursor <= raw.length ? raw.substring(0, oldCursor) : raw;
  // count digits in before
  final digitsBefore = before.replaceAll(RegExp(r'[^0-9]'), '');
  int found = 0;
  for (int i = 0; i < formatted.length; i++) {
    if (RegExp(r'[0-9]').hasMatch(formatted[i])) found++;
    if (found >= digitsBefore.length) {
      return (i + 1).clamp(0, formatted.length);
    }
  }
  return formatted.length;
}
