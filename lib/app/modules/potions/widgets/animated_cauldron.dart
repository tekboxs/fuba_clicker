import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/potion_color.dart';
import '../../../theme/tokens.dart';

class AnimatedCauldron extends StatefulWidget {
  final Map<PotionColor, int> cauldron;
  final double size;

  const AnimatedCauldron({
    super.key,
    required this.cauldron,
    this.size = 250,
  });

  @override
  State<AnimatedCauldron> createState() => _AnimatedCauldronState();
}

class _AnimatedCauldronState extends State<AnimatedCauldron>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  int _cycleCount = 0;
  double _lastValue = 0.0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )
      ..addListener(() {
        setState(() {
          final currentValue = _waveController.value;
          // Detecta quando o controller reseta (valor voltou para próximo de 0)
          if (currentValue < 0.1 && _lastValue > 0.9) {
            _cycleCount++;
          }
          _lastValue = currentValue;
        });
      })
      ..repeat();
  }

  double get _continuousAnimationValue => _cycleCount + _waveController.value;

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Color _calculateLiquidColor() {
    if (widget.cauldron.isEmpty) {
      return Colors.grey.withAlpha(100);
    }

    final totalColors =
        widget.cauldron.values.fold(0, (sum, count) => sum + count);
    if (totalColors == 0) {
      return Colors.grey.withAlpha(100);
    }

    double r = 0, g = 0, b = 0;
    for (final entry in widget.cauldron.entries) {
      final color = entry.key.color;
      final weight = entry.value / totalColors;
      r += color.red * weight;
      g += color.green * weight;
      b += color.blue * weight;
    }

    return Color.fromRGBO(
      r.toInt().clamp(0, 255),
      g.toInt().clamp(0, 255),
      b.toInt().clamp(0, 255),
      0.9,
    );
  }

  double _calculateLiquidLevel() {
    final totalColors =
        widget.cauldron.values.fold(0, (sum, count) => sum + count);
    if (totalColors == 0) return 0.0;
    return (totalColors / 200).clamp(0.15, 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final liquidColor = _calculateLiquidColor();
    final liquidLevel = _calculateLiquidLevel();
    final totalColors =
        widget.cauldron.values.fold(0, (sum, count) => sum + count);
    final hasLiquid = totalColors > 0;

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size * 1.1,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: -widget.size * 0.05,
                child: Container(
                  width: widget.size * 0.85,
                  height: widget.size * 0.12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.size * 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: hasLiquid
                            ? liquidColor.withAlpha(80)
                            : AppColors.primary.withAlpha(40),
                        blurRadius: 32,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(180),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              ClipPath(
                clipper: CauldronClipper(),
                child: Container(
                  width: widget.size,
                  height: widget.size * 1.0,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.2,
                      colors: [
                        AppColors.card.withAlpha(220),
                        AppColors.card.withAlpha(200),
                        AppColors.secondary.withAlpha(220),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    border: Border.all(
                      color: hasLiquid
                          ? liquidColor.withAlpha(100)
                          : AppColors.border.withAlpha(80),
                      width: 2,
                    ),
                  ),
                  child: CustomPaint(
                    size: Size(widget.size, widget.size * 1.0),
                    painter: CauldronShapePainter(
                      liquidColor: liquidColor,
                      liquidLevel: liquidLevel,
                      animation: _continuousAnimationValue,
                      hasLiquid: hasLiquid,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: widget.size * 0.18,
                left: widget.size * 0.05,
                child: CustomPaint(
                  size: Size(widget.size * 0.2, widget.size * 0.25),
                  painter: CauldronHandlePainter(),
                ),
              ),
              Positioned(
                top: widget.size * 0.18,
                right: widget.size * 0.05,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(3.14159),
                  child: CustomPaint(
                    size: Size(widget.size * 0.2, widget.size * 0.25),
                    painter: CauldronHandlePainter(),
                  ),
                ),
              ),
              if (totalColors > 0)
                Positioned(
                  bottom: widget.size * 0.28,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.size * 0.08,
                      vertical: widget.size * 0.04,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.card.withAlpha(240),
                          AppColors.secondary.withAlpha(240),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: liquidColor.withAlpha(200),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: liquidColor.withAlpha(150),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: Colors.black.withAlpha(200),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: widget.size * 0.06,
                          height: widget.size * 0.06,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                liquidColor,
                                liquidColor.withAlpha(180),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: liquidColor.withAlpha(200),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: widget.size * 0.04),
                        Text(
                          '$totalColors',
                          style: TextStyle(
                            color: AppColors.foreground,
                            fontSize: widget.size * 0.11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: liquidColor.withAlpha(200),
                                blurRadius: 12,
                              ),
                              Shadow(
                                color: Colors.black.withAlpha(200),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class CauldronClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final centerX = size.width / 2;
    final bottomY = size.height * 0.95;
    
    // Formato U invertido: mais largo no topo, estreito na base
    final topWidth = size.width * 0.9;
    final topY = size.height * 0.15;
    final baseWidth = size.width * 0.4;
    final baseLeft = centerX - baseWidth / 2;
    final baseRight = centerX + baseWidth / 2;
    final baseY = bottomY - size.height * 0.1;
    
    final path = Path();
    path.moveTo(baseLeft, baseY);
    
    // Lado esquerdo - curva suave para fora conforme sobe
    path.quadraticBezierTo(
      baseLeft - size.width * 0.05,
      (baseY + topY) / 2,
      centerX - topWidth / 2,
      topY,
    );
    
    // Topo
    path.lineTo(centerX + topWidth / 2, topY);
    
    // Lado direito - curva suave para dentro conforme desce
    path.quadraticBezierTo(
      baseRight + size.width * 0.05,
      (baseY + topY) / 2,
      baseRight,
      baseY,
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CauldronClipper oldClipper) => false;
}

class CauldronShapePainter extends CustomPainter {
  final Color liquidColor;
  final double liquidLevel;
  final double animation;
  final bool hasLiquid;

  CauldronShapePainter({
    required this.liquidColor,
    required this.liquidLevel,
    required this.animation,
    required this.hasLiquid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottomY = size.height * 0.95;

    // Formato U invertido: mais largo no topo, estreito na base
    // O líquido preenche toda a área vermelha do desenho

    // Topo do caldeirão (mais largo) - onde o líquido começa
    final topWidth = size.width * 0.9;
    final topY = size.height * 0.15;

    // Base do caldeirão (mais estreita) - formato U invertido
    final baseWidth = size.width * 0.4;
    final baseLeft = centerX - baseWidth / 2;
    final baseRight = centerX + baseWidth / 2;
    final baseY = bottomY - size.height * 0.1; // Deixa espaço para as pernas

    final legWidth = size.width * 0.06;
    final legHeight = size.height * 0.08;
    final legSpacing = size.width * 0.12;

    final legGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.secondary,
        AppColors.secondary.withAlpha(200),
        AppColors.accent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final leftLegPath = Path();
    leftLegPath.moveTo(centerX - legSpacing, baseY);
    leftLegPath.lineTo(centerX - legSpacing - legWidth / 2, baseY + legHeight);
    leftLegPath.lineTo(centerX - legSpacing + legWidth / 2, baseY + legHeight);
    leftLegPath.close();

    final centerLegPath = Path();
    centerLegPath.moveTo(centerX, baseY);
    centerLegPath.lineTo(centerX - legWidth / 2, baseY + legHeight);
    centerLegPath.lineTo(centerX + legWidth / 2, baseY + legHeight);
    centerLegPath.close();

    final rightLegPath = Path();
    rightLegPath.moveTo(centerX + legSpacing, baseY);
    rightLegPath.lineTo(centerX + legSpacing - legWidth / 2, baseY + legHeight);
    rightLegPath.lineTo(centerX + legSpacing + legWidth / 2, baseY + legHeight);
    rightLegPath.close();

    final legPaint = Paint()
      ..shader = legGradient.createShader(
        Rect.fromLTWH(centerX - legSpacing - legWidth, baseY, legSpacing * 2 + legWidth * 2, legHeight),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(leftLegPath, legPaint);
    canvas.drawPath(centerLegPath, legPaint);
    canvas.drawPath(rightLegPath, legPaint);

    final legBorderPaint = Paint()
      ..color = AppColors.border.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(leftLegPath, legBorderPaint);
    canvas.drawPath(centerLegPath, legBorderPaint);
    canvas.drawPath(rightLegPath, legBorderPaint);

    // Desenha o líquido (área vermelha do desenho) - formato U invertido
    if (liquidLevel > 0) {
      final liquidPath = Path();

      // O líquido preenche de baixo para cima
      final liquidTopY = baseY - (baseY - topY) * liquidLevel;

      // Calcula a largura do líquido na altura atual (formato U invertido)
      // Quanto mais alto, mais largo
      final progress = (baseY - liquidTopY) / (baseY - topY);
      final liquidWidth = baseWidth + (topWidth - baseWidth) * progress;
      final liquidLeft = centerX - liquidWidth / 2;
      final liquidRight = centerX + liquidWidth / 2;

      // Desenha o formato U invertido do líquido
      // Começa na base esquerda
      liquidPath.moveTo(baseLeft, baseY);

      // Lado esquerdo - curva suave para fora conforme sobe
      liquidPath.quadraticBezierTo(
        baseLeft - size.width * 0.05, // Ponto de controle para fora
        (baseY + liquidTopY) / 2, // Meio caminho
        liquidLeft,
        liquidTopY,
      );

      final waveHeight = size.height * 0.02;
      final waveLength = liquidWidth / 110.5;
      final continuousAnimation = animation * 2 * math.pi;

      for (double x = liquidLeft; x <= liquidRight; x += 1) {
        final normalizedX = (x - liquidLeft) / liquidWidth;
        final y = liquidTopY +
            (waveHeight *
                math.sin((normalizedX * waveLength * 2 * math.pi) +
                    continuousAnimation));
        liquidPath.lineTo(x, y);
      }

      // Lado direito - curva suave para dentro conforme desce
      liquidPath.quadraticBezierTo(
        baseRight + size.width * 0.05, // Ponto de controle para fora
        (baseY + liquidTopY) / 2, // Meio caminho
        baseRight,
        baseY,
      );

      liquidPath.close();

      final liquidGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          liquidColor.withOpacity(0.98),
          liquidColor,
          liquidColor.withOpacity(0.95),
          liquidColor.withAlpha(220),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );

      final liquidPaint = Paint()
        ..shader = liquidGradient.createShader(
          Rect.fromLTWH(liquidLeft, liquidTopY - waveHeight, liquidWidth,
              baseY - liquidTopY + waveHeight),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(liquidPath, liquidPaint);

      final highlightPath = Path();
      highlightPath.moveTo(liquidLeft, liquidTopY);

      for (double x = liquidLeft; x <= liquidRight; x += 1) {
        final normalizedX = (x - liquidLeft) / liquidWidth;
        final y = liquidTopY +
            waveHeight *
                0.5 *
                math.sin((normalizedX * waveLength * 2 * math.pi) +
                    continuousAnimation +
                    math.pi / 2);
        highlightPath.lineTo(x, y);
      }

      highlightPath.lineTo(liquidRight, liquidTopY);
      highlightPath.close();

      final highlightGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withAlpha(180),
          liquidColor.withAlpha(80),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      );

      final highlightPaint = Paint()
        ..shader = highlightGradient.createShader(
          Rect.fromLTWH(
              liquidLeft, liquidTopY - waveHeight, liquidWidth, waveHeight * 3),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(highlightPath, highlightPaint);

      final rimReflectionPath = Path();
      rimReflectionPath.moveTo(liquidLeft, liquidTopY);
      for (double x = liquidLeft; x <= liquidRight; x += 1) {
        final normalizedX = (x - liquidLeft) / liquidWidth;
        final y = liquidTopY +
            waveHeight *
                0.2 *
                math.sin((normalizedX * waveLength * 2 * math.pi) +
                    continuousAnimation);
        rimReflectionPath.lineTo(x, y);
      }
      rimReflectionPath.lineTo(liquidRight, liquidTopY);
      rimReflectionPath.close();

      final rimReflectionPaint = Paint()
        ..color = liquidColor.withAlpha(100)
        ..style = PaintingStyle.fill;

      canvas.drawPath(rimReflectionPath, rimReflectionPaint);

      for (int i = 0; i < 6; i++) {
        final bubbleX =
            liquidLeft + (i % 3) * (liquidWidth / 3) + liquidWidth / 6;
        final bubbleY = liquidTopY +
            size.height * 0.1 -
            ((animation * 120 + i * 25) % (size.height * 0.5));
        final bubbleSize = 2.5 + (i % 3) * 1.5;

        if (bubbleY > liquidTopY && bubbleY < baseY) {
          final bubbleGradient = RadialGradient(
            colors: [
              Colors.white.withAlpha(180),
              Colors.white.withAlpha(100),
              liquidColor.withAlpha(60),
            ],
            stops: const [0.0, 0.5, 1.0],
          );

          final bubblePaint = Paint()
            ..shader = bubbleGradient.createShader(
              Rect.fromCircle(
                center: Offset(bubbleX, bubbleY),
                radius: bubbleSize,
              ),
            )
            ..style = PaintingStyle.fill;

          canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleSize, bubblePaint);

          final bubbleHighlightPaint = Paint()
            ..color = Colors.white.withAlpha(200)
            ..style = PaintingStyle.fill;

          canvas.drawCircle(
            Offset(bubbleX - bubbleSize * 0.3, bubbleY - bubbleSize * 0.3),
            bubbleSize * 0.3,
            bubbleHighlightPaint,
          );
        }
      }
    }

    final rimWidth = size.width * 0.98;
    final rimLeft = centerX - rimWidth / 2;
    final rimY = topY - size.height * 0.06;
    final rimThickness = size.height * 0.07;

    final rimPath = Path();
    rimPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rimLeft, rimY, rimWidth, rimThickness),
        Radius.circular(rimThickness / 2),
      ),
    );

    final rimGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.secondary,
        AppColors.accent,
        AppColors.secondary.withAlpha(220),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rimPaint = Paint()
      ..shader = rimGradient.createShader(
        Rect.fromLTWH(rimLeft, rimY, rimWidth, rimThickness),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(rimPath, rimPaint);

    final rimBorderPaint = Paint()
      ..color = hasLiquid
          ? liquidColor.withAlpha(180)
          : AppColors.primary.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(rimPath, rimBorderPaint);

    final rimHighlightPaint = Paint()
      ..color = Colors.white.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rimHighlightPath = Path();
    rimHighlightPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rimLeft + 2, rimY + 1, rimWidth - 4, rimThickness * 0.3),
        Radius.circular(rimThickness / 2),
      ),
    );
    canvas.drawPath(rimHighlightPath, rimHighlightPaint);
  }

  @override
  bool shouldRepaint(CauldronShapePainter oldDelegate) {
    return oldDelegate.liquidColor != liquidColor ||
        oldDelegate.liquidLevel != liquidLevel ||
        oldDelegate.animation != animation ||
        oldDelegate.hasLiquid != hasLiquid;
  }
}

class CauldronHandlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.4,
      size.width * 0.4,
      size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.5,
    );

    final handleGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.secondary,
        AppColors.accent,
        AppColors.secondary.withAlpha(220),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = handleGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(CauldronHandlePainter oldDelegate) => false;
}
