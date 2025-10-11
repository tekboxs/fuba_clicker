import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/cake_accessory.dart';
import '../models/loot_box.dart';

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
