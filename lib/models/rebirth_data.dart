import 'dart:math';
import 'package:big_decimal/big_decimal.dart';
import 'package:hive/hive.dart';

part 'rebirth_data.g.dart';

enum RebirthTier {
  rebirth,
  ascension,
  transcendence,
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
    }
  }

  double getRequirement(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return _safeCalculateRequirement(1e15, 10, currentCount * 0.8);
      case RebirthTier.ascension:
        return _safeCalculateRequirement(500e27, 20, currentCount.toDouble());
      case RebirthTier.transcendence:
        return _safeCalculateRequirement(1e45, 50, currentCount.toDouble());
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

  double getMultiplierGain(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return 2.0; // 2x por rebirth
      case RebirthTier.ascension:
        return 10.0; // 10x por ascensão
      case RebirthTier.transcendence:
        return 100.0; // 100x por transcendência
    }
  }

  double getTokenReward(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return 0.5;
      case RebirthTier.ascension:
        return (1 + (currentCount ~/ 2)).toDouble();
      case RebirthTier.transcendence:
        return (5 + currentCount).toDouble();
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
  final double celestialTokens;
  
  @HiveField(4)
  final bool hasUsedOneTimeMultiplier;
  
  @HiveField(5)
  final List<String> usedCoupons;
  

  const RebirthData({
    this.rebirthCount = 0,
    this.ascensionCount = 0,
    this.transcendenceCount = 0,
    this.celestialTokens = 0.0,
    this.hasUsedOneTimeMultiplier = false,
    this.usedCoupons = const [],
  });

  RebirthData copyWith({
    int? rebirthCount,
    int? ascensionCount,
    int? transcendenceCount,
    double? celestialTokens,
    bool? hasUsedOneTimeMultiplier,
    List<String>? usedCoupons,
  }) {
    return RebirthData(
      rebirthCount: rebirthCount ?? this.rebirthCount,
      ascensionCount: ascensionCount ?? this.ascensionCount,
      transcendenceCount: transcendenceCount ?? this.transcendenceCount,
      celestialTokens: celestialTokens ?? this.celestialTokens,
      hasUsedOneTimeMultiplier: hasUsedOneTimeMultiplier ?? this.hasUsedOneTimeMultiplier,
      usedCoupons: usedCoupons ?? this.usedCoupons,
    );
  }

  BigDecimal getTotalMultiplier() {
    BigDecimal multiplier = BigDecimal.one;

    // Rebirth multiplier
    if (rebirthCount > 0) {
      final rebirthGain = BigDecimal.parse(RebirthTier.rebirth.getMultiplierGain(0).toString());
      final rebirthMultiplier = BigDecimal.one + (rebirthGain * BigDecimal.parse(rebirthCount.toString()));
      multiplier *= rebirthMultiplier;
    }

    // Ascension multiplier
    if (ascensionCount > 0) {
      final ascensionGain = BigDecimal.parse(RebirthTier.ascension.getMultiplierGain(0).toString());
      final ascensionMultiplier = ascensionGain.pow(ascensionCount);
      multiplier *= ascensionMultiplier;
    }

    // Transcendence multiplier
    if (transcendenceCount > 0) {
      final transcendenceGain = BigDecimal.parse(RebirthTier.transcendence.getMultiplierGain(0).toString());
      final transcendenceMultiplier = transcendenceGain.pow(transcendenceCount);
      multiplier *= transcendenceMultiplier;
    }

    return multiplier;
  }

  Map<String, dynamic> toJson() {
    return {
      'rebirth_count': rebirthCount,
      'ascension_count': ascensionCount,
      'transcendence_count': transcendenceCount,
      'celestial_tokens': celestialTokens,
      'has_used_one_time_multiplier': hasUsedOneTimeMultiplier,
      'used_coupons': usedCoupons,
    };
  }

  factory RebirthData.fromJson(Map<String, dynamic> json) {
    return RebirthData(
      rebirthCount: json['rebirth_count'] ?? 0,
      ascensionCount: json['ascension_count'] ?? 0,
      transcendenceCount: json['transcendence_count'] ?? 0,
      celestialTokens: (json['celestial_tokens'] ?? 0).toDouble(),
      hasUsedOneTimeMultiplier: json['has_used_one_time_multiplier'] ?? false,
      usedCoupons: List<String>.from(json['used_coupons'] ?? []),
    );
  }
}

