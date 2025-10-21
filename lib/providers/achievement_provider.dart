import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../models/achievement.dart';
import '../widgets/achievement_popup.dart';
import 'rebirth_provider.dart';
import 'secret_provider.dart';
import 'game_providers.dart';
import 'accessory_provider.dart';
import '../models/cake_accessory.dart';

final unlockedAchievementsProvider = StateProvider<Set<String>>((ref) {
  return {};
});

final appContextProvider = StateProvider<BuildContext?>((ref) {
  return null;
});

final achievementStatsProvider = StateProvider<Map<String, double>>((ref) {
  return {
    'total_clicks': 0,
    'total_production': 0,
    'different_generators': 0,
    'lootboxes_opened': 0,
    'legendary_count': 0,
    'mythical_count': 0,
    'primordial_count': 0,
    'cosmic_count': 0,
    'infinite_count': 0,
    'equipped_count': 0,
    'clicks_per_second': 0,
    'max_clicks_per_second': 0,
    'click_streak': 0,
    'max_click_streak': 0,
    'fuba_per_click': 0,
    'max_fuba_per_click': 0,
    'clicks_in_10_seconds': 0,
    'time_since_last_click': 0,
    'total_click_fuba': 0,
    'all_mythical_equipped': 0,
    'total_inventory_accessories': 0,
    'legendary_lootbox_streak': 0,
    'time_without_clicking': 0,
    'max_time_without_clicking': 0,
    'consecutive_play_time': 0,
    'max_consecutive_play_time': 0,
  };
});

class AchievementNotifier {
  AchievementNotifier(this.ref);
  final Ref ref;

