import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luz_en_el_gasto/presupuesto_categoria_repository.dart';
import 'package:luz_en_el_gasto/features/budgets/domain/entities/budget_period.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PresupuestoCategoriaRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('guardar y obtener presupuesto por categoria', () async {
      final periodo = PeriodoPresupuesto.mensual;
      await PresupuestoCategoriaRepository.guardarPresupuesto(
        periodo,
        'Comida',
        123.45,
      );
      final value = await PresupuestoCategoriaRepository.obtenerPresupuesto(
        periodo,
        'Comida',
      );
      expect(value, equals(123.45));
    });

    test('obtenerTodosPorPeriodo contiene categorias iniciales', () async {
      final periodo = PeriodoPresupuesto.mensual;
      final map = await PresupuestoCategoriaRepository.obtenerTodosPorPeriodo(
        periodo,
      );
      expect(map, isA<Map<String, double>>());
      expect(map.containsKey('Supermercado'), true);
    });
  });
}
