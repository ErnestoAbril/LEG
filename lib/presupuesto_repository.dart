import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class PresupuestoRepository {
  static const List<PeriodoPresupuesto> periodos = [
    PeriodoPresupuesto.diario,
    PeriodoPresupuesto.semanal,
    PeriodoPresupuesto.quincenal,
    PeriodoPresupuesto.mensual,
    PeriodoPresupuesto.anual,
  ];

  static String _keyMonto(PeriodoPresupuesto p) =>
      'presupuesto_monto_${p.name}';

  static Future<double> obtenerPresupuesto(PeriodoPresupuesto p) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyMonto(p)) ?? 0;
  }

  static Future<void> guardarPresupuesto(
    double valor,
    PeriodoPresupuesto periodo,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMonto(periodo), valor);
  }

  static Future<Map<PeriodoPresupuesto, double>> obtenerTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <PeriodoPresupuesto, double>{};
    for (var p in periodos) {
      map[p] = prefs.getDouble(_keyMonto(p)) ?? 0;
    }
    return map;
  }
}
