import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Constantes do jogo
class GameConstants {
  /// Padding padrão usado na interface
  static const double defaultPadding = 16.0;
  
  /// Duração da animação do bolo ao ser clicado
  static const Duration cakeAnimationDuration = Duration(milliseconds: 200);
  
  /// Duração da animação de paralaxe de fundo
  static const Duration parallaxAnimationDuration = Duration(seconds: 400);
  
  /// Intervalo de produção automática dos geradores
  static const Duration autoProductionInterval = Duration(seconds: 1);
  
  /// Cores do tema
  static const int primaryColorAlpha = 198;
  static const int borderColorAlpha = 76;
  static const int affordColorAlpha = 60;
  static const int affordBorderAlpha = 250;
  
  /// Tamanhos de fonte para desktop
  static const double titleFontSizeDesktop = 18.0;
  static const double counterFontSizeDesktop = 48.0;
  static const double generatorNameFontSizeDesktop = 16.0;
  static const double generatorDescFontSizeDesktop = 12.0;
  static const double generatorCostFontSizeDesktop = 14.0;
  static const double generatorProductionFontSizeDesktop = 11.0;
  static const double generatorOwnedFontSizeDesktop = 12.0;
  static const double generatorEmojiSizeDesktop = 32.0;
  
  /// Tamanhos de fonte para mobile
  static const double titleFontSizeMobile = 16.0;
  static const double counterFontSizeMobile = 32.0;
  static const double generatorNameFontSizeMobile = 14.0;
  static const double generatorDescFontSizeMobile = 10.0;
  static const double generatorCostFontSizeMobile = 12.0;
  static const double generatorProductionFontSizeMobile = 9.0;
  static const double generatorOwnedFontSizeMobile = 10.0;
  static const double generatorEmojiSizeMobile = 24.0;
  
  /// Padding para mobile
  static const double defaultPaddingMobile = 12.0;
  static const double cardPaddingMobile = 8.0;
  
  /// Detecta se é mobile baseado na largura da tela
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
  
  /// Detecta se está rodando na web
  static bool get isWeb => kIsWeb;
  
  /// Detecta se é mobile web (web + mobile screen)
  static bool isMobileWeb(BuildContext? context) {
    return isWeb && context != null && isMobile(context);
  }
  
  /// Retorna o número de partículas baseado na plataforma e contexto
  static int getParticleCount(BuildContext? context) {
    if (context != null && isMobileWeb(context)) return 4;
    return isWeb ? 8 : 15;
  }
  
  /// Retorna o número de camadas de paralaxe baseado na plataforma e contexto
  static int getParallaxLayerCount(BuildContext? context) {
    if (context != null && isMobileWeb(context)) return 2;
    return isWeb ? 4 : 8;
  }
  
  /// Retorna o número de partículas baseado na plataforma (deprecated - use getParticleCount)
  static int get particleCount => isWeb ? 8 : 15;
  
  /// Retorna o número de camadas de paralaxe baseado na plataforma (deprecated - use getParallaxLayerCount)
  static int get parallaxLayerCount => isWeb ? 4 : 8;
  
  /// Retorna o tamanho de fonte responsivo
  static double getTitleFontSize(BuildContext context) {
    return isMobile(context) ? titleFontSizeMobile : titleFontSizeDesktop;
  }
  
  static double getCounterFontSize(BuildContext context) {
    return isMobile(context) ? counterFontSizeMobile : counterFontSizeDesktop;
  }
  
  static double getGeneratorNameFontSize(BuildContext context) {
    return isMobile(context) ? generatorNameFontSizeMobile : generatorNameFontSizeDesktop;
  }
  
  static double getGeneratorDescFontSize(BuildContext context) {
    return isMobile(context) ? generatorDescFontSizeMobile : generatorDescFontSizeDesktop;
  }
  
  static double getGeneratorCostFontSize(BuildContext context) {
    return isMobile(context) ? generatorCostFontSizeMobile : generatorCostFontSizeDesktop;
  }
  
  static double getGeneratorProductionFontSize(BuildContext context) {
    return isMobile(context) ? generatorProductionFontSizeMobile : generatorProductionFontSizeDesktop;
  }
  
  static double getGeneratorOwnedFontSize(BuildContext context) {
    return isMobile(context) ? generatorOwnedFontSizeMobile : generatorOwnedFontSizeDesktop;
  }
  
  static double getGeneratorEmojiSize(BuildContext context) {
    return isMobile(context) ? generatorEmojiSizeMobile : generatorEmojiSizeDesktop;
  }
  
  static double getDefaultPadding(BuildContext context) {
    return isMobile(context) ? defaultPaddingMobile : defaultPadding;
  }
  
  static double getCardPadding(BuildContext context) {
    return isMobile(context) ? cardPaddingMobile : defaultPadding;
  }
  
  /// Formata números grandes para melhor legibilidade
  static String formatNumber(double number) {
    if (number.isInfinite || number.isNaN) {
      return 'Infinity';
    }
    
    if (number >= 1e100) {
      return 'Infinity';
    }
    
    if (number >= 1e33) {
      return '${(number / 1e33).toStringAsFixed(1)}Dc';
    } else if (number >= 1e30) {
      return '${(number / 1e30).toStringAsFixed(1)}No';
    } else if (number >= 1e27) {
      return '${(number / 1e27).toStringAsFixed(1)}Oc';
    } else if (number >= 1e24) {
      return '${(number / 1e24).toStringAsFixed(1)}Sp';
    } else if (number >= 1e21) {
      return '${(number / 1e21).toStringAsFixed(1)}Sx';
    } else if (number >= 1e18) {
      return '${(number / 1e18).toStringAsFixed(1)}Qi';
    } else if (number >= 1e15) {
      return '${(number / 1e15).toStringAsFixed(1)}Qa';
    } else if (number >= 1e12) {
      return '${(number / 1e12).toStringAsFixed(1)}T';
    } else if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(1)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(1)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(1);
    }
  }
}
