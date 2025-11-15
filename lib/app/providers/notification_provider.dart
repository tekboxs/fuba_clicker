import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rebirth_upgrade.dart';
import '../models/loot_box.dart';
import '../models/rebirth_data.dart';
import 'rebirth_upgrade_provider.dart';
import 'rebirth_provider.dart';
import 'game_providers.dart';
import 'achievement_provider.dart';

final viewedAchievementsProvider = StateProvider<Set<String>>((ref) {
  return <String>{};
});

final viewedNotificationsProvider = StateProvider<Map<String, bool>>((ref) {
  return <String, bool>{};
});

class NotificationNotifier {
  NotificationNotifier(this.ref);
  final Ref ref;

  void markAchievementAsViewed(String achievementId) {
    final viewed = ref.read(viewedAchievementsProvider);
    ref.read(viewedAchievementsProvider.notifier).state = {
      ...viewed,
      achievementId,
    };
  }

  void markNotificationsAsViewed(String notificationType) {
    final viewed = ref.read(viewedNotificationsProvider);
    ref.read(viewedNotificationsProvider.notifier).state = {
      ...viewed,
      notificationType: true,
    };
  }

  void clearAllNotifications() {
    ref.read(viewedNotificationsProvider.notifier).state = {};
    ref.read(viewedAchievementsProvider.notifier).state = {};
  }
}

final notificationNotifierProvider = Provider<NotificationNotifier>((ref) {
  return NotificationNotifier(ref);
});

final availableUpgradesCountProvider = Provider<int>((ref) {
  final upgradeLevels = ref.watch(upgradeLevelsProvider);
  final rebirthData = ref.watch(rebirthDataProvider);

  int count = 0;
  for (final upgrade in allUpgrades) {
    final currentLevel = upgradeLevels[upgrade.id] ?? 0;
    if (currentLevel >= upgrade.maxLevel) continue;
    if (rebirthData.ascensionCount < upgrade.ascensionRequirement) continue;

    final cost = upgrade.getTokenCost(currentLevel);
    if (rebirthData.celestialTokens >= cost) {
      count++;
    }
  }

  return count;
});

final newAchievementsCountProvider = Provider<int>((ref) {
  final unlocked = ref.watch(unlockedAchievementsProvider);
  final viewed = ref.watch(viewedAchievementsProvider);

  int count = 0;
  for (final achievementId in unlocked) {
    if (!viewed.contains(achievementId)) {
      count++;
    }
  }

  return count;
});

final availableShopItemsCountProvider = Provider<int>((ref) {
  final fuba = ref.watch(fubaProvider);
  final generatorsOwned = ref.watch(generatorsProvider);
  final rebirthData = ref.watch(rebirthDataProvider);

  int count = 0;
  for (final tier in LootBoxTier.values) {
    if (tier.usesCelestialTokens()) {
      final tokensCost = tier.getCelestialTokensCost();
      if (rebirthData.celestialTokens >= tokensCost) {
        count++;
      }
    } else if (tier.usesGenerators()) {
      final generatorIndex = tier.getGeneratorIndex();
      final generatorCost = tier.getGeneratorCost();
      
      if (generatorIndex >= 0 && 
          generatorIndex < generatorsOwned.length && 
          generatorsOwned[generatorIndex] >= generatorCost) {
        count++;
      }
    } else {
      final tierCost = tier.getCost(fuba);
      if (fuba.compareTo(tierCost) >= 0) {
        count++;
      }
    }
  }

  return count;
});

final canRebirthCountProvider = Provider<int>((ref) {
  int count = 0;

  for (final tier in RebirthTier.values) {
    final canRebirth = ref.watch(canRebirthProvider(tier));
    if (canRebirth) {
      count++;
    }
  }

  return count;
});

final upgradesBadgeCountProvider = Provider<int?>((ref) {
  final count = ref.watch(availableUpgradesCountProvider);
  final viewed = ref.watch(viewedNotificationsProvider);
  
  if (count == 0) return null;
  if (viewed['upgrades'] == true) return null;
  
  return count;
});

final achievementsBadgeCountProvider = Provider<int?>((ref) {
  final count = ref.watch(newAchievementsCountProvider);
  
  if (count == 0) return null;
  
  return count;
});

final shopBadgeCountProvider = Provider<int?>((ref) {
  final count = ref.watch(availableShopItemsCountProvider);
  final viewed = ref.watch(viewedNotificationsProvider);
  
  if (count == 0) return null;
  if (viewed['shop'] == true) return null;
  
  return count;
});

final rebirthBadgeCountProvider = Provider<int?>((ref) {
  final count = ref.watch(canRebirthCountProvider);
  final viewed = ref.watch(viewedNotificationsProvider);
  
  if (count == 0) return null;
  if (viewed['rebirth'] == true) return null;
  
  return count;
});

