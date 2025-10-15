import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  Color color;
  double size;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    this.size = 4.0,
  });
}

class ParticleSystem extends StatefulWidget {
  final bool shouldAnimate;
  final VoidCallback? onComplete;
  final Color particleColor;

  const ParticleSystem({
    super.key,
    required this.shouldAnimate,
    this.onComplete,
    this.particleColor = Colors.orange,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    if (widget.shouldAnimate) {
      _generateParticles();
      _controller.forward().then((_) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    }
  }

  @override
  void didUpdateWidget(ParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate && !oldWidget.shouldAnimate) {
      _generateParticles();
      _controller.forward().then((_) {
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    }
  }

  void _generateParticles() {
    _particles.clear();
    final particleCount = GameConstants.particleCount;
    for (int i = 0; i < particleCount; i++) {
      _particles.add(Particle(
        x: 50 + _random.nextDouble() * 100,
        y: 50 + _random.nextDouble() * 100,
        vx: (_random.nextDouble() - 0.5) * 200,
        vy: (_random.nextDouble() - 0.5) * 200,
        life: 1.0,
        color: widget.particleColor,
        size: 2.0 + _random.nextDouble() * 4.0,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shouldAnimate || _particles.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          _updateParticles();
          return CustomPaint(
            painter: ParticlePainter(_particles),
            size: const Size(200, 200),
          );
        },
      ),
    );
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.x += particle.vx * _controller.value * 0.016;
      particle.y += particle.vy * _controller.value * 0.016;
      particle.life -= 0.02;
      particle.vy += 50 * 0.016;
    }
    _particles.removeWhere((particle) => particle.life <= 0);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.life)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * particle.life,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
