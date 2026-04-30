import 'dart:math';

enum RandomEventType { cornRain, clickFrenzy, tokenStorm, goldenCorn }

class RandomEvent {
  final RandomEventType type;
  final DateTime appearedAt;
  bool activated;
  DateTime? activatedAt;

  RandomEvent({required this.type, required this.appearedAt})
      : activated = false;

  // Player has 30s to tap the banner to activate the event
  bool get isClaimed => activated;

  bool get isClaimExpired =>
      !activated &&
      DateTime.now().difference(appearedAt).inSeconds > 30;

  bool get isEffectExpired =>
      activated &&
      activatedAt != null &&
      DateTime.now().difference(activatedAt!).inSeconds > effectDuration;

  bool get isDone => isClaimExpired || isEffectExpired;

  int get effectDuration {
    switch (type) {
      case RandomEventType.cornRain:
        return 60;
      case RandomEventType.clickFrenzy:
        return 30;
      case RandomEventType.tokenStorm:
        return 120;
      case RandomEventType.goldenCorn:
        return 10;
    }
  }

  int get secondsRemaining {
    if (!activated) {
      final elapsed = DateTime.now().difference(appearedAt).inSeconds;
      return (30 - elapsed).clamp(0, 30);
    }
    if (activatedAt == null) return 0;
    final elapsed = DateTime.now().difference(activatedAt!).inSeconds;
    return (effectDuration - elapsed).clamp(0, effectDuration);
  }

  double get productionMultiplier {
    if (!activated || isEffectExpired) return 1.0;
    switch (type) {
      case RandomEventType.cornRain:
        return 3.0;
      case RandomEventType.goldenCorn:
        return 50.0;
      default:
        return 1.0;
    }
  }

  double get clickMultiplier {
    if (!activated || isEffectExpired) return 1.0;
    switch (type) {
      case RandomEventType.clickFrenzy:
        return 5.0;
      default:
        return 1.0;
    }
  }

  double get tokenMultiplier {
    if (!activated || isEffectExpired) return 1.0;
    switch (type) {
      case RandomEventType.tokenStorm:
        return 2.0;
      default:
        return 1.0;
    }
  }

  String get title {
    switch (type) {
      case RandomEventType.cornRain:
        return 'Chuva de Milho!';
      case RandomEventType.clickFrenzy:
        return 'Frenesi de Cliques!';
      case RandomEventType.tokenStorm:
        return 'Tempestade de Tokens!';
      case RandomEventType.goldenCorn:
        return 'Milho Dourado!';
    }
  }

  String get description {
    switch (type) {
      case RandomEventType.cornRain:
        return '3x produção por ${effectDuration}s';
      case RandomEventType.clickFrenzy:
        return '5x poder de clique por ${effectDuration}s';
      case RandomEventType.tokenStorm:
        return '2x tokens em rebirths por ${effectDuration}s';
      case RandomEventType.goldenCorn:
        return '50x produção por ${effectDuration}s';
    }
  }

  String get emoji {
    switch (type) {
      case RandomEventType.cornRain:
        return '🌽';
      case RandomEventType.clickFrenzy:
        return '⚡';
      case RandomEventType.tokenStorm:
        return '⭐';
      case RandomEventType.goldenCorn:
        return '🌟';
    }
  }

  void activate() {
    activated = true;
    activatedAt = DateTime.now();
  }

  static RandomEvent random() {
    final types = RandomEventType.values;
    final type = types[Random().nextInt(types.length)];
    return RandomEvent(type: type, appearedAt: DateTime.now());
  }
}
