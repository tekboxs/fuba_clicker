import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../core/utils/efficient_number.dart';
import 'package:fuba_clicker/app/models/rebirth_upgrade.dart';
import 'package:fuba_clicker/app/providers/rebirth_upgrade_provider.dart';
import 'package:fuba_clicker/app/core/utils/difficulty_barriers.dart';
import 'package:fuba_clicker/app/theme/tokens.dart';

class HexagonalUpgradeCard extends ConsumerWidget {
  final RebirthUpgrade upgrade;
  final dynamic rebirthData;
  final bool isBarrierLocked;
  final DifficultyBarrier? barrier;
  final EfficientNumber fuba;
  final List<int> generatorsOwned;

  const HexagonalUpgradeCard({
    super.key,
    required this.upgrade,
    required this.rebirthData,
    required this.isBarrierLocked,
    this.barrier,
    required this.fuba,
    required this.generatorsOwned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final allUpgradesData = ref.watch(allUpgradesDataProvider);
        final upgradeData = allUpgradesData[upgrade.id]!;
        final currentLevel = upgradeData['currentLevel'] as int;
        final isMaxed = upgradeData['isMaxed'] as bool;
        final isLocked = upgradeData['isLocked'] as bool;

        final upgradeNotifier = ref.read(upgradeNotifierProvider);
        final canPurchase = upgradeNotifier.canPurchase(upgrade);

        final cardColors = _getCardColors(
          upgrade,
          isMaxed,
          isLocked,
          isBarrierLocked,
          canPurchase,
        );

        final isMobile = MediaQuery.of(context).size.width < 600;
        final cardWidth = isMobile ? double.infinity : 480.0;
        final cardHeight = isMobile ? 320.0 : 480.0;
        final iconSize = isMobile ? 60.0 : 80.0;
        final iconFontSize = isMobile ? 32.0 : 40.0;
        final verticalPadding = isMobile ? 100.0 : 120.0;

        return GestureDetector(
          onTap: canPurchase && !isMaxed && !isLocked && !isBarrierLocked
              ? () {
                  upgradeNotifier.purchaseUpgrade(upgrade);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${upgrade.name} melhorado!'),
                      backgroundColor: AppColors.emerald500,
                    ),
                  );
                }
              : null,
          child: Stack(
            children: [
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: CustomPaint(
                  painter: HexagonalPainter(
                    gradient: cardColors.gradient,
                    borderColor: cardColors.borderColor,
                    isLocked: isLocked || isBarrierLocked,
                    canPurchase: canPurchase &&
                        !isMaxed &&
                        !isLocked &&
                        !isBarrierLocked,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIcon(
                          upgrade,
                          isLocked,
                          isBarrierLocked,
                          canPurchase &&
                              !isMaxed &&
                              !isLocked &&
                              !isBarrierLocked,
                          iconSize,
                          iconFontSize,
                        ),
                        _buildContent(
                          upgrade,
                          currentLevel,
                          isMaxed,
                          isLocked,
                          isBarrierLocked,
                          canPurchase,
                          cardColors,
                          isMobile,
                        ),
                        const Spacer(),
                        _buildBanner(
                          upgrade,
                          isMaxed,
                          isLocked,
                          isBarrierLocked,
                          cardColors,
                          canPurchase &&
                              !isMaxed &&
                              !isLocked &&
                              !isBarrierLocked,
                          isMobile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (canPurchase && !isMaxed && !isLocked && !isBarrierLocked)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GlowPainter(
                        color: cardColors.borderColor,
                      ),
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                      duration: 2.seconds,
                      color: cardColors.borderColor.withOpacity(0.3),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon(
    RebirthUpgrade upgrade,
    bool isLocked,
    bool isBarrierLocked,
    bool canPurchase,
    double iconSize,
    double iconFontSize,
  ) {
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: isLocked || isBarrierLocked
              ? [
                  AppColors.muted.withAlpha(50),
                  AppColors.muted.withAlpha(30),
                ]
              : [
                  AppColors.foreground.withAlpha(30),
                  AppColors.foreground.withAlpha(10),
                ],
        ),
        border: Border.all(
          color: isLocked || isBarrierLocked
              ? AppColors.mutedForeground.withAlpha(100)
              : AppColors.foreground.withAlpha(150),
          width: 2,
        ),
        boxShadow: canPurchase
            ? [
                BoxShadow(
                  color: AppColors.cyan500.withAlpha(100),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            upgrade.emoji,
            style: TextStyle(
              fontSize: iconFontSize,
              color: isLocked || isBarrierLocked
                  ? AppColors.mutedForeground
                  : null,
            ),
          ).animate(
            onPlay: (controller) {
              if (canPurchase) controller.repeat(reverse: true);
            },
          ).scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 1.5.seconds,
            curve: Curves.easeInOut,
          ),
          if (isBarrierLocked)
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: AppColors.background.withAlpha(200),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                color: AppColors.mutedForeground,
                size: iconSize * 0.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(
    RebirthUpgrade upgrade,
    int currentLevel,
    bool isMaxed,
    bool isLocked,
    bool isBarrierLocked,
    bool canPurchase,
    CardColors cardColors,
    bool isMobile,
  ) {
    return Column(
      children: [
        Text(
          upgrade.name,
          style: TextStyle(
            fontSize: isMobile ? 14 : 18,
            fontWeight: FontWeight.bold,
            color: isLocked || isBarrierLocked
                ? AppColors.mutedForeground
                : AppColors.foreground,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isMobile ? 8 : 12),
        if (isBarrierLocked && barrier != null) ...[
          const SizedBox(),
          // _buildBarrierInfo(isMobile),
        ] else if (isLocked) ...[
          _buildLockedInfo(upgrade, isMobile),
        ] else if (!isMaxed) ...[
          // const SizedBox(),

          _buildUpgradeInfo(upgrade, currentLevel, canPurchase, isMobile),
        ] else ...[
          const SizedBox(),

          // _buildMaxedInfo(upgrade, currentLevel, isMobile),
        ],
      ],
    );
  }

  Widget _buildBarrierInfo(bool isMobile) {
    return Consumer(
      builder: (context, ref, child) {
        final progress = ref.watch(barrierProgressProvider(upgrade.id));

        return Column(
          children: [
            Text(
              '🔒 ${barrier!.description}',
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: AppColors.amber500,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 4 : 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: isMobile ? 6 : 8,
                backgroundColor: AppColors.muted,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.amber500),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: isMobile ? 8 : 10,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLockedInfo(RebirthUpgrade upgrade, bool isMobile) {
    return Text(
      'Requer ${upgrade.ascensionRequirement} Ascensões',
      style: TextStyle(
        fontSize: isMobile ? 10 : 12,
        color: AppColors.destructive,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUpgradeInfo(
    RebirthUpgrade upgrade,
    int currentLevel,
    bool canPurchase,
    bool isMobile,
  ) {
    final cost = upgrade.getTokenCost(currentLevel);

    return Column(
      children: [
        Text(
          upgrade.getEffectDescription(currentLevel + 1),
          style: TextStyle(
            fontSize: isMobile ? 9 : 11,
            color: AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isMobile ? 4 : 6),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 12,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.cyan500.withAlpha(200),
                AppColors.purple500.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: AppColors.cyan500.withAlpha(200),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan500.withAlpha(80),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💎', style: TextStyle(fontSize: isMobile ? 14 : 16)),
              SizedBox(width: isMobile ? 4 : 6),
              Text(
                '$cost',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  

  Widget _buildBanner(
    RebirthUpgrade upgrade,
    bool isMaxed,
    bool isLocked,
    bool isBarrierLocked,
    CardColors cardColors,
    bool canPurchase,
    bool isMobile,
  ) {
    String bannerText;
    if (isMaxed) {
      bannerText = 'MAX';
    } else if (isLocked || isBarrierLocked) {
      bannerText = 'LOCKED';
    } else {
      bannerText = 'UPGRADE';
    }
    if (bannerText != 'LOCKED') {
      return const SizedBox();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardColors.bannerColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: canPurchase
              ? AppColors.cyan500.withAlpha(150)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: canPurchase
            ? [
                BoxShadow(
                  color: cardColors.borderColor.withAlpha(100),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Text(
        bannerText,
        style: TextStyle(
          fontSize: isMobile ? 10 : 12,
          fontWeight: FontWeight.bold,
          color: AppColors.foreground,
          letterSpacing: 1.2,
        ),
      ),
    ).animate(
      onPlay: (controller) {
        if (canPurchase) controller.repeat();
      },
    ).shimmer(
      duration: 2.seconds,
      color: AppColors.cyan500.withOpacity(0.3),
    );
  }

  CardColors _getCardColors(
    RebirthUpgrade upgrade,
    bool isMaxed,
    bool isLocked,
    bool isBarrierLocked,
    bool canPurchase,
  ) {
    if (isMaxed) {
      return CardColors(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.emerald500, AppColors.emerald600],
        ),
        borderColor: AppColors.emerald500.withOpacity(0.8),
        bannerColors: [AppColors.emerald500, AppColors.emerald600],
      );
    }

    if (isLocked || isBarrierLocked) {
      return CardColors(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.muted, AppColors.muted.withAlpha(200)],
        ),
        borderColor: AppColors.mutedForeground.withOpacity(0.5),
        bannerColors: [AppColors.muted, AppColors.muted.withAlpha(200)],
      );
    }

    // Cores baseadas no tipo de upgrade
    switch (upgrade.id) {
      case 'auto_clicker':
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
          borderColor: Colors.blue.withOpacity(0.8),
          bannerColors: [Colors.blue.shade600, Colors.blue.shade800],
        );
      case 'click_power':
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
          ),
          borderColor: Colors.orange.withOpacity(0.8),
          bannerColors: [Colors.orange.shade600, Colors.orange.shade800],
        );
      case 'idle_boost':
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.purple500, AppColors.purple600],
          ),
          borderColor: AppColors.purple500.withOpacity(0.8),
          bannerColors: [AppColors.purple500, AppColors.purple600],
        );
      case 'lucky_boxes':
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.pink500, AppColors.pink600],
          ),
          borderColor: AppColors.pink500.withOpacity(0.8),
          bannerColors: [AppColors.pink500, AppColors.pink600],
        );
      case 'starting_fuba':
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          ),
          borderColor: Colors.green.withOpacity(0.8),
          bannerColors: [Colors.green.shade600, Colors.green.shade800],
        );
      case 'generator_discount':
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.cyan500, AppColors.cyan600],
          ),
          borderColor: AppColors.cyan500.withOpacity(0.8),
          bannerColors: [AppColors.cyan500, AppColors.cyan600],
        );
      case 'offline_production':
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF607D8B), Color(0xFF455A64)],
          ),
          borderColor: Colors.blueGrey.withOpacity(0.8),
          bannerColors: [Colors.blueGrey.shade600, Colors.blueGrey.shade800],
        );
      case 'production_multiplier':
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.amber500, AppColors.amber600],
          ),
          borderColor: AppColors.amber500.withOpacity(0.8),
          bannerColors: [AppColors.amber500, AppColors.amber600],
        );
      default:
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
          borderColor: Colors.blue.withOpacity(0.8),
          bannerColors: [Colors.blue.shade600, Colors.blue.shade800],
        );
    }
  }
}

