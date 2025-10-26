// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_save_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameSaveDataAdapter extends TypeAdapter<GameSaveData> {
  @override
  final int typeId = 0;

  @override
  GameSaveData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameSaveData(
      fuba: fields[0] as BigDecimal,
      generators: (fields[1] as List).cast<int>(),
      inventory: (fields[2] as Map).cast<String, int>(),
      equipped: (fields[3] as List).cast<String>(),
      rebirthData: fields[4] as RebirthData,
      achievements: (fields[5] as List).cast<String>(),
      achievementStats: (fields[6] as Map).cast<String, double>(),
      upgrades: (fields[7] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, GameSaveData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.fuba)
      ..writeByte(1)
      ..write(obj.generators)
      ..writeByte(2)
      ..write(obj.inventory)
      ..writeByte(3)
      ..write(obj.equipped)
      ..writeByte(4)
      ..write(obj.rebirthData)
      ..writeByte(5)
      ..write(obj.achievements)
      ..writeByte(6)
      ..write(obj.achievementStats)
      ..writeByte(7)
      ..write(obj.upgrades);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSaveDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
