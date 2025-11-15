enum PotionEffectType {
  productionMultiplier,
  clickPower,
  tokenGain,
  forusGain,
  rebirthMultiplier,
  generatorDiscount,
  accessoryDropChance,
  permanentMultiplier,
}

class PotionEffect {
  final PotionEffectType type;
  final double value;
  final Duration? duration;
  final DateTime? expiresAt;
  final bool isPermanent;

  PotionEffect({
    required this.type,
    required this.value,
    this.duration,
    this.expiresAt,
    this.isPermanent = false,
  }) : assert(
          isPermanent || duration != null || expiresAt != null,
          'Effect must have duration or be permanent',
        );

  bool get isExpired {
    if (isPermanent) return false;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get description {
    switch (type) {
      case PotionEffectType.productionMultiplier:
        return 'x${value.toStringAsFixed(2)} produção';
      case PotionEffectType.clickPower:
        return 'x${value.toStringAsFixed(2)} poder de clique';
      case PotionEffectType.tokenGain:
        return '+${value.toStringAsFixed(0)}% tokens celestiais';
      case PotionEffectType.forusGain:
        return '+${value.toStringAsFixed(0)}% forus';
      case PotionEffectType.rebirthMultiplier:
        return 'x${value.toStringAsFixed(2)} multiplicador de rebirth';
      case PotionEffectType.generatorDiscount:
        return '-${value.toStringAsFixed(0)}% custo geradores';
      case PotionEffectType.accessoryDropChance:
        return '+${value.toStringAsFixed(1)}% chance de itens raros';
      case PotionEffectType.permanentMultiplier:
        return 'x${value.toStringAsFixed(2)} multiplicador permanente';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'value': value,
      'duration': duration?.inMilliseconds,
      'expiresAt': expiresAt?.toIso8601String(),
      'isPermanent': isPermanent,
    };
  }

  factory PotionEffect.fromJson(Map<String, dynamic> json) {
    return PotionEffect(
      type: PotionEffectType.values[json['type'] as int],
      value: (json['value'] as num).toDouble(),
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isPermanent: json['isPermanent'] as bool? ?? false,
    );
  }
}

