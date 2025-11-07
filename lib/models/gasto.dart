import 'package:hive/hive.dart';

part 'gasto.g.dart';

@HiveType(typeId: 0)
class Gasto extends HiveObject {
  @HiveField(0)
  String monto;
  @HiveField(1)
  String categoria;
  @HiveField(2)
  String nota;
  @HiveField(3)
  DateTime fecha;
  @HiveField(4)
  int? presupuestoId; // Nuevo: id del presupuesto unificado
  @HiveField(5)
  int? montoCents; // nuevo campo canonico (entero en centavos)

  Gasto({
    required this.monto,
    required this.categoria,
    required this.nota,
    required this.fecha,
    this.presupuestoId,
    this.montoCents,
  });
}