import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rebirth_upgrade.dart';
import 'rebirth_provider.dart';

final upgradesLevelProvider = StateProvider<Map<String, int>>((ref) {
  return {};
});

final upgradeLevelsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(upgradesLevelProvider);
});

class UpgradeNotifier {
  UpgradeNotifier(this.ref);
  final Ref ref;

  bool canPurchase(RebirthUpgrade upgrade) {
    final currentLevel = getUpgradeLevel(upgrade.id);
    if (currentLevel >= upgrade.maxLevel) return false;

    final rebirthData = ref.read(rebirthDataProvider);
    if (rebirthData.ascensionCount < upgrade.ascensionRequirement) {
      return false;
    }

    final cost = upgrade.getTokenCost(currentLevel);
    return rebirthData.celestialTokens >= cost;
  }

  void purchaseUpgrade(RebirthUpgrade upgrade) {
    if (!canPurchase(upgrade)) return;

    final currentLevel = getUpgradeLevel(upgrade.id);
    final cost = upgrade.getTokenCost(currentLevel);

    ref.read(rebirthNotifierProvider).spendTokens(cost.toDouble());

    final levels = ref.read(upgradesLevelProvider);
    final newLevels = Map<String, int>.from(levels);
    newLevels[upgrade.id] = currentLevel + 1;
    ref.read(upgradesLevelProvider.notifier).state = newLevels;
  }

  int getUpgradeLevel(String upgradeId) {
    return ref.read(upgradeLevelsProvider)[upgradeId] ?? 0;
  }

  double getUpgradeEffect(UpgradeType type) {
    final upgrade = allUpgrades.firstWhere((u) => u.type == type);
    final level = getUpgradeLevel(upgrade.id);
    return upgrade.getEffectValue(level);
  }

  double getTotalProductionMultiplier() {
    double multiplier = 1.0;
    multiplier *= getUpgradeEffect(UpgradeType.idleBoost);
    multiplier *= getUpgradeEffect(UpgradeType.productionMultiplier);
    return multiplier;
  }

  double getClickMultiplier() {
    return getUpgradeEffect(UpgradeType.clickPower);
  }

  double getAutoClickerRate() {
    return getUpgradeEffect(UpgradeType.autoClicker);
  }

  double getAnimationSpeedMultiplier() {
    return getUpgradeEffect(UpgradeType.animationSpeed);
  }

  int getAccessoryCapacity() {
    return getUpgradeEffect(UpgradeType.accessoryCapacity).toInt();
  }

  bool shouldKeepItems() {
    return getUpgradeEffect(UpgradeType.keepItems) >= 1.0;
  }
}

final upgradeNotifierProvider = Provider<UpgradeNotifier>((ref) {
  return UpgradeNotifier(ref);
});

final upgradeProductionMultiplierProvider = Provider<double>((ref) {
  return ref.watch(upgradeNotifierProvider).getTotalProductionMultiplier();
});

final upgradeCardDataProvider = Provider.family<Map<String, dynamic>, String>((ref, upgradeId) {
  final upgradeLevels = ref.watch(upgradeLevelsProvider);
  final rebirthData = ref.watch(rebirthDataProvider);
  final upgrade = allUpgrades.firstWhere((u) => u.id == upgradeId);
  
  final currentLevel = upgradeLevels[upgradeId] ?? 0;
  final isMaxed = currentLevel >= upgrade.maxLevel;
  final isLocked = rebirthData.ascensionCount < upgrade.ascensionRequirement;
  
  return {
    'currentLevel': currentLevel,
    'isMaxed': isMaxed,
    'isLocked': isLocked,
  };
});

