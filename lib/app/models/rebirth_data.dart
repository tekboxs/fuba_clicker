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
        return _safeCalculateRequirement(1e15, 10, currentCount * 0.8);
      case RebirthTier.ascension:
        return _safeCalculateRequirement(500e27, 20, currentCount.toDouble());
      case RebirthTier.transcendence:
        return _safeCalculateRequirement(1e45, 50, currentCount.toDouble());
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

  double getMultiplierGain(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return 2.0; // 2x por rebirth
      case RebirthTier.ascension:
        return 10.0; // 10x por ascensão
      case RebirthTier.transcendence:
        return 10.0; // 10x por transcendência
      case RebirthTier.furuborus:
        return 1.0; // Sem multiplicador, apenas forus
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

  const RebirthData({
    this.rebirthCount = 0,
    this.ascensionCount = 0,
    this.transcendenceCount = 0,
    this.furuborusCount = 0,
    this.celestialTokens = 0.0,
    this.hasUsedOneTimeMultiplier = false,
    this.usedCoupons = const [],
    this.forus = 0.0,
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
    );
  }

  EfficientNumber getTotalMultiplier() {
    EfficientNumber multiplier = const EfficientNumber.one();

    // Rebirth multiplier
    if (rebirthCount > 0) {
      final rebirthGain = EfficientNumber.fromValues(
          RebirthTier.rebirth.getMultiplierGain(0), 0);
      final rebirthMultiplier = const EfficientNumber.one() + 
          (rebirthGain * EfficientNumber.fromValues(rebirthCount.toDouble(), 0));
      multiplier *= rebirthMultiplier;
    }

    // Ascension multiplier
    if (ascensionCount > 0) {
      final gainValue = RebirthTier.ascension.getMultiplierGain(0);
      final ascensionMultiplier = EfficientNumber.fromPower(gainValue, ascensionCount.toDouble());
      multiplier *= ascensionMultiplier;
    }

    // Transcendence multiplier
    if (transcendenceCount > 0) {
      final gainValue = RebirthTier.transcendence.getMultiplierGain(0);
      final transcendenceMultiplier = EfficientNumber.fromPower(gainValue, transcendenceCount.toDouble());
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
    );
  }
}

