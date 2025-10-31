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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
        return _InventoryTile(
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = GameConstants.isMobile(context);
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: _getInventoryAspectRatio(screenHeight, isMobile),
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

  double _getInventoryAspectRatio(double h, bool isMobile) {
    if (h < 500) return isMobile ? 3.5 : 4.0;
    if (h < 600) return isMobile ? 3.0 : 3.5;
    if (h < 700) return isMobile ? 2.8 : 3.2;
    if (h < 800) return isMobile ? 2.6 : 3.0;
    return isMobile ? 2.4 : 2.8;
  }
}

class _InventoryTile extends ConsumerWidget {
  final CakeAccessory accessory;
  final int count;
  final bool isEquipped;
  final int equippedCount;

  const _InventoryTile({
    required this.accessory,
    required this.count,
    required this.isEquipped,
    required this.equippedCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEquip =
        ref.watch(accessoryNotifierProvider).canEquip(accessory.id);
    final maxCapacity = ref.watch(accessoryCapacityProvider);
    final equipped = ref.watch(equippedAccessoriesProvider);

    const bg = Color(0xFF0F1115);
    const border = Colors.white10;
    final rarity = accessory.rarity.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(color: rarity.withOpacity(0.15), blurRadius: 20),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bg,
            rarity.withOpacity(0.08),
          ],
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(
              child:
                  Text(accessory.emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
        ),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'asdads',
                // accessory.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rarity.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: rarity.withOpacity(0.6)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Equipado', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.8,
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(rarity),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  accessory.rarity.displayName,
                  style: TextStyle(fontSize: 11, color: rarity),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Inventário: $count',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 12),
                Text('Slots: ${equipped.length}/$maxCapacity',
                    style:
                        TextStyle(fontSize: 11, color: Colors.blue.shade300)),
              ],
            ),
            if (equippedCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('Equipados: $equippedCount',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    )),
              ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (equippedCount > 0)
              InkResponse(
                onTap: () {
                  final n = ref.read(accessoryNotifierProvider);
                  n.unequipAccessory(accessory.id);
                  final newEquipped = ref.read(equippedAccessoriesProvider);
                  ref.read(achievementNotifierProvider).updateStat(
                        'equipped_count',
                        newEquipped.length.toDouble(),
                        context,
                      );
                  ref.read(saveNotifierProvider.notifier).saveImmediate();
                },
                child: const Icon(Icons.close, color: Colors.red),
              ),
            const SizedBox(height: 8),
            InkWell(
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
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: canEquip ? rarity : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
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
