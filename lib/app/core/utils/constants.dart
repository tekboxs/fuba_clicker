import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'efficient_number.dart';

class UIConstants {
  static const double defaultMargin = 16.0;
  static const double defaultMarginSmall = 8.0;
  static const double defaultRadius = 8.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}

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
    if (context != null && isMobileWeb(context)) return 3;
    return isWeb ? 6 : 12;
  }

  /// Retorna o número de camadas de paralaxe baseado na plataforma e contexto
  static int getParallaxLayerCount(BuildContext? context) {
    if (context != null && isMobileWeb(context)) return 2;
    return isWeb ? 3 : 6;
  }

  /// Retorna o número de partículas baseado na plataforma (deprecated - use getParticleCount)
  static int get particleCount => isWeb ? 6 : 12;

  /// Retorna o número de camadas de paralaxe baseado na plataforma (deprecated - use getParallaxLayerCount)
  static int get parallaxLayerCount => isWeb ? 3 : 6;

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

  static String formatNumber(EfficientNumber number) {
    try {
      if (number.mantissa == 0) {
        return '0.0';
      }

      bool isNegative = number.mantissa < 0;
      EfficientNumber absNumber = number.abs();
      int exponent = absNumber.exponent;

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
      'Qag', 'Uqag', 'Dqag', 'Tqag', 'Qaqag', 'Qiqag', 'Sxqag', 'Spqag',
      'Ocqag', 'Noqag',
      // Quinquagintillions (10^153 to 10^180)
      'Qig', 'Uqig', 'Dqig', 'Tqig', 'Qaqig', 'Qiqig', 'Sxqig', 'Spqig',
      'Ocqig', 'Noqig',
      // Sexagintillions (10^183 to 10^210)
      'Sxg', 'Usxg', 'Dsxg', 'Tsxg', 'Qasxg', 'Qisxg', 'Sxsxg', 'Spsxg',
      'Ocsxg', 'Nosxg',
      // Septuagintillions (10^213 to 10^240)
      'Spg', 'Uspg', 'Dspg', 'Tspg', 'Qaspg', 'Qispg', 'Spspg', 'Spspg',
      'Ocspg', 'Nospg',
      // Octogintillions (10^243 to 10^270)
      'Ocog', 'Uocog', 'Docog', 'Tocog', 'Qaocog', 'Qiocog', 'Sxocog', 'Spocog',
      'Ococog', 'Noocog',
      // Nonagintillions (10^273 to 10^300)
      'Nog', 'Unog', 'Dnog', 'Tnog', 'Qanog', 'Qinog', 'Sxnog', 'Spnog',
      'Ocnog', 'Nonog',
      // Centillions (10^303 to 10^330)
      'Ct', 'Uct', 'Dct', 'Tct', 'Qact', 'Qict', 'Sxct', 'Spct', 'Occt', 'Noct',
      // Centillions-group (10^333 to 10^360)
      'Cg', 'Ucg', 'Dcg', 'Tcg', 'Qacg', 'Qicg', 'Sxcg', 'Spcg', 'Occg', 'Nocg',
      // Additional suffixes for 10^363 to 10^399 (magnitudes 121 to 133)
      'Cag', 'Ucag', 'Dcag', 'Tcag', 'Qacag', 'Qicag', 'Sxcag', 'Spcag',
      'Occag', 'Nocag',
      'Cig', 'Ucig', 'Dcig', 'Tcig', 'Qacig', 'Qicig', 'Sxcig', 'Spcig',
      'Occig', 'Nocig',
      // 10^393 to 10^420 (magnitudes 131 to 140)
      'Sxig', 'Usxig', 'Dsxig', 'Tsxig', 'Qasxig', 'Qisxig', 'Sxsxig', 'Spsxig',
      'Ocsxig', 'Nosxig',
      // 10^423 to 10^450 (magnitudes 141 to 150)
      'Spig', 'Uspig', 'Dspig', 'Tspig', 'Qaspig', 'Qispig', 'Sxspig', 'Spspig',
      'Ocspig', 'Nospig',
      // 10^453 to 10^480 (magnitudes 151 to 160)
      'Ocig', 'Uocig', 'Docig', 'Tocig', 'Qaocig', 'Qiocig', 'Sxocig', 'Spocig',
      'Ococig', 'Noocig',
      // 10^483 to 10^510 (magnitudes 161 to 170)
      'Noig', 'Unoig', 'Dnoig', 'Tnoig', 'Qanoig', 'Qinoig', 'Sxnoig', 'Spnoig',
      'Ocnoig', 'Nonoig',
      // 10^513 to 10^540 (magnitudes 171 to 180)
      'Ung', 'Uung', 'Dung', 'Tung', 'Qaung', 'Qiung', 'Sxung', 'Spung',
      'Ocung', 'Nounig',
      // 10^543 to 10^570 (magnitudes 181 to 190)
      'Dng', 'Udng', 'Ddng', 'Tdng', 'Qadng', 'Qidng', 'Sxdng', 'Spdng',
      'Ocdng', 'Nodng',
      // 10^573 to 10^600 (magnitudes 191 to 200)
      'Tng', 'Utng', 'Dtng', 'Ttng', 'Qatng', 'Qitng', 'Sxtng', 'Sptng',
      'Octng', 'Notng',
      // 10^603 to 10^630 (magnitudes 201 to 210)
      'Qang', 'Uqang', 'Dqang', 'Tqang', 'Qaqang', 'Qiqang', 'Sxqang', 'Spqang',
      'Ocqang', 'Noqang',
      // 10^633 to 10^660 (magnitudes 211 to 220)
      'Qing', 'Uqing', 'Dqing', 'Tqing', 'Qaqing', 'Qiqing', 'Sxqing', 'Spqing',
      'Ocqing', 'Noqing',
      // 10^663 to 10^690 (magnitudes 221 to 230)
      'Sxng', 'Usxng', 'Dsxng', 'Tsxng', 'Qasxng', 'Qisxng', 'Sxsxng', 'Spsxng',
      'Ocsxng', 'Nosxng',
      // 10^693 to 10^720 (magnitudes 231 to 240)
      'Spng', 'Uspng', 'Dspng', 'Tspng', 'Qaspng', 'Qispng', 'Sxspng', 'Spspng',
      'Ocspng', 'Nospng',
      // 10^723 to 10^750 (magnitudes 241 to 250)
      'Ocng', 'Uocng', 'Docng', 'Tocng', 'Qaocng', 'Qiocng', 'Sxocng', 'Spocng',
      'Ococng', 'Noocng',
      // 10^753 to 10^780 (magnitudes 251 to 260)
      'Nong', 'Unong', 'Dnong', 'Tnong', 'Qanong', 'Qinong', 'Sxnong', 'Spnong',
      'Ocnong', 'Nonong',
      // 10^783 to 10^810 (magnitudes 261 to 270)
      'Uctg', 'Uuctg', 'Ductg', 'Tuctg', 'Qauctg', 'Qiuctg', 'Sxuctg', 'Spuctg',
      'Ocuctg', 'Nouctg',
      // 10^813 to 10^840 (magnitudes 271 to 280)
      'Dctg', 'Udctg', 'Ddctg', 'Tdctg', 'Qadctg', 'Qidctg', 'Sxdctg', 'Spdctg',
      'Ocdctg', 'Nodctg',
      // 10^843 to 10^870 (magnitudes 281 to 290)
      'Tctg', 'Utctg', 'Dtctg', 'Ttctg', 'Qatctg', 'Qitctg', 'Sxtctg', 'Sptctg',
      'Octctg', 'Notctg',
      // 10^873 to 10^900 (magnitudes 291 to 300)
      'Qactg', 'Uqactg', 'Dqactg', 'Tqactg', 'Qaqactg', 'Qiqactg', 'Sxqactg',
      'Spqactg', 'Ocqactg', 'Noqactg',
      // 10^903 to 10^930 (magnitudes 301 to 310)
      'Qictg', 'Uqictg', 'Dqictg', 'Tqictg', 'Qaqictg', 'Qiqictg', 'Sxqictg',
      'Spqictg', 'Ocqictg', 'Noqictg',
      // 10^933 to 10^960 (magnitudes 311 to 320)
      'Sxctg', 'Usxctg', 'Dsxctg', 'Tsxctg', 'Qasxctg', 'Qisxctg', 'Sxsxctg',
      'Spsxctg', 'Ocsxctg', 'Nosxctg',
      // 10^963 to 10^990 (magnitudes 321 to 330)
      'Spctg', 'Uspctg', 'Dspctg', 'Tspctg', 'Qaspctg', 'Qispctg', 'Sxspctg',
      'Spspctg', 'Ocspctg', 'Nospctg',
      // 10^993 to 10^1020 (magnitudes 331 to 340)
      'Occtg', 'Uocctg', 'Docctg', 'Tocctg', 'Qaocctg', 'Qiocctg', 'Sxocctg',
      'Spocctg', 'Ococctg', 'Noocctg',
      // 10^1023 to 10^1050 (magnitudes 341 to 350)
      'Noctg', 'Unoctg', 'Dnoctg', 'Tnoctg', 'Qanoctg', 'Qinoctg', 'Sxnoctg',
      'Spnoctg', 'Ocnoctg', 'Nonoctg',
      // 10^1053 to 10^1080 (magnitudes 351 to 360)
      'Ucag', 'Uucag', 'Ducag', 'Tucag', 'Qaucag', 'Qiucag', 'Sxucag', 'Spucag',
      'Ocucag', 'Noucag',
      // 10^1083 to 10^1110 (magnitudes 361 to 370)
      'Dcag', 'Udcag', 'Ddcag', 'Tdcag', 'Qadcag', 'Qidcag', 'Sxdcag', 'Spdcag',
      'Ocdcag', 'Nodcag',
      // 10^1113 to 10^1140 (magnitudes 371 to 380)
      'Tcag', 'Utcag', 'Dtcag', 'Ttcag', 'Qatcag', 'Qitcag', 'Sxtcag', 'Sptcag',
      'Octcag', 'Notcag',
      // 10^1143 to 10^1170 (magnitudes 381 to 390)
      'Qacag', 'Uqacag', 'Dqacag', 'Tqacag', 'Qaqacag', 'Qiqacag', 'Sxqacag',
      'Spqacag', 'Ocqacag', 'Noqacag',
      // 10^1173 to 10^1200 (magnitudes 391 to 400)
      'Qicag', 'Uqicag', 'Dqicag', 'Tqicag', 'Qaqicag', 'Qiqicag', 'Sxqicag',
      'Spqicag', 'Ocqicag', 'Noqicag',
      // 10^1203 to 10^1230 (magnitudes 401 to 410)
      'Sxcag', 'Usxcag', 'Dsxcag', 'Tsxcag', 'Qasxcag', 'Qisxcag', 'Sxsxcag',
      'Spsxcag', 'Ocsxcag', 'Nosxcag',
      // 10^1233 to 10^1260 (magnitudes 411 to 420)
      'Spcag', 'Uspcag', 'Dspcag', 'Tspcag', 'Qaspcag', 'Qispcag', 'Sxspcag',
      'Spspcag', 'Ocspcag', 'Nospcag',
      // 10^1263 to 10^1290 (magnitudes 421 to 430)
      'Occag', 'Uoccag', 'Doccag', 'Toccag', 'Qaoccag', 'Qioccag', 'Sxoccag',
      'Spoccag', 'Ococcag', 'Nooccag',
      // 10^1293 to 10^1320 (magnitudes 431 to 440)
      'Nocag', 'Unocag', 'Dnocag', 'Tnocag', 'Qanocag', 'Qinocag', 'Sxnocag',
      'Spnocag', 'Ocnocag', 'Nonocag',
      // 10^1323 to 10^1350 (magnitudes 441 to 450)
      'Ucig', 'Uucig', 'Ducig', 'Tucig', 'Qaucig', 'Qiucig', 'Sxucig', 'Spucig',
      'Ocucig', 'Noucig',
      // 10^1353 to 10^1380 (magnitudes 451 to 460)
      'Dcig', 'Udcig', 'Ddcig', 'Tdcig', 'Qadcig', 'Qidcig', 'Sxdcig', 'Spdcig',
      'Ocdcig', 'Nodcig',
      // 10^1383 to 10^1410 (magnitudes 461 to 470)
      'Tcig', 'Utcig', 'Dtcig', 'Ttcig', 'Qatcig', 'Qitcig', 'Sxtcig', 'Sptcig',
      'Octcig', 'Notcig',
      // 10^1413 to 10^1440 (magnitudes 471 to 480)
      'Qacig', 'Uqacig', 'Dqacig', 'Tqacig', 'Qaqacig', 'Qiqacig', 'Sxqacig',
      'Spqacig', 'Ocqacig', 'Noqacig',
      // 10^1443 to 10^1470 (magnitudes 481 to 490)
      'Qicig', 'Uqicig', 'Dqicig', 'Tqicig', 'Qaqicig', 'Qiqicig', 'Sxqicig',
      'Spqicig', 'Ocqicig', 'Noqicig',
      // 10^1473 to 10^1500 (magnitudes 491 to 500)
      'Sxcig', 'Usxcig', 'Dsxcig', 'Tsxcig', 'Qasxcig', 'Qisxcig', 'Sxsxcig',
      'Spsxcig', 'Ocsxcig', 'Nosxcig',
      'Spcig', 'Uspcig', 'Dspcig', 'Tspcig', 'Qaspcig', 'Qispcig', 'Sxspcig',
      'Spspcig', 'Ocspcig', 'Nospcig'
    ];

    if (exponent < 3) {
      final doubleValue = absNumber.toDouble();
      if (doubleValue.isInfinite || doubleValue.isNaN) {
        return 'Fubinity';
      }
      return '${isNegative ? '-' : ''}${doubleValue.toStringAsFixed(1)}';
    }

    int magnitude = (exponent / 3).floor();
    if (magnitude >= baseSuffixes.length) {
      return 'Fubinity';
    }

    final numDivisor = EfficientNumber.fromPower(10.0, magnitude * 3);
    EfficientNumber result = absNumber / numDivisor;

    final doubleValue = result.mantissa * math.pow(10, result.exponent);
    if (doubleValue.isInfinite || doubleValue.isNaN) {
      return 'Fubinity';
    }

    String formattedResult = doubleValue.toStringAsFixed(1);

    return '${isNegative ? '-' : ''}$formattedResult${baseSuffixes[magnitude]}';
    } catch (e) {
      return 'Fubinity';
    }
  }
}

