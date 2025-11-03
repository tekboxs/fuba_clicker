import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fuba_clicker/app/models/forus_upgrade.dart';
import 'package:fuba_clicker/app/providers/forus_upgrade_provider.dart';
import 'package:fuba_clicker/app/providers/rebirth_provider.dart';
import 'package:fuba_clicker/gen/assets.gen.dart';

class ForusUpgradeCard extends ConsumerWidget {
  final ForusUpgrade upgrade;
  final bool isMobile;

  const ForusUpgradeCard({
    super.key,
    required this.upgrade,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedUpgrades = ref.watch(forusUpgradesOwnedProvider);
    final rebirthData = ref.watch(rebirthDataProvider);
    final hasUpgrade = ownedUpgrades.contains(upgrade.id);
    final canPurchase = !hasUpgrade && rebirthData.forus >= upgrade.forusCost;

    return Card(
      // color: Colors.red,
      // color: const Color(0xFF0F1115),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasUpgrade
              ? Colors.green.withAlpha(100)
              : canPurchase
                  ? Colors.orange.withAlpha(150)
                  : Colors.white.withAlpha(50),
          width: 2,
        ),
      ),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: hasUpgrade
                ? [
                    Colors.green.withAlpha(30),
                    Colors.green.withAlpha(10),
                  ]
                : canPurchase
                    ? [
                        Colors.orange.withAlpha(40),
                        Colors.deepOrange.withAlpha(20),
                      ]
                    : [
                        Colors.grey.withAlpha(20),
                        Colors.grey.withAlpha(10),
                      ],
          ),
          boxShadow: [
            BoxShadow(
              color: hasUpgrade
                  ? Colors.green.withAlpha(50)
                  : canPurchase
                      ? Colors.orange.withAlpha(80)
                      : Colors.black.withAlpha(100),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isMobile ? 56 : 64,
                    height: isMobile ? 56 : 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D23),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: hasUpgrade
                              ? Colors.green.withAlpha(60)
                              : canPurchase
                                  ? Colors.orange.withAlpha(80)
                                  : Colors.white.withAlpha(40),
                          blurRadius: 12,
                          spreadRadius: canPurchase ? 1 : 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            upgrade.emoji,
                            style: TextStyle(fontSize: isMobile ? 32 : 36),
                          ),
                        ),
                        if (canPurchase && !hasUpgrade)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.transparent,
                                      Colors.orange.withAlpha(30),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            )
                                .animate(
                                  onComplete: (controller) =>
                                      controller.repeat(),
                                )
                                .shimmer(
                                  duration: 3.seconds,
                                  color: Colors.orange.withOpacity(0.3),
                                  angle: -0.5,
                                ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upgrade.name,
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate(
                          onComplete: (controller) {
                            if (canPurchase && !hasUpgrade) {
                              controller.repeat(reverse: true);
                            }
                          },
                        ).shimmer(
                          duration: canPurchase && !hasUpgrade
                              ? 2.5.seconds
                              : 0.seconds,
                          color: Colors.orange.withOpacity(0.2),
                          delay: 500.ms,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          upgrade.description,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D23),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: canPurchase && !hasUpgrade
                        ? Colors.orange.withAlpha(80)
                        : Colors.white.withAlpha(30),
                    width: canPurchase && !hasUpgrade ? 1.5 : 1,
                  ),
                  boxShadow: canPurchase && !hasUpgrade
                      ? [
                          BoxShadow(
                            color: Colors.orange.withAlpha(40),
                            blurRadius: 8,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          Assets.images.forus.path,
                          width: isMobile ? 24 : 28,
                          height: isMobile ? 24 : 28,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.diamond,
                              size: 24,
                              color: Colors.cyan,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Custo: ${upgrade.forusCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (canPurchase && !hasUpgrade)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: const Alignment(-1.5, 0),
                                end: const Alignment(1.5, 0),
                                stops: const [0.0, 0.5, 1.0],
                                colors: [
                                  Colors.transparent,
                                  Colors.orange.withAlpha(20),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        )
                            .animate(
                              onComplete: (controller) => controller.repeat(),
                            )
                            .shimmer(
                              duration: 4.seconds,
                              color: Colors.orange.withOpacity(0.25),
                              angle: 0,
                            ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: hasUpgrade
                        ? null
                        : canPurchase
                            ? () {
                                ref
                                    .read(forusUpgradeNotifierProvider)
                                    .purchaseUpgrade(upgrade);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${upgrade.name} adquirido!'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasUpgrade
                          ? Colors.grey.withAlpha(100)
                          : canPurchase
                              ? Colors.orange
                              : Colors.grey.withAlpha(100),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 14,
                        horizontal: isMobile ? 12 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: hasUpgrade || !canPurchase ? 0 : 6,
                      shadowColor: canPurchase && !hasUpgrade
                          ? Colors.orange.withAlpha(150)
                          : Colors.black,
                    ),
                    child: Text(
                      hasUpgrade
                          ? 'Já adquirido ✓'
                          : canPurchase
                              ? 'Comprar'
                              : 'Forus insuficiente',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  .animate(
                    onInit: (controller) {
                      if (canPurchase && !hasUpgrade) {
                        controller.repeat(reverse: true);
                      }
                    },
                    onComplete: (controller) => controller.repeat(),
                  )
                  .shimmer(
                    duration: 2.seconds,
                    color: Colors.white.withOpacity(0.4),
                    angle: 0,
                  ),
                  ),
            ],
          ),
        ),
      ),
    ).animate(
      effects: [
        FadeEffect(duration: 300.ms),
        ScaleEffect(
          begin: const Offset(0.9, 0.9),
          duration: 300.ms,
        ),
      ],
    );
  }
}