class CardColors {
  final LinearGradient gradient;
  final Color borderColor;
  final List<Color> bannerColors;

  CardColors({
    required this.gradient,
    required this.borderColor,
    required this.bannerColors,
  });
}

class HexagonalPainter extends CustomPainter {
  final LinearGradient gradient;
  final Color borderColor;
  final bool isLocked;
  final bool canPurchase;

  HexagonalPainter({
    required this.gradient,
    required this.borderColor,
    required this.isLocked,
    this.canPurchase = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = canPurchase ? 2.5 : 2.0;

    final path = _createHexagonPath(size);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    if (!isLocked) {
      _drawSparkles(canvas, size);
    }

    if (canPurchase) {
      _drawGlow(canvas, size);
    }
  }

  Path _createHexagonPath(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final width = size.width * 0.9;
    final height = size.height * 0.9;

    // Criar um hexágono mais alongado verticalmente
    final points = [
      Offset(centerX, centerY - height * 0.4), // Topo
      Offset(centerX + width * 0.35, centerY - height * 0.2), // Topo direito
      Offset(centerX + width * 0.35, centerY + height * 0.2), // Base direita
      Offset(centerX, centerY + height * 0.4), // Base
      Offset(centerX - width * 0.35, centerY + height * 0.2), // Base esquerda
      Offset(centerX - width * 0.35, centerY - height * 0.2), // Topo esquerdo
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    return path;
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final sparklePaint = Paint()
      ..color = AppColors.cyan500.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final sparklePositions = [
      Offset(size.width * 0.2, size.height * 0.15),
      Offset(size.width * 0.8, size.height * 0.25),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.85, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.9),
    ];

    for (final position in sparklePositions) {
      canvas.drawCircle(position, 2.0, sparklePaint);
      final glowPaint = Paint()
        ..color = AppColors.cyan500.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(position, 4.0, glowPaint);
    }
  }

  void _drawGlow(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final path = _createHexagonPath(size);
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! HexagonalPainter) return true;
    return oldDelegate.gradient != gradient ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.isLocked != isLocked ||
        oldDelegate.canPurchase != canPurchase;
  }
}

class _GlowPainter extends CustomPainter {
  final Color color;

  _GlowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) * 0.3;

    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
