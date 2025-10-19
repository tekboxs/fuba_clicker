import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/achievement.dart';
import '../utils/constants.dart';

class HexagonalAchievementBadge extends StatefulWidget {
  final AchievementDifficulty difficulty;
  final String emoji;
  final bool isUnlocked;
  final double? size;
  final bool enableAnimations;

  const HexagonalAchievementBadge({
    super.key,
    required this.difficulty,
    required this.emoji,
    this.isUnlocked = true,
    this.size,
    this.enableAnimations = true,
  });

  @override
  State<HexagonalAchievementBadge> createState() => _HexagonalAchievementBadgeState();
}

class _HexagonalAchievementBadgeState extends State<HexagonalAchievementBadge>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.enableAnimations) {
      _pulseController = AnimationController(
        duration: GameConstants.animationDurations[widget.difficulty.name] ?? const Duration(milliseconds: 500),
        vsync: this,
      );
      
      _sparkleController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );
      
      _glowController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );

      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );

      _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
      );

      _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
      );

      _startAnimations();
    }
  }

  void _startAnimations() {
    if (widget.difficulty.index >= AchievementDifficulty.rare.index) {
      _pulseController.repeat(reverse: true);
    }
    
    if (widget.difficulty.index >= AchievementDifficulty.epic.index) {
      _sparkleController.repeat();
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimations) {
      _pulseController.dispose();
      _sparkleController.dispose();
      _glowController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? GameConstants.badgeSizes[widget.difficulty.name] ?? 60.0;
    final isMobile = GameConstants.isMobile(context);
    final adjustedSize = isMobile ? size * 0.8 : size;

    Widget badge = SizedBox(
      width: adjustedSize,
      height: adjustedSize,
      child: CustomPaint(
        painter: HexagonalBadgePainter(
          difficulty: widget.difficulty,
          isUnlocked: widget.isUnlocked,
          sparkleAnimation: widget.enableAnimations ? _sparkleAnimation.value : 0.0,
          glowAnimation: widget.enableAnimations ? _glowAnimation.value : 0.3,
          pulseAnimation: widget.enableAnimations ? _pulseAnimation.value : 1.0,
        ),
        child: Center(
          child: Text(
            widget.isUnlocked ? widget.emoji : '❓',
            style: TextStyle(
              fontSize: adjustedSize * 0.4,
              color: widget.isUnlocked ? null : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );

    if (widget.enableAnimations && widget.difficulty.index >= AchievementDifficulty.epic.index) {
      return AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _sparkleController, _glowController]),
        builder: (context, child) => badge,
      );
    }

    return badge;
  }
}

class HexagonalBadgePainter extends CustomPainter {
  final AchievementDifficulty difficulty;
  final bool isUnlocked;
  final double sparkleAnimation;
  final double glowAnimation;
  final double pulseAnimation;

  HexagonalBadgePainter({
    required this.difficulty,
    required this.isUnlocked,
    required this.sparkleAnimation,
    required this.glowAnimation,
    required this.pulseAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * pulseAnimation;

    _drawHexagon(canvas, center, radius);
    _drawSparkles(canvas, size);
    _drawGlow(canvas, center, radius);
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius) {
    final paint = Paint();
    
    if (!isUnlocked) {
      paint.color = Colors.grey.shade800;
      paint.style = PaintingStyle.fill;
    } else {
      final gradient = RadialGradient(
        colors: [
          Colors.blue.shade300,
          Colors.blue.shade700,
        ],
      );
      paint.shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));
    }

    final path = _createHexagonPath(center, radius);
    canvas.drawPath(path, paint);

    _drawBorders(canvas, center, radius);
    _drawGlossyEffect(canvas, center, radius);
  }

  Path _createHexagonPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawBorders(Canvas canvas, Offset center, double radius) {
    if (!isUnlocked) return;

    final outerPaint = Paint()
      ..color = Colors.white.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final innerPaint = Paint()
      ..color = Colors.blue.shade200.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = _createHexagonPath(center, radius);
    canvas.drawPath(path, outerPaint);
    canvas.drawPath(path, innerPaint);
  }

  void _drawGlossyEffect(Canvas canvas, Offset center, double radius) {
    if (!isUnlocked) return;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withAlpha(100),
        Colors.transparent,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    final path = Path();
    final highlightSize = radius * 0.6;
    path.moveTo(center.dx - highlightSize, center.dy - highlightSize);
    path.lineTo(center.dx + highlightSize, center.dy - highlightSize);
    path.lineTo(center.dx + highlightSize * 0.7, center.dy + highlightSize * 0.7);
    path.lineTo(center.dx - highlightSize * 0.7, center.dy + highlightSize * 0.7);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawSparkles(Canvas canvas, Size size) {
    if (!isUnlocked) return;

    final sparkleCount = GameConstants.sparkleCounts[difficulty.name] ?? 3;
    final paint = Paint()
      ..color = Colors.white.withAlpha((255 * sparkleAnimation).round());

    for (int i = 0; i < sparkleCount; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sparkleSize = random.nextDouble() * 3 + 1;

      _drawSparkle(canvas, Offset(x, y), sparkleSize, paint);
    }

    if (difficulty.index >= AchievementDifficulty.rare.index) {
      _drawRadialRays(canvas, Offset(size.width / 2, size.height / 2), size.width / 2);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final points = [
      Offset(center.dx, center.dy - size),
      Offset(center.dx + size * 0.3, center.dy - size * 0.3),
      Offset(center.dx + size, center.dy),
      Offset(center.dx + size * 0.3, center.dy + size * 0.3),
      Offset(center.dx, center.dy + size),
      Offset(center.dx - size * 0.3, center.dy + size * 0.3),
      Offset(center.dx - size, center.dy),
      Offset(center.dx - size * 0.3, center.dy - size * 0.3),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawRadialRays(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white.withAlpha((80 * glowAnimation).round())
      ..strokeWidth = 1.0;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final endX = center.dx + (radius * 0.8) * math.cos(angle);
      final endY = center.dy + (radius * 0.8) * math.sin(angle);
      
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  void _drawGlow(Canvas canvas, Offset center, double radius) {
    if (!isUnlocked || difficulty.index < AchievementDifficulty.epic.index) return;

    final glowRadius = GameConstants.glowIntensities[difficulty.name] ?? 5.0;
    final paint = Paint()
      ..color = GameConstants.difficultyColors[difficulty.name]?.withAlpha((50 * glowAnimation).round()) ?? Colors.blue.withAlpha(50);

    final glowPath = _createHexagonPath(center, radius + glowRadius);
    canvas.drawPath(glowPath, paint);
  }

  @override
  bool shouldRepaint(HexagonalBadgePainter oldDelegate) {
    return oldDelegate.difficulty != difficulty ||
           oldDelegate.isUnlocked != isUnlocked ||
           oldDelegate.sparkleAnimation != sparkleAnimation ||
           oldDelegate.glowAnimation != glowAnimation ||
           oldDelegate.pulseAnimation != pulseAnimation;
  }
}
