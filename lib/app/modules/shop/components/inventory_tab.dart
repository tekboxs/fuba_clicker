import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/models/cake_accessory.dart';
import 'package:fuba_clicker/app/providers/accessory_provider.dart';
import 'package:fuba_clicker/app/providers/achievement_provider.dart';
import 'package:fuba_clicker/app/providers/save_provider.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';

class LootBoxInventoryTab extends ConsumerWidget {
  const LootBoxInventoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final equipped = ref.watch(equippedAccessoriesProvider);
    final maxCapacity = ref.watch(accessoryCapacityProvider);
    final isMobile = GameConstants.isMobile(context);

    if (inventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📦',
              style: TextStyle(
                fontSize: isMobile ? 80 : 100,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Text(
              'Inventário vazio',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              'Compre caixas para conseguir acessórios!',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    final inventoryItems = inventory.entries.toList();
    inventoryItems.sort((a, b) {
      final accessoryA = allAccessories.firstWhere((acc) => acc.id == a.key);
      final accessoryB = allAccessories.firstWhere((acc) => acc.id == b.key);
      return accessoryB.rarity.value.compareTo(accessoryA.rarity.value);
    });

    return Column(
      children: [
        Expanded(
          child: _EquippedSlotsHeader(
            maxCapacity: maxCapacity,
            equipped: equipped,
            onUnequipAll: () => _unequipAll(context, ref),
          ),
        ),
        Expanded(
          flex: 2,
          child: isMobile
              ? _MobileInventoryList(items: inventoryItems)
              : _DesktopInventoryGrid(items: inventoryItems),
        ),
      ],
    );
  }

  void _unequipAll(BuildContext context, WidgetRef ref) {
    final equipped = ref.read(equippedAccessoriesProvider);
    if (equipped.isEmpty) return;
    ref.read(equippedAccessoriesProvider.notifier).state = [];
    ref
        .read(achievementNotifierProvider)
        .updateStat('equipped_count', 0.0, context);
    ref.read(saveNotifierProvider.notifier).saveImmediate();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todos os acessórios foram desequipados!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class _MobileInventoryList extends ConsumerWidget {
  final List<MapEntry<String, int>> items;
  const _MobileInventoryList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 140,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        final accessory = allAccessories.firstWhere(
          (acc) => acc.id == entry.key,
        );
        final count = entry.value;
        final equipped = ref.watch(equippedAccessoriesProvider);
        final isEquipped = equipped.contains(accessory.id);
        final equippedCount = equipped.where((id) => id == accessory.id).length;
        return _DesktopInventoryItem(
          accessory: accessory,
          count: count,
          isEquipped: isEquipped,
          equippedCount: equippedCount,
        );
      },
    );
  }
}

class _DesktopInventoryGrid extends ConsumerWidget {
  final List<MapEntry<String, int>> items;
  const _DesktopInventoryGrid({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 460,
        mainAxisExtent: 140,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        final accessory = allAccessories.firstWhere(
          (acc) => acc.id == entry.key,
        );
        final count = entry.value;
        final equipped = ref.watch(equippedAccessoriesProvider);
        final isEquipped = equipped.contains(accessory.id);
        final equippedCount = equipped.where((id) => id == accessory.id).length;
        return _DesktopInventoryItem(
          accessory: accessory,
          count: count,
          isEquipped: isEquipped,
          equippedCount: equippedCount,
        );
      },
    );
  }
}

class _DesktopInventoryItem extends ConsumerWidget {
  final CakeAccessory accessory;
  final int count;
  final bool isEquipped;
  final int equippedCount;

  const _DesktopInventoryItem({
    required this.accessory,
    required this.count,
    required this.isEquipped,
    required this.equippedCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEquip =
        ref.watch(accessoryNotifierProvider).canEquip(accessory.id);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: accessory.rarity.color.withOpacity(0.15),
            blurRadius: 24,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canEquip
              ? () {
                  final n = ref.read(accessoryNotifierProvider);
                  n.equipAccessory(accessory.id);
                  final newEquipped = ref.read(equippedAccessoriesProvider);
                  ref.read(achievementNotifierProvider).updateStat(
                        'equipped_count',
                        newEquipped.length.toDouble(),
                        context,
                      );
                  ref.read(saveNotifierProvider.notifier).saveImmediate();
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1115),
                    boxShadow: [
                      BoxShadow(
                        color: accessory.rarity.color.withOpacity(0.15),
                        blurRadius: 10,
                      ),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: Text(accessory.emoji,
                        style: const TextStyle(fontSize: 38)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        accessory.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 5,
                            decoration: BoxDecoration(
                              color: accessory.rarity.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                              .animate(
                                onComplete: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .shimmer(
                                duration: 5.seconds,
                                blendMode: BlendMode.colorDodge,
                                color: accessory.rarity.color.withValues(),
                                delay: 1.seconds,
                              ),
                          const SizedBox(width: 10),
                          Text(
                            accessory.rarity.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              color: accessory.rarity.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Inventário: $count',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      if (equippedCount > 0)
                        Text(
                          'Equipados: $equippedCount',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (equippedCount > 0)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                          size: 24,
                        ),
                        onPressed: () {
                          final n = ref.read(accessoryNotifierProvider);
                          n.unequipAccessory(accessory.id);
                          final newEquipped =
                              ref.read(equippedAccessoriesProvider);
                          ref.read(achievementNotifierProvider).updateStat(
                                'equipped_count',
                                newEquipped.length.toDouble(),
                                context,
                              );
                          ref
                              .read(saveNotifierProvider.notifier)
                              .saveImmediate();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EquippedSlotsHeader extends ConsumerWidget {
  final int maxCapacity;
  final List<String> equipped;
  final VoidCallback onUnequipAll;

  const _EquippedSlotsHeader({
    required this.maxCapacity,
    required this.equipped,
    required this.onUnequipAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = GameConstants.isMobile(context);
    final slots = List.generate(maxCapacity, (i) => i);
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.all(isMobile ? 12 : 16),
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0D11),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Equipamentos',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        )),
                    Text('${equipped.length}/$maxCapacity slots em uso',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    children: [
                      for (final s in slots)
                        _SlotTile(
                          index: s,
                          equipped: equipped,
                          isUnlocked: s < maxCapacity,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: equipped.isNotEmpty ? onUnequipAll : null,
              child: const Text(
                'Desequipar Todos',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlotTile extends ConsumerWidget {
  final int index;
  final List<String> equipped;
  final bool isUnlocked;

  const _SlotTile({
    required this.index,
    required this.equipped,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accId = index < equipped.length ? equipped[index] : null;
    final accessory =
        accId != null ? allAccessories.firstWhere((a) => a.id == accId) : null;
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: accessory != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(accessory.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 6),
                Text(accessory.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
              ],
            )
          : Icon(
              isUnlocked ? Icons.lock_open : Icons.lock_outline,
              color: Colors.white24,
            ),
    );
  }
}
