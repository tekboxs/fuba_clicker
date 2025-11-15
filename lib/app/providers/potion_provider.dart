import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cake_accessory.dart';
import '../models/potion.dart';
import '../models/potion_color.dart';
import '../models/potion_effect.dart';
import 'rebirth_provider.dart';
import 'save_provider.dart';
import 'forus_upgrade_provider.dart';
import 'accessory_provider.dart';

final cauldronProvider = StateProvider<Map<PotionColor, int>>((ref) {
  return {};
});

final activePotionEffectsProvider = StateProvider<List<PotionEffect>>((ref) {
  return [];
});

final permanentPotionMultiplierProvider = StateProvider<double>((ref) {
  return 1.0;
});

final activePotionCountProvider = StateProvider<Map<String, int>>((ref) {
  return {};
});

class PotionNotifier {
  PotionNotifier(this.ref);
  final Ref ref;

  void addItemToCauldron(CakeAccessory accessory, int quantity) {
    final inventory = ref.read(inventoryProvider);
    final equipped = ref.read(equippedAccessoriesProvider);
    
    final totalQuantity = inventory[accessory.id] ?? 0;
    final equippedCount = equipped.where((id) => id == accessory.id).length;
    final availableQuantity = totalQuantity - equippedCount;
    
    if (availableQuantity < quantity) {
      return;
    }

    final newInventory = Map<String, int>.from(inventory);
    final currentCount = newInventory[accessory.id] ?? 0;
    newInventory[accessory.id] = currentCount - quantity;
    
    if (newInventory[accessory.id] == 0) {
      newInventory.remove(accessory.id);
    }
    
    ref.read(inventoryProvider.notifier).state = newInventory;

    final cauldron = ref.read(cauldronProvider);
    final color = getItemColor(accessory);
    final colorValue = getItemColorValue(accessory);
    final totalValue = colorValue * quantity;

    final newCauldron = Map<PotionColor, int>.from(cauldron);
    newCauldron[color] = (newCauldron[color] ?? 0) + totalValue;
    
    ref.read(cauldronProvider.notifier).state = newCauldron;
    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }

  void clearCauldron() {
    ref.read(cauldronProvider.notifier).state = {};
  }

  List<Potion> getAvailablePotions() {
    final cauldron = ref.read(cauldronProvider);
    return allPotions.where((potion) => potion.matches(cauldron)).toList();
  }

  Potion? getBestMatchingPotion() {
    final available = getAvailablePotions();
    if (available.isEmpty) return null;
    
    available.sort((a, b) => b.getPowerLevel().compareTo(a.getPowerLevel()));
    return available.first;
  }

  bool _canActivatePotion(Potion potion) {
    final activeCount = ref.read(activePotionCountProvider);
    final currentCount = activeCount[potion.id] ?? 0;
    return currentCount < 10;
  }

  void _incrementPotionCount(String potionId) {
    final activeCount = ref.read(activePotionCountProvider);
    final newCount = Map<String, int>.from(activeCount);
    newCount[potionId] = (newCount[potionId] ?? 0) + 1;
    ref.read(activePotionCountProvider.notifier).state = newCount;
  }


  void brewPotion(Potion potion) {
    final cauldron = ref.read(cauldronProvider);
    if (!potion.matches(cauldron)) return;

    if (!_canActivatePotion(potion)) {
      return;
    }

    final newCauldron = Map<PotionColor, int>.from(cauldron);
    for (final entry in potion.colorComposition.entries) {
      final color = entry.key;
      final required = entry.value;
      final current = newCauldron[color] ?? 0;
      newCauldron[color] = current - required;
      if (newCauldron[color]! <= 0) {
        newCauldron.remove(color);
      }
    }

    ref.read(cauldronProvider.notifier).state = newCauldron;

    _incrementPotionCount(potion.id);

    final now = DateTime.now();
    for (final effect in potion.effects) {
      if (effect.isPermanent) {
        final current = ref.read(permanentPotionMultiplierProvider);
        ref.read(permanentPotionMultiplierProvider.notifier).state = 
            current * effect.value;
      } else {
        final active = ref.read(activePotionEffectsProvider);
        final expiresAt = effect.duration != null
            ? now.add(effect.duration!)
            : effect.expiresAt;
        
        final existingEffectIndex = active.indexWhere(
          (e) => !e.isExpired && e.type == effect.type && !e.isPermanent,
        );
        
        if (existingEffectIndex >= 0) {
          final existingEffect = active[existingEffectIndex];
          final mergedValue = _mergeEffectValues(effect.type, existingEffect.value, effect.value);
          final existingExpiresAt = existingEffect.expiresAt ?? now;
          final newExpiresAt = expiresAt ?? now;
          final mergedExpiresAt = newExpiresAt.isAfter(existingExpiresAt)
              ? newExpiresAt
              : existingExpiresAt;
          
          final mergedEffect = PotionEffect(
            type: effect.type,
            value: mergedValue,
            duration: null,
            expiresAt: mergedExpiresAt,
            isPermanent: false,
          );
          
          final updatedActive = List<PotionEffect>.from(active);
          updatedActive[existingEffectIndex] = mergedEffect;
          ref.read(activePotionEffectsProvider.notifier).state = updatedActive;
        } else {
          final newEffect = PotionEffect(
            type: effect.type,
            value: effect.value,
            duration: effect.duration,
            expiresAt: expiresAt,
            isPermanent: false,
          );
          
          ref.read(activePotionEffectsProvider.notifier).state = [
            ...active,
            newEffect,
          ];
        }
      }
    }
    
    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }

