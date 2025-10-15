import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fuba_generator.dart';
import '../providers/game_providers.dart';
import '../providers/achievement_provider.dart';
import '../providers/secret_provider.dart';
import '../providers/save_provider.dart';
import '../utils/constants.dart';
import 'particle_system.dart';

/// Widget da seção de geradores de fubá
class GeneratorSection extends ConsumerWidget {
  const GeneratorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generators = ref.watch(generatorsProvider);
    final fuba = ref.watch(fubaProvider);
    final unlockedSecrets = ref.watch(unlockedSecretsProvider);

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
          Align(
            alignment: Alignment.center,
            child: Text(
              'JOJINHA',
              style: TextStyle(
                fontSize: GameConstants.getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
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
                final isUnlocked = generator.isUnlocked(generators, unlockedSecrets);
                final canAfford = fuba >= cost && isUnlocked;

                return _GeneratorCard(
                  key: ValueKey('generator_$index'),
                  generator: generator,
                  owned: owned,
                  cost: cost,
                  canAfford: canAfford,
                  isUnlocked: isUnlocked,
                  onTap: canAfford
                      ? () => _buyGenerator(ref, index, cost)
                      : null,
                  onLongPressStart: canAfford
                      ? () => _startAutoBuyForGenerator(ref, index, cost)
                      : null,
                  onLongPressEnd: canAfford
                      ? () => _stopAutoBuyForGenerator(ref, index)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Compra um gerador
  void _buyGenerator(WidgetRef ref, int index, double cost) {
    ref.read(fubaProvider.notifier).state -= cost;
    final generators = List<int>.from(ref.read(generatorsProvider));
    generators[index]++;
    ref.read(generatorsProvider.notifier).state = generators;
    
    final differentGenerators = generators.where((count) => count > 0).length;
    ref.read(achievementNotifierProvider).updateStat(
      'different_generators',
      differentGenerators.toDouble(),
    );
    
    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }

  /// Inicia a compra automática de um gerador
  void _startAutoBuyForGenerator(WidgetRef ref, int index, double cost) {
    // A lógica de compra automática será implementada no _GeneratorCard
  }

  /// Para a compra automática de um gerador
  void _stopAutoBuyForGenerator(WidgetRef ref, int index) {
    // A lógica de parar compra automática será implementada no _GeneratorCard
  }
}

/// Widget do card individual de um gerador
class _GeneratorCard extends StatefulWidget {
  final FubaGenerator generator;
  final int owned;
  final double cost;
  final bool canAfford;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const _GeneratorCard({
    super.key,
    required this.generator,
    required this.owned,
    required this.cost,
    required this.canAfford,
    required this.isUnlocked,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
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
  Timer? _autoBuyTimer;
  bool _isAutoBuying = false;

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

    if (!widget.canAfford && _isAutoBuying) {
      _stopAutoBuy();
    }

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

  void _startAutoBuy() {
    if (!widget.canAfford || _isAutoBuying) return;
    
    widget.onLongPressStart?.call();
    
    setState(() {
      _isAutoBuying = true;
    });
    
    _autoBuyTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted && widget.canAfford) {
        widget.onTap?.call();
      } else {
        _stopAutoBuy();
      }
    });
  }

  void _stopAutoBuy() {
    _autoBuyTimer?.cancel();
    _autoBuyTimer = null;
    widget.onLongPressEnd?.call();
    setState(() {
      _isAutoBuying = false;
    });
  }


  @override
  void dispose() {
    _autoBuyTimer?.cancel();
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
    } else if (_isAutoBuying) {
      backgroundColor = Colors.orange.withAlpha(
        GameConstants.affordColorAlpha + 50,
      );
      borderColor = Colors.orange.withAlpha(
        GameConstants.affordBorderAlpha + 50,
      );
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

    // double scale = 1.0 + (widget.owned * 0.01).clamp(0.0, 0.2);
    double scale = 1.0;
    double glowIntensity = (widget.owned * 0.05).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.only(
        top: GameConstants.isMobile(context) ? 3 : 5, 
        left: GameConstants.isMobile(context) ? 18 : 20, 
        right: GameConstants.isMobile(context) ? 18 : 20,
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
                      width: widget.owned > 0 ? 2.0 : 1.0,
                    ),
                    boxShadow: widget.owned > 5
                        ? [
                            BoxShadow(
                              color: widget.generator.tierColor.withAlpha(
                                (255 * glowIntensity * 0.3).toInt(),
                              ),
                              blurRadius: 8 + (widget.owned * 0.5),
                              spreadRadius: 2 + (widget.owned * 0.1),
                            ),
                          ]
                        : null,
                  ),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    onLongPressStart: widget.canAfford ? (_) => _startAutoBuy() : null,
                    onLongPressEnd: widget.canAfford ? (_) => _stopAutoBuy() : null,
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(GameConstants.isMobile(context) ? 8 : 16),
                        child: Row(
                        children: [
                          _buildGeneratorVisual(),
                          SizedBox(width: GameConstants.isMobile(context) ? 8 : 12),
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
                                        ? widget.generator.tierColor
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
                                      color: widget.generator.tierColor,
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
                                      color: widget.generator.tierColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ],
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
                      blurRadius: 10 + (widget.owned * 2),
                      spreadRadius: 2 + (widget.owned * 0.5),
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
