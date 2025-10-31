import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fuba_clicker/app/core/utils/efficient_number.dart';
import 'package:fuba_clicker/app/models/loot_box.dart';
import 'package:fuba_clicker/app/core/utils/difficulty_barriers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';

class LootBoxCard extends StatelessWidget {
  final LootBoxTier tier;
  final EfficientNumber fuba;
  final List<int> generatorsOwned;
  final bool isMobile;
  final void Function(LootBoxTier) onOpenSingle;
  final void Function(LootBoxTier, int) onOpenMultiple;

  const LootBoxCard({
    super.key,
    required this.tier,
    required this.fuba,
    required this.generatorsOwned,
    required this.isMobile,
    required this.onOpenSingle,
    required this.onOpenMultiple,
  });

  bool _isTierUnlocked() {
    final barriers = DifficultyBarrierManager.getBarriersForCategory('lootbox');

    if (tier == LootBoxTier.basic) {
      return true;
    }

    return barriers[tier.value - 1].isUnlocked(fuba, generatorsOwned);
  }

  String _raritySummary(LootBoxTier t) {
    final entries = t.rarityWeights.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final parts = entries.take(4).map((e) {
      final pct = (e.value * 100).toStringAsFixed(e.value >= 0.1 ? 0 : 2);
      final name = '${e.key.displayName}s';
      return '$pct% $name';
    }).toList();
    return parts.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = _isTierUnlocked();
    final tierCost = tier.getCost(fuba);
    final canAfford = isUnlocked && fuba.compareTo(tierCost) >= 0;
    final canAfford5 = isUnlocked &&
        fuba.compareTo(tierCost * EfficientNumber.parse('5')) >= 0;
    final canAfford10 = isUnlocked &&
        fuba.compareTo(tierCost * EfficientNumber.parse('10')) >= 0;
    bool canAfford50 = isUnlocked &&
        fuba.compareTo(tierCost * EfficientNumber.parse('50')) >= 0;

    EfficientNumber basePrimordial = EfficientNumber.parse('1e80');

    if (tier == LootBoxTier.primordial && fuba.compareTo(basePrimordial) > 0) {
      canAfford50 = true;
    }

    final isLocked = !isUnlocked;

    return Card(
      color: tier.color.withAlpha(isLocked ? 10 : 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 155,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [
                  tier.color.withAlpha(isLocked ? 30 : 120),
                  tier.color.withAlpha(isLocked ? 20 : 80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DotsPatternPainter(),
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isLocked)
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              tier.color,
                              tier.color.withAlpha(80),
                              tier.color.withAlpha(0),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      isLocked ? '🔒' : tier.emoji,
                      style: TextStyle(fontSize: isMobile ? 50 : 70),
                    )
                  ],
                )
                    .animate(
                      autoPlay: canAfford,
                      onComplete: (c) => c.repeat(reverse: true),
                    )
                    .moveY(
                      begin: 8,
                      end: -8,
                      duration: 1000.ms,
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            tier.displayName,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 14,
              vertical: isMobile ? 10 : 12,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(
              minHeight: 100,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Raridades:',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _raritySummary(tier),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 12 : 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLocked
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(50),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.withAlpha(100)),
                    ),
                    child: Center(
                      child: Text(
                        'BLOQUEADO',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 12 : 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _PurchaseButtons(
                    tier: tier,
                    fuba: fuba,
                    tierCost: tierCost,
                    canAfford: canAfford,
                    canAfford1: canAfford5,
                    canAfford10: canAfford10,
                    canAfford50: canAfford50,
                    isMobile: isMobile,
                    onOpenSingle: onOpenSingle,
                    onOpenMultiple: onOpenMultiple,
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PurchaseButtons extends StatelessWidget {
  final LootBoxTier tier;
  final EfficientNumber fuba;
  final EfficientNumber tierCost;
  final bool canAfford;
  final bool canAfford1;
  final bool canAfford10;
  final bool canAfford50;
  final bool isMobile;
  final void Function(LootBoxTier) onOpenSingle;
  final void Function(LootBoxTier, int) onOpenMultiple;

  const _PurchaseButtons({
    required this.tier,
    required this.fuba,
    required this.tierCost,
    required this.canAfford,
    required this.canAfford1,
    required this.canAfford10,
    required this.canAfford50,
    required this.isMobile,
    required this.onOpenSingle,
    required this.onOpenMultiple,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BulkPurchaseButton(
            tier: tier,
            quantity: 1,
            tierCost: tierCost,
            canAfford: canAfford1,
            isMobile: isMobile,
            onTap: () => onOpenMultiple(tier, 1),
            fuba: fuba,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: _BulkPurchaseButton(
            tier: tier,
            quantity: 10,
            tierCost: tierCost,
            canAfford: canAfford10,
            isMobile: isMobile,
            onTap: () => onOpenMultiple(tier, 10),
            fuba: fuba,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: _BulkPurchaseButton(
            tier: tier,
            quantity: 50,
            tierCost: tierCost,
            canAfford: canAfford50,
            isMobile: isMobile,
            onTap: () => onOpenMultiple(tier, 50),
            fuba: fuba,
          ),
        ),
      ],
    );
  }
}

class _BulkPurchaseButton extends StatelessWidget {
  final LootBoxTier tier;
  final int quantity;
  final EfficientNumber tierCost;
  final bool canAfford;
  final bool isMobile;
  final VoidCallback onTap;
  final EfficientNumber fuba;

  const _BulkPurchaseButton({
    required this.tier,
    required this.quantity,
    required this.tierCost,
    required this.canAfford,
    required this.isMobile,
    required this.onTap,
    required this.fuba,
  });

  @override
  Widget build(BuildContext context) {
    EfficientNumber totalCost =
        tierCost * EfficientNumber.parse(quantity.toString());
    if (tier == LootBoxTier.primordial && quantity == 30) {
      if (fuba.compareTo(EfficientNumber.parse('1e80')) > 0) {
        totalCost = fuba;
      }
    }

    const discount = 0;
    final discountedCost =
        totalCost * EfficientNumber.parse((1 - discount).toString());

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: canAfford
            ? Colors.deepOrange.withAlpha(50)
            : Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: canAfford ? Colors.deepOrange : Colors.grey,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAfford ? onTap : null,
          borderRadius: BorderRadius.circular(2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$quantity',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  color: canAfford ? Colors.deepOrange : Colors.grey,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  GameConstants.formatNumber(discountedCost),
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: canAfford ? Colors.orange : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..style = PaintingStyle.fill;

    const dotRadius = 1.0;
    const spacing = 21.0;

    for (double y = spacing / 3; y < size.height; y += spacing) {
      for (double x = spacing / 1.5; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
