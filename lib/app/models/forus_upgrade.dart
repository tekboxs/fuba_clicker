enum ForusUpgradeType {
  mergeItems,
  cauldron,
}

class ForusUpgrade {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final ForusUpgradeType type;
  final double forusCost;
  final bool isOneTime;

  const ForusUpgrade({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.type,
    required this.forusCost,
    this.isOneTime = true,
  });
}

const List<ForusUpgrade> allForusUpgrades = [
  ForusUpgrade(
    id: 'merge_items',
    name: 'Fundir Itens',
    emoji: '🔗',
    description: 'Permite fundir acessórios para criar versões melhores',
    type: ForusUpgradeType.mergeItems,
    forusCost: 1.0,
    isOneTime: true,
  ),
  ForusUpgrade(
    id: 'cauldron',
    name: 'Caldeirão de Poções',
    emoji: '🧪',
    description: 'Desbloqueia o caldeirão para criar poções mágicas',
    type: ForusUpgradeType.cauldron,
    forusCost: 5.0,
    isOneTime: true,
  ),
];

