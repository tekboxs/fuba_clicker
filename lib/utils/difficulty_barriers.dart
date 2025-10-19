import 'package:big_decimal/big_decimal.dart';

class DifficultyBarrier {
  final String name;
  final String description;
  final BigDecimal requiredFuba;
  final int requiredGeneratorTier;
  final int requiredGeneratorCount;
  final String unlockMessage;
  final String emoji;

  const DifficultyBarrier({
    required this.name,
    required this.description,
    required this.requiredFuba,
    required this.requiredGeneratorTier,
    required this.requiredGeneratorCount,
    required this.unlockMessage,
    required this.emoji,
  });

  bool isUnlocked(BigDecimal currentFuba, List<int> generatorsOwned) {
    if (currentFuba.compareTo(requiredFuba) < 0) return false;
    if (requiredGeneratorTier >= generatorsOwned.length) return false;
    return generatorsOwned[requiredGeneratorTier] >= requiredGeneratorCount;
  }

  double getProgress(BigDecimal currentFuba, List<int> generatorsOwned) {
    final fubaProgress = currentFuba.divide(requiredFuba, scale: 10, roundingMode: RoundingMode.HALF_UP).toDouble().clamp(0.0, 1.0);
    
    if (requiredGeneratorTier >= generatorsOwned.length) return fubaProgress;
    
    final generatorProgress = (generatorsOwned[requiredGeneratorTier] / requiredGeneratorCount).clamp(0.0, 1.0);
    return (fubaProgress + generatorProgress) / 2;
  }
}

class DifficultyBarrierManager {
  static final List<DifficultyBarrier> lootBoxBarriers = [
    DifficultyBarrier(
      name: 'Primeira Caixa',
      description: 'Desbloqueie a primeira caixa de acessórios',
      requiredFuba: BigDecimal.parse('10000'),
      requiredGeneratorTier: 3,
      requiredGeneratorCount: 2,
      unlockMessage: 'Você desbloqueou a primeira caixa de acessórios!',
      emoji: '📦',
    ),
    DifficultyBarrier(
      name: 'Caixas Raras',
      description: 'Desbloqueie caixas de qualidade rara',
      requiredFuba: BigDecimal.parse('500000'),
      requiredGeneratorTier: 7,
      requiredGeneratorCount: 5,
      unlockMessage: 'Caixas raras desbloqueadas!',
      emoji: '💎',
    ),
    DifficultyBarrier(
      name: 'Caixas Épicas',
      description: 'Desbloqueie caixas de qualidade épica',
      requiredFuba: BigDecimal.parse('10000000'),
      requiredGeneratorTier: 12,
      requiredGeneratorCount: 8,
      unlockMessage: 'Caixas épicas desbloqueadas!',
      emoji: '✨',
    ),
    DifficultyBarrier(
      name: 'Caixas Lendárias',
      description: 'Desbloqueie caixas de qualidade lendária',
      requiredFuba: BigDecimal.parse('500000000'),
      requiredGeneratorTier: 18,
      requiredGeneratorCount: 12,
      unlockMessage: 'Caixas lendárias desbloqueadas!',
      emoji: '👑',
    ),
    DifficultyBarrier(
      name: 'Caixas Míticas',
      description: 'Desbloqueie caixas de qualidade mítica',
      requiredFuba: BigDecimal.parse('50000000000'),
      requiredGeneratorTier: 22,
      requiredGeneratorCount: 15,
      unlockMessage: 'Caixas míticas desbloqueadas!',
      emoji: '🌟',
    ),
    DifficultyBarrier(
      name: 'Caixas Divinas',
      description: 'Desbloqueie caixas de qualidade divina',
      requiredFuba: BigDecimal.parse('5000000000000'),
      requiredGeneratorTier: 26,
      requiredGeneratorCount: 20,
      unlockMessage: 'Caixas divinas desbloqueadas!',
      emoji: '💎',
    ),
    DifficultyBarrier(
      name: 'Caixas Transcendentes',
      description: 'Desbloqueie caixas de qualidade transcendente',
      requiredFuba: BigDecimal.parse('500000000000000'),
      requiredGeneratorTier: 28,
      requiredGeneratorCount: 25,
      unlockMessage: 'Caixas transcendentais desbloqueadas!',
      emoji: '🌟',
    ),
  ];

