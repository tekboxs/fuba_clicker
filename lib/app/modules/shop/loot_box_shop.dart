import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fuba_clicker/app/models/loot_box.dart';
import 'package:fuba_clicker/app/models/cake_accessory.dart';
import 'package:fuba_clicker/app/providers/game_providers.dart';
import 'package:fuba_clicker/app/providers/accessory_provider.dart';
import 'package:fuba_clicker/app/providers/achievement_provider.dart';
import 'package:fuba_clicker/app/providers/save_provider.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/core/utils/difficulty_barriers.dart';
import 'package:fuba_clicker/app/models/fuba_generator.dart';
import 'package:fuba_clicker/app/modules/shop/components/loot_box_opening.dart';

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

  double _getMainAxisExtent(double screenHeight, bool isMobile) {
    if (screenHeight < 500) {
      return isMobile ? 280 : 320;
    } else if (screenHeight < 600) {
      return isMobile ? 320 : 360;
    } else if (screenHeight < 700) {
      return isMobile ? 360 : 400;
    } else if (screenHeight < 800) {
      return isMobile ? 400 : 450;
    } else {
      return isMobile ? 420 : 480;
    }
  }

  double _getInventoryAspectRatio(double screenHeight, bool isMobile) {
    if (screenHeight < 500) {
      return isMobile ? 3.5 : 4.0;
    } else if (screenHeight < 600) {
      return isMobile ? 3.0 : 3.5;
    } else if (screenHeight < 700) {
      return isMobile ? 2.8 : 3.2;
    } else if (screenHeight < 800) {
      return isMobile ? 2.6 : 3.0;
    } else {
      return isMobile ? 2.4 : 2.8;
    }
  }

  bool _isLootBoxTierUnlocked(
    LootBoxTier tier,
    BigDecimal fuba,
    List<int> generatorsOwned,
  ) {
    final barriers = DifficultyBarrierManager.getBarriersForCategory('lootbox');

    switch (tier) {
      case LootBoxTier.basic:
        return true;
      case LootBoxTier.advanced:
        return barriers[1].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.premium:
        return barriers[2].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.ultimate:
        return barriers[3].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.divine:
        return barriers[4].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.transcendent:
        return barriers[5].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.primordial:
        return barriers[6].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.cosmic:
        return barriers[7].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.infinite:
        return barriers[8].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.reality:
        return barriers[9].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.omniversal:
        return barriers[10].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.tek:
        return barriers[11].isUnlocked(fuba, generatorsOwned);
      case LootBoxTier.absolute:
        return barriers[12].isUnlocked(fuba, generatorsOwned);
    }
  }

  DifficultyBarrier? _getBarrierForTier(LootBoxTier tier) {
    final barriers = DifficultyBarrierManager.getBarriersForCategory('lootbox');

    switch (tier) {
      case LootBoxTier.basic:
        return null;
      case LootBoxTier.advanced:
        return barriers[1];
      case LootBoxTier.premium:
        return barriers[2];
      case LootBoxTier.ultimate:
        return barriers[3];
      case LootBoxTier.divine:
        return barriers[4];
      case LootBoxTier.transcendent:
        return barriers[5];
      case LootBoxTier.primordial:
        return barriers[6];
      case LootBoxTier.cosmic:
        return barriers[7];
      case LootBoxTier.infinite:
        return barriers[8];
      case LootBoxTier.reality:
        return barriers[9];
      case LootBoxTier.omniversal:
        return barriers[10];
      case LootBoxTier.tek:
        return barriers[11];
      case LootBoxTier.absolute:
        return barriers[12];
    }
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
    final screenHeight = MediaQuery.of(context).size.height;

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
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisExtent: _getMainAxisExtent(screenHeight, isMobile),
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

  Widget _buildLootBoxCard(LootBoxTier tier, BigDecimal fuba) {
    final generatorsOwned = ref.watch(generatorsProvider);
    final isUnlocked = _isLootBoxTierUnlocked(tier, fuba, generatorsOwned);
    final tierCost = tier.getCost(fuba);
    final canAfford = isUnlocked && fuba.compareTo(tierCost) >= 0;
    final canAfford5 =
        isUnlocked && fuba.compareTo(tierCost * BigDecimal.parse('5')) >= 0;
    final canAfford10 =
        isUnlocked && fuba.compareTo(tierCost * BigDecimal.parse('10')) >= 0;
    final canAfford30 =
        isUnlocked && fuba.compareTo(tierCost * BigDecimal.parse('30')) >= 0;
    final isMobile = GameConstants.isMobile(context);

    final barrier = _getBarrierForTier(tier);
    final isLocked = !isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: tier.color.withAlpha(isLocked ? 10 : 30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tier.color.withAlpha(
            canAfford
                ? 150
                : isLocked
                ? 30
                : 50,
          ),
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(tier.emoji, style: TextStyle(fontSize: isMobile ? 64 : 80))
                    .animate(
                      autoPlay: canAfford,
                      onComplete: (controller) => controller.repeat(),
                    )
                    .shimmer(
                      duration: 2.seconds,
                      color: tier.color.withAlpha(100),
                    ),
                if (isLocked)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: isMobile ? 32 : 40,
                    ),
                  ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              tier.displayName,
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: isLocked
                    ? Colors.grey
                    : (canAfford ? tier.color : Colors.grey),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 8 : 12),
            if (isLocked && barrier != null) ...[
              Text(
                '🔒 ${barrier.description}',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 8 : 12),
              _buildBarrierProgress(barrier, fuba, generatorsOwned, isMobile),
            ] else ...[
              Text(
                tier.description,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: canAfford ? Colors.white70 : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: isMobile ? 12 : 16),
            if (isLocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withAlpha(100)),
                ),
                child: Text(
                  'BLOQUEADO',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              )
            else
              _buildPurchaseButtons(
                tier,
                fuba,
                tierCost,
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
    BigDecimal fuba,
    BigDecimal tierCost,
    bool canAfford,
    bool canAfford5,
    bool canAfford10,
    bool canAfford30,
    bool isMobile,
  ) {
    return Column(
      children: [
        _buildSinglePurchaseButton(tier, fuba, tierCost, canAfford, isMobile),
        SizedBox(height: isMobile ? 8 : 12),
        Row(
          children: [
            Expanded(
              child: _buildBulkPurchaseButton(
                tier,
                5,
                tierCost,
                canAfford5,
                isMobile,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: _buildBulkPurchaseButton(
                tier,
                10,
                tierCost,
                canAfford10,
                isMobile,
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: _buildBulkPurchaseButton(
                tier,
                30,
                tierCost,
                canAfford30,
                isMobile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSinglePurchaseButton(
    LootBoxTier tier,
    BigDecimal fuba,
    BigDecimal tierCost,
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
                GameConstants.formatNumber(tierCost),
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
    BigDecimal tierCost,
    bool canAfford,
    bool isMobile,
  ) {
    final totalCost = tierCost * BigDecimal.parse(quantity.toString());
    const discount = 0;
    final discountedCost =
        totalCost * BigDecimal.parse((1 - discount).toString());

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

  Widget _buildBarrierProgress(
    DifficultyBarrier barrier,
    BigDecimal fuba,
    List<int> generatorsOwned,
    bool isMobile,
  ) {
    double progress = barrier.getProgress(BigDecimal.zero, generatorsOwned);
    progress -= 0.5;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withAlpha(100)),
          ),
          child: Column(
            children: [
              Text(
                'Requisitos:',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (barrier.requiredGeneratorTier < generatorsOwned.length)
                Text(
                  '${availableGenerators[barrier.requiredGeneratorTier].emoji} ${barrier.requiredGeneratorCount}x ${availableGenerators[barrier.requiredGeneratorTier].name}',
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 11,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress * 2,
            minHeight: 12,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${((progress * 2) * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  void _openLootBox(LootBoxTier tier) {
    final fuba = ref.read(fubaProvider);
    final tierCost = tier.getCost(fuba);
    if (fuba.compareTo(tierCost) < 0) return;

    ref.read(fubaProvider.notifier).state -= tierCost;

    final lootBox = LootBox(tier: tier);
    final reward = lootBox.openBox();

    ref
        .read(achievementNotifierProvider)
        .incrementStat('lootboxes_opened', 1, context);

    if (reward.rarity == AccessoryRarity.legendary) {
      ref
          .read(achievementNotifierProvider)
          .incrementStat('legendary_count', 1, context);
    } else if (reward.rarity == AccessoryRarity.mythical) {
      ref
          .read(achievementNotifierProvider)
          .incrementStat('mythical_count', 1, context);
    } else if (reward.rarity == AccessoryRarity.primordial) {
      ref
          .read(achievementNotifierProvider)
          .incrementStat('primordial_count', 1, context);
    } else if (reward.rarity == AccessoryRarity.cosmic) {
      ref
          .read(achievementNotifierProvider)
          .incrementStat('cosmic_count', 1, context);
    } else if (reward.rarity == AccessoryRarity.infinite) {
      ref
          .read(achievementNotifierProvider)
          .incrementStat('infinite_count', 1, context);
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
    final tierCost = tier.getCost(fuba);

    final totalCost = BigDecimal.parse(
      (tierCost * BigDecimal.parse(quantity.toString())).toString(),
    );

    if (fuba.compareTo(totalCost) < 0) return;

    ref.read(fubaProvider.notifier).state -= totalCost;

    final rewards = <CakeAccessory>[];
    for (int i = 0; i < quantity; i++) {
      final lootBox = LootBox(tier: tier);
      final reward = lootBox.openBox();
      rewards.add(reward);
    }

    ref
        .read(achievementNotifierProvider)
        .incrementStat('lootboxes_opened', quantity.toDouble(), context);

    for (final reward in rewards) {
      if (reward.rarity == AccessoryRarity.legendary) {
        ref
            .read(achievementNotifierProvider)
            .incrementStat('legendary_count', 1, context);
      } else if (reward.rarity == AccessoryRarity.mythical) {
        ref
            .read(achievementNotifierProvider)
            .incrementStat('mythical_count', 1, context);
      } else if (reward.rarity == AccessoryRarity.primordial) {
        ref
            .read(achievementNotifierProvider)
            .incrementStat('primordial_count', 1, context);
      } else if (reward.rarity == AccessoryRarity.cosmic) {
        ref
            .read(achievementNotifierProvider)
            .incrementStat('cosmic_count', 1, context);
      } else if (reward.rarity == AccessoryRarity.infinite) {
        ref
            .read(achievementNotifierProvider)
            .incrementStat('infinite_count', 1, context);
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
                  '${equipped.length}/$maxCapacity slots usados',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 12),
                ElevatedButton.icon(
                  onPressed: () {
                    _unequipAllAccessories(ref);
                  },
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  label: const Text(
                    'Desequipar Todos',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withAlpha(30),
                    side: BorderSide(color: Colors.red.withAlpha(100)),
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
    final canEquip = ref
        .watch(accessoryNotifierProvider)
        .canEquip(accessory.id);
    final maxCapacity = ref.watch(accessoryCapacityProvider);
    final equipped = ref.watch(equippedAccessoriesProvider);

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
            Text(
              'Slots: ${equipped.length}/$maxCapacity',
              style: TextStyle(fontSize: 11, color: Colors.blue.shade300),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (equippedCount > 0)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  final notifier = ref.read(accessoryNotifierProvider);
                  notifier.unequipAccessory(accessory.id);
                  final newEquipped = ref.read(equippedAccessoriesProvider);
                  ref
                      .read(achievementNotifierProvider)
                      .updateStat(
                        'equipped_count',
                        newEquipped.length.toDouble(),
                        context,
                      );
                  ref.read(saveNotifierProvider.notifier).saveImmediate();
                },
              ),
            IconButton(
              icon: Icon(
                isEquipped ? Icons.add_circle : Icons.circle_outlined,
                color: canEquip ? Colors.green : Colors.grey,
              ),
              onPressed: canEquip
                  ? () {
                      final notifier = ref.read(accessoryNotifierProvider);
                      notifier.equipAccessory(accessory.id);
                      final newEquipped = ref.read(equippedAccessoriesProvider);
                      ref
                          .read(achievementNotifierProvider)
                          .updateStat(
                            'equipped_count',
                            newEquipped.length.toDouble(),
                            context,
                          );
                      ref.read(saveNotifierProvider.notifier).saveImmediate();
                    }
                  : null,
            ),
          ],
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
    final canEquip = ref
        .watch(accessoryNotifierProvider)
        .canEquip(accessory.id);
    // 1    final maxCapacity = ref.watch(accessoryCapacityProvider);
    //     final equipped = ref.watch(equippedAccessoriesProvider);

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
          onTap: canEquip
              ? () {
                  final notifier = ref.read(accessoryNotifierProvider);
                  notifier.equipAccessory(accessory.id);
                  final newEquipped = ref.read(equippedAccessoriesProvider);
                  ref
                      .read(achievementNotifierProvider)
                      .updateStat(
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
                          final notifier = ref.read(accessoryNotifierProvider);
                          notifier.unequipAccessory(accessory.id);
                          final newEquipped = ref.read(
                            equippedAccessoriesProvider,
                          );
                          ref
                              .read(achievementNotifierProvider)
                              .updateStat(
                                'equipped_count',
                                newEquipped.length.toDouble(),
                                context,
                              );
                          ref
                              .read(saveNotifierProvider.notifier)
                              .saveImmediate();
                        },
                      ),
                    Icon(
                      isEquipped ? Icons.add_circle : Icons.circle_outlined,
                      color: isEquipped ? Colors.green : Colors.grey,
                      size: 32,
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

  void _unequipAllAccessories(WidgetRef ref) {
    final equipped = ref.read(equippedAccessoriesProvider);
    if (equipped.isEmpty) return;

    // Remove todos os acessórios equipados
    ref.read(equippedAccessoriesProvider.notifier).state = [];

    // Atualiza estatísticas
    ref
        .read(achievementNotifierProvider)
        .updateStat('equipped_count', 0.0, context);

    // Salva o estado
    ref.read(saveNotifierProvider.notifier).saveImmediate();

    // Mostra feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todos os acessórios foram desequipados!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
