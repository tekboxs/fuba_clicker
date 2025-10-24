import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../models/fuba_generator.dart';
import '../providers/game_providers.dart';
import '../providers/achievement_provider.dart';
import '../providers/save_provider.dart';
import '../utils/constants.dart';
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

    return Container(
      padding: EdgeInsets.all(GameConstants.getCardPadding(context)),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(GameConstants.primaryColorAlpha),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withAlpha(GameConstants.borderColorAlpha),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FUGERADORES',
                style: TextStyle(
                  fontSize: GameConstants.getTitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              _buildGlobalMultiBuyButtons(ref, context),
            ],
          ),
          SizedBox(height: GameConstants.isMobile(context) ? 8 : 12),
          Expanded(
            child: ListView.builder(
              cacheExtent: 1000,
              itemCount: availableGenerators.length,
              itemBuilder: (context, index) {
                final generator = availableGenerators[index];
                final owned = generators[index];
                final cost = generator.getCost(owned);
                final isUnlocked = generator.isUnlocked(generators, <String>{});
                final canAfford = fuba.compareTo(cost) >= 0 && isUnlocked;

                return InkWell(
                  onTap: canAfford
                      ? () => _buyGenerator(ref, index, cost, context)
                      : null,
                  child: GestureDetector(
                    onLongPressStart: canAfford
                        ? (_) => _startAutoBuyForGenerator(ref, index, cost, context)
                        : null,
                    onLongPressEnd: canAfford
                        ? (_) => _stopAutoBuyForGenerator(ref, index)
                        : null,
                    child: _GeneratorCard(
                    key: ValueKey('generator_$index'),
                    generator: generator,
                    owned: owned,
                    cost: cost,
                    canAfford: canAfford,
                    isUnlocked: isUnlocked,
                  ),
                    ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  /// Compra um gerador
  void _buyGenerator(WidgetRef ref, int index, BigDecimal cost, BuildContext context) {
    if (_activeMultiBuyQuantity > 0) {
      _buyMultipleGenerators(ref, index, _activeMultiBuyQuantity, context);
    } else if (_activeMultiBuyQuantity == -1) {
      _buyMaxGenerators(ref, index, context);
    } else {
      _buyMultipleGenerators(ref, index, 1, context);
    }
  }

  /// Compra múltiplos geradores
  void _buyMultipleGenerators(WidgetRef ref, int index, int quantity, BuildContext context) {
    final currentFuba = ref.read(fubaProvider);
    final generators = List<int>.from(ref.read(generatorsProvider));
    final generator = availableGenerators[index];
    
    BigDecimal totalCost = BigDecimal.zero;
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
    
    BigDecimal totalCost = BigDecimal.zero;
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
  void _startAutoBuyForGenerator(WidgetRef ref, int index, BigDecimal cost, BuildContext context) {
    _autoBuyTimers[index]?.cancel();
    _autoBuyTimers[index] = Timer.periodic(const Duration(milliseconds: 100), (timer) {
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
        const SizedBox(width: 4),
        _buildToggleButton('xMAX', -1, Colors.red),
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
  final BigDecimal cost;
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
      backgroundColor = Colors.grey.withAlpha(GameConstants.affordColorAlpha);
      borderColor = Colors.grey.withAlpha(GameConstants.affordBorderAlpha);
    } else if (widget.canAfford) {
      backgroundColor = widget.generator.tierColor.withAlpha(
        GameConstants.affordColorAlpha,
      );
      borderColor = widget.generator.tierColor.withAlpha(
        GameConstants.affordBorderAlpha,
      );
    } else {
      backgroundColor = Colors.grey.withAlpha(GameConstants.affordColorAlpha);
      borderColor = Colors.grey.withAlpha(GameConstants.affordBorderAlpha);
    }

    if (widget.generator.tier == GeneratorTier.absolute) {
      backgroundColor = Colors.black.withAlpha(120);
      borderColor = Colors.white.withAlpha(200);
    }

    // double scale = 1.0 + (widget.owned * 0.01).clamp(0.0, 0.2);
    double scale = 1.0;
    double glowIntensity = (widget.owned * 0.005).clamp(0.0, 0.8);

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
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        backgroundColor,
                        backgroundColor.withAlpha(backgroundColor.a ~/ 2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: widget.owned > 0 || widget.generator.tier == GeneratorTier.absolute ? 2.0 : 1.0,
                    ),
                    boxShadow: widget.owned > 5 || widget.generator.tier == GeneratorTier.absolute
                        ? [
                            BoxShadow(
                              color: widget.generator.tier == GeneratorTier.absolute
                                  ? Colors.white.withAlpha(100)
                                  : widget.generator.tierColor.withAlpha(
                                      (255 * glowIntensity * 0.3).toInt(),
                                    ),
                              blurRadius: widget.generator.tier == GeneratorTier.absolute 
                                  ? 15.0 
                                  : (8 + (widget.owned * 0.5)).clamp(8.0, 25.0).toDouble(),
                              spreadRadius: widget.generator.tier == GeneratorTier.absolute 
                                  ? 3.0 
                                  : (2 + (widget.owned * 0.1)).clamp(2.0, 8.0).toDouble(),
                            ),
                          ]
                        : null,
                  ),
                  child: Padding(
                        padding: EdgeInsets.all(GameConstants.isMobile(context) ? 6 : 16),
                        child: Row(
                        children: [
                          _buildGeneratorVisual(),
                          SizedBox(width: GameConstants.isMobile(context) ? 6 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isUnlocked
                                      ? widget.generator.name
                                      : '? ? ?',
                                  style: TextStyle(
                                    fontSize:
                                        GameConstants.getGeneratorNameFontSize(context),
                                    fontWeight: FontWeight.bold,
                                    color: widget.isUnlocked
                                        ? (widget.generator.tier == GeneratorTier.absolute 
                                            ? Colors.white 
                                            : widget.generator.tierColor)
                                        : Colors.grey,
                                  ),
                                ),
                                Text(
                                  widget.isUnlocked
                                      ? widget.generator.description
                                      : 'Compre mais geradores para desbloquear',
                                  style: TextStyle(
                                    fontSize:
                                        GameConstants.getGeneratorDescFontSize(context),
                                    color: widget.isUnlocked
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                if (widget.owned > 0 && widget.isUnlocked)
                                  Text(
                                    '${GameConstants.formatNumber(widget.generator.getProduction(widget.owned))} fubá/s',
                                    style: TextStyle(
                                      fontSize: GameConstants
                                          .getGeneratorProductionFontSize(context),
                                      color: widget.generator.tier == GeneratorTier.absolute 
                                          ? Colors.white 
                                          : widget.generator.tierColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                                if (widget.isUnlocked)
                                  Text(
                                    '${GameConstants.formatNumber(widget.cost)} fubá',
                                    style: TextStyle(
                                      fontSize:
                                          GameConstants.getGeneratorCostFontSize(context),
                                      fontWeight: FontWeight.bold,
                                      color: widget.canAfford
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  )
                                else
                                  const Text('', style: TextStyle(fontSize: 20)),
                                if (widget.owned > 0 && widget.isUnlocked)
                                  Text(
                                    'Tem: ${widget.owned}',
                                    style: TextStyle(
                                      fontSize:
                                          GameConstants.getGeneratorOwnedFontSize(context),
                                      color: widget.generator.tier == GeneratorTier.absolute 
                                          ? Colors.white 
                                          : widget.generator.tierColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              );
            },
          ),

          if (_showParticles)
            Positioned.fill(
              child: ParticleSystem(
                shouldAnimate: _showParticles,
                particleColor: widget.generator.tierColor,
                onComplete: () {
                  setState(() {
                    _showParticles = false;
                  });
                },
              ),
            ),

          if (_showMilestone)
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Center(
                    child: Transform.scale(
                      scale: _milestoneController.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 0.5,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(200),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.yellow,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withAlpha(100),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.rotate(
                                angle: _rotationAnimation.value * 2,
                                child: Text(
                                  '🏆',
                                  style: TextStyle(
                                    fontSize: 24 * _milestoneController.value,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'MILESTONE!',
                                style: TextStyle(
                                  fontSize: 16 * _milestoneController.value,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Transform.rotate(
                                angle: -_rotationAnimation.value * 2,
                                child: Text(
                                  '🏆',
                                  style: TextStyle(
                                    fontSize: 24 * _milestoneController.value,
                                  ),
                                ),
                              ),
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

  Widget _buildGeneratorVisual() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: widget.owned > 0
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.generator.tierColor.withAlpha(
                        (100 * _glowAnimation.value).toInt(),
                      ),
                      blurRadius: (10 + (widget.owned * 2)).clamp(10.0, 50.0).toDouble(),
                      spreadRadius: (2 + (widget.owned * 0.5)).clamp(2.0, 15.0).toDouble(),
                    ),
                  ],
                )
              : null,
          child: Text(
            widget.isUnlocked ? widget.generator.emoji : '🔒',
            style: TextStyle(
              fontSize: GameConstants.getGeneratorEmojiSize(context),
              color: widget.isUnlocked ? null : Colors.grey,
            ),
          ),
        );
      },
    );
  }

}
