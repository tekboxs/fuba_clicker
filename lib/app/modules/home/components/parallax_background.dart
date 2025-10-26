import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/providers/visual_settings_provider.dart';

/// Widget que cria o fundo com efeito de paralaxe ultra-otimizado
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
    
    return Positioned.fill(
      child: RepaintBoundary(
        child: _buildStaticParallaxWithTransform(context),
      ),
    );
  }

  /// Constrói parallax ultra-simples e performático
  Widget _buildStaticParallaxWithTransform(BuildContext context) {
    return AnimatedBuilder(
      animation: parallaxController,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        return Stack(
          children: [
            // Camada única com movimento suave
            Transform.translate(
              offset: Offset(parallaxController.value * screenWidth * 0.2, 0),
              child: _buildUltraSimpleLayer(
                screenWidth, 
                screenHeight,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Constrói uma camada ultra-simples com apenas alguns elementos
  Widget _buildUltraSimpleLayer(
    double screenWidth, 
    double screenHeight,
  ) {
    return SizedBox(
      width: screenWidth * 1.5,
      height: screenHeight,
      child: Stack(
        children: [
          // Apenas 8 elementos estáticos para máxima performance
          Positioned(left: 50, top: 100, child: Text('🌽', style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.1)))),
          Positioned(left: 200, top: 200, child: Text('🌾', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.08)))),
          Positioned(left: 350, top: 150, child: Text('🌽', style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.06)))),
          Positioned(left: 500, top: 300, child: Text('🌾', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.1)))),
          Positioned(left: 650, top: 80, child: Text('🌽', style: TextStyle(fontSize: 22, color: Colors.white.withOpacity(0.08)))),
          Positioned(left: 800, top: 250, child: Text('🌾', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.06)))),
          Positioned(left: 950, top: 180, child: Text('🌽', style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.1)))),
          Positioned(left: 1100, top: 120, child: Text('🌾', style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.08)))),
        ],
      ),
    );
  }

}
