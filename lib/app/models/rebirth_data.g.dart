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
      furuborusCount: fields[3] as int,
      celestialTokens: fields[4] as double,
      hasUsedOneTimeMultiplier: fields[5] as bool,
      usedCoupons: (fields[6] as List).cast<String>(),
      forus: fields[7] as double,
      cauldronUnlocked: fields[8] as bool,
      craftUnlocked: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RebirthData obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.rebirthCount)
      ..writeByte(1)
      ..write(obj.ascensionCount)
      ..writeByte(2)
      ..write(obj.transcendenceCount)
      ..writeByte(3)
      ..write(obj.furuborusCount)
      ..writeByte(4)
      ..write(obj.celestialTokens)
      ..writeByte(5)
      ..write(obj.hasUsedOneTimeMultiplier)
      ..writeByte(6)
      ..write(obj.usedCoupons)
      ..writeByte(7)
      ..write(obj.forus)
      ..writeByte(8)
      ..write(obj.cauldronUnlocked)
      ..writeByte(9)
      ..write(obj.craftUnlocked);
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
