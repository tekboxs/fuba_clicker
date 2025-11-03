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
    try {
      final numOfFields = reader.readByte();
      int rebirthCount = 0;
      int ascensionCount = 0;
      int transcendenceCount = 0;
      int furuborusCount = 0;
      double celestialTokens = 0.0;
      bool hasUsedOneTimeMultiplier = false;
      List<String> usedCoupons = const [];
      double forus = 0.0;

      for (int i = 0; i < numOfFields; i++) {
        final key = reader.readByte();
        try {
          final value = reader.read();
          switch (key) {
            case 0:
              rebirthCount = safeToInt(value, context: 'RebirthData.rebirthCount');
              break;
            case 1:
              ascensionCount = safeToInt(value, context: 'RebirthData.ascensionCount');
              break;
            case 2:
              transcendenceCount = safeToInt(value, context: 'RebirthData.transcendenceCount');
              break;
            case 3:
              furuborusCount = safeToInt(value, context: 'RebirthData.furuborusCount');
              break;
            case 4:
              celestialTokens = safeToDouble(value, context: 'RebirthData.celestialTokens');
              break;
            case 5:
              hasUsedOneTimeMultiplier = (value as bool?) ?? false;
              break;
            case 6:
              usedCoupons = safeCastToListString(value, context: 'RebirthData.usedCoupons');
              break;
            case 7:
              forus = safeToDouble(value, context: 'RebirthData.forus');
              break;
          }
        } catch (e) {
          print('[HiveAdapter] Erro ao ler campo $key de RebirthData: $e');
        }
      }

      return RebirthData(
        rebirthCount: rebirthCount,
        ascensionCount: ascensionCount,
        transcendenceCount: transcendenceCount,
        furuborusCount: furuborusCount,
        celestialTokens: celestialTokens,
        hasUsedOneTimeMultiplier: hasUsedOneTimeMultiplier,
        usedCoupons: usedCoupons,
        forus: forus,
      );
    } catch (e, st) {
      print('[HiveAdapter] Erro ao ler RebirthData: $e');
      print(st);
      return const RebirthData();
    }
  }

  @override
  void write(BinaryWriter writer, RebirthData obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.forus);
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
