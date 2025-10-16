import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cake_accessory.dart';

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
  }

  void equipAccessory(String accessoryId) {
    final equipped = ref.read(equippedAccessoriesProvider);
    if (equipped.length >= 8) {
      return;
    }
    final inventory = ref.read(inventoryProvider);
    if ((inventory[accessoryId] ?? 0) <= 0) {
      return;
    }

    ref.read(equippedAccessoriesProvider.notifier).state = [
      ...equipped,
      accessoryId
    ];
  }

  void unequipAccessory(String accessoryId) {
    final equipped = ref.read(equippedAccessoriesProvider);
    final index = equipped.indexOf(accessoryId);
    if (index != -1) {
      final newEquipped = List<String>.from(equipped);
      newEquipped.removeAt(index);
      ref.read(equippedAccessoriesProvider.notifier).state = newEquipped;
    }
  }

  void unequipAllOfType(String accessoryId) {
    final equipped = ref.read(equippedAccessoriesProvider);
    ref.read(equippedAccessoriesProvider.notifier).state =
        equipped.where((id) => id != accessoryId).toList();
  }

  bool isEquipped(String accessoryId) {
    return ref.read(equippedAccessoriesProvider).contains(accessoryId);
  }

  bool canEquip(String accessoryId) {
    final equipped = ref.read(equippedAccessoriesProvider);
    final inventory = ref.read(inventoryProvider);
    return equipped.length < 8 && (inventory[accessoryId] ?? 0) > getEquippedCount(accessoryId);
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

  double getTotalProductionMultiplier() {
    final equipped = ref.read(equippedAccessoriesProvider);
    if (equipped.isEmpty) return 1.0;

    double totalMultiplier = 1.0;
    for (final id in equipped) {
      final accessory = allAccessories.firstWhere((acc) => acc.id == id);
      totalMultiplier *= accessory.productionMultiplier;
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
}

final accessoryNotifierProvider = Provider<AccessoryNotifier>((ref) {
  return AccessoryNotifier(ref);
});

final accessoryMultiplierProvider = Provider<double>((ref) {
  return ref.watch(accessoryNotifierProvider).getTotalProductionMultiplier();
});

