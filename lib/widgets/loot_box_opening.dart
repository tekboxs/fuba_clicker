import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/cake_accessory.dart';
import '../models/loot_box.dart';
import 'dart:math';

class LootBoxOpeningAnimation extends StatefulWidget {
  const LootBoxOpeningAnimation({
    super.key,
    required this.lootBoxTier,
    required this.reward,
    required this.onComplete,
  });

  final LootBoxTier lootBoxTier;
  final CakeAccessory reward;
  final VoidCallback onComplete;

  @override
  State<LootBoxOpeningAnimation> createState() =>
      _LootBoxOpeningAnimationState();
}

class _LootBoxOpeningAnimationState extends State<LootBoxOpeningAnimation>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _openController;
  late AnimationController _revealController;
  bool _showBox = true;
  bool _showReward = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _shakeController.forward();

    setState(() {
      _showBox = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _showReward = true;
    });

    await _revealController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    widget.onComplete();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _openController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(230),
      body: Container(
        color: Colors.black.withAlpha(230),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_showBox) _buildBox(),
              if (_showReward) _buildReward(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBox() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final value = _shakeController.value;
        final shake = (value * 20).round() % 2 == 0 ? -5.0 : 5.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child:
              Text(
                    widget.lootBoxTier.emoji,
                    style: const TextStyle(fontSize: 120),
                  )
                  .animate(
                    autoPlay: true,
                    onComplete: (controller) => controller.repeat(),
                  )
                  .shimmer(
                    duration: 1.seconds,
                    color: widget.lootBoxTier.color.withAlpha(150),
                  ),
        );
      },
    );
  }

  Widget _buildReward() {
    return Column(
      children: [
        Text(widget.reward.emoji, style: const TextStyle(fontSize: 120))
            .animate()
            .scale(
              duration: 500.milliseconds,
              curve: Curves.elasticOut,
              begin: const Offset(0.0, 0.0),
              end: const Offset(1.0, 1.0),
            )
            .then()
            .shimmer(
              duration: 1.seconds,
              color: widget.reward.rarity.color.withAlpha(150),
            ),
        const SizedBox(height: 24),
        Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.reward.rarity.color.withAlpha(50),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.reward.rarity.color, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    widget.reward.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.reward.rarity.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.reward.rarity.displayName,
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.reward.rarity.color.withAlpha(200),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.reward.description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 400.milliseconds, delay: 300.milliseconds)
            .slideY(
              begin: 0.3,
              end: 0,
              duration: 400.milliseconds,
              delay: 300.milliseconds,
              curve: Curves.easeOut,
            ),
      ],
    );
  }
}

class MultipleLootBoxOpeningAnimation extends StatefulWidget {
  const MultipleLootBoxOpeningAnimation({
    super.key,
    required this.lootBoxTier,
    required this.rewards,
    required this.onComplete,
  });

  final LootBoxTier lootBoxTier;
  final List<CakeAccessory> rewards;
  final VoidCallback onComplete;

  @override
  State<MultipleLootBoxOpeningAnimation> createState() =>
      _MultipleLootBoxOpeningAnimationState();
}

class _MultipleLootBoxOpeningAnimationState extends State<MultipleLootBoxOpeningAnimation>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _openController;
  late AnimationController _revealController;
  bool _showBoxes = true;
  bool _showRewards = false;
  final List<Offset> _boxPositions = [];
  final List<Offset> _rewardPositions = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_boxPositions.isEmpty) {
      _generatePositions();
      _startAnimation();
    }
  }

  void _generatePositions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;
    
    final quantity = widget.rewards.length;
    final spacing = 120.0;
    
    if (quantity <= 5) {
      for (int i = 0; i < quantity; i++) {
        final x = centerX + (i - (quantity - 1) / 2) * spacing;
        final y = centerY + _random.nextDouble() * 100 - 50;
        _boxPositions.add(Offset(x, y));
        _rewardPositions.add(Offset(x, y));
      }
    } else if (quantity <= 10) {
      for (int i = 0; i < quantity; i++) {
        final row = i ~/ 5;
        final col = i % 5;
        final x = centerX + (col - 2) * spacing;
        final y = centerY + (row - 0.5) * spacing * 0.8;
        _boxPositions.add(Offset(x, y));
        _rewardPositions.add(Offset(x, y));
      }
    } else {
      for (int i = 0; i < quantity; i++) {
        final row = i ~/ 6;
        final col = i % 6;
        final x = centerX + (col - 2.5) * spacing * 0.8;
        final y = centerY + (row - (quantity / 6 - 1) / 2) * spacing * 0.6;
        _boxPositions.add(Offset(x, y));
        _rewardPositions.add(Offset(x, y));
      }
    }
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _shakeController.forward();

    setState(() {
      _showBoxes = false;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      _showRewards = true;
    });

    await _revealController.forward();

    await Future.delayed(const Duration(milliseconds: 3000));
    widget.onComplete();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _openController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(230),
      body: Container(
        color: Colors.black.withAlpha(230),
        child: Stack(
          children: [
            if (_showBoxes) ..._buildBoxes(),
            if (_showRewards) ..._buildRewards(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBoxes() {
    return List.generate(widget.rewards.length, (index) {
      return Positioned(
        left: _boxPositions[index].dx - 60,
        top: _boxPositions[index].dy - 60,
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final value = _shakeController.value;
            final shakeX = (value * 30).round() % 2 == 0 ? -8.0 : 8.0;
            final shakeY = (value * 25).round() % 2 == 0 ? -5.0 : 5.0;
            return Transform.translate(
              offset: Offset(shakeX, shakeY),
              child: Text(
                widget.lootBoxTier.emoji,
                style: const TextStyle(fontSize: 80),
              )
                  .animate(
                    autoPlay: true,
                    onComplete: (controller) => controller.repeat(),
                  )
                  .shimmer(
                    duration: 1.seconds,
                    color: widget.lootBoxTier.color.withAlpha(150),
                  ),
            );
          },
        ),
      );
    });
  }

  List<Widget> _buildRewards() {
    return List.generate(widget.rewards.length, (index) {
      final reward = widget.rewards[index];
      return Positioned(
        left: _rewardPositions[index].dx - 40,
        top: _rewardPositions[index].dy - 40,
        child: Text(reward.emoji, style: const TextStyle(fontSize: 80))
            .animate()
            .scale(
              duration: 600.milliseconds,
              curve: Curves.elasticOut,
              begin: const Offset(0.0, 0.0),
              end: const Offset(1.0, 1.0),
              delay: (index * 100).milliseconds,
            )
            .then()
            .shimmer(
              duration: 1.seconds,
              color: reward.rarity.color.withAlpha(150),
              delay: (index * 50).milliseconds,
            ),
      );
    });
  }
}
