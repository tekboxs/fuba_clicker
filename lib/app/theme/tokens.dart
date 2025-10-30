import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

@immutable
class AppColors {
  static const Color background = Color(0xFF0F0720);
  static const Color foreground = Color(0xFFFBFBFC);
  static const Color card = Color(0xFF1A0F2E);
  static const Color cardForeground = Color(0xFFFBFBFC);
  static const Color primary = Color(0xFF9333EA);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF2E1D4A);
  static const Color secondaryForeground = Color(0xFFFBFBFC);
  static const Color muted = Color(0xFF2E1D4A);
  static const Color mutedForeground = Color(0xFFB4B0C0);
  static const Color accent = Color(0xFF3D2A5C);
  static const Color accentForeground = Color(0xFFFBFBFC);
  static const Color destructive = Color(0xFFD4183D);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color border = Color(0x40A78BFA);
  static const Color inputBackground = Color(0xFF241837);
  static const Color ring = Color(0xFF9333EA);
  static const Color sidebar = Color(0xFF1A0F2E);
  static const Color sidebarForeground = Color(0xFFFBFBFC);

  static const Color purple400 = Color(0xFFA78BFA);
  static const Color purple500 = Color(0xFF9333EA);
  static const Color purple600 = Color(0xFF7C3AED);
  static const Color purple800 = Color(0xFF5B21B6);
  static const Color purple900 = Color(0xFF3B0764);
  
  static const Color fuchsia400 = Color(0xFFE879F9);
  static const Color fuchsia500 = Color(0xFFD946EF);
  static const Color fuchsia600 = Color(0xFFC026D3);
  static const Color fuchsia800 = Color(0xFF86198F);
  static const Color fuchsia900 = Color(0xFF701A75);
  
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color cyan800 = Color(0xFF155E75);
  
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald800 = Color(0xFF065F46);
  
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber800 = Color(0xFF92400E);
  
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue800 = Color(0xFF1E3A8A);
  
  static const Color pink400 = Color(0xFFF472B6);
  static const Color pink500 = Color(0xFFEC4899);
  static const Color pink600 = Color(0xFFDB2777);
  static const Color pink800 = Color(0xFF9F1239);
  
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red800 = Color(0xFF991B1B);
}

@immutable
class AppSpacing {
  static const double unit = 4;
  static const double xxs = unit;
  static const double xs = unit * 2;
  static const double sm = unit * 3;
  static const double md = unit * 4;
  static const double lg = unit * 6;
  static const double xl = unit * 8;
  static const double xxl = unit * 12;
}

@immutable
class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
}

@immutable
class AppElevations {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
}

@immutable
class AppDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 180);
  static const Duration slow = Duration(milliseconds: 240);
}

@immutable
class AppCurves {
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve standard = Curves.easeInOut;
  static const Curve emphasizedDecel = Curves.easeOutQuart;
}

@immutable
class AppShadows {
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x50000000),
      blurRadius: 64,
      offset: Offset(0, 24),
    ),
  ];

  static const List<BoxShadow> glowPurple = [
    BoxShadow(
      color: Color(0x509333EA),
      blurRadius: 24,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> glowFuchsia = [
    BoxShadow(
      color: Color(0x50D946EF),
      blurRadius: 24,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> glowCyan = [
    BoxShadow(
      color: Color(0x5022D3EE),
      blurRadius: 24,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> glowEmerald = [
    BoxShadow(
      color: Color(0x5010B981),
      blurRadius: 24,
      offset: Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> glowAmber = [
    BoxShadow(
      color: Color(0x50F59E0B),
      blurRadius: 24,
      offset: Offset(0, 0),
    ),
  ];
}

@immutable
class AppGradients {
  static const LinearGradient purpleFuchsia = LinearGradient(
    colors: [AppColors.purple600, AppColors.fuchsia600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleCyan = LinearGradient(
    colors: [AppColors.purple500, AppColors.cyan500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fuchsiaCyan = LinearGradient(
    colors: [AppColors.fuchsia500, AppColors.cyan500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGreen = LinearGradient(
    colors: [AppColors.emerald500, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueCyan = LinearGradient(
    colors: [AppColors.blue500, AppColors.cyan500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberYellow = LinearGradient(
    colors: [AppColors.amber500, Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkFuchsia = LinearGradient(
    colors: [AppColors.pink500, AppColors.fuchsia500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redRose = LinearGradient(
    colors: [AppColors.red500, Color(0xFFFE2C55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1E0E3E), Color(0xFF3B0764), Color(0xFF581C87)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient glowOrb = RadialGradient(
    colors: [Color(0x339333EA), Color(0x00000000)],
    radius: 1.5,
  );
}

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double spacingUnit;
  final Duration durationFast;
  final Duration durationNormal;
  final Duration durationSlow;
  final Curve curveStandard;
  final Curve curveEmphasized;

  const AppTokens({
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.spacingUnit,
    required this.durationFast,
    required this.durationNormal,
    required this.durationSlow,
    required this.curveStandard,
    required this.curveEmphasized,
  });

  static const AppTokens light = AppTokens(
    radiusSm: AppRadii.sm,
    radiusMd: AppRadii.md,
    radiusLg: AppRadii.lg,
    radiusXl: AppRadii.xl,
    spacingUnit: AppSpacing.unit,
    durationFast: AppDurations.fast,
    durationNormal: AppDurations.normal,
    durationSlow: AppDurations.slow,
    curveStandard: AppCurves.standard,
    curveEmphasized: AppCurves.emphasized,
  );

  @override
  AppTokens copyWith({
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? spacingUnit,
    Duration? durationFast,
    Duration? durationNormal,
    Duration? durationSlow,
    Curve? curveStandard,
    Curve? curveEmphasized,
  }) =>
      AppTokens(
        radiusSm: radiusSm ?? this.radiusSm,
        radiusMd: radiusMd ?? this.radiusMd,
        radiusLg: radiusLg ?? this.radiusLg,
        radiusXl: radiusXl ?? this.radiusXl,
        spacingUnit: spacingUnit ?? this.spacingUnit,
        durationFast: durationFast ?? this.durationFast,
        durationNormal: durationNormal ?? this.durationNormal,
        durationSlow: durationSlow ?? this.durationSlow,
        curveStandard: curveStandard ?? this.curveStandard,
        curveEmphasized: curveEmphasized ?? this.curveEmphasized,
      );

  @override
  ThemeExtension<AppTokens> lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      spacingUnit: lerpDouble(spacingUnit, other.spacingUnit, t)!,
      durationFast: Duration(
        milliseconds: lerpDouble(
          durationFast.inMilliseconds.toDouble(),
          other.durationFast.inMilliseconds.toDouble(),
          t,
        )!
            .round(),
      ),
      durationNormal: Duration(
        milliseconds: lerpDouble(
          durationNormal.inMilliseconds.toDouble(),
          other.durationNormal.inMilliseconds.toDouble(),
          t,
        )!
            .round(),
      ),
      durationSlow: Duration(
        milliseconds: lerpDouble(
          durationSlow.inMilliseconds.toDouble(),
          other.durationSlow.inMilliseconds.toDouble(),
          t,
        )!
            .round(),
      ),
      curveStandard: other.curveStandard,
      curveEmphasized: other.curveEmphasized,
    );
  }
}


