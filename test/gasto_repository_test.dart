import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:luz_en_el_gasto/legacy_gasto_repository.dart';
import 'package:luz_en_el_gasto/models/gasto.dart';

void main() {
  group('GastoRepository', () {
    late Directory tmpDir;
    setUpAll(() async {
      tmpDir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(tmpDir.path);
      Hive.registerAdapter(GastoAdapter());
      await GastoRepository.init();
    });

    tearDownAll(() async {
      await Hive.close();
      try {
        tmpDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('agregar y obtener gasto', () async {
      final before = GastoRepository.obtenerGastos();
      final gasto = Gasto(
        monto: '1.00',
        categoria: 'Test',
        nota: 'nota',
        fecha: DateTime.now(),
        montoCents: 100,
      );
      await GastoRepository.agregarGasto(gasto);
      final all = GastoRepository.obtenerGastos();
      expect(all.length, greaterThanOrEqualTo(before.length + 1));
      final found = all.firstWhere((g) => g.nota == 'nota');
      expect(found.categoria, equals('Test'));
    });
  });
}
