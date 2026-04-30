import 'dart:math';
import 'package:hive/hive.dart';
import '../core/utils/efficient_number.dart';

part 'rebirth_data.g.dart';

enum RebirthTier {
  rebirth,
  ascension,
  transcendence,
  furuborus,
}

extension RebirthTierExtension on RebirthTier {
  String get displayName {
    switch (this) {
      case RebirthTier.rebirth:
        return 'Rebirth';
      case RebirthTier.ascension:
        return 'Ascensão';
      case RebirthTier.transcendence:
        return 'Transcendência';
      case RebirthTier.furuborus:
        return 'Furuborus';
    }
  }

  String get emoji {
    switch (this) {
      case RebirthTier.rebirth:
        return '🔄';
      case RebirthTier.ascension:
        return '✨';
      case RebirthTier.transcendence:
        return '🌟';
      case RebirthTier.furuborus:
        return '🐉';
    }
  }

  String get description {
    switch (this) {
      case RebirthTier.rebirth:
        return 'Recomeça do zero, mas com multiplicador permanente';
      case RebirthTier.ascension:
        return 'Reset completo com grande boost e tokens celestiais';
      case RebirthTier.transcendence:
        return 'Transcende a realidade por poder incomparável';
      case RebirthTier.furuborus:
        return 'Renascimento místico que concede forus';
    }
  }

  double getRequirement(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return _safeCalculateRequirement(1e14, 8, currentCount * 0.72);
      case RebirthTier.ascension:
        return _safeCalculateRequirement(
            1e28, 16, currentCount.toDouble() * 1.05);
      case RebirthTier.transcendence:
        return _safeCalculateRequirement(
            1e42, 32, currentCount.toDouble() * 1.05);
      case RebirthTier.furuborus:
        return _safeCalculateRequirement(1e54, 64, currentCount.toDouble());
    }
  }

  double _safeCalculateRequirement(
      double base, double multiplier, double exponent) {
    // Evita overflow usando logaritmos para cálculos grandes
    if (exponent > 30) {
      // Para expoentes grandes, usa aproximação logarítmica
      final logBase = log(base);
      final logMultiplier = log(multiplier);
      final logResult = logBase + (logMultiplier * exponent);

      // Se o resultado é muito grande, retorna um valor máximo seguro
      if (logResult > 690) {
        // e^690 fica próximo do limite seguro de double
        return 1e300;
      }

      return exp(logResult);
    }

    // Para expoentes pequenos, usa cálculo direto
    final result = base * pow(multiplier, exponent);

    // Verifica se o resultado é finito
    if (result.isInfinite || result.isNaN) {
      return 1e300;
    }

    return result;
  }

  double getLogarithmicGain(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return 1.15 * (1 + log(currentCount + 1) * 0.16);
      case RebirthTier.ascension:
        return 2.5 * log(currentCount + 1) + 1.2;
      case RebirthTier.transcendence:
        return 4.0 * log(currentCount + 1) + 1.5;
      case RebirthTier.furuborus:
        return 1.0;
    }
  }

  double getEffectiveMultiplierGain(int currentCount) {
    if (this == RebirthTier.furuborus) {
      return 1.0;
    }

    final base = getLogarithmicGain(currentCount);

    switch (this) {
      case RebirthTier.rebirth:
        return base;
      case RebirthTier.ascension:
        const softCap = 8.0;
        const hardCap = 18.0;
        if (base <= softCap) {
          return base;
        }
        final excess = base - softCap;
        final withSoftCap = softCap + excess * 0.1;
        return withSoftCap < hardCap ? withSoftCap : hardCap;
      case RebirthTier.transcendence:
        const softCap = 12.0;
        const hardCap = 30.0;
        if (base <= softCap) {
          return base;
        }
        final excess = base - softCap;
        final withSoftCap = softCap + excess * 0.1;
        return withSoftCap < hardCap ? withSoftCap : hardCap;
      case RebirthTier.furuborus:
        return 1.0;
    }
  }

  double getMultiplierGain(int currentCount) {
    return getEffectiveMultiplierGain(currentCount);
  }

  double getTokenReward(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return 0.5;
      case RebirthTier.ascension:
        return (1 + (currentCount ~/ 2)).toDouble();
      case RebirthTier.transcendence:
        return (50 + currentCount * 5).toDouble();
      case RebirthTier.furuborus:
        return 0.0;
    }
  }
}

@HiveType(typeId: 1)
class RebirthData {
  @HiveField(0)
  final int rebirthCount;

  @HiveField(1)
  final int ascensionCount;

