import 'dart:math';

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
        return 1.0;
      case RebirthTier.ascension:
        return 3.0;
      case RebirthTier.transcendence:
        return 6.5;
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

class RebirthData {
  final int rebirthCount;
  final int ascensionCount;
  final int transcendenceCount;
  final double celestialTokens;
  final bool hasUsedOneTimeMultiplier;
  final Set<String> usedCoupons;

  const RebirthData({
    this.rebirthCount = 0,
    this.ascensionCount = 0,
    this.transcendenceCount = 0,
    this.celestialTokens = 0.0,
    this.hasUsedOneTimeMultiplier = false,
    this.usedCoupons = const {},
  });

  RebirthData copyWith({
    int? rebirthCount,
    int? ascensionCount,
    int? transcendenceCount,
    double? celestialTokens,
    bool? hasUsedOneTimeMultiplier,
    Set<String>? usedCoupons,
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

  double getTotalMultiplier() {
    double multiplier = 1.0;

    // Otimização: evita cálculos custosos para números muito grandes
    if (rebirthCount > 0) {
      multiplier *= 1.0 + (RebirthTier.rebirth.getMultiplierGain(0) * rebirthCount);
    }

    if (ascensionCount > 0) {
      // Para muitas ascensões, usa aproximação logarítmica
      if (ascensionCount > 50) {
        final logMultiplier = ascensionCount * log(RebirthTier.ascension.getMultiplierGain(0));
        multiplier *= exp(logMultiplier);
      } else {
        multiplier *= pow(
          RebirthTier.ascension.getMultiplierGain(0),
          ascensionCount,
        ).toDouble();
      }
    }

    if (transcendenceCount > 0) {
      // Para muitas transcendências, usa aproximação logarítmica
      if (transcendenceCount > 30) {
        final logMultiplier = transcendenceCount * log(RebirthTier.transcendence.getMultiplierGain(0));
        multiplier *= exp(logMultiplier);
      } else {
        multiplier *= pow(
          RebirthTier.transcendence.getMultiplierGain(0),
          transcendenceCount,
        ).toDouble();
      }
    }

    // Verifica se o resultado é finito
    if (multiplier.isInfinite || multiplier.isNaN) {
      return 1e50; // Valor máximo seguro
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
      'used_coupons': usedCoupons.toList(),
    };
  }

  factory RebirthData.fromJson(Map<String, dynamic> json) {
    return RebirthData(
      rebirthCount: json['rebirth_count'] ?? 0,
      ascensionCount: json['ascension_count'] ?? 0,
      transcendenceCount: json['transcendence_count'] ?? 0,
      celestialTokens: (json['celestial_tokens'] ?? 0).toDouble(),
      hasUsedOneTimeMultiplier: json['has_used_one_time_multiplier'] ?? false,
      usedCoupons: Set<String>.from(json['used_coupons'] ?? []),
    );
  }
}

