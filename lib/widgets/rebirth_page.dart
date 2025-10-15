import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rebirth_data.dart';
import '../providers/rebirth_provider.dart';
import '../providers/game_providers.dart';
import '../utils/constants.dart';

class RebirthPage extends ConsumerWidget {
  const RebirthPage({super.key});

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
            colors: [
              Colors.deepPurple.shade900.withAlpha(200),
              Colors.black,
            ],
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                _buildStatChip(
                  '🔄 ${rebirthData.rebirthCount}',
                  'Rebirths',
                ),
                _buildStatChip(
                  '✨ ${rebirthData.ascensionCount}',
                  'Ascensões',
                ),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
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

    final currentCount = switch (tier) {
      RebirthTier.rebirth => rebirthData.rebirthCount,
      RebirthTier.ascension => rebirthData.ascensionCount,
      RebirthTier.transcendence => rebirthData.transcendenceCount,
    };

    final requirement = tier.getRequirement(currentCount);
    final multiplierGain = tier.getMultiplierGain(currentCount);
    final tokenReward = tier.getTokenReward(currentCount);

    final progress = (fuba / requirement).clamp(0.0, 1.0);

    return Card(
      color: canRebirth
          ? _getTierColor(tier).withAlpha(100)
          : Colors.grey.shade900.withAlpha(150),
      child: InkWell(
        onTap: canRebirth
            ? () => _showRebirthConfirmation(context, ref, tier)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    tier.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tier.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRequirementBar(requirement, progress),
              const SizedBox(height: 12),
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
          'Requisito: ${GameConstants.formatNumber(requirement)} fubá',
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
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

  void _showRebirthConfirmation(
    BuildContext context,
    WidgetRef ref,
    RebirthTier tier,
  ) {
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
            Text(tier.description),
            const SizedBox(height: 16),
            const Text(
              'Você perderá:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
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
              '• x${tier.getMultiplierGain(0)} multiplicador permanente',
            ),
            if (tier.getTokenReward(0) > 0)
              Text(
                '• ${tier.getTokenReward(0)} tokens celestiais',
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
              ref.read(rebirthNotifierProvider).performRebirth(tier);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${tier.displayName} realizado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getTierColor(tier),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

