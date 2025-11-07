// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gasto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GastoAdapter extends TypeAdapter<Gasto> {
  @override
  final int typeId = 0;

  @override
  Gasto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gasto(
      monto: fields[0] as String,
      categoria: fields[1] as String,
      nota: fields[2] as String,
      fecha: fields[3] as DateTime,
      presupuestoId: fields[4] as int?,
      montoCents: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Gasto obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.monto)
      ..writeByte(1)
      ..write(obj.categoria)
      ..writeByte(2)
      ..write(obj.nota)
      ..writeByte(3)
      ..write(obj.fecha)
      ..writeByte(4)
      ..write(obj.presupuestoId)
      ..writeByte(5)
      ..write(obj.montoCents);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GastoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
