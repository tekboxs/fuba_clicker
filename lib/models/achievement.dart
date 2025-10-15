enum AchievementCategory {
  production,
  clicks,
  generators,
  accessories,
  lootBoxes,
  rebirth,
  secret,
}

enum AchievementRewardType {
  multiplier,
  tokens,
  unlockSecret,
}

class AchievementReward {
  final AchievementRewardType type;
  final double value;
  final String? secretId;

  const AchievementReward({
    required this.type,
    required this.value,
    this.secretId,
  });
}

class Achievement {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final AchievementCategory category;
  final bool isSecret;
  final double targetValue;
  final AchievementReward reward;

  const Achievement({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.category,
    required this.targetValue,
    required this.reward,
    this.isSecret = false,
  });
}

const List<Achievement> allAchievements = [
  Achievement(
    id: 'first_click',
    name: 'Primeiro Clique',
    emoji: '👆',
    description: 'Clique no bolo pela primeira vez',
    category: AchievementCategory.clicks,
    targetValue: 1,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.1),
  ),
  Achievement(
    id: 'click_100',
    name: 'Clicador Dedicado',
    emoji: '💪',
    description: 'Clique no bolo 100 vezes',
    category: AchievementCategory.clicks,
    targetValue: 100,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.2),
  ),
  Achievement(
    id: 'click_1000',
    name: 'Clicador Insano',
    emoji: '🔥',
    description: 'Clique no bolo 1000 vezes',
    category: AchievementCategory.clicks,
    targetValue: 1000,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.5),
  ),
  Achievement(
    id: 'production_1k',
    name: 'Produtor Iniciante',
    emoji: '🌽',
    description: 'Produza 1.000 fubá total',
    category: AchievementCategory.production,
    targetValue: 1000,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.1),
  ),
  Achievement(
    id: 'production_1m',
    name: 'Produtor Experiente',
    emoji: '🏭',
    description: 'Produza 1 milhão de fubá total',
    category: AchievementCategory.production,
    targetValue: 1e6,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.3),
  ),
  Achievement(
    id: 'production_1b',
    name: 'Produtor Lendário',
    emoji: '👑',
    description: 'Produza 1 bilhão de fubá total',
    category: AchievementCategory.production,
    targetValue: 1e9,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.5),
  ),
  Achievement(
    id: 'production_1t',
    name: 'Produtor Cósmico',
    emoji: '🌌',
    description: 'Produza 1 trilhão de fubá total',
    category: AchievementCategory.production,
    targetValue: 1e12,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 2.0),
  ),
  Achievement(
    id: 'first_generator',
    name: 'Primeiro Gerador',
    emoji: '⚙️',
    description: 'Compre seu primeiro gerador',
    category: AchievementCategory.generators,
    targetValue: 1,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.1),
  ),
  Achievement(
    id: 'generator_10',
    name: 'Colecionador',
    emoji: '📦',
    description: 'Possua 10 geradores diferentes',
    category: AchievementCategory.generators,
    targetValue: 10,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.3),
  ),
  Achievement(
    id: 'generator_all',
    name: 'Mestre dos Geradores',
    emoji: '🎯',
    description: 'Possua todos os geradores',
    category: AchievementCategory.generators,
    targetValue: 30,
    reward: AchievementReward(
      type: AchievementRewardType.unlockSecret,
      value: 1.0,
      secretId: 'cake_awakened',
    ),
  ),
  Achievement(
    id: 'first_accessory',
    name: 'Primeira Decoração',
    emoji: '✨',
    description: 'Consiga seu primeiro acessório',
    category: AchievementCategory.accessories,
    targetValue: 1,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.1),
  ),
  Achievement(
    id: 'accessory_legendary',
    name: 'Sortudo',
    emoji: '💎',
    description: 'Consiga um acessório lendário',
    category: AchievementCategory.accessories,
    targetValue: 1,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.5),
  ),
  Achievement(
    id: 'accessory_mythical',
    name: 'Abençoado pelos Deuses',
    emoji: '🌟',
    description: 'Consiga um acessório mítico',
    category: AchievementCategory.accessories,
    targetValue: 1,
    reward: AchievementReward(type: AchievementRewardType.tokens, value: 5),
  ),
  Achievement(
    id: 'equip_8',
    name: 'Bolo Completo',
    emoji: '🎂',
    description: 'Equipe 8 acessórios ao mesmo tempo',
    category: AchievementCategory.accessories,
    targetValue: 8,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.3),
  ),
  Achievement(
    id: 'lootbox_10',
    name: 'Apostador',
    emoji: '🎰',
    description: 'Abra 10 caixas',
    category: AchievementCategory.lootBoxes,
    targetValue: 10,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.2),
  ),
  Achievement(
    id: 'lootbox_100',
    name: 'Viciado em Caixas',
    emoji: '📦',
    description: 'Abra 100 caixas',
    category: AchievementCategory.lootBoxes,
    targetValue: 100,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.5),
  ),
  Achievement(
    id: 'first_rebirth',
    name: 'Renascido',
    emoji: '🔄',
    description: 'Faça seu primeiro rebirth',
    category: AchievementCategory.rebirth,
    targetValue: 1,
    reward: AchievementReward(type: AchievementRewardType.tokens, value: 2),
  ),
  Achievement(
    id: 'rebirth_10',
    name: 'Ciclo Eterno',
    emoji: '♾️',
    description: 'Faça 10 rebirths',
    category: AchievementCategory.rebirth,
    targetValue: 10,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 2.0),
  ),
  Achievement(
    id: 'first_ascension',
    name: 'Ascendido',
    emoji: '✨',
    description: 'Faça sua primeira ascensão',
    category: AchievementCategory.rebirth,
    targetValue: 1,
    reward: AchievementReward(type: AchievementRewardType.tokens, value: 5),
  ),
  Achievement(
    id: 'first_transcendence',
    name: 'Transcendente',
    emoji: '🌟',
    description: 'Faça sua primeira transcendência',
    category: AchievementCategory.rebirth,
    targetValue: 1,
    reward: AchievementReward(type: AchievementRewardType.tokens, value: 10),
  ),
  Achievement(
    id: 'secret_fast_clicker',
    name: '???',
    emoji: '⚡',
    description: 'Clique 50 vezes em 10 segundos',
    category: AchievementCategory.secret,
    targetValue: 50,
    isSecret: true,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 1.5),
  ),
  Achievement(
    id: 'secret_patience',
    name: '???',
    emoji: '⏰',
    description: 'Espere 1 hora sem clicar',
    category: AchievementCategory.secret,
    targetValue: 3600,
    isSecret: true,
    reward: AchievementReward(type: AchievementRewardType.multiplier, value: 2.0),
  ),
  Achievement(
    id: 'secret_all_mythical',
    name: '???',
    emoji: '🎭',
    description: 'Equipe apenas acessórios míticos',
    category: AchievementCategory.secret,
    targetValue: 3,
    isSecret: true,
    reward: AchievementReward(
      type: AchievementRewardType.unlockSecret,
      value: 2.0,
      secretId: 'divine_baker',
    ),
  ),
  Achievement(
    id: 'secret_no_generators',
    name: '???',
    emoji: '🚫',
    description: 'Alcance 100k fubá apenas clicando',
    category: AchievementCategory.secret,
    targetValue: 100000,
    isSecret: true,
    reward: AchievementReward(type: AchievementRewardType.tokens, value: 10),
  ),
];

