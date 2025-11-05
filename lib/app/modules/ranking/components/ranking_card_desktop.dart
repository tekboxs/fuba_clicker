import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';
import 'package:fuba_clicker/gen/assets.gen.dart';

class RankingCardDesktop extends StatelessWidget {
  final RankingEntry entry;
  final int rank;

  const RankingCardDesktop({
    super.key,
    required this.entry,
    required this.rank,
  });

  bool get _isFirst => rank == 1;

  List<Color> _getRankGradient() {
    switch (rank) {
      case 1:
        return [
          const Color(0xFFFBBF24),
          const Color(0xFFF59E0B),
          const Color(0xFFCA8A04),
        ];
      case 2:
        return [
          const Color(0xFFD1D5DB),
          const Color(0xFF9CA3AF),
          const Color(0xFF6B7280),
        ];
      case 3:
        return [
          const Color(0xFFFB923C),
          const Color(0xFFF97316),
          const Color(0xFFC2410C),
        ];
      default:
        return [
          const Color(0xFF6B7280),
          const Color(0xFF4B5563),
        ];
    }
  }

  Color _getRankGlow() {
    switch (rank) {
      case 1:
        return const Color(0xFFFBBF24).withValues(alpha: 0.5);
      case 2:
        return const Color(0xFFD1D5DB).withValues(alpha: 0.4);
      case 3:
        return const Color(0xFFFB923C).withValues(alpha: 0.4);
      default:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }

  Color _getRankBorder() {
    switch (rank) {
      case 1:
        return const Color(0xFFFBBF24).withValues(alpha: 0.3);
      case 2:
        return const Color(0xFF9CA3AF).withValues(alpha: 0.3);
      case 3:
        return const Color(0xFFFB923C).withValues(alpha: 0.3);
      default:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }

  Color _getRankCrownColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getRankGradient();
    final glow = _getRankGlow();
    final borderColor = _getRankBorder();

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: glow,
            blurRadius: 40,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 60,
            spreadRadius: -20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.95),
                  const Color(0xFF1E293B).withValues(alpha: 0.95),
                  const Color(0xFF0F172A).withValues(alpha: 0.95),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gradient[0].withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                _buildHologramLines(),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 350;
                    final padding = isSmall ? 16.0 : 24.0;
                    final avatarSize = isSmall ? 60.0 : 80.0;
                    final fontSize = isSmall ? 32.0 : 64.0;
                    final iconSize = isSmall ? 32.0 : 48.0;
                    final avatarTextSize = isSmall ? 24.0 : 32.0;

                    return Padding(
                      padding: EdgeInsets.all(padding),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: isSmall ? 8 : 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            if (_isFirst) ...[
                                              _buildAnimatedRings(avatarSize),
                                            ],
                                            Container(
                                              width: avatarSize,
                                              height: avatarSize,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: gradient,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: glow,
                                                    blurRadius: 40,
                                                    spreadRadius: 0,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      entry.username
                                                          .substring(0, 1)
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize:
                                                            avatarTextSize,
                                                      ),
                                                    ),
                                                  ),
                                                  _buildShineEffect(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: isSmall ? 8 : 12),
                                        Container(
                                          constraints: BoxConstraints(
                                              maxWidth: isSmall ? 80 : 120),
                                          child: Text(
                                            entry.username,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: isSmall ? 14 : 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: -20,
                                      left: -8,
                                      child: Transform.rotate(
                                        angle: -35 * pi / 180,
                                        child: Assets.images.crown.image(
                                          width: 28,
                                          height: 28,
                                          color: _getRankCrownColor(),
                                        ),
                                      ).animate(
                                        onPlay: (controller) {
                                          controller.repeat(reverse: true);
                                        },
                                      ).moveY(
                                        begin: -10,
                                        duration: 1.seconds,
                                        end: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: isSmall ? 12 : 24),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: ShaderMask(
                                              shaderCallback: (bounds) =>
                                                  LinearGradient(
                                                colors: gradient,
                                              ).createShader(bounds),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  entry.furuborusCount
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight.w900,
                                                    shadows: const [
                                                      Shadow(
                                                        color: Colors.black,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: isSmall ? 6 : 10),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: isSmall ? 8 : 12),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Assets.images.forus.image(
                                                  width: iconSize,
                                                  height: iconSize,
                                                ),
                                                SizedBox(
                                                    height: isSmall ? 4 : 8),
                                                Text(
                                                  'Forus',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: isSmall ? 10 : 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmall ? 16 : 24),
                            isSmall
                                ? Column(
                                    children: [
                                      _buildStatBadge(
                                        icon: Icons.diamond,
                                        value:
                                            entry.transcendenceCount.toString(),
                                        color: const Color(0xFF22D3EE),
                                        isSmall: true,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildStatBadge(
                                        icon: Icons.emoji_events,
                                        value:
                                            entry.achievementCount.toString(),
                                        color: const Color(0xFFEC4899),
                                        isSmall: true,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildStatBadge(
                                        icon: Icons.repeat,
                                        value: entry.rebirthCount.toString(),
                                        color: const Color(0xFF10B981),
                                        isSmall: true,
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatBadge(
                                          icon: Icons.diamond,
                                          value: entry.transcendenceCount
                                              .toString(),
                                          color: const Color(0xFF22D3EE),
                                          isSmall: false,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildStatBadge(
                                          icon: Icons.emoji_events,
                                          value:
                                              entry.achievementCount.toString(),
                                          color: const Color(0xFFEC4899),
                                          isSmall: false,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildStatBadge(
                                          icon: Icons.repeat,
                                          value: entry.rebirthCount.toString(),
                                          color: const Color(0xFF10B981),
                                          isSmall: false,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_isFirst)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            gradient[0].withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .fadeIn(
                          duration: 2.seconds,
                          curve: Curves.easeInOut,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required Color color,
    required bool isSmall,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: isSmall ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmall ? 16 : 20,
            color: color,
          ),
          SizedBox(width: isSmall ? 6 : 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: isSmall ? 16 : 20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHologramLines() {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 3),
        onEnd: () {},
        builder: (context, value, child) {
          return CustomPaint(
            painter: _HologramPainter(value),
          );
        },
      ),
    );
  }

  Widget _buildShineEffect() {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: -1.0, end: 2.0),
        duration: const Duration(seconds: 3),
        onEnd: () {},
        builder: (context, value, child) {
          return CustomPaint(
            painter: _ShinePainter(value),
          );
        },
      ).animate(
        onPlay: (controller) => controller.repeat(),
      ),
    );
  }

  Widget _buildAnimatedRings(double avatarSize) {
    return Positioned.fill(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (int i = 0; i < 2; i++)
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getRankGlow(),
                    width: 2,
                  ),
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.3, 1.3),
                    duration: 2.seconds,
                    delay: (i * 500).ms,
                    curve: Curves.easeOut,
                  )
                  .then()
                  .fadeOut(
                    duration: 2.seconds,
                    curve: Curves.easeOut,
                  ),
          ],
        ),
      ),
    );
  }
}

class _HologramPainter extends CustomPainter {
  final double progress;

  _HologramPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const lineSpacing = 4.0;
    final offsetY = (size.height * progress) % (lineSpacing * 2);

    for (double y = -offsetY; y < size.height; y += lineSpacing * 2) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HologramPainter oldDelegate) => true;
}

class _ShinePainter extends CustomPainter {
  final double progress;

  _ShinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0 + progress, -1.0 + progress),
        end: Alignment(1.0 + progress, 1.0 + progress),
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShinePainter oldDelegate) => true;
}
