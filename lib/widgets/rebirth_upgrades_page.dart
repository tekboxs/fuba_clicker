import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../models/rebirth_upgrade.dart';
import '../providers/rebirth_upgrade_provider.dart';
import '../providers/rebirth_provider.dart';
import '../providers/game_providers.dart';
import '../utils/difficulty_barriers.dart';
import 'hexagonal_upgrade_card.dart';

class RebirthUpgradesPage extends ConsumerWidget {
  const RebirthUpgradesPage({super.key});

  bool _isUpgradeBarrierLocked(
    RebirthUpgrade upgrade,
    BigDecimal fuba,
    List<int> generatorsOwned,
  ) {
    final barriers = DifficultyBarrierManager.getBarriersForCategory('upgrade');

    // if (kDebugMode) return false;

    switch (upgrade.id) {
      case 'auto_clicker':
      case 'click_power':
        return !barriers[0].isUnlocked(fuba, generatorsOwned);
      case 'idle_boost':
      case 'lucky_boxes':
      case 'starting_fuba':
        return !barriers[1].isUnlocked(fuba, generatorsOwned);
      case 'generator_discount':
      case 'offline_production':
      case 'production_multiplier':
        return !barriers[2].isUnlocked(fuba, generatorsOwned);
      default:
        return false;
    }
  }

  DifficultyBarrier? _getBarrierForUpgrade(RebirthUpgrade upgrade) {
    final barriers = DifficultyBarrierManager.getBarriersForCategory('upgrade');

    switch (upgrade.id) {
      case 'auto_clicker':
      case 'click_power':
        return barriers[0];
      case 'idle_boost':
      case 'lucky_boxes':
      case 'starting_fuba':
        return barriers[1];
      case 'generator_discount':
      case 'offline_production':
      case 'production_multiplier':
        return barriers[2];
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rebirthData = ref.watch(rebirthDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrades Celestiais'),
        backgroundColor: Colors.black.withAlpha(200),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.cyan.shade900.withAlpha(200), Colors.black],
          ),
        ),
        child: Column(
          children: [
            _buildTokenDisplay(rebirthData.celestialTokens),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 350,
                  // childAspectRatio: 0.85,
                  // mainAxisSpacing: 20,
                  // crossAxisSpacing: 20,
                ),
                itemCount: allUpgrades.length,
                itemBuilder: (context, index) {
                  final upgrade = allUpgrades[index];
                  final fuba = ref.watch(fubaProvider);
                  final generatorsOwned = ref.watch(generatorsProvider);
                  final isBarrierLocked = _isUpgradeBarrierLocked(
                    upgrade,
                    fuba,
                    generatorsOwned,
                  );
                  final barrier = _getBarrierForUpgrade(upgrade);

                  return HexagonalUpgradeCard(
                    upgrade: upgrade,
                    rebirthData: rebirthData,
                    isBarrierLocked: isBarrierLocked,
                    barrier: barrier,
                    fuba: fuba,
                    generatorsOwned: generatorsOwned,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenDisplay(double tokens) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withAlpha(100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💎', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Text(
            '$tokens',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Tokens Celestiais',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
          ),
          if (kDebugMode)
            Row(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: () {
                        ref.read(rebirthDataProvider.notifier).state = ref
                            .read(rebirthDataProvider)
                            .copyWith(
                              celestialTokens:
                                  ref
                                      .read(rebirthDataProvider)
                                      .celestialTokens +
                                  1000.0,
                            );
                      },
                      child: Text('+1000 tokens'),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: () {
                        _unlockAllUpgrades(ref);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Desbloquear Todos'),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _unlockAllUpgrades(WidgetRef ref) {
    final upgradeNotifier = ref.read(upgradeNotifierProvider);
    final rebirthData = ref.read(rebirthDataProvider);

    // Adiciona tokens suficientes para comprar todos os upgrades
    ref.read(rebirthDataProvider.notifier).state = rebirthData.copyWith(
      celestialTokens: 999999.0,
      ascensionCount: 10, // Garante que todos os upgrades estejam desbloqueados
    );

    // Compra todos os upgrades até o nível máximo
    for (final upgrade in allUpgrades) {
      final currentLevel = upgradeNotifier.getUpgradeLevel(upgrade.id);
      for (int level = currentLevel; level < upgrade.maxLevel; level++) {
        if (upgradeNotifier.canPurchase(upgrade)) {
          upgradeNotifier.purchaseUpgrade(upgrade);
        }
      }
    }
  }
}
