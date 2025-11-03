import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/core/utils/efficient_number.dart';
import 'package:fuba_clicker/app/models/rebirth_data.dart';
import 'package:fuba_clicker/app/providers/rebirth_provider.dart';
import 'package:fuba_clicker/app/providers/game_providers.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/core/utils/difficulty_barriers.dart';
import 'package:fuba_clicker/app/models/fuba_generator.dart';
import 'package:fuba_clicker/gen/assets.gen.dart';
import 'components/rebirth_banner_card.dart';
import 'package:fuba_clicker/app/providers/save_provider.dart';

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
      case RebirthTier.furuborus:
        return true;
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
      case RebirthTier.furuborus:
        return null;
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
          child: Column(
            children: [
              _buildRebirthInfo(ref),
              const SizedBox(height: 24),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final maxCrossAxisExtent = screenWidth > 1600
                        ? 600.0
                        : screenWidth > 1200
                            ? 550.0
                            : 700.0;
                    return GridView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: maxCrossAxisExtent,
                        mainAxisExtent: 200,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      children: [
                        _buildRebirthCard(context, ref, RebirthTier.rebirth),
                        _buildRebirthCard(context, ref, RebirthTier.ascension),
                        _buildRebirthCard(
                          context,
                          ref,
                          RebirthTier.transcendence,
                        ),
                        _buildRebirthCard(context, ref, RebirthTier.furuborus),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRebirthInfo(WidgetRef ref) {
    final rebirthData = ref.watch(rebirthDataProvider);
    final multiplier = rebirthData.getTotalMultiplier();

    return _NeonPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _GlowText(
            text: 'Multiplicador Total',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            glowColor: Colors.cyan,
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeInOut,
            builder: (context, t, _) {
              final glow = 0.3 + 0.3 * (1.0 - (t - 0.5).abs() * 2);
              return _GlowText(
                text: 'x${GameConstants.formatNumber(multiplier)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                glowColor: Colors.amber,
                glowOpacity: glow,
              );
            },
            onEnd: () {},
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _NeonChip(
                  leading: '🔄',
                  value: '${rebirthData.rebirthCount}',
                  label: 'Rebirths',
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NeonChip(
                  leading: '✨',
                  value: '${rebirthData.ascensionCount}',
                  label: 'Ascensões',
                  color: Colors.purpleAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NeonChip(
                  leading: '🌟',
                  value: '${rebirthData.transcendenceCount}',
                  label: 'Transcendências',
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _NeonChip(
                  leading: '🐉',
                  value: '${rebirthData.furuborusCount}',
                  label: 'Furuborus',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NeonChip(
                  leading: '💎',
                  value: rebirthData.forus.toStringAsFixed(0),
                  label: 'Forus',
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: _TokenPill(
              text: '💎 ${rebirthData.celestialTokens} Tokens Celestiais',
            ),
          ),
        ],
      ),
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
      case RebirthTier.furuborus:
        currentCount = rebirthData.furuborusCount;
        break;
    }

    final double requirement;
    final double multiplierGain;
    final double tokenReward;

    if (tier == RebirthTier.furuborus) {
      requirement = 0.0;
      multiplierGain = tier.getMultiplierGain(currentCount);
      tokenReward = 0.0;
    } else {
      requirement = tier.getRequirement(currentCount);
      multiplierGain = tier.getMultiplierGain(currentCount);
      tokenReward = tier.getTokenReward(currentCount);
    }

    final isUnlocked = _isRebirthTierUnlocked(tier, fuba, generatorsOwned);
    double progress;

    if (tier == RebirthTier.furuborus) {
      progress = rebirthData.transcendenceCount >= 100
          ? 1.0
          : rebirthData.transcendenceCount / 100.0;
    } else {
      // Otimização: usa SuffixNumber para comparações eficientes com números muito grandes
      if (requirement > 1e50) {
        // Para requisitos astronômicos, usa comparação de SuffixNumber
        final fubaSuffix = SuffixNumber.fromEfficientNumber(fuba);

        final requirementSuffix = SuffixNumber.fromEfficientNumber(
          EfficientNumber.parse(requirement.toString()),
        );

        progress = fubaSuffix.isGreaterOrEqual(requirementSuffix) ? 1.0 : 0.0;
      } else {
        try {
          final requirementNumber =
              EfficientNumber.parse(requirement.toString());
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
    }

    final barrier = _getBarrierForTier(tier);
    final barrierLocked = !isUnlocked;

    final title = tier.displayName;
    final requirementText = GameConstants.formatNumber(
      EfficientNumber.fromDouble(requirement),
    );
    String subtitle;
    if (tier == RebirthTier.furuborus) {
      subtitle = '${tier.description} • Custo: 100 Transcendências';
    } else if (barrierLocked && barrier != null) {
      final neededGen = barrier.requiredGeneratorCount;
      final tierIdx = barrier.requiredGeneratorTier + 1;
      final ownedGen = tierIdx - 1 < generatorsOwned.length
          ? generatorsOwned[tierIdx - 1]
          : 0;
      final genName = barrier.requiredGeneratorTier < availableGenerators.length
          ? availableGenerators[barrier.requiredGeneratorTier].name
          : 'G$tierIdx';
      subtitle =
          '🔒 ${barrier.description}\nReq: $requirementText fubá • $genName: $ownedGen/$neededGen';
    } else {
      subtitle = '${tier.description} • Req: $requirementText fubá';
    }
    final String? tokenText;
    final String multiplierText;
    if (tier == RebirthTier.furuborus) {
      tokenText = '+1 Forus';
      multiplierText = '';
    } else {
      tokenText = tokenReward > 0 ? '+$tokenReward 💎' : null;
      multiplierText = 'x${multiplierGain.toStringAsFixed(1)}';
    }

    final maxCount = tier == RebirthTier.furuborus
        ? (rebirthData.transcendenceCount ~/ 100).clamp(0, 5)
        : calculateMaxOperations(tier, fuba, rebirthData);

    final effectiveLocked = barrierLocked || !canRebirth;

    if (tier == RebirthTier.furuborus) {
      return _FuruborusCard(
        title: title,
        subtitle: subtitle,
        emoji: tier.emoji,
        progress: progress,
        isLocked: effectiveLocked,
        canActivate: canRebirth,
        rewardText: tokenText ?? '',
        isComingSoon: false,
        actions: effectiveLocked
            ? null
            : [
                _qtyButton(
                  context,
                  ref,
                  tier,
                  1,
                  maxCount: barrierLocked ? 0 : maxCount,
                ),
                _qtyButton(
                  context,
                  ref,
                  tier,
                  5,
                  maxCount: barrierLocked ? 0 : maxCount,
                ),
              ],
      );
    }

    return RebirthBannerCard(
      title: title,
      subtitle: subtitle,
      emoji: tier.emoji,
      progress: progress,
      isLocked: effectiveLocked,
      canActivate: canRebirth,
      lockedReason: effectiveLocked && barrier != null ? 'Requisitos' : null,
      rewardMultiplierText: multiplierText,
      rewardTokenText: tokenText,
      onTap: null,
      colors: _getTierGradient(tier),
      actions: effectiveLocked
          ? null
          : [
              _qtyButton(
                context,
                ref,
                tier,
                1,
                maxCount: barrierLocked ? 0 : maxCount,
              ),
              _qtyButton(
                context,
                ref,
                tier,
                5,
                maxCount: barrierLocked ? 0 : maxCount,
              ),
              _qtyButton(
                context,
                ref,
                tier,
                10,
                maxCount: barrierLocked ? 0 : maxCount,
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
      case RebirthTier.furuborus:
        return Colors.deepPurple;
    }
  }

  List<Color> _getTierGradient(RebirthTier tier) {
    switch (tier) {
      case RebirthTier.rebirth:
        return [
          const Color.fromARGB(255, 94, 0, 245),
          const Color.fromARGB(255, 0, 0, 0)
        ];
      case RebirthTier.ascension:
        return [
          const Color.fromARGB(255, 255, 77, 7),
          const Color.fromARGB(255, 255, 217, 0)
        ];
      case RebirthTier.transcendence:
        return [
          const Color.fromARGB(255, 255, 0, 0),
          const Color.fromARGB(255, 255, 123, 0)
        ];
      case RebirthTier.furuborus:
        return [
          const Color.fromARGB(255, 156, 39, 176),
          const Color.fromARGB(255, 106, 27, 154)
        ];
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
      case RebirthTier.furuborus:
        currentCount = rebirthData.furuborusCount;
        break;
    }

    if (tier == RebirthTier.furuborus) {
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
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 8),
              const Text('• Todo o fubá'),
              const Text('• Todos os geradores'),
              const Text('• Todos os acessórios'),
              const Text('• Todo o inventário'),
              const Text('• Todas as transcendências'),
              const Text('• Todas as ascensões'),
              const Text('• Todos os rebirths'),
              const SizedBox(height: 16),
              const Text(
                'Você ganhará:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text('• $count forus'),
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
                    content: Text(
                        '${tier.displayName} x$count realizado! +$count forus'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTierColor(tier),
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar x$count'),
            ),
          ],
        ),
      );
      return;
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
              foregroundColor: Colors.white,
            ),
            child: Text('Confirmar x$count'),
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
    final effective =
        maxCount == null ? count : (count > maxCount ? maxCount : count);
    final disabled = effective <= 0 || effective < count;
    return ElevatedButton(
      onPressed: disabled
          ? null
          : () {
              _showRebirthConfirmation(context, ref, tier, effective);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: _getTierColor(tier),
      ),
      child: Text(
        label ?? 'x$count',
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
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
              const SizedBox(height: 24),
              const Text(
                'GERADORES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final newGenerators = List.generate(
                    availableGenerators.length,
                    (index) => 1000,
                  );
                  ref.read(generatorsProvider.notifier).state = newGenerators;
                  ref.read(saveNotifierProvider.notifier).saveImmediate();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('+1000 de todos os geradores adicionados'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('Dar 1000 de todos os geradores'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
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

class _NeonPanel extends StatelessWidget {
  final Widget child;
  const _NeonPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.withOpacity(0.18),
            Colors.black.withOpacity(0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.01),
              Colors.white.withOpacity(0.00),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class _GlowText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;
  final double glowOpacity;
  const _GlowText({
    required this.text,
    required this.style,
    required this.glowColor,
    this.glowOpacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final base = glowColor.withOpacity(0.45 * glowOpacity);
    return Text(
      text,
      style: style.copyWith(
        shadows: [
          Shadow(color: base, blurRadius: 8),
          Shadow(
              color: glowColor.withOpacity(0.25 * glowOpacity), blurRadius: 20),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _NeonChip extends StatelessWidget {
  final String leading;
  final String value;
  final String label;
  final Color color;
  const _NeonChip({
    required this.leading,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.06),
            Colors.black.withOpacity(0.30),
          ],
        ),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            leading.isEmpty ? value : '$leading $value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TokenPill extends StatelessWidget {
  final String text;
  const _TokenPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.6),
            const Color(0xFF7C4DFF).withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FuruborusCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final double progress;
  final bool isLocked;
  final bool canActivate;
  final String rewardText;
  final bool isComingSoon;
  final List<Widget>? actions;

  const _FuruborusCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.progress,
    required this.isLocked,
    required this.canActivate,
    required this.rewardText,
    this.isComingSoon = false,
    this.actions,
  });

  @override
  State<_FuruborusCard> createState() => _FuruborusCardState();
}

class _FuruborusCardState extends State<_FuruborusCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 0, 0, 0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.purpleAccent.withOpacity(
                          0.3 + 0.2 * (_glowController.value * 2 - 1).abs()),
                      Colors.purple.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.purpleAccent
                        .withOpacity(0.5 + 0.3 * _pulseController.value),
                    width: 2 + _pulseController.value * 1.5,
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 20,
            top: 7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Assets.images.furuborus.image(
                width: 190,
                height: 190,
                errorBuilder: (context, error, stackTrace) =>
                    Assets.images.rebirth.image(width: 600, height: 600),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.purpleAccent.withOpacity(0.8),
                        blurRadius: 10,
                      ),
                      Shadow(
                        color: Colors.purple.withOpacity(0.6),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.white70),
                ),
                const Spacer(),
                if (widget.isComingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.3),
                          Colors.orange.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.schedule,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Aguarde o lançamento',
                          style: TextStyle(
                            color: Colors.amber.shade100,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.amber.withOpacity(0.8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurpleAccent.withOpacity(0.8),
                              Colors.purple.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.purpleAccent.withOpacity(0.8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              widget.rewardText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (widget.actions != null && widget.actions!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.actions!,
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (widget.isLocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
        ],
      ),
    );
  }
}
