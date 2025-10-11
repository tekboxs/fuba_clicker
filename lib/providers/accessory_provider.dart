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
    if (equipped.contains(accessoryId)) {
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
    ref.read(equippedAccessoriesProvider.notifier).state =
        equipped.where((id) => id != accessoryId).toList();
  }

  bool isEquipped(String accessoryId) {
    return ref.read(equippedAccessoriesProvider).contains(accessoryId);
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
}

final accessoryNotifierProvider = Provider<AccessoryNotifier>((ref) {
  return AccessoryNotifier(ref);
});

