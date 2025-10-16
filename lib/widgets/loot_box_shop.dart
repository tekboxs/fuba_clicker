import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/loot_box.dart';
import '../models/cake_accessory.dart';
import '../providers/game_providers.dart';
import '../providers/accessory_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/save_provider.dart';
import '../utils/constants.dart';
import 'loot_box_opening.dart';

class LootBoxShopPage extends ConsumerStatefulWidget {
  const LootBoxShopPage({super.key});

  @override
  ConsumerState<LootBoxShopPage> createState() => _LootBoxShopPageState();
}

class _LootBoxShopPageState extends ConsumerState<LootBoxShopPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(240),
      appBar: AppBar(
        title: const Text('Loja de Acessórios'),
        backgroundColor: Colors.deepOrange.withAlpha(200),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Caixas', icon: Icon(Icons.shopping_bag)),
            Tab(text: 'Inventário', icon: Icon(Icons.inventory)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildShopTab(), _buildInventoryTab()],
      ),
    );
  }

  Widget _buildShopTab() {
    final fuba = ref.watch(fubaProvider);
    final isMobile = GameConstants.isMobile(context);

    return Padding(
      padding: EdgeInsets.all(GameConstants.getDefaultPadding(context)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepOrange.withAlpha(100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🌽', style: TextStyle(fontSize: isMobile ? 32 : 40)),
                SizedBox(width: isMobile ? 12 : 16),
                Text(
                  GameConstants.formatNumber(fuba),
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 3,
                childAspectRatio: isMobile ? 0.8 : 1.2,
                crossAxisSpacing: isMobile ? 16 : 20,
                mainAxisSpacing: isMobile ? 16 : 20,
              ),
              itemCount: LootBoxTier.values.length,
              itemBuilder: (context, index) {
                final tier = LootBoxTier.values[index];
                return _buildLootBoxCard(tier, fuba);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLootBoxCard(LootBoxTier tier, double fuba) {
    final canAfford = fuba >= tier.cost;
    final canAfford5 = fuba >= (tier.cost * 5);
    final canAfford10 = fuba >= (tier.cost * 10);
    final canAfford30 = fuba >= (tier.cost * 30);
    final isMobile = GameConstants.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: tier.color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tier.color.withAlpha(canAfford ? 150 : 50),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tier.emoji, style: TextStyle(fontSize: isMobile ? 64 : 80))
                .animate(
                  autoPlay: canAfford,
                  onComplete: (controller) => controller.repeat(),
                )
                .shimmer(duration: 2.seconds, color: tier.color.withAlpha(100)),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              tier.displayName,
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: canAfford ? tier.color : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              tier.description,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: canAfford ? Colors.white70 : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            _buildPurchaseButtons(
              tier,
              fuba,
              canAfford,
              canAfford5,
              canAfford10,
              canAfford30,
              isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButtons(
    LootBoxTier tier,
    double fuba,
    bool canAfford,
    bool canAfford5,
    bool canAfford10,
    bool canAfford30,
    bool isMobile,
  ) {
    return Column(
      children: [
        _buildSinglePurchaseButton(tier, fuba, canAfford, isMobile),
        SizedBox(height: isMobile ? 8 : 12),
        Row(
          children: [
            Expanded(
              child: _buildBulkPurchaseButton(tier, 5, canAfford5, isMobile),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: _buildBulkPurchaseButton(tier, 10, canAfford10, isMobile),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: _buildBulkPurchaseButton(tier, 30, canAfford30, isMobile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSinglePurchaseButton(
    LootBoxTier tier,
    double fuba,
    bool canAfford,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: canAfford
            ? Colors.orange.withAlpha(50)
            : Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canAfford ? Colors.orange : Colors.grey,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford ? () => _openLootBox(tier) : null,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌽', style: TextStyle(fontSize: isMobile ? 16 : 20)),
              SizedBox(width: isMobile ? 4 : 6),
              Text(
                GameConstants.formatNumber(tier.cost),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: canAfford ? Colors.orange : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulkPurchaseButton(
    LootBoxTier tier,
    int quantity,
    bool canAfford,
    bool isMobile,
  ) {
    final totalCost = tier.cost * quantity;
    final discount = 0;
    final discountedCost = totalCost * (1 - discount);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: canAfford
            ? Colors.deepOrange.withAlpha(50)
            : Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: canAfford ? Colors.deepOrange : Colors.grey,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford
              ? () => _openMultipleLootBoxes(tier, quantity)
              : null,
          borderRadius: BorderRadius.circular(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$quantity',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: canAfford ? Colors.deepOrange : Colors.grey,
                ),
              ),
              if (discount > 0)
                Text(
                  '-${(discount * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: isMobile ? 8 : 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                GameConstants.formatNumber(discountedCost),
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: canAfford ? Colors.orange : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getBulkDiscount(int quantity) {
    switch (quantity) {
      case 5:
        return 0.05; // 5% discount
      case 10:
        return 0.10; // 10% discount
      case 30:
        return 0.15; // 15% discount
      default:
        return 0.0;
    }
  }

  void _openLootBox(LootBoxTier tier) {
    final fuba = ref.read(fubaProvider);
    if (fuba < tier.cost) return;

    ref.read(fubaProvider.notifier).state -= tier.cost;

    final lootBox = LootBox(tier: tier);
    final reward = lootBox.openBox();

    ref.read(achievementNotifierProvider).incrementStat('lootboxes_opened');

    if (reward.rarity == AccessoryRarity.legendary) {
      ref.read(achievementNotifierProvider).incrementStat('legendary_count');
    } else if (reward.rarity == AccessoryRarity.mythical) {
      ref.read(achievementNotifierProvider).incrementStat('mythical_count');
    }

    ref.read(saveNotifierProvider.notifier).saveImmediate();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LootBoxOpeningAnimation(
        lootBoxTier: tier,
        reward: reward,
        onComplete: () {
          ref.read(accessoryNotifierProvider).addToInventory(reward);
          ref.read(saveNotifierProvider.notifier).saveImmediate();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _openMultipleLootBoxes(LootBoxTier tier, int quantity) {
    final fuba = ref.read(fubaProvider);
    final discount = _getBulkDiscount(quantity);
    final totalCost = (tier.cost * quantity) * (1 - discount);

    if (fuba < totalCost) return;

    ref.read(fubaProvider.notifier).state -= totalCost;

    final rewards = <CakeAccessory>[];
    for (int i = 0; i < quantity; i++) {
      final lootBox = LootBox(tier: tier);
      final reward = lootBox.openBox();
      rewards.add(reward);
    }

    ref
        .read(achievementNotifierProvider)
        .incrementStat('lootboxes_opened', quantity.toDouble());

    for (final reward in rewards) {
      if (reward.rarity == AccessoryRarity.legendary) {
        ref.read(achievementNotifierProvider).incrementStat('legendary_count');
      } else if (reward.rarity == AccessoryRarity.mythical) {
        ref.read(achievementNotifierProvider).incrementStat('mythical_count');
      }
    }

    ref.read(saveNotifierProvider.notifier).saveImmediate();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MultipleLootBoxOpeningAnimation(
        lootBoxTier: tier,
        rewards: rewards,
        onComplete: () {
          for (final reward in rewards) {
            ref.read(accessoryNotifierProvider).addToInventory(reward);
          }
          ref.read(saveNotifierProvider.notifier).saveImmediate();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildInventoryTab() {
    final inventory = ref.watch(inventoryProvider);
    final equipped = ref.watch(equippedAccessoriesProvider);
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
        if (equipped.isNotEmpty)
          Container(
            margin: EdgeInsets.all(isMobile ? 16 : 20),
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withAlpha(100)),
            ),
            child: Column(
              children: [
                Text(
                  'Equipados',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 12),
                Wrap(
                  spacing: isMobile ? 8 : 12,
                  children: equipped
                      .fold<Map<String, int>>({}, (map, id) {
                        map[id] = (map[id] ?? 0) + 1;
                        return map;
                      })
                      .entries
                      .map((entry) {
                        final accessory = allAccessories.firstWhere(
                          (acc) => acc.id == entry.key,
                        );
                        return Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: accessory.rarity.color.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: accessory.rarity.color.withAlpha(100),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                accessory.emoji,
                                style: TextStyle(fontSize: isMobile ? 24 : 32),
                              ),
                              if (entry.value > 1)
                                Text(
                                  '${entry.value}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 10 : 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Text(
                  '${equipped.length}/8 slots usados',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: isMobile
              ? _buildMobileInventoryList(inventoryItems, equipped)
              : _buildDesktopInventoryGrid(inventoryItems, equipped),
        ),
      ],
    );
  }

  Widget _buildMobileInventoryList(
    List<MapEntry<String, int>> inventoryItems,
    List<String> equipped,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inventoryItems.length,
      itemBuilder: (context, index) {
        final entry = inventoryItems[index];
        final accessory = allAccessories.firstWhere(
          (acc) => acc.id == entry.key,
        );
        final count = entry.value;
        final isEquipped = equipped.contains(accessory.id);
        final equippedCount = equipped.where((id) => id == accessory.id).length;

        return _buildInventoryItem(accessory, count, isEquipped, equippedCount);
      },
    );
  }

  Widget _buildDesktopInventoryGrid(
    List<MapEntry<String, int>> inventoryItems,
    List<String> equipped,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: inventoryItems.length,
      itemBuilder: (context, index) {
        final entry = inventoryItems[index];
        final accessory = allAccessories.firstWhere(
          (acc) => acc.id == entry.key,
        );
        final count = entry.value;
        final isEquipped = equipped.contains(accessory.id);
        final equippedCount = equipped.where((id) => id == accessory.id).length;

        return _buildDesktopInventoryItem(
          accessory,
          count,
          isEquipped,
          equippedCount,
        );
      },
    );
  }

  Widget _buildInventoryItem(
    CakeAccessory accessory,
    int count,
    bool isEquipped,
    int equippedCount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: accessory.rarity.color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accessory.rarity.color.withAlpha(100),
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Text(accessory.emoji, style: const TextStyle(fontSize: 40)),
        title: Text(
          accessory.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: accessory.rarity.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              accessory.rarity.displayName,
              style: TextStyle(
                fontSize: 12,
                color: accessory.rarity.color.withAlpha(200),
              ),
            ),
            Text(
              'Inventário: $count',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            if (equippedCount > 0)
              Text(
                'Equipados: $equippedCount',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isEquipped ? Icons.check_circle : Icons.circle_outlined,
            color: isEquipped ? Colors.green : Colors.grey,
          ),
          onPressed: () {
            final notifier = ref.read(accessoryNotifierProvider);
            if (isEquipped) {
              notifier.unequipAccessory(accessory.id);
              final newEquipped = ref.read(equippedAccessoriesProvider);
              ref
                  .read(achievementNotifierProvider)
                  .updateStat('equipped_count', newEquipped.length.toDouble());
              ref.read(saveNotifierProvider.notifier).saveImmediate();
            } else {
              if (!notifier.canEquip(accessory.id)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Não é possível equipar mais acessórios!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              notifier.equipAccessory(accessory.id);
              final newEquipped = ref.read(equippedAccessoriesProvider);
              ref
                  .read(achievementNotifierProvider)
                  .updateStat('equipped_count', newEquipped.length.toDouble());
              ref.read(saveNotifierProvider.notifier).saveImmediate();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopInventoryItem(
    CakeAccessory accessory,
    int count,
    bool isEquipped,
    int equippedCount,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: accessory.rarity.color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accessory.rarity.color.withAlpha(100),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final notifier = ref.read(accessoryNotifierProvider);
            if (isEquipped) {
              notifier.unequipAccessory(accessory.id);
              final newEquipped = ref.read(equippedAccessoriesProvider);
              ref
                  .read(achievementNotifierProvider)
                  .updateStat('equipped_count', newEquipped.length.toDouble());
              ref.read(saveNotifierProvider.notifier).saveImmediate();
            } else {
              if (!notifier.canEquip(accessory.id)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Não é possível equipar mais acessórios!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              notifier.equipAccessory(accessory.id);
              final newEquipped = ref.read(equippedAccessoriesProvider);
              ref
                  .read(achievementNotifierProvider)
                  .updateStat('equipped_count', newEquipped.length.toDouble());
              ref.read(saveNotifierProvider.notifier).saveImmediate();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(accessory.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        accessory.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: accessory.rarity.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accessory.rarity.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          color: accessory.rarity.color.withAlpha(200),
                        ),
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
                Icon(
                  isEquipped ? Icons.check_circle : Icons.circle_outlined,
                  color: isEquipped ? Colors.green : Colors.grey,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