/// Classe para trabalhar com números grandes usando siglas
class SuffixNumber {
  final double value;
  final int magnitude;
  final String suffix;

  SuffixNumber(this.value, this.magnitude, this.suffix);

  /// Converte EfficientNumber para SuffixNumber
  static SuffixNumber fromEfficientNumber(EfficientNumber number) {
    if (number == EfficientNumber.zero()) {
      return SuffixNumber(0.0, 0, '');
    }

    bool isNegative = number < EfficientNumber.zero();
    EfficientNumber absNumber = isNegative ? -number : number;

    String numberString = absNumber.toPlainString();
    int exponent = 0;

    int decimalPointIndex = numberString.indexOf('.');
    if (decimalPointIndex != -1) {
      exponent = decimalPointIndex - 1;
    } else {
      exponent = numberString.length - 1;
    }

    if (exponent < 3) {
      return SuffixNumber(absNumber.toDouble(), 0, '');
    }

    int magnitude = (exponent / 3).floor();
    const List<String> baseSuffixes = [
      '',
      'K',
      'M',
      'B',
      'T',
      'Qa',
      'Qi',
      'Sx',
      'Sp',
      'Oc',
      'No',
      'Dc',
      'Ud',
      'Dd',
      'Td',
      'Qad',
      'Qid',
      'Sxd',
      'Spd',
      'Ocd',
      'Nod',
      'Vg',
      'Uvg',
      'Dvg',
      'Tvg',
      'Qavg',
      'Qivg',
      'Sxvg',
      'Spvg',
      'Ocvg',
      'Novg',
      'Tg',
      'Utg',
      'Dtg',
      'Ttg',
      'Qatg',
      'Qitg',
      'Sxtg',
      'Sptg',
      'Octg',
      'Notg',
      'Qag',
      'Uqag',
      'Dqag',
      'Tqag',
      'Qaqag',
      'Qiqag',
      'Sxqag',
      'Spqag',
      'Ocqag',
      'Noqag',
      'Qig',
      'Uqig',
      'Dqig',
      'Tqig',
      'Qaqig',
      'Qiqig',
      'Sxqig',
      'Spqig',
      'Ocqig',
      'Noqig',
      'Sxg',
      'Usxg',
      'Dsxg',
      'Tsxg',
      'Qasxg',
      'Qisxg',
      'Sxsxg',
      'Spsxg',
      'Ocsxg',
      'Nosxg',
      'Spg',
      'Uspg',
      'Dspg',
      'Tspg',
      'Qaspg',
      'Qispg',
      'Spspg',
      'Spspg',
      'Ocspg',
      'Nospg',
      'Ocog',
      'Uocog',
      'Docog',
      'Tocog',
      'Qaocog',
      'Qiocog',
      'Sxocog',
      'Spocog',
      'Ococog',
      'Noocog',
      'Nog',
      'Unog',
      'Dnog',
      'Tnog',
      'Qanog',
      'Qinog',
      'Sxnog',
      'Spnog',
      'Ocnog',
      'Nonog',
      'Ct',
      'Uct',
      'Dct',
      'Tct',
      'Qact',
      'Qict',
      'Sxct',
      'Spct',
      'Occt',
      'Noct',
      'Cg',
      'Ucg',
      'Dcg',
      'Tcg',
      'Qacg',
      'Qicg',
      'Sxcg',
      'Spcg',
      'Occg',
      'Nocg',
      'Cag',
      'Ucag',
      'Dcag',
      'Tcag',
      'Qacag',
      'Qicag',
      'Sxcag',
      'Spcag',
      'Occag',
      'Nocag',
      'Cig',
      'Ucig',
      'Dcig',
      'Tcig',
      'Qacig',
      'Qicig',
      'Sxcig',
      'Spcig',
      'Occig',
      'Nocig',
      'Sxig',
      'Usxig',
      'Dsxig',
      'Tsxig',
      'Qasxig',
      'Qisxig',
      'Sxsxig',
      'Spsxig',
      'Ocsxig',
      'Nosxig',
      'Spig',
      'Uspig',
      'Dspig',
      'Tspig',
      'Qaspig',
      'Qispig',
      'Sxspig',
      'Spspig',
      'Ocspig',
      'Nospig',
      'Ocig',
      'Uocig',
      'Docig',
      'Tocig',
      'Qaocig',
      'Qiocig',
      'Sxocig',
      'Spocig',
      'Ococig',
      'Noocig',
      'Noig',
      'Unoig',
      'Dnoig',
      'Tnoig',
      'Qanoig',
      'Qinoig',
      'Sxnoig',
      'Spnoig',
      'Ocnoig',
      'Nonoig',
      'Ung',
      'Uung',
      'Dung',
      'Tung',
      'Qaung',
      'Qiung',
      'Sxung',
      'Spung',
      'Ocung',
      'Nounig',
      'Dng',
      'Udng',
      'Ddng',
      'Tdng',
      'Qadng',
      'Qidng',
      'Sxdng',
      'Spdng',
      'Ocdng',
      'Nodng',
      'Tng',
      'Utng',
      'Dtng',
      'Ttng',
      'Qatng',
      'Qitng',
      'Sxtng',
      'Sptng',
      'Octng',
      'Notng',
      'Qang',
      'Uqang',
      'Dqang',
      'Tqang',
      'Qaqang',
      'Qiqang',
      'Sxqang',
      'Spqang',
      'Ocqang',
      'Noqang',
      'Qing',
      'Uqing',
      'Dqing',
      'Tqing',
      'Qaqing',
      'Qiqing',
      'Sxqing',
      'Spqing',
      'Ocqing',
      'Noqing',
      'Sxng',
      'Usxng',
      'Dsxng',
      'Tsxng',
      'Qasxng',
      'Qisxng',
      'Sxsxng',
      'Spsxng',
      'Ocsxng',
      'Nosxng',
      'Spng',
      'Uspng',
      'Dspng',
      'Tspng',
      'Qaspng',
      'Qispng',
      'Sxspng',
      'Spspng',
      'Ocspng',
      'Nospng',
      'Ocng',
      'Uocng',
      'Docng',
      'Tocng',
      'Qaocng',
      'Qiocng',
      'Sxocng',
      'Spocng',
      'Ococng',
      'Noocng',
      'Nong',
      'Unong',
      'Dnong',
      'Tnong',
      'Qanong',
      'Qinong',
      'Sxnong',
      'Spnong',
      'Ocnong',
      'Nonong',
      'Uctg',
      'Uuctg',
      'Ductg',
      'Tuctg',
      'Qauctg',
      'Qiuctg',
      'Sxuctg',
      'Spuctg',
      'Ocuctg',
      'Nouctg',
      'Dctg',
      'Udctg',
      'Ddctg',
      'Tdctg',
      'Qadctg',
      'Qidctg',
      'Sxdctg',
      'Spdctg',
      'Ocdctg',
      'Nodctg',
      'Tctg',
      'Utctg',
      'Dtctg',
      'Ttctg',
      'Qatctg',
      'Qitctg',
      'Sxtctg',
      'Sptctg',
      'Octctg',
      'Notctg',
      'Qactg',
      'Uqactg',
      'Dqactg',
      'Tqactg',
      'Qaqactg',
      'Qiqactg',
      'Sxqactg',
      'Spqactg',
      'Ocqactg',
      'Noqactg',
      'Qictg',
      'Uqictg',
      'Dqictg',
      'Tqictg',
      'Qaqictg',
      'Qiqictg',
      'Sxqictg',
      'Spqictg',
      'Ocqictg',
      'Noqictg',
      'Sxctg',
      'Usxctg',
      'Dsxctg',
      'Tsxctg',
      'Qasxctg',
      'Qisxctg',
      'Sxsxctg',
      'Spsxctg',
      'Ocsxctg',
      'Nosxctg',
      'Spctg',
      'Uspctg',
      'Dspctg',
      'Tspctg',
      'Qaspctg',
      'Qispctg',
      'Sxspctg',
      'Spspctg',
      'Ocspctg',
      'Nospctg',
      'Occtg',
      'Uocctg',
      'Docctg',
      'Tocctg',
      'Qaocctg',
      'Qiocctg',
      'Sxocctg',
      'Spocctg',
      'Ococctg',
      'Noocctg',
      'Noctg',
      'Unoctg',
      'Dnoctg',
      'Tnoctg',
      'Qanoctg',
      'Qinoctg',
      'Sxnoctg',
      'Spnoctg',
      'Ocnoctg',
      'Nonoctg',
      'Ucag',
      'Uucag',
      'Ducag',
      'Tucag',
      'Qaucag',
      'Qiucag',
      'Sxucag',
      'Spucag',
      'Ocucag',
      'Noucag',
      'Dcag',
      'Udcag',
      'Ddcag',
      'Tdcag',
      'Qadcag',
      'Qidcag',
      'Sxdcag',
      'Spdcag',
      'Ocdcag',
      'Nodcag',
      'Tcag',
      'Utcag',
      'Dtcag',
      'Ttcag',
      'Qatcag',
      'Qitcag',
      'Sxtcag',
      'Sptcag',
      'Octcag',
      'Notcag',
      'Qacag',
      'Uqacag',
      'Dqacag',
      'Tqacag',
      'Qaqacag',
      'Qiqacag',
      'Sxqacag',
      'Spqacag',
      'Ocqacag',
      'Noqacag',
      'Qicag',
      'Uqicag',
      'Dqicag',
      'Tqicag',
      'Qaqicag',
      'Qiqicag',
      'Sxqicag',
      'Spqicag',
      'Ocqicag',
      'Noqicag',
      'Sxcag',
      'Usxcag',
      'Dsxcag',
      'Tsxcag',
      'Qasxcag',
      'Qisxcag',
      'Sxsxcag',
      'Spsxcag',
      'Ocsxcag',
      'Nosxcag',
      'Spcag',
      'Uspcag',
      'Dspcag',
      'Tspcag',
      'Qaspcag',
      'Qispcag',
      'Sxspcag',
      'Spspcag',
      'Ocspcag',
      'Nospcag',
      'Occag',
      'Uoccag',
      'Doccag',
      'Toccag',
      'Qaoccag',
      'Qioccag',
      'Sxoccag',
      'Spoccag',
      'Ococcag',
      'Nooccag',
      'Nocag',
      'Unocag',
      'Dnocag',
      'Tnocag',
      'Qanocag',
      'Qinocag',
      'Sxnocag',
      'Spnocag',
      'Ocnocag',
      'Nonocag',
      'Ucig',
      'Uucig',
      'Ducig',
      'Tucig',
      'Qaucig',
      'Qiucig',
      'Sxucig',
      'Spucig',
      'Ocucig',
      'Noucig',
      'Dcig',
      'Udcig',
      'Ddcig',
      'Tdcig',
      'Qadcig',
      'Qidcig',
      'Sxdcig',
      'Spdcig',
      'Ocdcig',
      'Nodcig',
      'Tcig',
      'Utcig',
      'Dtcig',
      'Ttcig',
      'Qatcig',
      'Qitcig',
      'Sxtcig',
      'Sptcig',
      'Octcig',
      'Notcig',
      'Qacig',
      'Uqacig',
      'Dqacig',
      'Tqacig',
      'Qaqacig',
      'Qiqacig',
      'Sxqacig',
      'Spqacig',
      'Ocqacig',
      'Noqacig',
      'Qicig',
      'Uqicig',
      'Dqicig',
      'Tqicig',
      'Qaqicig',
      'Qiqicig',
      'Sxqicig',
      'Spqicig',
      'Ocqicig',
      'Noqicig',
      'Sxcig',
      'Usxcig',
      'Dsxcig',
      'Tsxcig',
      'Qasxcig',
      'Qisxcig',
      'Sxsxcig',
      'Spsxcig',
      'Ocsxcig',
      'Nosxcig',
      'Spcig',
      'Uspcig',
      'Dspcig',
      'Tspcig',
      'Qaspcig',
      'Qispcig',
      'Sxspcig',
      'Spspcig',
      'Ocspcig',
      'Nospcig'
    ];

    if (magnitude >= baseSuffixes.length) {
      return SuffixNumber(1.0, 500, 'Fubinity');
    }

    final divisor = EfficientNumber.fromPower(10.0, magnitude * 3.0);
    final result = absNumber / divisor;

    return SuffixNumber(isNegative ? -result.toDouble() : result.toDouble(),
        magnitude, baseSuffixes[magnitude]);
  }

  /// Converte EfficientNumber para SuffixNumber (alias para compatibilidade)
  static SuffixNumber fromBigDecimal(EfficientNumber number) {
    return fromEfficientNumber(number);
  }

  /// Compara dois SuffixNumber
  int compareTo(SuffixNumber other) {
    if (magnitude != other.magnitude) {
      return magnitude.compareTo(other.magnitude);
    }
    return value.compareTo(other.value);
  }

  /// Verifica se é maior ou igual
  bool isGreaterOrEqual(SuffixNumber other) {
    return compareTo(other) >= 0;
  }

  /// Converte de volta para EfficientNumber (aproximado)
  EfficientNumber toEfficientNumber() {
    if (magnitude == 0) {
      return EfficientNumber.parse(value.toString());
    }

    final multiplier = EfficientNumber.fromPower(10.0, magnitude * 3.0);
    return EfficientNumber.parse(value.toString()) * multiplier;
  }

  /// Converte de volta para EfficientNumber (alias para compatibilidade)
  EfficientNumber toBigDecimal() {
    return toEfficientNumber();
  }

  @override
  String toString() {
    return '${value.toStringAsFixed(1)}$suffix';
  }
}
