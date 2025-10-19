enum UpgradeType {
  autoClicker,
  idleBoost,
  luckyBoxes,
  clickPower,
  generatorDiscount,
  offlineProduction,
  startingFuba,
  productionMultiplier,
  animationSpeed,
  accessoryCapacity,
}

class RebirthUpgrade {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final UpgradeType type;
  final int baseTokenCost;
  final int maxLevel;
  final int ascensionRequirement;

  const RebirthUpgrade({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.type,
    required this.baseTokenCost,
    this.maxLevel = 10,
    this.ascensionRequirement = 0,
  });

  int getTokenCost(int currentLevel) {
    return baseTokenCost + (currentLevel * baseTokenCost ~/ 2);
  }

  double getEffectValue(int level) {
    switch (type) {
      case UpgradeType.autoClicker:
        return level.toDouble();
      case UpgradeType.idleBoost:
        return 1.0 + (level * 0.2);
      case UpgradeType.luckyBoxes:
        return level * 0.05;
      case UpgradeType.clickPower:
        return 1.0 + (level * 2.0);
      case UpgradeType.generatorDiscount:
        return level * 0.02;
      case UpgradeType.offlineProduction:
        return level * 10.0;
      case UpgradeType.startingFuba:
        return level * 1000.0;
      case UpgradeType.productionMultiplier:
        return 1.0 + (level * 0.1);
      case UpgradeType.animationSpeed:
        return 1.0 - (level * 0.1);
      case UpgradeType.accessoryCapacity:
        return 3.0 + (level * 1.0);
    }
  }

  String getEffectDescription(int level) {
    switch (type) {
      case UpgradeType.autoClicker:
        return '+${level.toStringAsFixed(0)} cliques/s';
      case UpgradeType.idleBoost:
        return '+${((getEffectValue(level) - 1) * 100).toStringAsFixed(0)}% produção idle';
      case UpgradeType.luckyBoxes:
        return '+${(getEffectValue(level) * 100).toStringAsFixed(0)}% chance item melhor';
      case UpgradeType.clickPower:
        return 'x${getEffectValue(level).toStringAsFixed(1)} fubá por clique';
      case UpgradeType.generatorDiscount:
        return '-${(getEffectValue(level) * 100).toStringAsFixed(0)}% custo geradores';
      case UpgradeType.offlineProduction:
        return '+${getEffectValue(level).toStringAsFixed(0)} minutos offline';
      case UpgradeType.startingFuba:
        return '+${getEffectValue(level).toStringAsFixed(0)} fubá inicial';
      case UpgradeType.productionMultiplier:
        return 'x${getEffectValue(level).toStringAsFixed(1)} produção total';
      case UpgradeType.animationSpeed:
        return 'x${getEffectValue(level).toStringAsFixed(1)} velocidade animação';
      case UpgradeType.accessoryCapacity:
        return '${getEffectValue(level).toInt()} slots de acessórios';
    }
  }
}

const List<RebirthUpgrade> allUpgrades = [
  RebirthUpgrade(
    id: 'auto_clicker',
    name: 'Auto Clicker',
    emoji: '👆',
    description: 'Clica no bolo automaticamente',
    type: UpgradeType.autoClicker,
    baseTokenCost: 1,
    maxLevel: 20,
  ),
  RebirthUpgrade(
    id: 'click_power',
    name: 'Poder do Clique',
    emoji: '💪',
    description: 'Multiplica fubá por clique',
    type: UpgradeType.clickPower,
    baseTokenCost: 1,
    maxLevel: 20,
  ),
  RebirthUpgrade(
    id: 'idle_boost',
    name: 'Boost Idle',
    emoji: '💤',
    description: 'Aumenta produção passiva',
    type: UpgradeType.idleBoost,
    baseTokenCost: 2,
    maxLevel: 15,
  ),
  RebirthUpgrade(
    id: 'lucky_boxes',
    name: 'Caixas da Sorte',
    emoji: '🍀',
    description: 'Aumenta chance de itens melhores',
    type: UpgradeType.luckyBoxes,
    baseTokenCost: 3,
    maxLevel: 10,
  ),
  RebirthUpgrade(
    id: 'generator_discount',
    name: 'Desconto de Geradores',
    emoji: '💰',
    description: 'Reduz custo dos geradores',
    type: UpgradeType.generatorDiscount,
    baseTokenCost: 4,
    maxLevel: 10,
    ascensionRequirement: 1,
  ),
  // RebirthUpgrade(
  //   id: 'offline_production',
  //   name: 'Produção Offline',
  //   emoji: '⏰',
  //   description: 'Produz fubá enquanto offline',
  //   type: UpgradeType.offlineProduction,
  //   baseTokenCost: 5,
  //   maxLevel: 12,
  //   ascensionRequirement: 2,
  // ),
  // RebirthUpgrade(
  //   id: 'starting_fuba',
  //   name: 'Fubá Inicial',
  //   emoji: '🌽',
  //   description: 'Começa com mais fubá',
  //   type: UpgradeType.startingFuba,
  //   baseTokenCost: 3,
  //   maxLevel: 20,
  //   ascensionRequirement: 1,
  // ),
  RebirthUpgrade(
    id: 'production_multiplier',
    name: 'Super Produção',
    emoji: '⚡',
    description: 'Multiplica toda produção',
    type: UpgradeType.productionMultiplier,
    baseTokenCost: 10,
    maxLevel: 10,
    ascensionRequirement: 3,
  ),
  RebirthUpgrade(
    id: 'animation_speed',
    name: 'Velocidade Celestial',
    emoji: '⚡',
    description: 'Acelera animações de abertura de caixas',
    type: UpgradeType.animationSpeed,
    baseTokenCost: 5,
    maxLevel: 10,
    ascensionRequirement: 1,
  ),
  RebirthUpgrade(
    id: 'accessory_capacity',
    name: 'Capacidade Expandida',
    emoji: '🎒',
    description: 'Aumenta capacidade de acessórios equipados',
    type: UpgradeType.accessoryCapacity,
    baseTokenCost: 8,
    maxLevel: 12,
    ascensionRequirement: 2,
  ),
];

