import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../models/cake_accessory.dart';
import '../models/rebirth_upgrade.dart';
import 'rebirth_upgrade_provider.dart';
import 'achievement_provider.dart';

final inventoryProvider = StateProvider<Map<String, int>>((ref) {
  return {};
});

final equippedAccessoriesProvider = StateProvider<List<String>>((ref) {
  return [];
});

class AccessoryNotifier {
  AccessoryNotifier(this.ref);
  final Ref ref;

  void addToInventory(CakeAccessory accessory) {
    final inventory = ref.read(inventoryProvider);
    final newInventory = Map<String, int>.from(inventory);
    newInventory[accessory.id] = (newInventory[accessory.id] ?? 0) + 1;
    ref.read(inventoryProvider.notifier).state = newInventory;
    
    _updateInventoryStats();
  }

  void equipAccessory(String accessoryId) {
    final equipped = ref.read(equippedAccessoriesProvider);
    final maxCapacity = ref.read(accessoryCapacityProvider);
    if (equipped.length >= maxCapacity) {
      return;
    }
    final inventory = ref.read(inventoryProvider);
    final availableCount = inventory[accessoryId] ?? 0;
    final equippedCount = getEquippedCount(accessoryId);
    
    if (availableCount <= equippedCount) {
      return;
    }

    ref.read(equippedAccessoriesProvider.notifier).state = [
      ...equipped,
      accessoryId
    ];
    
    _checkMythicalAchievement();
  }

  void unequipAccessory(String accessoryId) {
    final equipped = ref.read(equippedAccessoriesProvider);
    final index = equipped.lastIndexOf(accessoryId);
    if (index != -1) {
      final newEquipped = List<String>.from(equipped);
      newEquipped.removeAt(index);
      ref.read(equippedAccessoriesProvider.notifier).state = newEquipped;
    }
    
    _checkMythicalAchievement();
  }

  void unequipAllOfType(String accessoryId) {
    final equipped = ref.read(equippedAccessoriesProvider);
    ref.read(equippedAccessoriesProvider.notifier).state =
        equipped.where((id) => id != accessoryId).toList();
    
    _checkMythicalAchievement();
  }

  bool isEquipped(String accessoryId) {
    return ref.read(equippedAccessoriesProvider).contains(accessoryId);
  }

  bool canEquip(String accessoryId) {
    final equipped = ref.read(equippedAccessoriesProvider);
    final maxCapacity = ref.read(accessoryCapacityProvider);
    final inventory = ref.read(inventoryProvider);
    final availableCount = inventory[accessoryId] ?? 0;
    final equippedCount = getEquippedCount(accessoryId);
    return equipped.length < maxCapacity && availableCount > equippedCount;
  }

  int getInventoryCount(String accessoryId) {
    return ref.read(inventoryProvider)[accessoryId] ?? 0;
  }

  int getEquippedCount(String accessoryId) {
    return ref
        .read(equippedAccessoriesProvider)
        .where((id) => id == accessoryId)
        .length;
  }

  BigDecimal getTotalProductionMultiplier() {
    final equipped = ref.read(equippedAccessoriesProvider);
    if (equipped.isEmpty) return BigDecimal.one;

    BigDecimal totalMultiplier = BigDecimal.one;
    for (final id in equipped) {
      final accessory = allAccessories.firstWhere((acc) => acc.id == id);
      totalMultiplier *= BigDecimal.parse(accessory.productionMultiplier.toString());
    }
    return totalMultiplier;
  }

  List<CakeAccessory> getActiveEffects() {
    final equipped = ref.read(equippedAccessoriesProvider);
    return equipped
        .map((id) => allAccessories.firstWhere((acc) => acc.id == id))
        .where((acc) => acc.visualEffect != VisualEffect.none)
        .toList();
  }

  List<SpecialAbility> getActiveAbilities() {
    final equipped = ref.read(equippedAccessoriesProvider);
    return equipped
        .map((id) => allAccessories.firstWhere((acc) => acc.id == id))
        .where((acc) => acc.specialAbility != SpecialAbility.none)
        .map((acc) => acc.specialAbility)
        .toList();
  }

  Map<String, int> getEquippedCounts() {
    final equipped = ref.read(equippedAccessoriesProvider);
    final counts = <String, int>{};
    for (final id in equipped) {
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  int getRemainingInventory(String accessoryId) {
    final inventory = ref.read(inventoryProvider);
    final availableCount = inventory[accessoryId] ?? 0;
    final equippedCount = getEquippedCount(accessoryId);
    return availableCount - equippedCount;
  }

  void _checkMythicalAchievement() {
    final equipped = ref.read(equippedAccessoriesProvider);
    if (equipped.isEmpty) {
      ref.read(achievementNotifierProvider).updateAllMythicalEquipped(0);
      return;
    }

    final equippedAccessories = equipped
        .map((id) => allAccessories.firstWhere((acc) => acc.id == id))
        .toList();

    final allMythical = equippedAccessories
        .every((accessory) => accessory.rarity == AccessoryRarity.mythical);

    if (allMythical) {
      ref.read(achievementNotifierProvider).updateAllMythicalEquipped(
        equippedAccessories.length.toDouble(),
      );
    } else {
      ref.read(achievementNotifierProvider).updateAllMythicalEquipped(0);
    }
  }

  void _updateInventoryStats() {
    final inventory = ref.read(inventoryProvider);
    final totalAccessories = inventory.values.fold(0, (sum, count) => sum + count);
    ref.read(achievementNotifierProvider).updateTotalInventoryAccessories(
      totalAccessories.toDouble(),
    );
  }
}

final accessoryNotifierProvider = Provider<AccessoryNotifier>((ref) {
  return AccessoryNotifier(ref);
});

final accessoryMultiplierProvider = Provider<BigDecimal>((ref) {
  final equipped = ref.watch(equippedAccessoriesProvider);
  if (equipped.isEmpty) return BigDecimal.one;

  BigDecimal totalMultiplier = BigDecimal.one;
  for (final id in equipped) {
    final accessory = allAccessories.firstWhere((acc) => acc.id == id);
    totalMultiplier *= BigDecimal.parse(accessory.productionMultiplier.toString());
  }
  return totalMultiplier;
});

final accessoryCapacityProvider = Provider<int>((ref) {
  final upgradeLevels = ref.watch(upgradesLevelProvider);
  final upgrade = allUpgrades.firstWhere((u) => u.type == UpgradeType.accessoryCapacity);
  final level = upgradeLevels[upgrade.id] ?? 0;
  final effect = upgrade.getEffectValue(level);
  if (effect.isInfinite || effect.isNaN) {
    return 0;
  }
  return effect.clamp(0, 1e6).toInt();
});

