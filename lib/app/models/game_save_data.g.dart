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
    EfficientNumber? fuba;
    List<int>? generators;
    Map<String, int>? inventory;
    List<String>? equipped;
    RebirthData? rebirthData;
    List<String>? achievements;
    Map<String, double>? achievementStats;
    Map<String, int>? upgrades;

    try {
      final numOfFields = reader.readByte();
      for (int i = 0; i < numOfFields; i++) {
        try {
          final key = reader.readByte();
          dynamic value;
          try {
            value = reader.read();
          } on HiveError catch (hiveError) {
            print('[HiveAdapter] HiveError ao ler campo $key: $hiveError');
            if (hiveError.message.contains('unknown typeId')) {
              final match = RegExp(r'typeId: (\d+)').firstMatch(hiveError.message);
              final typeId = match?.group(1) ?? 'unknown';
              print('[HiveAdapter] TypeId desconhecido: $typeId no campo $key. Usando valor padrão.');
            }
            continue;
          } catch (readError) {
            print('[HiveAdapter] Erro ao fazer reader.read() para campo $key: $readError');
            continue;
          }

          try {
            switch (key) {
              case 0:
                fuba = value as EfficientNumber?;
                break;
              case 1:
                generators = safeCastToListInt(value, context: 'GameSaveData.generators');
                break;
              case 2:
                inventory = safeCastToMapStringInt(value, context: 'GameSaveData.inventory');
                break;
              case 3:
                equipped = safeCastToListString(value, context: 'GameSaveData.equipped');
                break;
              case 4:
                rebirthData = value as RebirthData?;
                break;
              case 5:
                achievements = safeCastToListString(value, context: 'GameSaveData.achievements');
                break;
              case 6:
                achievementStats = safeCastToMapStringDouble(value, context: 'GameSaveData.achievementStats');
                break;
              case 7:
                upgrades = safeCastToMapStringInt(value, context: 'GameSaveData.upgrades');
                break;
            }
          } catch (processError) {
            print('[HiveAdapter] Erro ao processar campo $key do GameSaveData: $processError');
          }
        } catch (e) {
          print('[HiveAdapter] Erro geral ao iterar campo do GameSaveData: $e');
        }
      }
    } catch (e, st) {
      print('[HiveAdapter] Erro crítico ao ler GameSaveData: $e');
      print(st);
    }

    return GameSaveData(
      fuba: fuba ?? const EfficientNumber.zero(),
      generators: generators ?? const <int>[],
      inventory: inventory ?? const <String, int>{},
      equipped: equipped ?? const <String>[],
      rebirthData: rebirthData ?? const RebirthData(),
      achievements: achievements ?? const <String>[],
      achievementStats: achievementStats ?? const <String, double>{},
      upgrades: upgrades ?? const <String, int>{},
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
