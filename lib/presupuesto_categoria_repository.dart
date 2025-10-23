import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class PresupuestoCategoriaRepository {
  static String _key(PeriodoPresupuesto periodo, String categoria) =>
      'presupuesto_${periodo.name}_${categoria.trim().toLowerCase()}';

  static Future<double> obtenerPresupuesto(
    PeriodoPresupuesto periodo,
    String categoria,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key(periodo, categoria)) ?? 0;
  }

  static Future<void> guardarPresupuesto(
    PeriodoPresupuesto periodo,
    String categoria,
    double monto,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key(periodo, categoria), monto);
  }

  static Future<Map<String, double>> obtenerTodosPorPeriodo(
    PeriodoPresupuesto periodo,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, double>{};
    for (var cat in GastoRepository.categoriasIniciales) {
      map[cat] = prefs.getDouble(_key(periodo, cat)) ?? 0;
    }
    return map;
  }
}
