import 'efficient_number.dart';

class DifficultyBarrier {
  final String name;
  final String description;
  final EfficientNumber requiredFuba;
  final int requiredGeneratorTier;
  final int requiredGeneratorCount;
  final String unlockMessage;
  final String emoji;
  final String? asset;

  const DifficultyBarrier({
    required this.name,
    required this.description,
    required this.requiredFuba,
    required this.requiredGeneratorTier,
    required this.requiredGeneratorCount,
    required this.unlockMessage,
    required this.emoji,
    this.asset,
  });

  bool isUnlocked(EfficientNumber currentFuba, List<int> generatorsOwned) {
    if (currentFuba.compareTo(requiredFuba) < 0) return false;
    if (requiredGeneratorTier >= generatorsOwned.length) return false;
    return generatorsOwned[requiredGeneratorTier] >= requiredGeneratorCount;
  }

  double getProgress(EfficientNumber currentFuba, List<int> generatorsOwned) {
    // Otimização: evita divisões EfficientNumber custosas para grandes números
    double fubaProgress;
    
    if (currentFuba.compareTo(requiredFuba) >= 0) {
      fubaProgress = 1.0;
    } else {
      // Otimização adicional: compara strings para evitar operações EfficientNumber custosas
      final currentStr = currentFuba.toString();
      final requiredStr = requiredFuba.toString();
      
      // Se o fuba atual é muito menor que o requerido, retorna 0 sem cálculos
      if (currentStr.length < requiredStr.length - 2) {
        fubaProgress = 0.0;
      } else {
        // Usa comparação de magnitude (exponent) para evitar divisões custosas
        final currentMagnitude = currentFuba.exponent;
        final requiredMagnitude = requiredFuba.exponent;
        
        if (currentMagnitude - requiredMagnitude > 10) {
          // Se a diferença de magnitude é muito grande, usa aproximação
          fubaProgress = 0.0;
        } else {
          // Só faz divisão se os números são comparáveis
          try {
            final result = currentFuba / requiredFuba;
            fubaProgress = result.toDouble().clamp(0.0, 1.0);
          } catch (e) {
            fubaProgress = 0.0;
          }
        }
      }
    }
    
    if (requiredGeneratorTier >= generatorsOwned.length) return fubaProgress;
    
    final generatorProgress = (generatorsOwned[requiredGeneratorTier] / requiredGeneratorCount).clamp(0.0, 1.0);
    return (fubaProgress + generatorProgress) / 2;
  }
}

class DifficultyBarrierManager {
  static final List<DifficultyBarrier> lootBoxBarriers = [
    const DifficultyBarrier(
      name: 'Primeira Caixa',
      description: 'Desbloqueie a primeira caixa de acessórios',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 4,
      requiredGeneratorCount: 3,
      unlockMessage: 'Você desbloqueou a primeira caixa de acessórios!',
      emoji: '📦',
    ),
    const DifficultyBarrier(
      name: 'Caixas Raras',
      description: 'Desbloqueie caixas de qualidade rara',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 8,
      requiredGeneratorCount: 6,
      unlockMessage: 'Caixas raras desbloqueadas!',
      emoji: '💎',
    ),
    const DifficultyBarrier(
      name: 'Caixas Épicas',
      description: 'Desbloqueie caixas de qualidade épica',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 13,
      requiredGeneratorCount: 10,
      unlockMessage: 'Caixas épicas desbloqueadas!',
      emoji: '✨',
    ),
    const DifficultyBarrier(
      name: 'Caixas Lendárias',
      description: 'Desbloqueie caixas de qualidade lendária',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 19,
      requiredGeneratorCount: 15,
      unlockMessage: 'Caixas lendárias desbloqueadas!',
      emoji: '👑',
      asset: 'assets/images/supreme_crate.png',

    ),
    const DifficultyBarrier(
      name: 'Caixas Míticas',
      description: 'Desbloqueie caixas de qualidade mítica',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 24,
      requiredGeneratorCount: 20,
      unlockMessage: 'Caixas míticas desbloqueadas!',
      emoji: '🌟',
    ),
    const DifficultyBarrier(
      name: 'Caixas Divinas',
      description: 'Desbloqueie caixas de qualidade divina',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 28,
      requiredGeneratorCount: 30,
      unlockMessage: 'Caixas divinas desbloqueadas!',
      emoji: '💎',
      asset: 'assets/images/cosmic_crate.png',

    ),
    const DifficultyBarrier(
      name: 'Caixas Transcendentes',
      description: 'Desbloqueie caixas de qualidade transcendente',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 32,
      requiredGeneratorCount: 40,
      unlockMessage: 'Caixas transcendentais desbloqueadas!',
      emoji: '🌟',
    ),
    const DifficultyBarrier(
      name: 'Caixas Primordiais',
      description: 'Desbloqueie caixas de qualidade primordial',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 36,
      requiredGeneratorCount: 60,
      unlockMessage: 'Caixas primordiais desbloqueadas!',
      emoji: '🌌',
      asset: 'assets/images/cosmic_crate.png',
    ),
    const DifficultyBarrier(
      name: 'Caixas Cósmicas',
      description: 'Desbloqueie caixas de qualidade cósmica',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 38,
      requiredGeneratorCount: 100,
      unlockMessage: 'Caixas cósmicas desbloqueadas!',
      emoji: '🌠',
      // asset: 'assets/images/cosmic_crate.png',
    ),
    const DifficultyBarrier(
      name: 'Caixas Infinitas',
      description: 'Desbloqueie caixas de qualidade infinita',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 41,
      requiredGeneratorCount: 150,
      unlockMessage: 'Caixas infinitas desbloqueadas!',
      emoji: '♾️',
    ),
    const DifficultyBarrier(
      name: 'Caixas da Realidade',
      description: 'Desbloqueie caixas da própria realidade',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 43,
      requiredGeneratorCount: 250,
      unlockMessage: 'Caixas da realidade desbloqueadas!',
      emoji: '🔮',
    ),
    const DifficultyBarrier(
      name: 'Caixas Omniversais',
      description: 'Desbloqueie caixas de todos os universos',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 46,
      requiredGeneratorCount: 400,
      unlockMessage: 'Caixas omniversais desbloqueadas!',
      emoji: '🌐',
    ),
    const DifficultyBarrier(
      name: 'Caixas Tek',
      description: 'Desbloqueie caixas de tecnologia avançada',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 52,
      requiredGeneratorCount: 600,
      unlockMessage: 'Caixas Tek desbloqueadas!',
      emoji: '💻',
    ),
    const DifficultyBarrier(
      name: 'Caixas Absolutas',
      description: 'Desbloqueie caixas de poder absoluto',
      requiredFuba: EfficientNumber.zero(),
      requiredGeneratorTier: 58,
      requiredGeneratorCount: 800,
      unlockMessage: 'Caixas absolutas desbloqueadas!',
      emoji: '👑',
    ),
  ];

