import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/utils/efficient_number.dart';

import 'package:fuba_clicker/app/models/loot_box.dart';
import 'package:fuba_clicker/app/models/cake_accessory.dart';
import 'package:fuba_clicker/app/providers/game_providers.dart';
import 'package:fuba_clicker/app/providers/accessory_provider.dart';
import 'package:fuba_clicker/app/providers/achievement_provider.dart';
import 'package:fuba_clicker/app/providers/save_provider.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/modules/shop/components/loot_box_opening.dart';
import 'package:fuba_clicker/app/modules/shop/components/loot_box_card.dart';
import 'package:fuba_clicker/app/modules/shop/components/inventory_tab.dart';

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

  // double _getMainAxisExtent(double screenHeight, bool isMobile) {
  //   if (screenHeight < 500) {
  //     return isMobile ? 280 : 320;
  //   } else if (screenHeight < 600) {
  //     return isMobile ? 320 : 360;
  //   } else if (screenHeight < 700) {
  //     return isMobile ? 360 : 400;
  //   } else if (screenHeight < 800) {
  //     return isMobile ? 400 : 450;
  //   } else {
  //     return isMobile ? 420 : 480;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(240),
      appBar: AppBar(
        title: const Text('Loja de Acessórios'),
        backgroundColor: Colors.deepOrange.withAlpha(200),
      ),
      floatingActionButton: _FloatingNav(
        currentIndex: _tabController.index,
        onIndexChange: (index) {
          setState(() {
            _tabController.index = index;
          });
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildShopTab(), const LootBoxInventoryTab()],
      ),
    );
  }

  Widget _buildShopTab() {
    final fuba = ref.watch(fubaProvider);
    final isMobile = GameConstants.isMobile(context);
    // final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(GameConstants.getDefaultPadding(context)),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 250),
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: const Color(0xff231D1A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withAlpha(100),
                  blurRadius: 30,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: Colors.orange.withAlpha(50),
                  blurRadius: 50,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌽', style: TextStyle(fontSize: 45)),
                const SizedBox(width: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Fubás",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    Text(
                      GameConstants.formatNumber(fuba),
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisExtent: 450,
                // mainAxisExtent: _getMainAxisExtent(screenHeight, isMobile),
                crossAxisSpacing: isMobile ? 16 : 20,
                mainAxisSpacing: isMobile ? 16 : 20,
              ),
              itemCount: LootBoxTier.values.length,
              itemBuilder: (context, index) {
                final tier = LootBoxTier.values[index];
                final generatorsOwned = ref.watch(generatorsProvider);
                return LootBoxCard(
                  tier: tier,
                  fuba: fuba,
                  generatorsOwned: generatorsOwned,
                  isMobile: isMobile,
                  onOpenSingle: _openLootBox,
                  onOpenMultiple: _openMultipleLootBoxes,
                );
              },
            ),
          ),
        ],
      ),
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

    final totalCost = EfficientNumber.parse(
      (tierCost * EfficientNumber.parse(quantity.toString())).toString(),
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
}

class _FloatingNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChange;

  const _FloatingNav({
    required this.currentIndex,
    required this.onIndexChange,
  });

  @override
  State<_FloatingNav> createState() => _FloatingNavState();
}

class _FloatingNavState extends State<_FloatingNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF18181B).withOpacity(0.9),
              const Color(0xFF27272A).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 32,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavButton(
                icon: Icons.shopping_bag,
                label: 'Caixas',
                isSelected: widget.currentIndex == 0,
                selectedGradient: const LinearGradient(
                  colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                ),
                selectedShadowColor: Colors.orange.withOpacity(0.5),
                onTap: () => widget.onIndexChange(0),
              ),
              const SizedBox(width: 12),
              _NavButton(
                icon: Icons.inventory,
                label: 'Inventário',
                isSelected: widget.currentIndex == 1,
                selectedGradient: const LinearGradient(
                  colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                ),
                selectedShadowColor: Colors.cyan.withOpacity(0.5),
                onTap: () => widget.onIndexChange(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final LinearGradient selectedGradient;
  final Color selectedShadowColor;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedGradient,
    required this.selectedShadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? selectedGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedShadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: selectedGradient,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