  @HiveField(2)
  final int transcendenceCount;

  @HiveField(3)
  final int furuborusCount;

  @HiveField(4)
  final double celestialTokens;

  @HiveField(5)
  final bool hasUsedOneTimeMultiplier;

  @HiveField(6)
  final List<String> usedCoupons;

  @HiveField(7)
  final double forus;

  @HiveField(8)
  final bool cauldronUnlocked;

  @HiveField(9)
  final bool craftUnlocked;

  const RebirthData({
    this.rebirthCount = 0,
    this.ascensionCount = 0,
    this.transcendenceCount = 0,
    this.furuborusCount = 0,
    this.celestialTokens = 0.0,
    this.hasUsedOneTimeMultiplier = false,
    this.usedCoupons = const [],
    this.forus = 0.0,
    this.cauldronUnlocked = false,
    this.craftUnlocked = false,
  });

  RebirthData copyWith({
    int? rebirthCount,
    int? ascensionCount,
    int? transcendenceCount,
    int? furuborusCount,
    double? celestialTokens,
    bool? hasUsedOneTimeMultiplier,
    List<String>? usedCoupons,
    double? forus,
    bool? cauldronUnlocked,
    bool? craftUnlocked,
  }) {
    return RebirthData(
      rebirthCount: rebirthCount ?? this.rebirthCount,
      ascensionCount: ascensionCount ?? this.ascensionCount,
      transcendenceCount: transcendenceCount ?? this.transcendenceCount,
      furuborusCount: furuborusCount ?? this.furuborusCount,
      celestialTokens: celestialTokens ?? this.celestialTokens,
      hasUsedOneTimeMultiplier:
          hasUsedOneTimeMultiplier ?? this.hasUsedOneTimeMultiplier,
      usedCoupons: usedCoupons ?? this.usedCoupons,
      forus: forus ?? this.forus,
      cauldronUnlocked: cauldronUnlocked ?? this.cauldronUnlocked,
      craftUnlocked: craftUnlocked ?? this.craftUnlocked,
    );
  }

  EfficientNumber getTotalMultiplier() {
    EfficientNumber multiplier = const EfficientNumber.one();

    // Rebirth multiplier (logarítmico com base cumulativa)
    if (rebirthCount > 0) {
      final rebirthGain =
          RebirthTier.rebirth.getEffectiveMultiplierGain(rebirthCount);
      final rebirthMultiplier = EfficientNumber.fromValues(rebirthGain, 0);
      multiplier *= rebirthMultiplier;
    }

    // Ascension multiplier (logarítmico com caps)
    if (ascensionCount > 0) {
      final gainValue =
          RebirthTier.ascension.getEffectiveMultiplierGain(ascensionCount);
      final ascensionMultiplier = EfficientNumber.fromValues(gainValue, 0);
      multiplier *= ascensionMultiplier;
    }

    // Transcendence multiplier (logarítmico com caps)
    if (transcendenceCount > 0) {
      final gainValue = RebirthTier.transcendence
          .getEffectiveMultiplierGain(transcendenceCount);
      final transcendenceMultiplier = EfficientNumber.fromValues(gainValue, 0);
      multiplier *= transcendenceMultiplier;
    }

    return multiplier;
  }

  Map<String, dynamic> toJson() {
    return {
      'rebirthCount': rebirthCount,
      'ascensionCount': ascensionCount,
      'transcendenceCount': transcendenceCount,
      'furuborusCount': furuborusCount,
      'celestialToken': celestialTokens,
      'hasUsedOneTimeMultiplier': hasUsedOneTimeMultiplier,
      'usedCoupons': usedCoupons,
      'forus': forus,
      'cauldronUnlocked': cauldronUnlocked,
      'craftUnlocked': craftUnlocked,
    };
  }

  factory RebirthData.fromJson(Map<String, dynamic> json) {
    return RebirthData(
      rebirthCount: json['rebirthCount'] ?? 0,
      ascensionCount: json['ascensionCount'] ?? 0,
      transcendenceCount: json['transcendenceCount'] ?? 0,
      furuborusCount: json['furuborusCount'] ?? 0,
      celestialTokens: (json['celestialToken'] ?? 0).toDouble(),
      hasUsedOneTimeMultiplier: json['hasUsedOneTimeMultiplier'] ?? false,
      usedCoupons: List<String>.from(json['usedCoupons'] ?? []),
      forus: (json['forus'] ?? 0).toDouble(),
      cauldronUnlocked: json['cauldronUnlocked'] ?? false,
      craftUnlocked: json['craftUnlocked'] ?? false,
    );
  }
}
