import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../models/rebirth_data.dart';
import '../providers/rebirth_provider.dart';
import '../providers/game_providers.dart';
import '../utils/constants.dart';
import '../utils/difficulty_barriers.dart';
import '../models/fuba_generator.dart';

class RebirthPage extends ConsumerWidget {
  const RebirthPage({super.key});

  bool _isRebirthTierUnlocked(
    RebirthTier tier,
    BigDecimal fuba,
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
              'x${GameConstants.formatNumber(BigDecimal.parse(multiplier.toString()))}',
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

    final currentCount = switch (tier) {
      RebirthTier.rebirth => rebirthData.rebirthCount,
      RebirthTier.ascension => rebirthData.ascensionCount,
      RebirthTier.transcendence => rebirthData.transcendenceCount,
    };

    final requirement = tier.getRequirement(currentCount);
    final multiplierGain = tier.getMultiplierGain(currentCount);
    final tokenReward = tier.getTokenReward(currentCount);

    final isUnlocked = _isRebirthTierUnlocked(tier, fuba, generatorsOwned);
    final progress =
        (fuba
                .divide(
                  BigDecimal.parse(requirement.toString()),
                  scale: 10,
                  roundingMode: RoundingMode.HALF_UP,
                )
                .toDouble())
            .clamp(0.0, 1.0);

    final barrier = _getBarrierForTier(tier);
    final isLocked = !isUnlocked;

    return Card(
      color: isLocked
          ? Colors.grey.shade800.withAlpha(150)
          : (canRebirth
                ? _getTierColor(tier).withAlpha(100)
                : Colors.grey.shade900.withAlpha(150)),
      child: InkWell(
        onTap: isLocked
            ? null
            : (canRebirth
                  ? () => _showRebirthConfirmation(context, ref, tier, 1)
                  : null),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(tier.emoji, style: const TextStyle(fontSize: 32)),
                      if (isLocked)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(150),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.lock, color: Colors.grey, size: 20),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey : null,
                          ),
                        ),
                        if (isLocked && barrier != null) ...[
                          Text(
                            '🔒 ${barrier.description}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          Text(
                            tier.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLocked && barrier != null) ...[
                _buildBarrierProgress(barrier, fuba, generatorsOwned),
                const SizedBox(height: 12),
              ] else ...[
                _buildRequirementBar(requirement, progress),
                const SizedBox(height: 12),
              ],
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRewardChip(
                          'x${multiplierGain.toStringAsFixed(1)} Multiplicador',
                          Icons.trending_up,
                          Colors.orange,
                        ),
                        if (tokenReward > 0)
                          _buildRewardChip(
                            '+$tokenReward 💎',
                            Icons.star,
                            Colors.cyan,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMultipleOperationsButtons(context, ref, tier, fuba, rebirthData),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementBar(double requirement, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requisito: ${GameConstants.formatNumber(BigDecimal.parse(requirement.toString()))} fubá',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 20,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildRewardChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarrierProgress(
    DifficultyBarrier barrier,
    BigDecimal fuba,
    List<int> generatorsOwned,
  ) {
    final progress = barrier.getProgress(fuba, generatorsOwned);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '🌽 ${GameConstants.formatNumber(barrier.requiredFuba)} fubá',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
              if (barrier.requiredGeneratorTier < generatorsOwned.length)
                Text(
                  '${availableGenerators[barrier.requiredGeneratorTier].emoji} ${barrier.requiredGeneratorCount}x ${availableGenerators[barrier.requiredGeneratorTier].name}',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
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

  Widget _buildMultipleOperationsButtons(
    BuildContext context,
    WidgetRef ref,
    RebirthTier tier,
    BigDecimal fuba,
    RebirthData rebirthData,
  ) {
    final maxOperations = calculateMaxOperations(tier, fuba, rebirthData);
    
    if (maxOperations <= 1) return const SizedBox.shrink();
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showRebirthConfirmation(context, ref, tier, 1),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('1x'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _getTierColor(tier),
              side: BorderSide(color: _getTierColor(tier)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showRebirthConfirmation(context, ref, tier, maxOperations),
            icon: const Icon(Icons.all_inclusive, size: 16),
            label: Text('${maxOperations}x'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getTierColor(tier),
            ),
          ),
        ),
      ],
    );
  }

  void _showRebirthConfirmation(
    BuildContext context,
    WidgetRef ref,
    RebirthTier tier,
    int count,
  ) {
    final rebirthData = ref.read(rebirthDataProvider);
    final currentCount = switch (tier) {
      RebirthTier.rebirth => rebirthData.rebirthCount,
      RebirthTier.ascension => rebirthData.ascensionCount,
      RebirthTier.transcendence => rebirthData.transcendenceCount,
    };
    
    int totalTokenReward = 0;
    double totalMultiplierGain = 0;
    for (int i = 0; i < count; i++) {
      totalTokenReward += tier.getTokenReward(currentCount + i);
      totalMultiplierGain += tier.getMultiplierGain(currentCount + i);
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
            Text('• x${totalMultiplierGain.toStringAsFixed(1)} multiplicador permanente'),
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
                ref.read(rebirthNotifierProvider).performMultipleRebirth(tier, count);
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
}
