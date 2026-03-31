// Temporary compatibility layer for GastoRepository
// This file provides backward compatibility while we migrate to Clean Architecture
// TODO: Remove this file once all legacy code is migrated

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/gasto.dart';
import 'shared/utils/format_utils.dart';

/// Legacy compatibility class for GastoRepository
/// This maintains the old API while delegating to new architecture
class GastoRepository {
  static const List<String> categoriasIniciales = [
    'Supermercado',
    'Transporte',
    'Comida',
    'Salud',
    'Educación',
    'Entretenimiento',
    'Servicios',
    'Ropa',
    'Mascotas',
    'Hogar',
    'Regalos',
    'Otros',
  ];

  static late Box<Gasto> _box;

  static ValueListenable<Box<Gasto>> boxListenable() {
    return _box.listenable();
  }

  static List<String> obtenerCategoriasFrecuentes({int top = 8}) {
    final gastos = _box.values.toList();
    final Map<String, int> conteo = {};
    for (var g in gastos) {
      final cat = g.categoria.trim();
      if (cat.isNotEmpty) conteo[cat] = (conteo[cat] ?? 0) + 1;
    }
    final ordenadas = conteo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final frecuentes = ordenadas.take(top).map((e) => e.key).toList();
    // Combina iniciales y frecuentes, sin duplicados
    final todas = [...categoriasIniciales, ...frecuentes];
    return {for (var c in todas) c.trim(): null}.keys.toList();
  }

  static Future<void> init() async {
    _box = await Hive.openBox<Gasto>('gastos');
    // Migración ligera: rellenar montoCents para gastos antiguos si falta
    final saves = <Future>[];
    for (final g in _box.values) {
      if (g.montoCents == null) {
        final parsed = parseMonto(g.monto) ?? 0;
        g.montoCents = (parsed * 100).round();
        saves.add(g.save());
      }
    }
    if (saves.isNotEmpty) await Future.wait(saves);
  }

  static Future<void> agregarGasto(Gasto gasto) async {
    await _box.add(gasto);
  }

  static List<Gasto> obtenerGastos() {
    return _box.values.toList()..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  static Future<void> eliminarGasto(int index) async {
    await _box.deleteAt(index);
  }

  static Future<void> editarGasto(int index, Gasto gasto) async {
    await _box.putAt(index, gasto);
  }

  static List<Gasto> obtenerGastosPorPresupuesto(int? presupuestoId) {
    if (presupuestoId == null) return [];
    return _box.values
        .where((g) => g.presupuestoId == presupuestoId)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  static Future<void> limpiarGastos() async {
    await _box.clear();
  }

  static double calcularTotalGastos() {
    return _box.values.fold(0.0, (sum, gasto) {
      final monto = parseMonto(gasto.monto) ?? 0.0;
      return sum + monto;
    });
  }

  static Map<String, double> obtenerGastosPorCategoria() {
    final Map<String, double> gastosPorCategoria = {};
    
    for (var gasto in _box.values) {
      final categoria = gasto.categoria.trim();
      final monto = parseMonto(gasto.monto) ?? 0.0;
      
      if (categoria.isNotEmpty) {
        gastosPorCategoria[categoria] = 
            (gastosPorCategoria[categoria] ?? 0.0) + monto;
      }
    }
    
    return gastosPorCategoria;
  }

  static List<Gasto> obtenerGastosPorFecha(DateTime inicio, DateTime fin) {
    return _box.values.where((gasto) {
      return gasto.fecha.isAfter(inicio.subtract(const Duration(days: 1))) &&
             gasto.fecha.isBefore(fin.add(const Duration(days: 1)));
    }).toList()..sort((a, b) => b.fecha.compareTo(a.fecha));
  }
}