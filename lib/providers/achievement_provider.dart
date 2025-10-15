import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import 'rebirth_provider.dart';
import 'secret_provider.dart';

final unlockedAchievementsProvider = StateProvider<Set<String>>((ref) {
  return {};
});

final achievementStatsProvider = StateProvider<Map<String, double>>((ref) {
  return {
    'total_clicks': 0,
    'total_production': 0,
    'different_generators': 0,
    'lootboxes_opened': 0,
    'legendary_count': 0,
    'mythical_count': 0,
    'equipped_count': 0,
  };
});

class AchievementNotifier {
  AchievementNotifier(this.ref);
  final Ref ref;

  void checkAchievements() {
    final stats = ref.read(achievementStatsProvider);
    final unlocked = ref.read(unlockedAchievementsProvider);
    final rebirthData = ref.read(rebirthDataProvider);

    for (final achievement in allAchievements) {
      if (unlocked.contains(achievement.id)) continue;

      bool shouldUnlock = false;

      switch (achievement.category) {
        case AchievementCategory.clicks:
          shouldUnlock = (stats['total_clicks'] ?? 0) >= achievement.targetValue;
          break;
        case AchievementCategory.production:
          shouldUnlock =
              (stats['total_production'] ?? 0) >= achievement.targetValue;
          break;
        case AchievementCategory.generators:
          shouldUnlock =
              (stats['different_generators'] ?? 0) >= achievement.targetValue;
          break;
        case AchievementCategory.accessories:
          if (achievement.id == 'first_accessory') {
            shouldUnlock =
                (stats['legendary_count'] ?? 0) + (stats['mythical_count'] ?? 0) >
                    0;
          } else if (achievement.id == 'accessory_legendary') {
            shouldUnlock = (stats['legendary_count'] ?? 0) >= 1;
          } else if (achievement.id == 'accessory_mythical') {
            shouldUnlock = (stats['mythical_count'] ?? 0) >= 1;
          } else if (achievement.id == 'equip_8') {
            shouldUnlock = (stats['equipped_count'] ?? 0) >= 8;
          }
          break;
        case AchievementCategory.lootBoxes:
          shouldUnlock =
              (stats['lootboxes_opened'] ?? 0) >= achievement.targetValue;
          break;
        case AchievementCategory.rebirth:
          if (achievement.id == 'first_rebirth') {
            shouldUnlock = rebirthData.rebirthCount >= 1;
          } else if (achievement.id == 'rebirth_10') {
            shouldUnlock = rebirthData.rebirthCount >= 10;
          } else if (achievement.id == 'first_ascension') {
            shouldUnlock = rebirthData.ascensionCount >= 1;
          } else if (achievement.id == 'first_transcendence') {
            shouldUnlock = rebirthData.transcendenceCount >= 1;
          }
          break;
        case AchievementCategory.secret:
          break;
      }

      if (shouldUnlock) {
        unlockAchievement(achievement.id);
      }
    }
  }

  void unlockAchievement(String achievementId) {
    final unlocked = ref.read(unlockedAchievementsProvider);
    if (unlocked.contains(achievementId)) return;

    ref.read(unlockedAchievementsProvider.notifier).state = {
      ...unlocked,
      achievementId,
    };

    final achievement =
        allAchievements.firstWhere((a) => a.id == achievementId);

    if (achievement.reward.type == AchievementRewardType.tokens) {
      final rebirthData = ref.read(rebirthDataProvider);
      ref.read(rebirthDataProvider.notifier).state = rebirthData.copyWith(
        celestialTokens: rebirthData.celestialTokens + achievement.reward.value.toInt(),
      );
    } else if (achievement.reward.type == AchievementRewardType.unlockSecret) {
      if (achievement.reward.secretId != null) {
        ref.read(secretNotifierProvider).unlockSecret(achievement.reward.secretId!);
      }
    }
  }

  void incrementStat(String statKey, [double amount = 1]) {
    final stats = ref.read(achievementStatsProvider);
    final newStats = Map<String, double>.from(stats);
    newStats[statKey] = (newStats[statKey] ?? 0) + amount;
    ref.read(achievementStatsProvider.notifier).state = newStats;
    checkAchievements();
  }

  void updateStat(String statKey, double value) {
    final stats = ref.read(achievementStatsProvider);
    final newStats = Map<String, double>.from(stats);
    newStats[statKey] = value;
    ref.read(achievementStatsProvider.notifier).state = newStats;
    checkAchievements();
  }

  double getTotalMultiplierFromAchievements() {
    final unlocked = ref.read(unlockedAchievementsProvider);
    double multiplier = 1.0;

    for (final achievementId in unlocked) {
      final achievement =
          allAchievements.firstWhere((a) => a.id == achievementId);
      if (achievement.reward.type == AchievementRewardType.multiplier) {
        multiplier *= achievement.reward.value;
      }
    }

    return multiplier;
  }
}

final achievementNotifierProvider = Provider<AchievementNotifier>((ref) {
  return AchievementNotifier(ref);
});

final achievementMultiplierProvider = Provider<double>((ref) {
  return ref
      .watch(achievementNotifierProvider)
      .getTotalMultiplierFromAchievements();
});

