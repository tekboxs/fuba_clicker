import 'dart:math';

class CampaignPhase {
  final int phase;
  final String enemyName;
  final String enemyEmoji;
  final double maxHp;
  final bool isBoss;
  final int tokenReward;
  final double forusReward;

  const CampaignPhase({
    required this.phase,
    required this.enemyName,
    required this.enemyEmoji,
    required this.maxHp,
    required this.isBoss,
    required this.tokenReward,
    required this.forusReward,
  });

  int get timerSeconds => isBoss ? 120 : 45;

  static double _calcHp(int phase) =>
      (30 * pow(1.08, phase - 1)).ceilToDouble();

  static final _normalNames = [
    'Espiga Rebelde',
    'Milho Guerreiro',
    'Grão Enraivecido',
    'Espigazinha Furia',
    'Polenta Sombria',
    'Farinha do Caos',
    'Milho Encantado',
    'Grão das Trevas',
    'Canjica Irada',
    'Angu Selvagem',
    'Milho do Abismo',
    'Creme de Milho Maldito',
    'Fubá Vingativo',
    'Pamonha Cruel',
    'Cuscuz do Inferno',
    'Quirera Mágica',
    'Broinha do Mal',
    'Xerém Sombrio',
    'Mingau Amaldiçoado',
    'Mungunzá das Sombras',
    'Milho Fantasma',
    'Espiga Venenosa',
    'Grão Dimensional',
    'Fubá Quântico',
    'Polenta Interdimensional',
    'Angu do Vazio',
    'Canjica Eterna',
    'Milho do Tempo',
    'Farinha Cósmica',
    'Grão da Eternidade',
    'Espiga do Destino',
    'Milho Transcendente',
  ];

  static final _bossNames = [
    'Rei do Milho',
    'Senhor do Fubá',
    'Imperador da Polenta',
    'Deus da Farinha',
    'Lorde do Angu',
    'Titã da Canjica',
    'Supremo do Quirera',
    'O Absoluto Fubá',
  ];

  static final _normalEmojis = [
    '🌽',
    '🌾',
    '🫘',
    '🌿',
    '🍞',
    '🥣',
    '🫙',
    '🌰',
    '🧀',
    '🍳',
    '🥫',
    '🍜',
  ];

  static final _bossEmojis = [
    '👑',
    '🐉',
    '💀',
    '🔥',
    '⚡',
    '🌪️',
    '🌊',
    '☄️',
  ];

  static CampaignPhase forPhase(int phase) {
    final isBoss = phase % 5 == 0;
    final hp = _calcHp(phase) * (isBoss ? 3 : 1);
    final bossIndex = (phase ~/ 5) - 1;
    final normalIndex = (phase - 1) % _normalNames.length;
    final emojiIndex = (phase - 1) % _normalEmojis.length;

    return CampaignPhase(
      phase: phase,
      enemyName: isBoss
          ? _bossNames[bossIndex.clamp(0, _bossNames.length - 1)]
          : _normalNames[normalIndex],
      enemyEmoji: isBoss
          ? _bossEmojis[bossIndex.clamp(0, _bossEmojis.length - 1)]
          : _normalEmojis[emojiIndex],
      maxHp: hp,
      isBoss: isBoss,
      tokenReward: isBoss ? phase * 50 : phase * 10,
      forusReward: (isBoss && phase >= 10) ? 0.5 : 0.0,
    );
  }

  static List<CampaignPhase> get allPhases =>
      List.generate(40, (i) => forPhase(i + 1));
}

class CampaignBattle {
  final CampaignPhase phase;
  double currentHp;
  final DateTime startedAt;
  bool finished;
  bool won;

  CampaignBattle({required this.phase})
      : currentHp = phase.maxHp,
        startedAt = DateTime.now(),
        finished = false,
        won = false;

  double get hpPercent => (currentHp / phase.maxHp).clamp(0.0, 1.0);

  int get secondsElapsed => DateTime.now().difference(startedAt).inSeconds;

  int get secondsRemaining =>
      (phase.timerSeconds - secondsElapsed).clamp(0, phase.timerSeconds);

  bool get isTimeUp => secondsElapsed >= phase.timerSeconds;

  void dealDamage(double dmg) {
    if (finished) return;
    currentHp = (currentHp - dmg).clamp(0, phase.maxHp);
    if (currentHp <= 0) {
      finished = true;
      won = true;
    }
  }

  void checkTimeout() {
    if (!finished && isTimeUp) {
      finished = true;
      won = false;
    }
  }
}
