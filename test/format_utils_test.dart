import 'package:flutter_test/flutter_test.dart';
import 'package:luz_en_el_gasto/shared/utils/format_utils.dart';
import 'package:luz_en_el_gasto/app_settings.dart';

void main() {
  // Ensure currencyNotifier has a known value for tests
  setUp(() {
    // Default currency settings used in app_settings for tests may vary; set an explicit one.
    currencyNotifier.value = CurrencySettings(
      symbol: '\$',
      thousandSeparator: ',',
      decimalSeparator: '.',
    );
  });

  test(
    'limpiarMonto removes non-numeric except dot/comma and normalizes to dot',
    () {
      final input = "USD 1.234,56";
      final out = limpiarMonto(input);
      expect(out, equals('1234.56'));
    },
  );

  test('parseMonto parses based on currency settings', () {
    // With settings above (thousand=',' decimal='.')
    expect(parseMonto('1,234.56'), equals(1234.56));
    // If currency symbol present
    expect(parseMonto('\$1,234.56'), equals(1234.56));
    // different separators: simulate european style by changing notifier
    currencyNotifier.value = CurrencySettings(
      symbol: '€',
      thousandSeparator: '.',
      decimalSeparator: ',',
    );
    expect(parseMonto('1.234,56'), equals(1234.56));
  });

  test('formatNumberForInput formats numbers using settings', () {
    currencyNotifier.value = CurrencySettings(
      symbol: '\$',
      thousandSeparator: ',',
      decimalSeparator: '.',
    );
    expect(formatNumberForInput(1234.56), equals('1,234.56'));
    currencyNotifier.value = CurrencySettings(
      symbol: '€',
      thousandSeparator: '.',
      decimalSeparator: ',',
    );
    expect(formatNumberForInput(1234.56), equals('1.234,56'));
  });
}
