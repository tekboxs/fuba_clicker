import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:big_decimal/big_decimal.dart';

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
  static const double titleFontSizeMobile = 18.0;
  static const double counterFontSizeMobile = 28.0;
  static const double generatorNameFontSizeMobile = 13.0;
  static const double generatorDescFontSizeMobile = 9.0;
  static const double generatorCostFontSizeMobile = 11.0;
  static const double generatorProductionFontSizeMobile = 8.0;
  static const double generatorOwnedFontSizeMobile = 9.0;
  static const double generatorEmojiSizeMobile = 22.0;

  /// Sistema de dificuldade de conquistas
  static const Map<String, Color> difficultyColors = {
    'common': Color(0xFF4CAF50),
    'uncommon': Color(0xFF2196F3),
    'rare': Color(0xFF9C27B0),
    'epic': Color(0xFFFF9800),
    'legendary': Color(0xFFFF5722),
  };

  static const Map<String, double> badgeSizes = {
    'common': 60.0,
    'uncommon': 65.0,
    'rare': 70.0,
    'epic': 75.0,
    'legendary': 80.0,
  };

  static const Map<String, int> sparkleCounts = {
    'common': 3,
    'uncommon': 6,
    'rare': 8,
    'epic': 12,
    'legendary': 15,
  };

  static const Map<String, double> glowIntensities = {
    'common': 5.0,
    'uncommon': 8.0,
    'rare': 12.0,
    'epic': 18.0,
    'legendary': 25.0,
  };

  static const Map<String, Duration> animationDurations = {
    'common': Duration(milliseconds: 300),
    'uncommon': Duration(milliseconds: 400),
    'rare': Duration(milliseconds: 500),
    'epic': Duration(milliseconds: 600),
    'legendary': Duration(milliseconds: 800),
  };

  /// Padding para mobile
  static const double defaultPaddingMobile = 8.0;
  static const double cardPaddingMobile = 6.0;

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
    return isMobile(context)
        ? generatorNameFontSizeMobile
        : generatorNameFontSizeDesktop;
  }

  static double getGeneratorDescFontSize(BuildContext context) {
    return isMobile(context)
        ? generatorDescFontSizeMobile
        : generatorDescFontSizeDesktop;
  }

  static double getGeneratorCostFontSize(BuildContext context) {
    return isMobile(context)
        ? generatorCostFontSizeMobile
        : generatorCostFontSizeDesktop;
  }

  static double getGeneratorProductionFontSize(BuildContext context) {
    return isMobile(context)
        ? generatorProductionFontSizeMobile
        : generatorProductionFontSizeDesktop;
  }

  static double getGeneratorOwnedFontSize(BuildContext context) {
    return isMobile(context)
        ? generatorOwnedFontSizeMobile
        : generatorOwnedFontSizeDesktop;
  }

  static double getGeneratorEmojiSize(BuildContext context) {
    return isMobile(context)
        ? generatorEmojiSizeMobile
        : generatorEmojiSizeDesktop;
  }

  static double getDefaultPadding(BuildContext context) {
    return isMobile(context) ? defaultPaddingMobile : defaultPadding;
  }

  static double getCardPadding(BuildContext context) {
    return isMobile(context) ? cardPaddingMobile : defaultPadding;
  }

  /// Formata números grandes para melhor legibilidade
  static String formatNumber(BigDecimal number) {
    // Handle special cases: zero, negative, or extremely small numbers
    if (number.compareTo(BigDecimal.zero) == 0) {
      return '0.0';
    }
    
    bool isNegative = number.compareTo(BigDecimal.zero) < 0;
    BigDecimal absNumber = isNegative ? (-number) : number;

    // Define suffixes for thousands, millions, billions, etc.
    const List<String> baseSuffixes = [
      // Units
      '', 'K', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No',
      // Decillions (10^33 to 10^60)
      'Dc', 'Ud', 'Dd', 'Td', 'Qad', 'Qid', 'Sxd', 'Spd', 'Ocd', 'Nod',
      // Vigintillions (10^63 to 10^90)
      'Vg', 'Uvg', 'Dvg', 'Tvg', 'Qavg', 'Qivg', 'Sxvg', 'Spvg', 'Ocvg', 'Novg',
      // Trigintillions (10^93 to 10^120)
      'Tg', 'Utg', 'Dtg', 'Ttg', 'Qatg', 'Qitg', 'Sxtg', 'Sptg', 'Octg', 'Notg',
      // Quadragintillions (10^123 to 10^150)
      'Qag', 'Uqag', 'Dqag', 'Tqag', 'Qaqag', 'Qiqag', 'Sxqag', 'Spqag', 'Ocqag', 'Noqag',
      // Quinquagintillions (10^153 to 10^180)
      'Qig', 'Uqig', 'Dqig', 'Tqig', 'Qaqig', 'Qiqig', 'Sxqig', 'Spqig', 'Ocqig', 'Noqig',
      // Sexagintillions (10^183 to 10^210)
      'Sxg', 'Usxg', 'Dsxg', 'Tsxg', 'Qasxg', 'Qisxg', 'Sxsxg', 'Spsxg', 'Ocsxg', 'Nosxg',
      // Septuagintillions (10^213 to 10^240)
      'Spg', 'Uspg', 'Dspg', 'Tspg', 'Qaspg', 'Qispg', 'Spspg', 'Spspg', 'Ocspg', 'Nospg',
      // Octogintillions (10^243 to 10^270)
      'Ocog', 'Uocog', 'Docog', 'Tocog', 'Qaocog', 'Qiocog', 'Sxocog', 'Spocog', 'Ococog', 'Noocog',
      // Nonagintillions (10^273 to 10^300)
      'Nog', 'Unog', 'Dnog', 'Tnog', 'Qanog', 'Qinog', 'Sxnog', 'Spnog', 'Ocnog', 'Nonog',
      // Centillions (10^303 to 10^330)
      'Ct', 'Uct', 'Dct', 'Tct', 'Qact', 'Qict', 'Sxct', 'Spct', 'Occt', 'Noct',
      // Centillions-group (10^333 to 10^360)
      'Cg', 'Ucg', 'Dcg', 'Tcg', 'Qacg', 'Qicg', 'Sxcg', 'Spcg', 'Occg', 'Nocg',
      // Additional suffixes for 10^363 to 10^399 (magnitudes 121 to 133)
      'Cag', 'Ucag', 'Dcag', 'Tcag', 'Qacag', 'Qicag', 'Sxcag', 'Spcag', 'Occag', 'Nocag',
      'Cig', 'Ucig', 'Dcig' // Up to 133 suffixes (10^399)
    ];

    String numberString = absNumber.toPlainString();
    int exponent = 0;

    int decimalPointIndex = numberString.indexOf('.');
    if (decimalPointIndex != -1) {
      exponent = decimalPointIndex - 1;
    } else {
      exponent = numberString.length - 1;
    }

    if (exponent < 3) {
      return '${isNegative ? '-' : ''}${absNumber.toDouble().toStringAsFixed(1)}';
    }

    int magnitude = (exponent / 3).floor();
    if (magnitude >= baseSuffixes.length) {
      return 'Fubinity';
    }

    BigDecimal divisor = BigDecimal.parse('1${'0' * (magnitude * 3)}');
    BigDecimal result = absNumber.divide(divisor, scale: 10, roundingMode: RoundingMode.HALF_UP);
    
    String formattedResult = result.toDouble().toStringAsFixed(1);
    
    return '${isNegative ? '-' : ''}$formattedResult${baseSuffixes[magnitude]}';
  }
}
