import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/efficient_number.dart';
import '../../../models/fuba_generator.dart';
import '../../../providers/game_providers.dart';
import '../../../providers/achievement_provider.dart';
import '../../../providers/save_provider.dart';
import '../../../core/utils/constants.dart';
import '../../../theme/tokens.dart';
import '../../../theme/components.dart';
import 'particle_system.dart';

/// Widget da seção de geradores de fubá
class GeneratorSection extends ConsumerStatefulWidget {
  const GeneratorSection({super.key});

  @override
  ConsumerState<GeneratorSection> createState() => _GeneratorSectionState();
}

class _GeneratorSectionState extends ConsumerState<GeneratorSection> {
  static final Map<int, Timer?> _autoBuyTimers = {};

  // Estado dos toggles de compra múltipla
  int _activeMultiBuyQuantity = 0; // 0 = desativado, 10, 100, 1000, -1 = MAX

  @override
  Widget build(BuildContext context) {
    final generators = ref.watch(generatorsProvider);
    final fuba = ref.watch(fubaProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.all(GameConstants.getCardPadding(context)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.card.withOpacity(0.6),
                AppColors.card.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
            boxShadow: AppShadows.level2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GradientText(
                    'FUGERADORES',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: GameConstants.getTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                        ),
                    gradient: AppGradients.purpleCyan,
                  ),
                  _buildGlobalMultiBuyButtons(ref, context),
                ],
              ),
              SizedBox(height: GameConstants.isMobile(context) ? 8 : 12),
              Expanded(
                child: ListView.builder(
                  cacheExtent: 1000,
                  itemExtent: null,
                  addRepaintBoundaries: true,
                  itemCount: availableGenerators.length,
                  itemBuilder: (context, index) {
                    final generator = availableGenerators[index];
                    final owned = generators[index];
                    final cost = generator.getCost(owned);
                    final isUnlocked =
                        generator.isUnlocked(generators, <String>{});
                    final canAfford = fuba.compareTo(cost) >= 0 && isUnlocked;

                    return InkWell(
                      onTap: canAfford
                          ? () => _buyGenerator(ref, index, cost, context)
                          : null,
                      child: GestureDetector(
                        onLongPressStart: canAfford
                            ? (_) => _startAutoBuyForGenerator(
                                ref, index, cost, context)
                            : null,
                        onLongPressEnd: canAfford
                            ? (_) => _stopAutoBuyForGenerator(ref, index)
                            : null,
                        child: RepaintBoundary(
                          child: _GeneratorCard(
                            key: ValueKey('generator_$index'),
                            generator: generator,
                            owned: owned,
                            cost: cost,
                            canAfford: canAfford,
                            isUnlocked: isUnlocked,
                          ),
                        ),
                      ),
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

  /// Compra um gerador
  void _buyGenerator(
      WidgetRef ref, int index, EfficientNumber cost, BuildContext context) {
    if (_activeMultiBuyQuantity > 0) {
      _buyMultipleGenerators(ref, index, _activeMultiBuyQuantity, context);
    } else if (_activeMultiBuyQuantity == -1) {
      _buyMaxGenerators(ref, index, context);
    } else {
      _buyMultipleGenerators(ref, index, 1, context);
    }
  }

  /// Compra múltiplos geradores
  void _buyMultipleGenerators(
      WidgetRef ref, int index, int quantity, BuildContext context) {
    final currentFuba = ref.read(fubaProvider);
    final generators = List<int>.from(ref.read(generatorsProvider));
    final generator = availableGenerators[index];

    EfficientNumber totalCost = const EfficientNumber.zero();
    int actualQuantity = 0;

    for (int i = 0; i < quantity; i++) {
      final currentOwned = generators[index] + actualQuantity;
      final currentCost = generator.getCost(currentOwned);

      if (currentFuba.compareTo(totalCost + currentCost) >= 0) {
        totalCost += currentCost;
        actualQuantity++;
      } else {
        break;
      }
    }

    if (actualQuantity > 0) {
      ref.read(fubaProvider.notifier).state = currentFuba - totalCost;
      generators[index] += actualQuantity;
      ref.read(generatorsProvider.notifier).state = generators;

      final differentGenerators = generators.where((count) => count > 0).length;
      ref.read(achievementNotifierProvider).updateStat(
            'different_generators',
            differentGenerators.toDouble(),
            context,
          );

      ref.read(saveNotifierProvider.notifier).saveImmediate();
    }
  }

  /// Compra o máximo possível de um gerador
  void _buyMaxGenerators(WidgetRef ref, int index, BuildContext context) {
    final currentFuba = ref.read(fubaProvider);
    final generators = List<int>.from(ref.read(generatorsProvider));
    final generator = availableGenerators[index];

    EfficientNumber totalCost = const EfficientNumber.zero();
    int actualQuantity = 0;

    while (true) {
      final currentOwned = generators[index] + actualQuantity;
      final currentCost = generator.getCost(currentOwned);

      if (currentFuba.compareTo(totalCost + currentCost) >= 0) {
        totalCost += currentCost;
        actualQuantity++;
      } else {
        break;
      }
    }

    if (actualQuantity > 0) {
      ref.read(fubaProvider.notifier).state = currentFuba - totalCost;
      generators[index] += actualQuantity;
      ref.read(generatorsProvider.notifier).state = generators;

      final differentGenerators = generators.where((count) => count > 0).length;
      ref.read(achievementNotifierProvider).updateStat(
            'different_generators',
            differentGenerators.toDouble(),
            context,
          );

      ref.read(saveNotifierProvider.notifier).saveImmediate();
    }
  }

  /// Inicia a compra automática de um gerador
  void _startAutoBuyForGenerator(
      WidgetRef ref, int index, EfficientNumber cost, BuildContext context) {
    _autoBuyTimers[index]?.cancel();
    _autoBuyTimers[index] =
        Timer.periodic(const Duration(milliseconds: 150), (timer) {
      final generators = ref.read(generatorsProvider);
      final fuba = ref.read(fubaProvider);
      final generator = availableGenerators[index];
      final owned = generators[index];
      final currentCost = generator.getCost(owned);

      if (fuba.compareTo(currentCost) >= 0) {
        _buyGenerator(ref, index, currentCost, context);
      } else {
        timer.cancel();
        _autoBuyTimers[index] = null;
      }
    });
  }

  /// Para a compra automática de um gerador
  void _stopAutoBuyForGenerator(WidgetRef ref, int index) {
    _autoBuyTimers[index]?.cancel();
    _autoBuyTimers[index] = null;
  }

  /// Constrói os botões de compra múltipla globais
  Widget _buildGlobalMultiBuyButtons(WidgetRef ref, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleButton('x1', 1, Colors.green),
        const SizedBox(width: 4),
        _buildToggleButton('x10', 10, Colors.blue),
        const SizedBox(width: 4),
        _buildToggleButton('x100', 100, Colors.purple),
        const SizedBox(width: 4),
        _buildToggleButton('x1000', 1000, Colors.orange),
        // const SizedBox(width: 4),
        // _buildToggleButton('xMAX', -1, Colors.red),
      ],
    );
  }

  /// Constrói um botão toggle
  Widget _buildToggleButton(String label, int quantity, Color color) {
    final isActive = _activeMultiBuyQuantity == quantity;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_activeMultiBuyQuantity == quantity) {
            _activeMultiBuyQuantity = 0; // Desativa se já estiver ativo
          } else {
            _activeMultiBuyQuantity = quantity; // Ativa este toggle
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color : color.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : color.withAlpha(150),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Widget do card individual de um gerador
class _GeneratorCard extends StatefulWidget {
  final FubaGenerator generator;
  final int owned;
  final EfficientNumber cost;
  final bool canAfford;
  final bool isUnlocked;

  const _GeneratorCard({
    super.key,
    required this.generator,
    required this.owned,
    required this.cost,
    required this.canAfford,
    required this.isUnlocked,
  });

  @override
  State<_GeneratorCard> createState() => _GeneratorCardState();
}

class _GeneratorCardState extends State<_GeneratorCard>
    with TickerProviderStateMixin {
  late AnimationController _purchaseController;
  late AnimationController _glowController;
  late AnimationController _milestoneController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;
  bool _showParticles = false;
  bool _showMilestone = false;
  int _lastOwned = 0;

  @override
  void initState() {
    super.initState();
    _lastOwned = widget.owned;

    _purchaseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _milestoneController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _purchaseController, curve: Curves.bounceOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _milestoneController, curve: Curves.elasticOut),
    );

    if (widget.owned > 0) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_GeneratorCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.owned > _lastOwned) {
      _handlePurchase();
    }
    _lastOwned = widget.owned;

    if (widget.owned > 0 && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    }
  }

  void _handlePurchase() {
    _purchaseController.forward().then((_) => _purchaseController.reverse());
    setState(() {
      _showParticles = true;
    });

    _checkForMilestone();
  }

  void _checkForMilestone() {
    const milestones = [10, 25, 50, 100, 250, 500, 1000];
    if (milestones.contains(widget.owned)) {
      setState(() {
        _showMilestone = true;
      });
      _milestoneController.forward().then((_) {
        _milestoneController.reverse();
        setState(() {
          _showMilestone = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _purchaseController.dispose();
    _glowController.dispose();
    _milestoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;

    if (!widget.isUnlocked) {
      backgroundColor = const Color.fromARGB(255, 94, 94, 94).withAlpha(GameConstants.affordColorAlpha);
      borderColor = Colors.grey.withAlpha(GameConstants.affordBorderAlpha);
    } else if (widget.canAfford) {
      backgroundColor = widget.generator.tierColor.withAlpha(
        GameConstants.affordColorAlpha,
      );
      borderColor = widget.generator.tierColor.withAlpha(
        GameConstants.affordBorderAlpha,
      );
    } else {
      backgroundColor = const Color.fromARGB(255, 102, 102, 102).withAlpha(GameConstants.affordColorAlpha);
      borderColor = Colors.grey.withAlpha(GameConstants.affordBorderAlpha);
    }

    if (widget.generator.tier == GeneratorTier.absolute) {
      backgroundColor = Colors.black.withAlpha(120);
      borderColor = Colors.white.withAlpha(200);
    }

    double scale = 1.0;
    double glowIntensity = (widget.owned * 0.005).clamp(0.0, 0.5);

    return Padding(
      padding: EdgeInsets.only(
        top: GameConstants.isMobile(context) ? 2 : 5,
        left: GameConstants.isMobile(context) ? 8 : 30,
        right: GameConstants.isMobile(context) ? 8 : 30,
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: scale * (1.0 + _scaleAnimation.value * 0.05),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            backgroundColor.withOpacity(0.8),
                            backgroundColor.withOpacity(0.4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        border: Border.all(
                          color: borderColor.withOpacity(0.6),
                          width: widget.owned > 0 ||
                                  widget.generator.tier ==
                                      GeneratorTier.absolute
                              ? 2.0
                              : 1.5,
                        ),
                        boxShadow: widget.owned > 5 ||
                                widget.generator.tier == GeneratorTier.absolute
                            ? [
                                BoxShadow(
                                  color: widget.generator.tier ==
                                          GeneratorTier.absolute
                                      ? Colors.white.withOpacity(0.4)
                                      : widget.generator.tierColor.withOpacity(
                                          glowIntensity * 0.5,
                                        ),
                                  blurRadius: widget.generator.tier ==
                                          GeneratorTier.absolute
                                      ? 24.0
                                      : (12 + (widget.owned * 0.5))
                                          .clamp(12.0, 32.0)
                                          .toDouble(),
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: widget.isUnlocked
                                        ? widget.generator.tierColor
                                            .withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.md),
                                    border: Border.all(
                                      color: widget.isUnlocked
                                          ? widget.generator.tierColor
                                              .withOpacity(0.4)
                                          : Colors.grey.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.isUnlocked
                                          ? widget.generator.emoji
                                          : '🔒',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.isUnlocked
                                            ? widget.generator.name
                                            : '? ? ?',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: widget.isUnlocked
                                              ? AppColors.foreground
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.isUnlocked
                                            ? widget.generator.description
                                            : 'Compre mais geradores para desbloquear',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.mutedForeground,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.isUnlocked && widget.owned > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.generator.tierColor
                                          .withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.sm),
                                      border: Border.all(
                                        color: widget.generator.tierColor
                                            .withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Nv ${_calculateLevel(widget.owned)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (widget.isUnlocked) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.trending_up,
                                      label: 'Prod.',
                                      value:
                                          '${GameConstants.formatNumber(widget.generator.getProduction(widget.owned))}/s',
                                      color: AppColors.foreground,
                                      isHighlighted: false,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.numbers,
                                      label: 'Qtd.',
                                      value: '${widget.owned}',
                                      color: AppColors.foreground,
                                      isHighlighted: false,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.attach_money,
                                      label: 'Custo',
                                      value: GameConstants.formatNumber(
                                          widget.cost),
                                      color: widget.canAfford
                                          ? AppColors.amber400
                                          : AppColors.mutedForeground,
                                      isHighlighted: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _calculateLevel(int owned) {
    if (owned < 10) return 1;
    if (owned < 25) return 2;
    if (owned < 50) return 3;
    if (owned < 100) return 5;
    if (owned < 250) return 10;
    if (owned < 500) return 15;
    if (owned < 1000) return 25;
    if (owned < 2500) return 50;
    return (owned / 100).floor();
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withOpacity(0.15)
            : AppColors.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: isHighlighted
              ? color.withOpacity(0.4)
              : AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: color.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
