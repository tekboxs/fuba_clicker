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
import 'package:fuba_clicker/app/providers/rebirth_provider.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/modules/shop/components/loot_box_opening.dart';
import 'package:fuba_clicker/app/modules/shop/components/loot_box_card.dart';
import 'package:fuba_clicker/app/modules/shop/components/inventory_tab.dart';
import 'package:fuba_clicker/app/modules/shop/components/shop_tutorial.dart';
import 'package:fuba_clicker/app/services/save_service.dart';

class LootBoxShopPage extends ConsumerStatefulWidget {
  const LootBoxShopPage({super.key});

  @override
  ConsumerState<LootBoxShopPage> createState() => _LootBoxShopPageState();
}

class _LootBoxShopPageState extends ConsumerState<LootBoxShopPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showTutorial = false;
  bool _tutorialChecked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final completed = await SaveService().hasCompletedShopTutorial();
    if (!completed && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showTutorialDialog();
      }
    }
    setState(() {
      _tutorialChecked = true;
    });
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D23),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.cyan.withOpacity(0.5),
            width: 2,
          ),
        ),
        title: const Text(
          'Bem-vindo à Loja!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Deseja fazer um tutorial rápido para aprender a usar a loja?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SaveService().setShopTutorialCompleted(true);
            },
            child: const Text(
              'Pular',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _showTutorial = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'Fazer Tutorial',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _completeTutorial() {
    setState(() {
      _showTutorial = false;
    });
    SaveService().setShopTutorialCompleted(true);
  }

  void _skipTutorial() {
    setState(() {
      _showTutorial = false;
    });
    SaveService().setShopTutorialCompleted(true);
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
    if (!_tutorialChecked) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
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
        ),
        if (_showTutorial)
          ShopTutorial(
            onComplete: _completeTutorial,
            onSkip: _skipTutorial,
          ),
      ],
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
                  key: index == 0
                      ? const ValueKey('loot_box_card')
                      : null,
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
    if (tier.usesCelestialTokens()) {
      final rebirthData = ref.read(rebirthDataProvider);
      final tokensCost = tier.getCelestialTokensCost();
      if (rebirthData.celestialTokens < tokensCost) return;

      ref.read(rebirthDataProvider.notifier).state = rebirthData.copyWith(
        celestialTokens: rebirthData.celestialTokens - tokensCost,
      );
    } else if (tier.usesGenerators()) {
      final generators = ref.read(generatorsProvider);
      final generatorIndex = tier.getGeneratorIndex();
      final generatorCost = tier.getGeneratorCost();
      
      if (generatorIndex < 0 || 
          generatorIndex >= generators.length || 
          generators[generatorIndex] < generatorCost) return;

      final newGenerators = List<int>.from(generators);
      while (newGenerators.length <= generatorIndex) {
        newGenerators.add(0);
      }
      newGenerators[generatorIndex] -= generatorCost;
      ref.read(generatorsProvider.notifier).state = newGenerators;
    } else {
      final fuba = ref.read(fubaProvider);
      final tierCost = tier.getCost(fuba);
      if (fuba.compareTo(tierCost) < 0) return;

      ref.read(fubaProvider.notifier).state -= tierCost;
    }

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
    if (tier.usesCelestialTokens()) {
      final rebirthData = ref.read(rebirthDataProvider);
      final tokensCost = tier.getCelestialTokensCost() * quantity;
      if (rebirthData.celestialTokens < tokensCost) return;

      ref.read(rebirthDataProvider.notifier).state = rebirthData.copyWith(
        celestialTokens: rebirthData.celestialTokens - tokensCost,
      );
    } else if (tier.usesGenerators()) {
      final generators = ref.read(generatorsProvider);
      final generatorIndex = tier.getGeneratorIndex();
      final generatorCost = tier.getGeneratorCost() * quantity;
      
      if (generatorIndex < 0 || 
          generatorIndex >= generators.length || 
          generators[generatorIndex] < generatorCost) return;

      final newGenerators = List<int>.from(generators);
      while (newGenerators.length <= generatorIndex) {
        newGenerators.add(0);
      }
      newGenerators[generatorIndex] -= generatorCost;
      ref.read(generatorsProvider.notifier).state = newGenerators;
    } else {
      final fuba = ref.read(fubaProvider);
      final tierCost = tier.getCost(fuba);

      final totalCost = EfficientNumber.parse(
        (tierCost * EfficientNumber.parse(quantity.toString())).toString(),
      );

      if (fuba.compareTo(totalCost) < 0) return;

      ref.read(fubaProvider.notifier).state -= totalCost;
    }

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
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _entranceController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF18181B).withOpacity(0.95),
                        const Color(0xFF27272A).withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                      const BoxShadow(
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
                          pulseController: widget.currentIndex != 1
                              ? _pulseController
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
  final AnimationController? pulseController;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedGradient,
    required this.selectedShadowColor,
    required this.onTap,
    this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? selectedGradient : null,
          color: isSelected
              ? null
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
          border: isSelected
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
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
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
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
                ] else ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
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

    if (pulseController != null && !isSelected) {
      return AnimatedBuilder(
        animation: pulseController!,
        builder: (context, child) {
          final pulseValue = pulseController!.value;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.3 * (1 - pulseValue)),
                  blurRadius: 20 + (10 * pulseValue),
                  spreadRadius: 2 + (3 * pulseValue),
                ),
              ],
            ),
            child: child,
          );
        },
        child: button,
      );
    }

    return button;
  }
}
