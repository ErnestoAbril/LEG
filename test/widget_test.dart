// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luz_en_el_gasto/main.dart';

void main() {
  testWidgets('La app carga correctamente el widget principal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LuzEnElGastoApp());
    expect(find.byType(LuzEnElGastoApp), findsOneWidget);
    expect(find.text('Luz en el Gasto'), findsOneWidget);
  });
}