  static final List<DifficultyBarrier> rebirthBarriers = [
    DifficultyBarrier(
      name: 'Primeiro Rebirth',
      description: 'Desbloqueie o sistema de rebirth',
      requiredFuba: EfficientNumber.parse('100000'),
      requiredGeneratorTier: 6,
      requiredGeneratorCount: 1,
      unlockMessage: 'Sistema de rebirth desbloqueado!',
      emoji: '🔄',
    ),
    DifficultyBarrier(
      name: 'Ascensão',
      description: 'Desbloqueie o sistema de ascensão',
      requiredFuba: EfficientNumber.parse('10000000'),
      requiredGeneratorTier: 15,
      requiredGeneratorCount: 3,
      unlockMessage: 'Sistema de ascensão desbloqueado!',
      emoji: '✨',
    ),
    DifficultyBarrier(
      name: 'Transcendência',
      description: 'Desbloqueie o sistema de transcendência',
      requiredFuba: EfficientNumber.parse('1000000000'),
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
      requiredFuba: EfficientNumber.parse('50000'),
      requiredGeneratorTier: 4,
      requiredGeneratorCount: 2,
      unlockMessage: 'Upgrades básicos desbloqueados!',
      emoji: '⚡',
    ),
    DifficultyBarrier(
      name: 'Upgrades Avançados',
      description: 'Desbloqueie upgrades avançados',
      requiredFuba: EfficientNumber.parse('1000000'),
      requiredGeneratorTier: 10,
      requiredGeneratorCount: 3,
      unlockMessage: 'Upgrades avançados desbloqueados!',
      emoji: '🚀',
    ),
    DifficultyBarrier(
      name: 'Upgrades Divinos',
      description: 'Desbloqueie upgrades divinos',
      requiredFuba: EfficientNumber.parse('100000000'),
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
      requiredFuba: EfficientNumber.parse('10000'),
      requiredGeneratorTier: 3,
      requiredGeneratorCount: 1,
      unlockMessage: 'Conquistas básicas desbloqueadas!',
      emoji: '🏆',
    ),
    DifficultyBarrier(
      name: 'Conquistas Avançadas',
      description: 'Desbloqueie conquistas avançadas',
      requiredFuba: EfficientNumber.parse('1000000'),
      requiredGeneratorTier: 8,
      requiredGeneratorCount: 2,
      unlockMessage: 'Conquistas avançadas desbloqueadas!',
      emoji: '🥇',
    ),
    DifficultyBarrier(
      name: 'Conquistas Épicas',
      description: 'Desbloqueie conquistas épicas',
      requiredFuba: EfficientNumber.parse('100000000'),
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

  static DifficultyBarrier? getNextBarrier(String category, EfficientNumber currentFuba, List<int> generatorsOwned) {
    final barriers = getBarriersForCategory(category);
    for (final barrier in barriers) {
      if (!barrier.isUnlocked(currentFuba, generatorsOwned)) {
        return barrier;
      }
    }
    return null;
  }

  static List<DifficultyBarrier> getUnlockedBarriers(String category, EfficientNumber currentFuba, List<int> generatorsOwned) {
    final barriers = getBarriersForCategory(category);
    return barriers.where((barrier) => barrier.isUnlocked(currentFuba, generatorsOwned)).toList();
  }

  static List<DifficultyBarrier> getLockedBarriers(String category, EfficientNumber currentFuba, List<int> generatorsOwned) {
    final barriers = getBarriersForCategory(category);
    return barriers.where((barrier) => !barrier.isUnlocked(currentFuba, generatorsOwned)).toList();
  }
}
