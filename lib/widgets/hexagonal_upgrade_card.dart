import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../models/rebirth_upgrade.dart';
import '../providers/rebirth_upgrade_provider.dart';
import '../utils/difficulty_barriers.dart';

class HexagonalUpgradeCard extends ConsumerWidget {
  final RebirthUpgrade upgrade;
  final dynamic rebirthData;
  final bool isBarrierLocked;
  final DifficultyBarrier? barrier;
  final BigDecimal fuba;
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
    final upgradeNotifier = ref.watch(upgradeNotifierProvider);
    final currentLevel = upgradeNotifier.getUpgradeLevel(upgrade.id);
    final canPurchase = upgradeNotifier.canPurchase(upgrade);
    final isMaxed = currentLevel >= upgrade.maxLevel;
    final isLocked = rebirthData.ascensionCount < upgrade.ascensionRequirement;

    final cardColors = _getCardColors(
      upgrade,
      isMaxed,
      isLocked,
      isBarrierLocked,
      canPurchase,
    );

    return GestureDetector(
      onTap: canPurchase && !isMaxed && !isLocked && !isBarrierLocked
          ? () {
              final upgradeNotifier = ref.read(upgradeNotifierProvider);
              upgradeNotifier.purchaseUpgrade(upgrade);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${upgrade.name} melhorado!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          : null,
      child: SizedBox(
        width: 180,
        height: 220,
        child: CustomPaint(
          painter: HexagonalPainter(
            gradient: cardColors.gradient,
            borderColor: cardColors.borderColor,
            isLocked: isLocked || isBarrierLocked,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 90),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(upgrade, isLocked, isBarrierLocked),
                _buildContent(
                  upgrade,
                  currentLevel,
                  isMaxed,
                  isLocked,
                  isBarrierLocked,
                  canPurchase,
                  cardColors,
                ),
                Spacer(),
                _buildBanner(
                  upgrade,
                  isMaxed,
                  isLocked,
                  isBarrierLocked,
                  cardColors,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(
    RebirthUpgrade upgrade,
    bool isLocked,
    bool isBarrierLocked,
  ) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            upgrade.emoji,
            style: TextStyle(
              fontSize: 32,
              color: isLocked || isBarrierLocked ? Colors.grey.shade700 : null,
            ),
          ),
          if (isBarrierLocked)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, color: Colors.grey, size: 24),
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
  ) {
    return Column(
      children: [
        Text(
          upgrade.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isLocked || isBarrierLocked
                ? Colors.grey.shade600
                : Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (isBarrierLocked && barrier != null) ...[
          _buildBarrierInfo(),
        ] else if (isLocked) ...[
          _buildLockedInfo(upgrade),
        ] else if (!isMaxed) ...[
          _buildUpgradeInfo(upgrade, currentLevel, canPurchase),
        ] else ...[
          _buildMaxedInfo(upgrade, currentLevel),
        ],
      ],
    );
  }

  Widget _buildBarrierInfo() {
    final progress = barrier!.getProgress(fuba, generatorsOwned);

    return Column(
      children: [
        Text(
          '🔒 ${barrier!.description}',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        Text(
          '${(progress * 100).toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 8, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildLockedInfo(RebirthUpgrade upgrade) {
    return Text(
      'Requer ${upgrade.ascensionRequirement} Ascensões',
      style: const TextStyle(
        fontSize: 10,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUpgradeInfo(
    RebirthUpgrade upgrade,
    int currentLevel,
    bool canPurchase,
  ) {
    final cost = upgrade.getTokenCost(currentLevel);

    return Column(
      children: [
        Text(
          upgrade.getEffectDescription(currentLevel + 1),
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.cyan.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💎', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 2),
              Text(
                '$cost',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaxedInfo(RebirthUpgrade upgrade, int currentLevel) {
    return Text(
      upgrade.getEffectDescription(currentLevel),
      style: const TextStyle(
        fontSize: 9,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBanner(
    RebirthUpgrade upgrade,
    bool isMaxed,
    bool isLocked,
    bool isBarrierLocked,
    CardColors cardColors,
  ) {
    String bannerText;
    if (isMaxed) {
      bannerText = 'MAX';
    } else if (isLocked || isBarrierLocked) {
      bannerText = 'LOCKED';
    } else {
      bannerText = 'UPGRADE';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: cardColors.bannerColors),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        bannerText,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
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
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
        borderColor: Colors.green.withOpacity(0.8),
        bannerColors: [Colors.green.shade600, Colors.green.shade800],
      );
    }

    if (isLocked || isBarrierLocked) {
      return CardColors(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF424242), Color(0xFF212121)],
        ),
        borderColor: Colors.grey.withOpacity(0.5),
        bannerColors: [Colors.grey.shade600, Colors.grey.shade800],
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
            colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          ),
          borderColor: Colors.purple.withOpacity(0.8),
          bannerColors: [Colors.purple.shade600, Colors.purple.shade800],
        );
      case 'lucky_boxes':
        return CardColors(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
          ),
          borderColor: Colors.pink.withOpacity(0.8),
          bannerColors: [Colors.pink.shade600, Colors.pink.shade800],
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
            colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
          ),
          borderColor: Colors.cyan.withOpacity(0.8),
          bannerColors: [Colors.cyan.shade600, Colors.cyan.shade800],
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
            colors: [Color(0xFFFFC107), Color(0xFFFF8F00)],
          ),
          borderColor: Colors.amber.withOpacity(0.8),
          bannerColors: [Colors.amber.shade600, Colors.amber.shade800],
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

  HexagonalPainter({
    required this.gradient,
    required this.borderColor,
    required this.isLocked,
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
      ..strokeWidth = 2.0;

    final path = _createHexagonPath(size);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    if (!isLocked) {
      _drawSparkles(canvas, size);
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
      ..color = Colors.white.withOpacity(0.8)
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
      canvas.drawCircle(position, 1.5, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
