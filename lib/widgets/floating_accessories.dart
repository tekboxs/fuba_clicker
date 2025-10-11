import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/cake_accessory.dart';

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

        return Transform.translate(
          offset: Offset(x, y),
          child: child,
        );
      },
      child:
          Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accessories[index].rarity.color.withAlpha(30),
                  border: Border.all(
                    color: widget.accessories[index].rarity.color.withAlpha(
                      100,
                    ),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.accessories[index].emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
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