  void checkAchievements([BuildContext? context]) {
    final stats = ref.read(achievementStatsProvider);
    final unlocked = ref.read(unlockedAchievementsProvider);
    final rebirthData = ref.read(rebirthDataProvider);

    for (final achievement in allAchievements) {
      if (unlocked.contains(achievement.id)) continue;

      bool shouldUnlock = false;

      switch (achievement.category) {
        case AchievementCategory.clicks:
          if (achievement.id.startsWith('click_') && 
              !achievement.id.startsWith('click_speed_') && 
              !achievement.id.startsWith('click_streak_') && 
              !achievement.id.startsWith('fuba_per_click_') &&
              !achievement.id.endsWith('_daily')) {
            shouldUnlock = (stats['total_clicks'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id.startsWith('click_speed_')) {
            shouldUnlock = (stats['max_clicks_per_second'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id.startsWith('click_streak_')) {
            shouldUnlock = (stats['max_click_streak'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id.startsWith('fuba_per_click_')) {
            shouldUnlock = (stats['max_fuba_per_click'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id.endsWith('_daily')) {
            shouldUnlock = (stats['total_clicks'] ?? 0) >= achievement.targetValue;
          }
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
                (stats['legendary_count'] ?? 0) + (stats['mythical_count'] ?? 0) +
                (stats['primordial_count'] ?? 0) + (stats['cosmic_count'] ?? 0) +
                (stats['infinite_count'] ?? 0) > 0;
          } else if (achievement.id == 'accessory_legendary') {
            shouldUnlock = (stats['legendary_count'] ?? 0) >= 1;
          } else if (achievement.id == 'accessory_mythical') {
            shouldUnlock = (stats['mythical_count'] ?? 0) >= 1;
          } else if (achievement.id == 'accessory_primordial') {
            shouldUnlock = (stats['primordial_count'] ?? 0) >= 1;
          } else if (achievement.id == 'accessory_cosmic') {
            shouldUnlock = (stats['cosmic_count'] ?? 0) >= 1;
          } else if (achievement.id == 'accessory_infinite') {
            shouldUnlock = (stats['infinite_count'] ?? 0) >= 1;
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
          if (achievement.id == 'secret_fast_clicker') {
            shouldUnlock = (stats['clicks_in_10_seconds'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id == 'secret_patience') {
            shouldUnlock = (stats['time_since_last_click'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id == 'secret_all_mythical') {
            shouldUnlock = (stats['all_mythical_equipped'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id == 'secret_no_generators') {
            final generators = ref.read(generatorsProvider);
            final hasGenerators = generators.any((count) => count > 0);
            shouldUnlock = !hasGenerators && (stats['total_click_fuba'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id == 'secret_midnight_clicker') {
            final now = DateTime.now();
            shouldUnlock = now.hour == 0;
          } else if (achievement.id == 'secret_hoarder') {
            shouldUnlock = (stats['total_inventory_accessories'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id == 'secret_perfectionist') {
            final generators = ref.read(generatorsProvider);
            shouldUnlock = generators.every((count) => count == achievement.targetValue);
          } else if (achievement.id == 'secret_speed_demon') {
            shouldUnlock = (stats['max_clicks_per_second'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id == 'secret_time_traveler') {
            shouldUnlock = (stats['max_consecutive_play_time'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id == 'secret_rainbow_collector') {
            final equipped = ref.read(equippedAccessoriesProvider);
            final equippedAccessories = equipped
                .map((id) => allAccessories.firstWhere((acc) => acc.id == id))
                .toList();
            final uniqueRarities = equippedAccessories
                .map((acc) => acc.rarity)
                .toSet()
                .length;
            shouldUnlock = uniqueRarities >= achievement.targetValue;
          } else if (achievement.id == 'secret_minimalist') {
            final generators = ref.read(generatorsProvider);
            shouldUnlock = generators.every((count) => count == 1) && 
                          generators.length >= achievement.targetValue;
          } else if (achievement.id == 'secret_lucky_streak') {
            shouldUnlock = (stats['legendary_lootbox_streak'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id == 'secret_zen_master') {
            shouldUnlock = (stats['max_time_without_clicking'] ?? 0) >= achievement.targetValue;
          } else if (achievement.id == 'secret_rebirth_master') {
            shouldUnlock = rebirthData.rebirthCount >= achievement.targetValue;
          } else if (achievement.id.startsWith('secret_meditation_')) {
            shouldUnlock = (stats['max_time_without_clicking'] ?? 0) >= achievement.targetValue;
          }
          break;
      }

      if (shouldUnlock) {
        unlockAchievement(achievement.id, context);
      }
    }
  }

  void unlockAchievement(String achievementId, [BuildContext? context]) {
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
        celestialTokens: rebirthData.celestialTokens + achievement.reward.value,
      );
    } else if (achievement.reward.type == AchievementRewardType.unlockSecret) {
      if (achievement.reward.secretId != null) {
        ref.read(secretNotifierProvider).unlockSecret(achievement.reward.secretId!);
      }
    }

    // Tentar usar o contexto passado primeiro, depois o do provider
    final targetContext = context ?? ref.read(appContextProvider);
    if (targetContext != null && targetContext.mounted) {
      AchievementPopupManager.showAchievementPopup(targetContext, achievement);
    }
  }

  void incrementStat(String statKey, [double amount = 1, BuildContext? context]) {
    try {
      final stats = ref.read(achievementStatsProvider);
      final newStats = Map<String, double>.from(stats);
      final currentValue = newStats[statKey] ?? 0;
      
      // Evita overflow para valores muito grandes
      if (currentValue > 1e100) {
        return;
      }
      
      newStats[statKey] = currentValue + amount;
      ref.read(achievementStatsProvider.notifier).state = newStats;
      checkAchievements(context);
    } catch (e) {
      // Se houver erro, não atualiza o estado para evitar crash
      print('Erro ao incrementar stat $statKey: $e');
    }
  }

  void updateStat(String statKey, double value, [BuildContext? context]) {
    try {
      final stats = ref.read(achievementStatsProvider);
      final newStats = Map<String, double>.from(stats);
      
      // Evita overflow para valores muito grandes
      if (value > 1e100) {
        newStats[statKey] = 1e100;
      } else {
        newStats[statKey] = value;
      }
      
      ref.read(achievementStatsProvider.notifier).state = newStats;
      checkAchievements(context);
    } catch (e) {
      // Se houver erro, não atualiza o estado para evitar crash
      print('Erro ao atualizar stat $statKey: $e');
    }
  }

  void updateClickSpeed(double clicksPerSecond, [BuildContext? context]) {
    try {
      final stats = ref.read(achievementStatsProvider);
      final newStats = Map<String, double>.from(stats);
      
      // Evita overflow para valores muito grandes
      if (clicksPerSecond > 1e100) {
        newStats['clicks_per_second'] = 1e100;
        newStats['max_clicks_per_second'] = 1e100;
      } else {
        newStats['clicks_per_second'] = clicksPerSecond;
        if (clicksPerSecond > (newStats['max_clicks_per_second'] ?? 0)) {
          newStats['max_clicks_per_second'] = clicksPerSecond;
        }
      }
      
      ref.read(achievementStatsProvider.notifier).state = newStats;
      checkAchievements(context);
    } catch (e) {
      print('Erro ao atualizar click speed: $e');
    }
  }

  void updateClickStreak(double streak, [BuildContext? context]) {
    try {
      final stats = ref.read(achievementStatsProvider);
      final newStats = Map<String, double>.from(stats);
      
      // Evita overflow para valores muito grandes
      if (streak > 1e100) {
        newStats['click_streak'] = 1e100;
        newStats['max_click_streak'] = 1e100;
      } else {
        newStats['click_streak'] = streak;
        if (streak > (newStats['max_click_streak'] ?? 0)) {
          newStats['max_click_streak'] = streak;
        }
      }
      
      ref.read(achievementStatsProvider.notifier).state = newStats;
      checkAchievements(context);
    } catch (e) {
      print('Erro ao atualizar click streak: $e');
    }
  }

  void updateFubaPerClick(double fubaPerClick, [BuildContext? context]) {
    try {
      final stats = ref.read(achievementStatsProvider);
      final newStats = Map<String, double>.from(stats);
      
      // Evita overflow para valores muito grandes
      if (fubaPerClick > 1e100) {
        newStats['fuba_per_click'] = 1e100;
        newStats['max_fuba_per_click'] = 1e100;
      } else {
        newStats['fuba_per_click'] = fubaPerClick;
        if (fubaPerClick > (newStats['max_fuba_per_click'] ?? 0)) {
          newStats['max_fuba_per_click'] = fubaPerClick;
        }
      }
      
      ref.read(achievementStatsProvider.notifier).state = newStats;
      checkAchievements(context);
    } catch (e) {
      print('Erro ao atualizar fuba per click: $e');
    }
  }

  void updateClicksIn10Seconds(double clicks, [BuildContext? context]) {
    try {
      final stats = ref.read(achievementStatsProvider);
      final newStats = Map<String, double>.from(stats);
      newStats['clicks_in_10_seconds'] = clicks > 1e100 ? 1e100 : clicks;
      ref.read(achievementStatsProvider.notifier).state = newStats;
      checkAchievements(context);
    } catch (e) {
      print('Erro ao atualizar clicks em 10 segundos: $e');
    }
  }

  void updateTimeSinceLastClick(double seconds, [BuildContext? context]) {
    final stats = ref.read(achievementStatsProvider);
    final newStats = Map<String, double>.from(stats);
    newStats['time_since_last_click'] = seconds;
    ref.read(achievementStatsProvider.notifier).state = newStats;
    checkAchievements(context);
  }

  void updateTotalClickFuba(double fuba, [BuildContext? context]) {
    final stats = ref.read(achievementStatsProvider);
    final newStats = Map<String, double>.from(stats);
    newStats['total_click_fuba'] = fuba;
    ref.read(achievementStatsProvider.notifier).state = newStats;
    checkAchievements(context);
  }

  void updateAllMythicalEquipped(double count, [BuildContext? context]) {
    final stats = ref.read(achievementStatsProvider);
    final newStats = Map<String, double>.from(stats);
    newStats['all_mythical_equipped'] = count;
    ref.read(achievementStatsProvider.notifier).state = newStats;
    checkAchievements(context);
  }

  void updateTotalInventoryAccessories(double count, [BuildContext? context]) {
    final stats = ref.read(achievementStatsProvider);
    final newStats = Map<String, double>.from(stats);
    newStats['total_inventory_accessories'] = count;
    ref.read(achievementStatsProvider.notifier).state = newStats;
    checkAchievements(context);
  }

  void updateLegendaryLootboxStreak(double streak, [BuildContext? context]) {
    final stats = ref.read(achievementStatsProvider);
    final newStats = Map<String, double>.from(stats);
    newStats['legendary_lootbox_streak'] = streak;
    ref.read(achievementStatsProvider.notifier).state = newStats;
    checkAchievements(context);
  }

  void updateTimeWithoutClicking(double seconds, [BuildContext? context]) {
    final stats = ref.read(achievementStatsProvider);
    final newStats = Map<String, double>.from(stats);
    newStats['time_without_clicking'] = seconds;
    if (seconds > (newStats['max_time_without_clicking'] ?? 0)) {
      newStats['max_time_without_clicking'] = seconds;
    }
    ref.read(achievementStatsProvider.notifier).state = newStats;
    checkAchievements(context);
  }

  void updateConsecutivePlayTime(double seconds, [BuildContext? context]) {
    final stats = ref.read(achievementStatsProvider);
    final newStats = Map<String, double>.from(stats);
    newStats['consecutive_play_time'] = seconds;
    if (seconds > (newStats['max_consecutive_play_time'] ?? 0)) {
      newStats['max_consecutive_play_time'] = seconds;
    }
    ref.read(achievementStatsProvider.notifier).state = newStats;
    checkAchievements(context);
  }

  BigDecimal getTotalMultiplierFromAchievements() {
    final unlocked = ref.read(unlockedAchievementsProvider);
    BigDecimal multiplier = BigDecimal.one;

    for (final achievementId in unlocked) {
      final achievement =
          allAchievements.firstWhere((a) => a.id == achievementId);
      if (achievement.reward.type == AchievementRewardType.multiplier) {
        multiplier *= BigDecimal.parse(achievement.reward.value.toString());
      }
    }

    return multiplier;
  }
}

final achievementNotifierProvider = Provider<AchievementNotifier>((ref) {
  return AchievementNotifier(ref);
});

final achievementMultiplierProvider = Provider<BigDecimal>((ref) {
  final unlocked = ref.watch(unlockedAchievementsProvider);
  BigDecimal multiplier = BigDecimal.one;

  for (final achievementId in unlocked) {
    final achievement =
        allAchievements.firstWhere((a) => a.id == achievementId);
    if (achievement.reward.type == AchievementRewardType.multiplier) {
      multiplier *= BigDecimal.parse(achievement.reward.value.toString());
    }
  }

  return multiplier;
});

