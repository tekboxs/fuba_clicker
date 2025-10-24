import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wave_offset.dart';
import '../utils/constants.dart';
import '../providers/visual_settings_provider.dart';

/// Widget que cria o fundo com efeito de paralaxe
class ParallaxBackground extends ConsumerWidget {
  final AnimationController parallaxController;

  const ParallaxBackground({
    super.key,
    required this.parallaxController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disableParallax = ref.watch(disableParallaxProvider);
    
    if (disableParallax) {
      return const SizedBox.shrink();
    }
    
    final layerCount = GameConstants.getParallaxLayerCount(context);
    final layers = <Widget>[];
    
    if (layerCount >= 1) layers.add(_buildContinuousLayer('🌽', 8.3, 30, 0.3));
    if (layerCount >= 2) layers.add(_buildContinuousLayer('🌾', 5.5, 50, 0.5));
    if (layerCount >= 3) layers.add(_buildContinuousLayer('🌽', 9.7, 70, 0.4));
    if (layerCount >= 4) layers.add(_buildContinuousLayer('🌽', 3.9, 90, 0.3));
    
    return Positioned.fill(
      child: Stack(children: layers),
    );
  }

  /// Constrói uma camada contínua de elementos flutuantes
  Widget _buildContinuousLayer(
    String emoji,
    double speed,
    double fontSize,
    double opacity,
  ) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: parallaxController,
        builder: (context, child) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          return Stack(
            children: List.generate(10, (index) {
              final randomSeed = index * 12345 + speed.hashCode;
              final random = Random(randomSeed);

              final initialOffset = random.nextDouble() * screenWidth * 2;
              final baseOffset =
                  (parallaxController.value * screenWidth * speed + initialOffset) %
                  (screenWidth + 200);
              final offset = baseOffset;

              final waveOffset = _calculateWaveOffset(
                parallaxController.value + (index * 0.1),
                index,
                speed,
                screenWidth,
              );

              final randomVerticalOffset = random.nextDouble() * screenHeight;

              return Positioned(
                left: offset + waveOffset.horizontal - 30,
                top: waveOffset.vertical + randomVerticalOffset,
                child: Opacity(
                  opacity: opacity * (0.7 + 0.3 * (index % 2)),
                  child: Transform.rotate(
                    angle: waveOffset.rotation,
                    child: Text(emoji, style: TextStyle(fontSize: fontSize)),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  /// Calcula o offset de onda para movimento orgânico
  WaveOffset _calculateWaveOffset(
    double animationValue,
    int index,
    double speed,
    double screenWidth,
  ) {
    final time = animationValue * 2 * pi;
    final waveFrequency = 0.5 + (index * 0.3);
    final waveAmplitude = 40.0 + (index * 10);
    final phaseOffset = index * pi / 3;

    final horizontalWave =
        sin(time * waveFrequency + phaseOffset) * waveAmplitude;
    final verticalWave =
        cos(time * waveFrequency * 0.7 + phaseOffset) * (waveAmplitude * 0.5);
    final rotation = sin(time * waveFrequency * 1.2 + phaseOffset) * 0.3;

    return WaveOffset(
      horizontal: horizontalWave,
      vertical: verticalWave,
      rotation: rotation,
    );
  }
}
