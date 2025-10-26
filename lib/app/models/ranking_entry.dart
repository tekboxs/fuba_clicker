import 'package:fuba_clicker/app/models/rebirth_data.dart';

class RankingEntry {
  final String username;
  final RebirthData rebirthData;
  final List<String> achievements;

  RankingEntry({
    required this.username,
    required this.rebirthData,
    required this.achievements,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      username: json['username'] ?? '',
      rebirthData: RebirthData.fromJson(json['rebirthData'] ?? {}),
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'rebirthData': rebirthData.toJson(),
      'achievements': achievements,
    };
  }

  int get rebirthCount => rebirthData.rebirthCount;
  int get ascensionCount => rebirthData.ascensionCount;
  int get transcendenceCount => rebirthData.transcendenceCount;
  int get achievementCount => achievements.length;
  double get celestialTokens => rebirthData.celestialTokens;
}


