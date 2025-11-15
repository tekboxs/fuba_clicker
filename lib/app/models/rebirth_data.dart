import 'dart:math';
import 'package:hive/hive.dart';
import '../core/utils/efficient_number.dart';
import '../core/utils/safe_convert.dart';

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
        return _safeCalculateRequirement(1e16, 12, currentCount * 0.8);
      case RebirthTier.ascension:
        return _safeCalculateRequirement(500e28, 24, currentCount.toDouble() * 1.2);
      case RebirthTier.transcendence:
        return _safeCalculateRequirement(1e46, 60, currentCount.toDouble() * 1.2);
      case RebirthTier.furuborus:
        return _safeCalculateRequirement(1e60, 100, currentCount.toDouble());
    }
  }
  
  double _safeCalculateRequirement(double base, double multiplier, double exponent) {
    // Evita overflow usando logaritmos para cálculos grandes
    if (exponent > 30) {
      // Para expoentes grandes, usa aproximação logarítmica
      final logBase = log(base);
      final logMultiplier = log(multiplier);
      final logResult = logBase + (logMultiplier * exponent);
      
      // Se o resultado é muito grande, retorna um valor máximo seguro
      if (logResult > 300) { // e^300 é aproximadamente 1e130
        return 1e100; // Valor máximo seguro para double
      }
      
      return exp(logResult);
    }
    
    // Para expoentes pequenos, usa cálculo direto
    final result = base * pow(multiplier, exponent);
    
    // Verifica se o resultado é finito
    if (result.isInfinite || result.isNaN) {
      return 1e100; // Valor máximo seguro
    }
    
    return result;
  }

  double getLogarithmicGain(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return 1.05 * (1 + log(currentCount + 1) * 0.1);
      case RebirthTier.ascension:
        return 2.0 * log(currentCount + 1) + 1.0;
      case RebirthTier.transcendence:
        return 3.0 * log(currentCount + 1) + 1.0;
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
        const softCap = 5.0;
        const hardCap = 10.0;
        if (base <= softCap) {
          return base;
        }
        final excess = base - softCap;
        final withSoftCap = softCap + excess * 0.1;
        return withSoftCap < hardCap ? withSoftCap : hardCap;
      case RebirthTier.transcendence:
        const softCap = 8.0;
        const hardCap = 15.0;
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
  }) {
    return RebirthData(
      rebirthCount: rebirthCount ?? this.rebirthCount,
      ascensionCount: ascensionCount ?? this.ascensionCount,
      transcendenceCount: transcendenceCount ?? this.transcendenceCount,
      furuborusCount: furuborusCount ?? this.furuborusCount,
      celestialTokens: celestialTokens ?? this.celestialTokens,
      hasUsedOneTimeMultiplier: hasUsedOneTimeMultiplier ?? this.hasUsedOneTimeMultiplier,
      usedCoupons: usedCoupons ?? this.usedCoupons,
      forus: forus ?? this.forus,
      cauldronUnlocked: cauldronUnlocked ?? this.cauldronUnlocked,
    );
  }

  EfficientNumber getTotalMultiplier() {
    EfficientNumber multiplier = const EfficientNumber.one();

    // Rebirth multiplier (logarítmico com base cumulativa)
    if (rebirthCount > 0) {
      final rebirthGain = RebirthTier.rebirth.getEffectiveMultiplierGain(rebirthCount);
      final rebirthMultiplier = EfficientNumber.fromValues(rebirthGain, 0);
      multiplier *= rebirthMultiplier;
    }

    // Ascension multiplier (logarítmico com caps)
    if (ascensionCount > 0) {
      final gainValue = RebirthTier.ascension.getEffectiveMultiplierGain(ascensionCount);
      final ascensionMultiplier = EfficientNumber.fromValues(gainValue, 0);
      multiplier *= ascensionMultiplier;
    }

    // Transcendence multiplier (logarítmico com caps)
    if (transcendenceCount > 0) {
      final gainValue = RebirthTier.transcendence.getEffectiveMultiplierGain(transcendenceCount);
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
    );
  }
}

