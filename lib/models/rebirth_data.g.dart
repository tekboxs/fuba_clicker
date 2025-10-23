// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rebirth_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RebirthDataAdapter extends TypeAdapter<RebirthData> {
  @override
  final int typeId = 1;

  @override
  RebirthData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RebirthData(
      rebirthCount: fields[0] as int,
      ascensionCount: fields[1] as int,
      transcendenceCount: fields[2] as int,
      celestialTokens: fields[3] as double,
      hasUsedOneTimeMultiplier: fields[4] as bool,
      usedCoupons: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, RebirthData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.rebirthCount)
      ..writeByte(1)
      ..write(obj.ascensionCount)
      ..writeByte(2)
      ..write(obj.transcendenceCount)
      ..writeByte(3)
      ..write(obj.celestialTokens)
      ..writeByte(4)
      ..write(obj.hasUsedOneTimeMultiplier)
      ..writeByte(5)
      ..write(obj.usedCoupons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RebirthDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
