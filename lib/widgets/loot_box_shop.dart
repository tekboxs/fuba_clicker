import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/loot_box.dart';
import '../models/cake_accessory.dart';
import '../providers/game_providers.dart';
import '../providers/accessory_provider.dart';
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
        children: [
          _buildShopTab(),
          _buildInventoryTab(),
        ],
      ),
    );
  }

  Widget _buildShopTab() {
    final fuba = ref.watch(fubaProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepOrange.withAlpha(100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🌽',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Text(
                  GameConstants.formatNumber(fuba),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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

    return Container(
      decoration: BoxDecoration(
        color: tier.color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tier.color.withAlpha(canAfford ? 150 : 50),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford ? () => _openLootBox(tier) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tier.emoji,
                  style: const TextStyle(fontSize: 64),
                )
                    .animate(
                      autoPlay: canAfford,
                      onComplete: (controller) => controller.repeat(),
                    )
                    .shimmer(
                      duration: 2.seconds,
                      color: tier.color.withAlpha(100),
                    ),
                const SizedBox(height: 12),
                Text(
                  tier.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? tier.color : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  tier.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: canAfford ? Colors.white70 : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? Colors.orange.withAlpha(50)
                        : Colors.grey.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌽', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        GameConstants.formatNumber(tier.cost),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? Colors.orange : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLootBox(LootBoxTier tier) {
    final fuba = ref.read(fubaProvider);
    if (fuba < tier.cost) return;

    ref.read(fubaProvider.notifier).state -= tier.cost;

    final lootBox = LootBox(tier: tier);
    final reward = lootBox.openBox();

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

  Widget _buildInventoryTab() {
    final inventory = ref.watch(inventoryProvider);
    final equipped = ref.watch(equippedAccessoriesProvider);

    if (inventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📦',
              style: TextStyle(
                fontSize: 80,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Inventário vazio',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Compre caixas para conseguir acessórios!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    final inventoryItems = inventory.entries.toList();
    inventoryItems.sort((a, b) {
      final accessoryA =
          allAccessories.firstWhere((acc) => acc.id == a.key);
      final accessoryB =
          allAccessories.firstWhere((acc) => acc.id == b.key);
      return accessoryB.rarity.value.compareTo(accessoryA.rarity.value);
    });

    return Column(
      children: [
        if (equipped.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withAlpha(100)),
            ),
            child: Column(
              children: [
                const Text(
                  'Equipados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: equipped.map((id) {
                    final accessory =
                        allAccessories.firstWhere((acc) => acc.id == id);
                    return Text(
                      accessory.emoji,
                      style: const TextStyle(fontSize: 32),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),
                Text(
                  '${equipped.length}/8 slots usados',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inventoryItems.length,
            itemBuilder: (context, index) {
              final entry = inventoryItems[index];
              final accessory =
                  allAccessories.firstWhere((acc) => acc.id == entry.key);
              final count = entry.value;
              final isEquipped = equipped.contains(accessory.id);

              return _buildInventoryItem(accessory, count, isEquipped);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryItem(
    CakeAccessory accessory,
    int count,
    bool isEquipped,
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
        leading: Text(
          accessory.emoji,
          style: const TextStyle(fontSize: 40),
        ),
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
              'Quantidade: $count',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
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
            if (isEquipped) {
              ref.read(accessoryNotifierProvider).unequipAccessory(
                    accessory.id,
                  );
              ref.read(saveNotifierProvider.notifier).saveImmediate();
            } else {
              final equipped = ref.read(equippedAccessoriesProvider);
              if (equipped.length >= 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Máximo de 8 acessórios equipados'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              ref.read(accessoryNotifierProvider).equipAccessory(
                    accessory.id,
                  );
              ref.read(saveNotifierProvider.notifier).saveImmediate();
            }
          },
        ),
      ),
    );
  }
}

