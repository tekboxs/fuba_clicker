import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/cake_accessory.dart';

class AccessoryShapePainter extends CustomPainter {
  final AccessoryShape shape;
  final Color color;
  final double size;

  AccessoryShapePainter({
    required this.shape,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2;

    switch (shape) {
      case AccessoryShape.circle:
        canvas.drawCircle(center, radius, paint);
        canvas.drawCircle(center, radius, strokePaint);
        break;
      case AccessoryShape.triangle:
        _drawTriangle(canvas, center, radius, paint, strokePaint);
        break;
      case AccessoryShape.square:
        _drawSquare(canvas, center, radius, paint, strokePaint);
        break;
      case AccessoryShape.pentagon:
        _drawPolygon(canvas, center, radius, 5, paint, strokePaint);
        break;
      case AccessoryShape.hexagon:
        _drawPolygon(canvas, center, radius, 6, paint, strokePaint);
        break;
      case AccessoryShape.octagon:
        _drawPolygon(canvas, center, radius, 8, paint, strokePaint);
        break;
    }
  }

  void _drawTriangle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    final path = Path();
    final angle = -pi / 2;
    for (int i = 0; i < 3; i++) {
      final x = center.dx + cos(angle + (i * 2 * pi / 3)) * radius;
      final y = center.dy + sin(angle + (i * 2 * pi / 3)) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawSquare(
    Canvas canvas,
    Offset center,
    double radius,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, strokePaint);
  }

  void _drawPolygon(
    Canvas canvas,
    Offset center,
    double radius,
    int sides,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    final path = Path();
    final angle = -pi / 2;
    for (int i = 0; i < sides; i++) {
      final x = center.dx + cos(angle + (i * 2 * pi / sides)) * radius;
      final y = center.dy + sin(angle + (i * 2 * pi / sides)) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is AccessoryShapePainter &&
        (oldDelegate.shape != shape ||
            oldDelegate.color != color ||
            oldDelegate.size != size);
  }
}

class FloatingAccessories extends StatefulWidget {
  const FloatingAccessories({
    super.key,
    required this.accessories,
    required this.centerSize,
  });

  final List<CakeAccessory> accessories;
  final double centerSize;

  @override
  State<FloatingAccessories> createState() => _FloatingAccessoriesState();
}

class _FloatingAccessoriesState extends State<FloatingAccessories>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<double> _angles = [];
  final List<double> _distances = [];
  final List<double> _speeds = [];

  @override
  void initState() {
    super.initState();
    _initializeAccessories();
  }

  @override
  void didUpdateWidget(FloatingAccessories oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.accessories.length != oldWidget.accessories.length) {
      _updateAccessories(oldWidget.accessories.length);
    }
  }

  void _initializeAccessories() {
    final random = Random();
    for (int i = 0; i < widget.accessories.length; i++) {
      _addAccessoryController(i, random);
    }
  }

  void _addAccessoryController(int index, Random random) {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 8000 + random.nextInt(4000)),
    );
    controller.repeat();
    _controllers.add(controller);

    _angles.add((360 / widget.accessories.length) * index);
    _distances.add(widget.centerSize / 2 + 40 + random.nextDouble() * 30);
    _speeds.add(1.0);
  }

  void _updateAccessories(int oldLength) {
    final random = Random();
    final newLength = widget.accessories.length;

    if (newLength > oldLength) {
      for (int i = oldLength; i < newLength; i++) {
        _addAccessoryController(i, random);
      }
    } else if (newLength < oldLength) {
      for (int i = oldLength - 1; i >= newLength; i--) {
        _controllers[i].dispose();
        _controllers.removeAt(i);
        _angles.removeAt(i);
        _distances.removeAt(i);
        _speeds.removeAt(i);
      }
    }

    for (int i = 0; i < _angles.length; i++) {
      _angles[i] = (360 / widget.accessories.length) * i;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.accessories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.centerSize + 200,
      height: widget.centerSize + 200,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(
          widget.accessories.length,
          (index) => _buildFloatingAccessory(index),
        ),
      ),
    );
  }

  Widget _buildFloatingAccessory(int index) {
    return AnimatedBuilder(
      animation: _controllers[index],
      builder: (context, child) {
        final angle =
            _angles[index] + (_controllers[index].value * 360 * _speeds[index]);
        final radians = angle * pi / 180;
        final distance = _distances[index];

        final x = cos(radians) * distance;
        final y = sin(radians) * distance;

        return Transform.translate(offset: Offset(x, y), child: child);
      },
      child:
          SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: AccessoryShapePainter(
                        shape: widget.accessories[index].shape,
                        color: widget.accessories[index].rarity.color.withAlpha(
                          90,
                        ),
                        size: 53,
                      ),
                    ),
                    Text(
                      widget.accessories[index].emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              )
              .animate(
                autoPlay: true,
                onComplete: (controller) => controller.repeat(),
              )
              .shimmer(
                duration: 2.seconds,
                color: widget.accessories[index].rarity.color.withAlpha(100),
              ),
    );
  }
}
