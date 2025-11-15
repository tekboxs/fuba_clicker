import '../core/utils/efficient_number.dart';
import '../core/utils/safe_convert.dart';
import 'package:hive/hive.dart';
import 'rebirth_data.dart';

part 'game_save_data.g.dart';

@HiveType(typeId: 0)
class GameSaveData {
  @HiveField(0)
  final EfficientNumber fuba;

  @HiveField(1)
  final List<int> generators;

  @HiveField(2)
  final Map<String, int> inventory;

  @HiveField(3)
  final List<String> equipped;

  @HiveField(4)
  final RebirthData rebirthData;

  @HiveField(5)
  final List<String> achievements;

  @HiveField(6)
  final Map<String, double> achievementStats;

  @HiveField(7)
  final Map<String, int> upgrades;

  @HiveField(8)
  final Map<String, int> cauldron;

  @HiveField(9)
  final List<Map<String, dynamic>> activePotionEffects;

  @HiveField(10)
  final double permanentPotionMultiplier;

  @HiveField(11)
  final Map<String, int> activePotionCount;

  GameSaveData({
    required this.fuba,
    required this.generators,
    required this.inventory,
    required this.equipped,
    required this.rebirthData,
    required this.achievements,
    required this.achievementStats,
    required this.upgrades,
    required this.cauldron,
    required this.activePotionEffects,
    required this.permanentPotionMultiplier,
    required this.activePotionCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'fuba': fuba.toString(),
      'generators': generators,
      'inventory': inventory,
      'equipped': equipped,
      'rebirthData': rebirthData.toJson(),
      'achievements': achievements,
      'achievementStats': achievementStats,
      'upgrades': upgrades,
      'cauldron': cauldron,
      'activePotionEffects': activePotionEffects,
      'permanentPotionMultiplier': permanentPotionMultiplier,
      'activePotionCount': activePotionCount,
    };
  }

  factory GameSaveData.fromJson(Map<String, dynamic> json) {
    return GameSaveData(
      fuba: EfficientNumber.parse(json['fuba']),
      generators: List<int>.from(json['generators'] ?? []),
      inventory: Map<String, int>.from(json['inventory'] ?? {}),
      equipped: List<String>.from(json['equipped'] ?? []),
      rebirthData: RebirthData.fromJson(json['rebirthData'] ?? {}),
      achievements: List<String>.from(json['achievements'] ?? []),
      achievementStats:
          Map<String, double>.from(json['achievementStats'] ?? {}),
      upgrades: Map<String, int>.from(json['upgrades'] ?? {}),
      cauldron: Map<String, int>.from(json['cauldron'] ?? {}),
      activePotionEffects: (json['activePotionEffects'] != null)
          ? List<Map<String, dynamic>>.from(json['activePotionEffects'])
          : [],
      permanentPotionMultiplier: (json['permanentPotionMultiplier'] ?? 1.0).toDouble(),
      activePotionCount: Map<String, int>.from(json['activePotionCount'] ?? {}),
    );
  }
}
