import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/core/utils/efficient_number.dart';
import 'package:fuba_clicker/app/models/rebirth_data.dart';
import 'package:fuba_clicker/app/providers/rebirth_provider.dart';
import 'package:fuba_clicker/app/providers/game_providers.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/core/utils/difficulty_barriers.dart';
import 'components/rebirth_banner_card.dart';

class RebirthPage extends ConsumerWidget {
  const RebirthPage({super.key});

  bool _isRebirthTierUnlocked(
    RebirthTier tier,
    EfficientNumber fuba,
    List<int> generatorsOwned,
  ) {
    final barriers = DifficultyBarrierManager.getBarriersForCategory('rebirth');

    switch (tier) {
      case RebirthTier.rebirth:
        return barriers[0].isUnlocked(fuba, generatorsOwned);
      case RebirthTier.ascension:
        return barriers[1].isUnlocked(fuba, generatorsOwned);
      case RebirthTier.transcendence:
        return barriers[2].isUnlocked(fuba, generatorsOwned);
    }
  }

  DifficultyBarrier? _getBarrierForTier(RebirthTier tier) {
    final barriers = DifficultyBarrierManager.getBarriersForCategory('rebirth');

    switch (tier) {
      case RebirthTier.rebirth:
        return barriers[0];
      case RebirthTier.ascension:
        return barriers[1];
      case RebirthTier.transcendence:
        return barriers[2];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rebirth'),
        backgroundColor: Colors.black.withAlpha(200),
        actions: kDebugMode
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.bug_report,
                    color: Colors.white,
                  ),
                  tooltip: 'Debug Tools',
                  onPressed: () => _showDebugDialog(context, ref),
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900.withAlpha(200), Colors.black],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRebirthInfo(ref),
                const SizedBox(height: 24),
                _buildRebirthCard(context, ref, RebirthTier.rebirth),
                const SizedBox(height: 16),
                _buildRebirthCard(context, ref, RebirthTier.ascension),
                const SizedBox(height: 16),
                _buildRebirthCard(context, ref, RebirthTier.transcendence),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRebirthInfo(WidgetRef ref) {
    final rebirthData = ref.watch(rebirthDataProvider);
    final multiplier = rebirthData.getTotalMultiplier();

    return Card(
      color: Colors.black.withAlpha(150),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Multiplicador Total',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'x${GameConstants.formatNumber(multiplier)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip('🔄 ${rebirthData.rebirthCount}', 'Rebirths'),
                _buildStatChip('✨ ${rebirthData.ascensionCount}', 'Ascensões'),
                _buildStatChip(
                  '🌟 ${rebirthData.transcendenceCount}',
                  'Transcendências',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.cyan.withAlpha(50),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyan.withAlpha(100)),
              ),
              child: Text(
                '💎 ${rebirthData.celestialTokens} Tokens Celestiais',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildRebirthCard(
    BuildContext context,
    WidgetRef ref,
    RebirthTier tier,
  ) {
    final rebirthData = ref.watch(rebirthDataProvider);
    final canRebirth = ref.watch(canRebirthProvider(tier));
    final fuba = ref.watch(fubaProvider);
    final generatorsOwned = ref.watch(generatorsProvider);

    final int currentCount;
    switch (tier) {
      case RebirthTier.rebirth:
        currentCount = rebirthData.rebirthCount;
        break;
      case RebirthTier.ascension:
        currentCount = rebirthData.ascensionCount;
        break;
      case RebirthTier.transcendence:
        currentCount = rebirthData.transcendenceCount;
        break;
    }

    final requirement = tier.getRequirement(currentCount);
    final multiplierGain = tier.getMultiplierGain(currentCount);
    final tokenReward = tier.getTokenReward(currentCount);

    final isUnlocked = _isRebirthTierUnlocked(tier, fuba, generatorsOwned);
    double progress;

    // Otimização: usa SuffixNumber para comparações eficientes com números muito grandes
    if (requirement > 1e50) {
      // Para requisitos astronômicos, usa comparação de SuffixNumber
      final fubaSuffix = SuffixNumber.fromEfficientNumber(fuba);
      final requirementSuffix =
          SuffixNumber.fromEfficientNumber(EfficientNumber.parse(requirement.toString()));
      progress = fubaSuffix.isGreaterOrEqual(requirementSuffix) ? 1.0 : 0.0;
    } else {
      try {
        final requirementNumber = EfficientNumber.parse(requirement.toString());
        final result = fuba / requirementNumber;
        progress = result.toDouble().clamp(0.0, 1.0);
      } catch (e) {
        // Se houver erro na divisão, usa comparação de SuffixNumber
        final fubaSuffix = SuffixNumber.fromEfficientNumber(fuba);
        final requirementSuffix = SuffixNumber.fromEfficientNumber(
            EfficientNumber.parse(requirement.toString()));
        progress = fubaSuffix.isGreaterOrEqual(requirementSuffix) ? 1.0 : 0.0;
      }
    }

    final barrier = _getBarrierForTier(tier);
    final isLocked = !isUnlocked;

    final title = tier.displayName;
    final requirementText = GameConstants.formatNumber(
      EfficientNumber.fromDouble(requirement),
    );
    String subtitle;
    if (isLocked && barrier != null) {
      final neededGen = barrier.requiredGeneratorCount;
      final tierIdx = barrier.requiredGeneratorTier + 1;
      final ownedGen = tierIdx - 1 < generatorsOwned.length
          ? generatorsOwned[tierIdx - 1]
          : 0;
      subtitle = '🔒 ${barrier.description}\nReq: $requirementText fubá • G$tierIdx: $ownedGen/$neededGen';
    } else {
      subtitle = '${tier.description} • Req: $requirementText fubá';
    }
    final tokenText = tokenReward > 0 ? '+$tokenReward 💎' : null;
    return RebirthBannerCard(
      title: title,
      subtitle: subtitle,
      emoji: tier.emoji,
      progress: progress,
      isLocked: isLocked,
      canActivate: canRebirth,
      lockedReason: isLocked && barrier != null ? 'Requisitos' : null,
      rewardMultiplierText: 'x${multiplierGain.toStringAsFixed(1)}',
      rewardTokenText: tokenText,
      onTap: () => _showRebirthSelector(context, ref, tier),
      colors: _getTierGradient(tier),
    );
  }

  Color _getTierColor(RebirthTier tier) {
    switch (tier) {
      case RebirthTier.rebirth:
        return Colors.blue;
      case RebirthTier.ascension:
        return Colors.purple;
      case RebirthTier.transcendence:
        return Colors.amber;
    }
  }

  List<Color> _getTierGradient(RebirthTier tier) {
    switch (tier) {
      case RebirthTier.rebirth:
        return [const Color(0xFF1E3A8A), const Color(0xFF2563EB)];
      case RebirthTier.ascension:
        return [const Color(0xFF4C1D95), const Color(0xFF7C3AED)];
      case RebirthTier.transcendence:
        return [const Color(0xFF92400E), const Color(0xFFF59E0B)];
    }
  }

  void _showRebirthConfirmation(
    BuildContext context,
    WidgetRef ref,
    RebirthTier tier,
    int count,
  ) {
    final rebirthData = ref.read(rebirthDataProvider);
    final int currentCount;
    switch (tier) {
      case RebirthTier.rebirth:
        currentCount = rebirthData.rebirthCount;
        break;
      case RebirthTier.ascension:
        currentCount = rebirthData.ascensionCount;
        break;
      case RebirthTier.transcendence:
        currentCount = rebirthData.transcendenceCount;
        break;
    }

    int totalTokenReward = 0;
    double totalMultiplierGain = 0;
    for (int i = 0; i < count; i++) {
      final reward = tier.getTokenReward(currentCount + i);
      if (reward.isFinite && !reward.isNaN && reward >= 0) {
        totalTokenReward += reward.clamp(0, 1e6).toInt();
      }
      final multiplier = tier.getMultiplierGain(currentCount + i);
      if (multiplier.isFinite && !multiplier.isNaN) {
        totalMultiplierGain += multiplier;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Row(
          children: [
            Text(tier.emoji),
            const SizedBox(width: 8),
            Text('${tier.displayName} x$count'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tier.description),
            const SizedBox(height: 16),
            const Text(
              'Você perderá:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Text('• Todo o fubá'),
            const Text('• Todos os geradores'),
            if (tier != RebirthTier.rebirth) ...[
              const Text('• Todos os acessórios'),
              const Text('• Todo o inventário'),
            ],
            const SizedBox(height: 16),
            const Text(
              'Você ganhará:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• x${totalMultiplierGain.toStringAsFixed(1)} multiplicador permanente',
            ),
            if (totalTokenReward > 0)
              Text('• $totalTokenReward tokens celestiais'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (count == 1) {
                ref.read(rebirthNotifierProvider).performRebirth(tier);
              } else {
                ref
                    .read(rebirthNotifierProvider)
                    .performMultipleRebirth(tier, count);
              }
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${tier.displayName} x$count realizado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getTierColor(tier),
            ),
            child: Text('Confirmar x$count'),
          ),
        ],
      ),
    );
  }

  void _showRebirthSelector(
    BuildContext context,
    WidgetRef ref,
    RebirthTier tier,
  ) {
    final rebirthData = ref.read(rebirthDataProvider);
    final fuba = ref.read(fubaProvider);
    final maxCount = calculateMaxOperations(tier, fuba, rebirthData);
    final int currentCount;
    switch (tier) {
      case RebirthTier.rebirth:
        currentCount = rebirthData.rebirthCount;
        break;
      case RebirthTier.ascension:
        currentCount = rebirthData.ascensionCount;
        break;
      case RebirthTier.transcendence:
        currentCount = rebirthData.transcendenceCount;
        break;
    }
    final requirement = tier.getRequirement(currentCount);
    final requirementText = GameConstants.formatNumber(
      EfficientNumber.fromDouble(requirement),
    );
    final barrier = _getBarrierForTier(tier);
    final generatorsOwned = ref.read(generatorsProvider);
    String? genReqText;
    if (barrier != null) {
      final neededGen = barrier.requiredGeneratorCount;
      final tierIdx = barrier.requiredGeneratorTier + 1;
      final ownedGen = tierIdx - 1 < generatorsOwned.length
          ? generatorsOwned[tierIdx - 1]
          : 0;
      genReqText = 'G$tierIdx: $ownedGen/$neededGen';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Row(
          children: [
            Text(tier.emoji),
            const SizedBox(width: 8),
            Text(tier.displayName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Requisito atual: $requirementText fubá'),
            if (genReqText != null) ...[
              const SizedBox(height: 6),
              Text('Geradores: $genReqText'),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _qtyButton(context, ref, tier, 1),
                _qtyButton(context, ref, tier, 5, maxCount: maxCount),
                _qtyButton(context, ref, tier, 10, maxCount: maxCount),
                _qtyButton(context, ref, tier, maxCount.clamp(1, 9999),
                    label: 'Max'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(
    BuildContext context,
    WidgetRef ref,
    RebirthTier tier,
    int count, {
    int? maxCount,
    String? label,
  }) {
    final effective = maxCount == null ? count : (count > maxCount ? maxCount : count);
    final disabled = effective <= 0;
    return ElevatedButton(
      onPressed: disabled
          ? null
          : () {
              Navigator.pop(context);
              _showRebirthConfirmation(context, ref, tier, effective);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: _getTierColor(tier),
      ),
      child: Text(label ?? 'x$effective'),
    );
  }

  void _showDebugDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, child) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.red),
              SizedBox(width: 8),
              Text('Debug Tools'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ADICIONAR REBIRTHS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 16),
              _buildDebugButton(
                dialogContext,
                ref,
                'Rebirth',
                RebirthTier.rebirth,
              ),
              const SizedBox(height: 8),
              _buildDebugButton(
                dialogContext,
                ref,
                'Ascensão',
                RebirthTier.ascension,
              ),
              const SizedBox(height: 8),
              _buildDebugButton(
                dialogContext,
                ref,
                'Transcendência',
                RebirthTier.transcendence,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    RebirthTier tier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Row(
          children: [
            IconButton(
              onPressed: () {
                ref.read(rebirthNotifierProvider).addDebugRebirth(tier, 1);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('+1 $label adicionado'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.green,
              tooltip: 'Adicionar 1',
            ),
            IconButton(
              onPressed: () {
                ref.read(rebirthNotifierProvider).addDebugRebirth(tier, 10);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('+10 $label adicionados'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.add_circle),
              color: Colors.green,
              tooltip: 'Adicionar 10',
            ),
            IconButton(
              onPressed: () {
                ref.read(rebirthNotifierProvider).addDebugRebirth(tier, 100);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('+100 $label adicionados'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_rounded),
              color: Colors.green,
              tooltip: 'Adicionar 100',
            ),
          ],
        ),
      ],
    );
  }
}
