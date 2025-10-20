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
        return 1e15 * pow(10, currentCount * 0.8);
      case RebirthTier.ascension:
        return 1e30 * pow(500, currentCount);
      case RebirthTier.transcendence:
        return 1e45 * pow(5000, currentCount);
    }
  }

  double getMultiplierGain(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return 0.2;
      case RebirthTier.ascension:
        return 2.0;
      case RebirthTier.transcendence:
        return 4.5;
    }
  }

  int getTokenReward(int currentCount) {
    switch (this) {
      case RebirthTier.rebirth:
        return 0;
      case RebirthTier.ascension:
        return 1 + (currentCount ~/ 2);
      case RebirthTier.transcendence:
        return 5 + currentCount;
    }
  }
}

class RebirthData {
  final int rebirthCount;
  final int ascensionCount;
  final int transcendenceCount;
  final int celestialTokens;
  final bool hasUsedOneTimeMultiplier;

  const RebirthData({
    this.rebirthCount = 0,
    this.ascensionCount = 0,
    this.transcendenceCount = 0,
    this.celestialTokens = 0,
    this.hasUsedOneTimeMultiplier = false,
  });

  RebirthData copyWith({
    int? rebirthCount,
    int? ascensionCount,
    int? transcendenceCount,
    int? celestialTokens,
    bool? hasUsedOneTimeMultiplier,
  }) {
    return RebirthData(
      rebirthCount: rebirthCount ?? this.rebirthCount,
      ascensionCount: ascensionCount ?? this.ascensionCount,
      transcendenceCount: transcendenceCount ?? this.transcendenceCount,
      celestialTokens: celestialTokens ?? this.celestialTokens,
      hasUsedOneTimeMultiplier: hasUsedOneTimeMultiplier ?? this.hasUsedOneTimeMultiplier,
    );
  }

  double getTotalMultiplier() {
    double multiplier = 1.0;

    multiplier *= 1.0 + (RebirthTier.rebirth.getMultiplierGain(0) * rebirthCount);

    multiplier *= pow(
      RebirthTier.ascension.getMultiplierGain(0),
      ascensionCount,
    ).toDouble();

    multiplier *= pow(
      RebirthTier.transcendence.getMultiplierGain(0),
      transcendenceCount,
    ).toDouble();

    return multiplier;
  }

  Map<String, dynamic> toJson() {
    return {
      'rebirth_count': rebirthCount,
      'ascension_count': ascensionCount,
      'transcendence_count': transcendenceCount,
      'celestial_tokens': celestialTokens,
      'has_used_one_time_multiplier': hasUsedOneTimeMultiplier,
    };
  }

  factory RebirthData.fromJson(Map<String, dynamic> json) {
    return RebirthData(
      rebirthCount: json['rebirth_count'] ?? 0,
      ascensionCount: json['ascension_count'] ?? 0,
      transcendenceCount: json['transcendence_count'] ?? 0,
      celestialTokens: json['celestial_tokens'] ?? 0,
      hasUsedOneTimeMultiplier: json['has_used_one_time_multiplier'] ?? false,
    );
  }
}

