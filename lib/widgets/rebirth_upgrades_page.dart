import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/utils/constants.dart';
import '../models/rebirth_upgrade.dart';
import '../providers/rebirth_upgrade_provider.dart';
import '../providers/rebirth_provider.dart';

class RebirthUpgradesPage extends ConsumerWidget {
  const RebirthUpgradesPage({super.key});

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
            colors: [
              Colors.cyan.shade900.withAlpha(200),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildTokenDisplay(rebirthData.celestialTokens),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: GameConstants.isMobile(context) ? 0.75 : 1.2,
                ),
                itemCount: allUpgrades.length,
                itemBuilder: (context, index) {
                  final upgrade = allUpgrades[index];
                  return _buildUpgradeCard(context, ref, upgrade, rebirthData);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildTokenDisplay(int tokens) {
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
          const Text(
            '💎',
            style: TextStyle(fontSize: 32),
          ),
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(
    BuildContext context,
    WidgetRef ref,
    RebirthUpgrade upgrade,
    dynamic rebirthData,
  ) {
    final upgradeNotifier = ref.watch(upgradeNotifierProvider);
    final currentLevel = upgradeNotifier.getUpgradeLevel(upgrade.id);
    final canPurchase = upgradeNotifier.canPurchase(upgrade);
    final isMaxed = currentLevel >= upgrade.maxLevel;
    final isLocked = rebirthData.ascensionCount < upgrade.ascensionRequirement;
    final cost = upgrade.getTokenCost(currentLevel);

    return Card(
      color: isMaxed
          ? Colors.green.shade900.withAlpha(100)
          : isLocked
              ? Colors.grey.shade900.withAlpha(100)
              : canPurchase
                  ? Colors.cyan.shade900.withAlpha(150)
                  : Colors.grey.shade900.withAlpha(150),
      child: InkWell(
        onTap: canPurchase && !isMaxed && !isLocked
            ? () => _showPurchaseConfirmation(context, ref, upgrade)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    upgrade.emoji,
                    style: TextStyle(
                      fontSize: 32,
                      color: isLocked ? Colors.grey.shade700 : null,
                    ),
                  ),
                  const Spacer(),
                  if (!isLocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isMaxed
                            ? Colors.green.withAlpha(100)
                            : Colors.cyan.withAlpha(100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isMaxed ? 'MAX' : 'Lv.$currentLevel',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                upgrade.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey.shade600 : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                upgrade.description,
                style: TextStyle(
                  fontSize: 11,
                  color: isLocked ? Colors.grey.shade700 : Colors.grey.shade400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withAlpha(100)),
                  ),
                  child: Text(
                    'Requer ${upgrade.ascensionRequirement} Ascensões',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (!isMaxed) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withAlpha(100)),
                  ),
                  child: Text(
                    upgrade.getEffectDescription(currentLevel + 1),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: canPurchase
                        ? Colors.cyan.withAlpha(100)
                        : Colors.grey.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: canPurchase
                          ? Colors.cyan.withAlpha(150)
                          : Colors.grey.withAlpha(100),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '$cost',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: canPurchase ? Colors.cyan : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withAlpha(100)),
                  ),
                  child: Text(
                    upgrade.getEffectDescription(currentLevel),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseConfirmation(
    BuildContext context,
    WidgetRef ref,
    RebirthUpgrade upgrade,
  ) {
    final upgradeNotifier = ref.read(upgradeNotifierProvider);
    final currentLevel = upgradeNotifier.getUpgradeLevel(upgrade.id);
    final cost = upgrade.getTokenCost(currentLevel);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Row(
          children: [
            Text(upgrade.emoji),
            const SizedBox(width: 8),
            Text(upgrade.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(upgrade.description),
            const SizedBox(height: 16),
            Text(
              'Nível Atual: $currentLevel',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Próximo Nível: ${upgrade.getEffectDescription(currentLevel + 1)}',
              style: const TextStyle(color: Colors.lightBlue),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Custo: 💎 '),
                Text(
                  '$cost',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              upgradeNotifier.purchaseUpgrade(upgrade);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${upgrade.name} melhorado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
            ),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }
}

