import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rebirth_upgrade.dart';
import 'rebirth_provider.dart';
import 'game_providers.dart';
import '../utils/difficulty_barriers.dart';

final upgradesLevelProvider = StateProvider<Map<String, int>>((ref) {
  return {};
});

final upgradeLevelsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(upgradesLevelProvider);
});

class UpgradeNotifier {
  UpgradeNotifier(this.ref);
  final Ref ref;
  
  // Cache para evitar recálculos desnecessários
  final Map<String, bool> _canPurchaseCache = {};
  final Map<String, int> _lastLevelCache = {};

  bool canPurchase(RebirthUpgrade upgrade) {
    final currentLevel = getUpgradeLevel(upgrade.id);
    final rebirthData = ref.read(rebirthDataProvider);
    
    // Verifica se o cache ainda é válido
    final cacheKey = '${upgrade.id}_${currentLevel}_${rebirthData.celestialTokens}';
    if (_canPurchaseCache.containsKey(cacheKey)) {
      return _canPurchaseCache[cacheKey]!;
    }
    
    if (currentLevel >= upgrade.maxLevel) {
      _canPurchaseCache[cacheKey] = false;
      return false;
    }

    if (rebirthData.ascensionCount < upgrade.ascensionRequirement) {
      _canPurchaseCache[cacheKey] = false;
      return false;
    }

    final cost = upgrade.getTokenCost(currentLevel);
    final canPurchase = rebirthData.celestialTokens >= cost;
    _canPurchaseCache[cacheKey] = canPurchase;
    return canPurchase;
  }
  
  void _clearCache() {
    _canPurchaseCache.clear();
    _lastLevelCache.clear();
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
    
    // Limpa o cache após uma compra
    _clearCache();
    
    // Limpa cache de barriers também
    ref.read(barrierProgressCacheProvider.notifier).state = {};
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

final allUpgradesDataProvider = Provider<Map<String, Map<String, dynamic>>>((ref) {
  final upgradeLevels = ref.watch(upgradeLevelsProvider);
  final rebirthData = ref.watch(rebirthDataProvider);
  
  final Map<String, Map<String, dynamic>> upgradesData = {};
  
  for (final upgrade in allUpgrades) {
    final currentLevel = upgradeLevels[upgrade.id] ?? 0;
    final isMaxed = currentLevel >= upgrade.maxLevel;
    final isLocked = rebirthData.ascensionCount < upgrade.ascensionRequirement;
    
    upgradesData[upgrade.id] = {
      'currentLevel': currentLevel,
      'isMaxed': isMaxed,
      'isLocked': isLocked,
    };
  }
  
  return upgradesData;
});

// Provider otimizado para barriers com cache
final barrierProgressCacheProvider = StateProvider<Map<String, double>>((ref) => {});

final barrierProgressProvider = Provider.family<double, String>((ref, upgradeId) {
  final fuba = ref.watch(fubaProvider);
  final generatorsOwned = ref.watch(generatorsProvider);
  final cache = ref.watch(barrierProgressCacheProvider);
  
  // Chave de cache baseada em fuba e geradores
  final cacheKey = '${upgradeId}_${fuba.toString()}_${generatorsOwned.join(',')}';
  
  // Verifica se já está em cache
  if (cache.containsKey(cacheKey)) {
    return cache[cacheKey]!;
  }
  
  // Cache simples para evitar recálculos
  final upgrade = allUpgrades.firstWhere((u) => u.id == upgradeId);
  
  // Determina qual barrier usar baseado no upgrade
  final barriers = DifficultyBarrierManager.getBarriersForCategory('upgrade');
  DifficultyBarrier? barrier;
  
  switch (upgrade.id) {
    case 'auto_clicker':
    case 'click_power':
      barrier = barriers[0];
      break;
    case 'idle_boost':
    case 'lucky_boxes':
    case 'starting_fuba':
      barrier = barriers[1];
      break;
    case 'generator_discount':
    case 'offline_production':
    case 'production_multiplier':
      barrier = barriers[2];
      break;
  }
  
  if (barrier == null) return 0.0;
  
  // Otimização: se já está desbloqueado, retorna 1.0 sem cálculos custosos
  if (barrier.isUnlocked(fuba, generatorsOwned)) {
    final result = 1.0;
    ref.read(barrierProgressCacheProvider.notifier).state = {
      ...cache,
      cacheKey: result,
    };
    return result;
  }
  
  final result = barrier.getProgress(fuba, generatorsOwned);
  
  // Armazena no cache
  ref.read(barrierProgressCacheProvider.notifier).state = {
    ...cache,
    cacheKey: result,
  };
  
  return result;
});

