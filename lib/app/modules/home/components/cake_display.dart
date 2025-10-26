import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/gen/assets.gen.dart';
import 'package:fuba_clicker/app/models/cake_visual_tier.dart';
import 'package:fuba_clicker/app/models/cake_accessory.dart';
import 'package:fuba_clicker/app/providers/visual_settings_provider.dart';

class CakeDisplay extends ConsumerWidget {
  const CakeDisplay({
    super.key,
    required this.accessories,
    required this.size,
    required this.animationController,
  });

  final List<CakeAccessory> accessories;
  final double size;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = CakeVisualTierExtension.fromAccessories(accessories);
    final hideAccessories = ref.watch(hideAccessoriesProvider);
    final disableEffects = ref.watch(disableEffectsProvider);

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (tier.glowIntensity > 0 && !disableEffects) _buildGlow(tier),
            _buildCake(tier, hideAccessories),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow(CakeVisualTier tier) {
    return Container(
          width: size + tier.glowIntensity * 2,
          height: size + tier.glowIntensity * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: tier.primaryColor.withAlpha(100),
                blurRadius: tier.glowIntensity,
                spreadRadius: tier.glowIntensity / 2,
              ),
            ],
          ),
        )
        .animate(
          autoPlay: true,
          onComplete: (controller) => controller.repeat(reverse: true),
        )
        .fadeIn(duration: Duration(milliseconds: tier.pulseSpeed))
        .fadeOut(duration: Duration(milliseconds: tier.pulseSpeed));
  }

  Widget _buildCake(CakeVisualTier tier, bool hideAccessories) {
  
    return AnimatedScale(
      scale: tier.scaleBonus,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: tier.glowIntensity > 0
              ? Border.all(color: tier.primaryColor.withAlpha(150), width: 3)
              : null,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tier == CakeVisualTier.normal
                ? Colors.transparent
                : tier.primaryColor.withAlpha(80),
          ),
          child: Assets.images.cake
                  .image(fit: BoxFit.contain)
                  .animate(controller: animationController)
                  .scale(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.bounceInOut,
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.1, 1.1),
                  ),
        ),
      ),
    );
  }
}