  void updateActiveEffects() {
    final active = ref.read(activePotionEffectsProvider);
    final remaining = active.where((effect) => !effect.isExpired).toList();
    
    if (remaining.length != active.length) {
      ref.read(activePotionEffectsProvider.notifier).state = remaining;
      _recalculatePotionCounts();
      ref.read(saveNotifierProvider.notifier).saveImmediate();
    }
  }

  void clearAllEffects() {
    ref.read(activePotionEffectsProvider.notifier).state = [];
    ref.read(activePotionCountProvider.notifier).state = {};
    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }

  void _recalculatePotionCounts() {
    final active = ref.read(activePotionEffectsProvider);
    final newCount = <String, int>{};
    
    for (final effect in active) {
      if (!effect.isExpired && !effect.isPermanent) {
        final matchingPotions = allPotions.where((potion) => 
          _matchesPotionEffect(potion, effect)
        ).toList();
        
        for (final potion in matchingPotions) {
          newCount[potion.id] = (newCount[potion.id] ?? 0) + 1;
        }
      }
    }
    
    ref.read(activePotionCountProvider.notifier).state = newCount;
  }

  bool _matchesPotionEffect(Potion potion, PotionEffect effect) {
    for (final potionEffect in potion.effects) {
      if (potionEffect.type == effect.type) {
        if (potion.effects.length == 1) {
          return potionEffect.value == effect.value;
        } else {
          return true;
        }
      }
    }
    return false;
  }

  double _mergeEffectValues(PotionEffectType type, double existingValue, double newValue) {
    switch (type) {
      case PotionEffectType.productionMultiplier:
      case PotionEffectType.clickPower:
      case PotionEffectType.rebirthMultiplier:
        return existingValue * newValue;
      case PotionEffectType.tokenGain:
      case PotionEffectType.forusGain:
      case PotionEffectType.generatorDiscount:
      case PotionEffectType.accessoryDropChance:
        return existingValue + newValue;
      case PotionEffectType.permanentMultiplier:
        return existingValue * newValue;
    }
  }

  void activatePotionEffectDebug(Potion potion) {
    if (!_canActivatePotion(potion)) {
      return;
    }

    _incrementPotionCount(potion.id);

    final now = DateTime.now();
    for (final effect in potion.effects) {
      if (effect.isPermanent) {
        final current = ref.read(permanentPotionMultiplierProvider);
        ref.read(permanentPotionMultiplierProvider.notifier).state = 
            current * effect.value;
      } else {
        final active = ref.read(activePotionEffectsProvider);
        final expiresAt = effect.duration != null
            ? now.add(effect.duration!)
            : effect.expiresAt;
        
        final existingEffectIndex = active.indexWhere(
          (e) => !e.isExpired && e.type == effect.type && !e.isPermanent,
        );
        
        if (existingEffectIndex >= 0) {
          final existingEffect = active[existingEffectIndex];
          final mergedValue = _mergeEffectValues(effect.type, existingEffect.value, effect.value);
          final existingExpiresAt = existingEffect.expiresAt ?? now;
          final newExpiresAt = expiresAt ?? now;
          final mergedExpiresAt = newExpiresAt.isAfter(existingExpiresAt)
              ? newExpiresAt
              : existingExpiresAt;
          
          final mergedEffect = PotionEffect(
            type: effect.type,
            value: mergedValue,
            duration: null,
            expiresAt: mergedExpiresAt,
            isPermanent: false,
          );
          
          final updatedActive = List<PotionEffect>.from(active);
          updatedActive[existingEffectIndex] = mergedEffect;
          ref.read(activePotionEffectsProvider.notifier).state = updatedActive;
        } else {
          final newEffect = PotionEffect(
            type: effect.type,
            value: effect.value,
            duration: effect.duration,
            expiresAt: expiresAt,
            isPermanent: false,
          );
          
          ref.read(activePotionEffectsProvider.notifier).state = [
            ...active,
            newEffect,
          ];
        }
      }
    }
    
    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }

}

final potionNotifierProvider = Provider<PotionNotifier>((ref) {
  return PotionNotifier(ref);
});

final cauldronUnlockedProvider = Provider<bool>((ref) {
  final rebirthData = ref.watch(rebirthDataProvider);
  final ownedUpgrades = ref.watch(forusUpgradesOwnedProvider);
  return rebirthData.cauldronUnlocked || ownedUpgrades.contains('cauldron');
});

