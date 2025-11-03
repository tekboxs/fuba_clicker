import '../core/utils/efficient_number.dart';
import 'package:fuba_clicker/app/models/rebirth_data.dart';

class RankingEntry {
  final String username;
  final RebirthData rebirthData;
  final List<String> achievements;
  final EfficientNumber fuba;
  RankingEntry({
    required this.username,
    required this.rebirthData,
    required this.achievements,
    required this.fuba,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      username: json['username'] ?? '',
      rebirthData: RebirthData.fromJson(json['rebirthData'] ?? {}),
      achievements: List<String>.from(json['achievements'] ?? []),
      fuba: EfficientNumber.parse(json['fuba'] ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'rebirthData': rebirthData.toJson(),
      'achievements': achievements,
      'fuba': fuba.toString(),
    };
  }

  int get rebirthCount => rebirthData.rebirthCount;
  int get ascensionCount => rebirthData.ascensionCount;
  int get transcendenceCount => rebirthData.transcendenceCount;
  int get furuborusCount => rebirthData.furuborusCount;
  int get achievementCount => achievements.length;
  double get celestialTokens => rebirthData.celestialTokens;
}
