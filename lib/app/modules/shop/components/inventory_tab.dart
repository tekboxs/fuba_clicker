import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/models/cake_accessory.dart';
import 'package:fuba_clicker/app/providers/accessory_provider.dart';
import 'package:fuba_clicker/app/providers/achievement_provider.dart';
import 'package:fuba_clicker/app/providers/save_provider.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/global_widgets/orbiting_emoji.dart';

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
            onEquipBest: () => _equipBest(context, ref),
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

  void _equipBest(BuildContext context, WidgetRef ref) {
    final inventory = ref.read(inventoryProvider);
    final equipped = ref.read(equippedAccessoriesProvider);
    final maxCapacity = ref.read(accessoryCapacityProvider);
    
    if (equipped.length >= maxCapacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os slots estão ocupados!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (inventory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inventário vazio!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final accessoryNotifier = ref.read(accessoryNotifierProvider);
    final equippedBefore = equipped.length;
    accessoryNotifier.equipBestItems();
    final equippedAfter = ref.read(equippedAccessoriesProvider).length;
    final equippedCount = equippedAfter - equippedBefore;
    
    ref.read(saveNotifierProvider.notifier).saveImmediate();
    
    if (equippedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$equippedCount melhor(es) item(ns) equipado(s)!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum item disponível para equipar!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
    final isMobile = GameConstants.isMobile(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canEquip
              ? accessory.rarity.color.withOpacity(0.5)
              : Colors.white10,
          width: canEquip ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: canEquip
                ? accessory.rarity.color.withOpacity(0.3)
                : accessory.rarity.color.withOpacity(0.15),
            blurRadius: canEquip ? 32 : 24,
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
          splashColor: canEquip
              ? accessory.rarity.color.withOpacity(0.3)
              : Colors.transparent,
          highlightColor: canEquip
              ? accessory.rarity.color.withOpacity(0.1)
              : Colors.transparent,
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
                    child: OrbitingEmoji(
                      emoji: accessory.emoji,
                      fontSize: 38,
                      orbitRadius: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              accessory.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (canEquip)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: isMobile ? 14 : 16,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Clique para equipar',
                                    style: TextStyle(
                                      fontSize: isMobile ? 10 : 11,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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
  final VoidCallback onEquipBest;

  const _EquippedSlotsHeader({
    required this.maxCapacity,
    required this.equipped,
    required this.onUnequipAll,
    required this.onEquipBest,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = GameConstants.isMobile(context);
    final slots = List.generate(maxCapacity, (i) => i);
    final hasEmptySlots = equipped.length < maxCapacity;
    return Column(
      children: [
        if (hasEmptySlots)
          Container(
            margin: EdgeInsets.fromLTRB(
              isMobile ? 12 : 16,
              isMobile ? 12 : 16,
              isMobile ? 12 : 16,
              8,
            ),
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    'Clique nos itens abaixo para equipá-los nos slots vazios',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: Colors.blue.shade200,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: equipped.length < maxCapacity ? onEquipBest : null,
                  child: const Text(
                    'Equipar Melhores',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: equipped.isNotEmpty ? onUnequipAll : null,
                  child: const Text(
                    'Desequipar Todos',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
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
    final isEmpty = accessory == null && isUnlocked;
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isEmpty
            ? const Color(0xFF0F1115).withOpacity(0.5)
            : const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEmpty
              ? Colors.blue.withOpacity(0.3)
              : Colors.white12,
          width: isEmpty ? 2 : 1,
          style: isEmpty ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: accessory != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OrbitingEmoji(
                  emoji: accessory.emoji,
                  fontSize: 36,
                  orbitRadius: 16,
                ),
                const SizedBox(height: 6),
                Text(accessory.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
              ],
            )
          : isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Colors.blue.withOpacity(0.6),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Slot vazio',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Icon(
                  Icons.lock_outline,
                  color: Colors.white24,
                ),
    );
  }
}