  static final List<DifficultyBarrier> rebirthBarriers = [
    DifficultyBarrier(
      name: 'Primeiro Rebirth',
      description: 'Desbloqueie o sistema de rebirth',
      requiredFuba: BigDecimal.parse('100000'),
      requiredGeneratorTier: 6,
      requiredGeneratorCount: 1,
      unlockMessage: 'Sistema de rebirth desbloqueado!',
      emoji: '🔄',
    ),
    DifficultyBarrier(
      name: 'Ascensão',
      description: 'Desbloqueie o sistema de ascensão',
      requiredFuba: BigDecimal.parse('10000000'),
      requiredGeneratorTier: 15,
      requiredGeneratorCount: 3,
      unlockMessage: 'Sistema de ascensão desbloqueado!',
      emoji: '✨',
    ),
    DifficultyBarrier(
      name: 'Transcendência',
      description: 'Desbloqueie o sistema de transcendência',
      requiredFuba: BigDecimal.parse('1000000000'),
      requiredGeneratorTier: 25,
      requiredGeneratorCount: 5,
      unlockMessage: 'Sistema de transcendência desbloqueado!',
      emoji: '🌟',
    ),
  ];

  static final List<DifficultyBarrier> upgradeBarriers = [
    DifficultyBarrier(
      name: 'Upgrades Básicos',
      description: 'Desbloqueie upgrades básicos',
      requiredFuba: BigDecimal.parse('50000'),
      requiredGeneratorTier: 4,
      requiredGeneratorCount: 2,
      unlockMessage: 'Upgrades básicos desbloqueados!',
      emoji: '⚡',
    ),
    DifficultyBarrier(
      name: 'Upgrades Avançados',
      description: 'Desbloqueie upgrades avançados',
      requiredFuba: BigDecimal.parse('1000000'),
      requiredGeneratorTier: 10,
      requiredGeneratorCount: 3,
      unlockMessage: 'Upgrades avançados desbloqueados!',
      emoji: '🚀',
    ),
    DifficultyBarrier(
      name: 'Upgrades Divinos',
      description: 'Desbloqueie upgrades divinos',
      requiredFuba: BigDecimal.parse('100000000'),
      requiredGeneratorTier: 20,
      requiredGeneratorCount: 5,
      unlockMessage: 'Upgrades divinos desbloqueados!',
      emoji: '👑',
    ),
  ];

  static final List<DifficultyBarrier> achievementBarriers = [
    DifficultyBarrier(
      name: 'Conquistas Básicas',
      description: 'Desbloqueie conquistas básicas',
      requiredFuba: BigDecimal.parse('10000'),
      requiredGeneratorTier: 3,
      requiredGeneratorCount: 1,
      unlockMessage: 'Conquistas básicas desbloqueadas!',
      emoji: '🏆',
    ),
    DifficultyBarrier(
      name: 'Conquistas Avançadas',
      description: 'Desbloqueie conquistas avançadas',
      requiredFuba: BigDecimal.parse('1000000'),
      requiredGeneratorTier: 8,
      requiredGeneratorCount: 2,
      unlockMessage: 'Conquistas avançadas desbloqueadas!',
      emoji: '🥇',
    ),
    DifficultyBarrier(
      name: 'Conquistas Épicas',
      description: 'Desbloqueie conquistas épicas',
      requiredFuba: BigDecimal.parse('100000000'),
      requiredGeneratorTier: 15,
      requiredGeneratorCount: 4,
      unlockMessage: 'Conquistas épicas desbloqueadas!',
      emoji: '💎',
    ),
  ];

  static List<DifficultyBarrier> getBarriersForCategory(String category) {
    switch (category) {
      case 'lootbox':
        return lootBoxBarriers;
      case 'rebirth':
        return rebirthBarriers;
      case 'upgrade':
        return upgradeBarriers;
      case 'achievement':
        return achievementBarriers;
      default:
        return [];
    }
  }

  static DifficultyBarrier? getNextBarrier(String category, BigDecimal currentFuba, List<int> generatorsOwned) {
    final barriers = getBarriersForCategory(category);
    for (final barrier in barriers) {
      if (!barrier.isUnlocked(currentFuba, generatorsOwned)) {
        return barrier;
      }
    }
    return null;
  }

  static List<DifficultyBarrier> getUnlockedBarriers(String category, BigDecimal currentFuba, List<int> generatorsOwned) {
    final barriers = getBarriersForCategory(category);
    return barriers.where((barrier) => barrier.isUnlocked(currentFuba, generatorsOwned)).toList();
  }

  static List<DifficultyBarrier> getLockedBarriers(String category, BigDecimal currentFuba, List<int> generatorsOwned) {
    final barriers = getBarriersForCategory(category);
    return barriers.where((barrier) => !barrier.isUnlocked(currentFuba, generatorsOwned)).toList();
  }
}
