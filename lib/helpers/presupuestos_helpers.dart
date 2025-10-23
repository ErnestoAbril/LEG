import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/presupuesto_unificado.dart';

class PresupuestosHelpers {
  static const _prefsKey = 'presupuestos_unificados';
  static double _norm2(double v) => ((v * 100).round()) / 100.0;
  static Future<List<PresupuestoUnificado>> loadPresupuestos() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_prefsKey);
    if (s == null) return [];
    try {
      final list = List<dynamic>.from(jsonDecode(s) as List<dynamic>);
      final result = <PresupuestoUnificado>[];
      for (var item in list) {
        final p = PresupuestoUnificado.fromMap(Map<String, dynamic>.from(item));
        final normCats = <String, double>{
          for (final e in p.categorias.entries) e.key: _norm2(e.value),
        };
        result.add(
          PresupuestoUnificado(
            id: p.id,
            nombre: p.nombre,
            tipo: p.tipo,
            categorias: normCats,
          ),
        );
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePresupuestos(
    List<PresupuestoUnificado> presupuestos,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = presupuestos.map((p) {
      final normCats = <String, double>{
        for (final e in p.categorias.entries) e.key: _norm2(e.value),
      };
      final normP = PresupuestoUnificado(
        id: p.id,
        nombre: p.nombre,
        tipo: p.tipo,
        categorias: normCats,
      );
      return normP.toJson();
    }).toList();
    await prefs.setString(_prefsKey, jsonEncode(normalized));
  }
}
