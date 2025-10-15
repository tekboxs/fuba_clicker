import 'dart:math';
import 'package:flutter/material.dart';

/// Tier dos geradores para classificação visual
enum GeneratorTier {
  common,
  rare,
  epic,
  legendary,
  mythical,
  godly,
  cosmic,
  divine,
  absolute,
  transcendent,
  eternal,
  truth,
}

/// Modelo para geradores de fubá
class FubaGenerator {
  final String name;
  final String emoji;
  final double baseCost;
  final double baseProduction;
  final String description;
  final int unlockRequirement;
  final GeneratorTier tier;
  final bool isSecret;
  final String? secretUnlockCondition;

  const FubaGenerator({
    required this.name,
    required this.emoji,
    required this.baseCost,
    required this.baseProduction,
    required this.description,
    this.unlockRequirement = 0,
    this.tier = GeneratorTier.common,
    this.isSecret = false,
    this.secretUnlockCondition,
  });

  /// Calcula o custo baseado na quantidade já possuída (crescimento exponencial)
  double getCost(int owned) {
    return baseCost * pow(1.15, owned);
  }

  /// Calcula a produção total baseada na quantidade possuída
  double getProduction(int owned) {
    return baseProduction * owned;
  }

  /// Verifica se o gerador está desbloqueado baseado na quantidade do gerador anterior
  bool isUnlocked(List<int> generatorsOwned, [Set<String>? unlockedSecrets]) {
    if (isSecret) {
      if (secretUnlockCondition == null) return false;
      if (unlockedSecrets == null) return false;
      return unlockedSecrets.contains(secretUnlockCondition);
    }
    
    if (unlockRequirement == 0) return true;
    if (unlockRequirement > generatorsOwned.length) return false;
    return generatorsOwned[unlockRequirement - 1] > 0;
  }

  /// Retorna a cor baseada no tier do gerador
  Color get tierColor {
    switch (tier) {
      case GeneratorTier.common:
        return Colors.green;
      case GeneratorTier.rare:
        return Colors.blue;
      case GeneratorTier.epic:
        return Colors.purple;
      case GeneratorTier.legendary:
        return Colors.orange;
      case GeneratorTier.mythical:
        return Colors.pink;
      case GeneratorTier.godly:
        return Colors.red;
      case GeneratorTier.cosmic:
        return Colors.cyan;
      case GeneratorTier.divine:
        return Colors.yellow;
      case GeneratorTier.absolute:
        return Colors.black;
      case GeneratorTier.transcendent:
        return Colors.teal;
      case GeneratorTier.eternal:
        return Colors.indigo;
      case GeneratorTier.truth:
        return Colors.white;
    }
  }
}

/// Lista de geradores disponíveis no jogo
const availableGenerators = [
  FubaGenerator(
    name: 'Espiga',
    emoji: '🌽',
    baseCost: 10,
    baseProduction: 0.1,
    description: 'Um milho solitário que produz fubá',
    unlockRequirement: 0,
    tier: GeneratorTier.common,
  ),
  FubaGenerator(
    name: 'Pé de Milho',
    emoji: '🌾',
    baseCost: 50,
    baseProduction: 0.5,
    description: 'Um pé de milho completo',
    unlockRequirement: 1,
    tier: GeneratorTier.common,
  ),
  FubaGenerator(
    name: 'Moedor Manual',
    emoji: '⚙️',
    baseCost: 200,
    baseProduction: 3,
    description: 'Moedor antigo mas eficiente',
    unlockRequirement: 2,
    tier: GeneratorTier.common,
  ),
  FubaGenerator(
    name: 'Fábrica de Fubá',
    emoji: '🏭',
    baseCost: 1000,
    baseProduction: 5,
    description: 'Produção industrial de fubá',
    unlockRequirement: 3,
    tier: GeneratorTier.rare,
  ),
  FubaGenerator(
    name: 'Moinho Gigante',
    emoji: '🌪️',
    baseCost: 5000,
    baseProduction: 20,
    description: 'Moinho movido pelo fubá',
    unlockRequirement: 4,
    tier: GeneratorTier.rare,
  ),
  FubaGenerator(
    name: 'Plantação de Milho',
    emoji: '🌄',
    baseCost: 15000,
    baseProduction: 50,
    description: 'Uma plantação inteira dedicada ao fubá',
    unlockRequirement: 5,
    tier: GeneratorTier.rare,
  ),
  FubaGenerator(
    name: 'Moinho de Vento',
    emoji: '💨',
    baseCost: 50000,
    baseProduction: 150,
    description: 'Moinho movido pela força dos ventos',
    unlockRequirement: 6,
    tier: GeneratorTier.epic,
  ),
  FubaGenerator(
    name: 'Fábrica Quântica',
    emoji: '⚛️',
    baseCost: 150000,
    baseProduction: 500,
    description: 'Produção de fubá usando física quântica',
    unlockRequirement: 7,
    tier: GeneratorTier.epic,
  ),
  FubaGenerator(
    name: 'Dimensão do Fubá',
    emoji: '🌀',
    baseCost: 500000,
    baseProduction: 1500,
    description: 'Um portal para uma dimensão feita de fubá',
    unlockRequirement: 8,
    tier: GeneratorTier.epic,
  ),
  FubaGenerator(
    name: 'Galáxia de Milho',
    emoji: '🌌',
    baseCost: 1500000,
    baseProduction: 5000,
    description: 'Uma galáxia inteira cultivando milho',
    unlockRequirement: 9,
    tier: GeneratorTier.legendary,
  ),
  FubaGenerator(
    name: 'Universo Fubá',
    emoji: '🌍',
    baseCost: 5000000,
    baseProduction: 15000,
    description: 'Múltiplos universos dedicados ao fubá',
    unlockRequirement: 10,
    tier: GeneratorTier.legendary,
  ),
  FubaGenerator(
    name: 'Máquina do Tempo',
    emoji: '⏰',
    baseCost: 15000000,
    baseProduction: 50000,
    description: 'Produz fubá de todas as eras temporais',
    unlockRequirement: 11,
    tier: GeneratorTier.legendary,
  ),
  FubaGenerator(
    name: 'Deus do Fubá',
    emoji: '👑',
    baseCost: 50000000,
    baseProduction: 150000,
    description: 'A divindade suprema do fubá',
    unlockRequirement: 12,
    tier: GeneratorTier.mythical,
  ),
  FubaGenerator(
    name: 'Fubá Ancestral',
    emoji: '💫',
    baseCost: 750000000,
    baseProduction: 2500000,
    description: 'A essência original de todo fubá existente',
    unlockRequirement: 13,
    tier: GeneratorTier.mythical,
  ),
  FubaGenerator(
    name: 'Laboratório Alquímico',
    emoji: '🧪',
    baseCost: 3500000000,
    baseProduction: 12000000,
    description: 'Transforma matéria em fubá puro',
    unlockRequirement: 14,
    tier: GeneratorTier.godly,
  ),
  FubaGenerator(
    name: 'Robô Fubá 3000',
    emoji: '🤖',
    baseCost: 18000000000,
    baseProduction: 65000000,
    description: 'IA avançada especializada em produção de fubá',
    unlockRequirement: 15,
    tier: GeneratorTier.godly,
  ),
  FubaGenerator(
    name: 'Portal Interdimensional',
    emoji: '🚪',
    baseCost: 95000000000,
    baseProduction: 350000000,
    description: 'Importa fubá de dimensões paralelas',
    unlockRequirement: 16,
    tier: GeneratorTier.godly,
  ),
  FubaGenerator(
    name: 'Colmeia de Abelhas Milho',
    emoji: '🐝',
    baseCost: 500000000000,
    baseProduction: 1800000000,
    description: 'Abelhas geneticamente modificadas para fazer fubá',
    unlockRequirement: 17,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Sexta Dimensão',
    emoji: '🔮',
    baseCost: 2800000000000,
    baseProduction: 9500000000,
    description: 'Acessa dimensões onde fubá é a lei da física',
    unlockRequirement: 18,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Máquina de Realidade',
    emoji: '🎭',
    baseCost: 15000000000000,
    baseProduction: 55000000000,
    description: 'Manipula a própria realidade para gerar fubá',
    unlockRequirement: 19,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Consciência Coletiva',
    emoji: '🧠',
    baseCost: 85000000000000,
    baseProduction: 320000000000,
    description: 'Toda a humanidade pensando em fubá',
    unlockRequirement: 20,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Big Bang Fubá',
    emoji: '💥',
    baseCost: 480000000000000,
    baseProduction: 1800000000000,
    description: 'Recria o Big Bang, mas desta vez com fubá',
    unlockRequirement: 21,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Matriz do Fubá',
    emoji: '🔢',
    baseCost: 2800000000000000,
    baseProduction: 10500000000000,
    description: 'O código fonte da realidade onde tudo é fubá',
    unlockRequirement: 22,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Eldritch Horror',
    emoji: '👁️',
    baseCost: 17500000000000000,
    baseProduction: 65000000000000,
    description: 'Entidade cósmica que se alimenta de fubá',
    unlockRequirement: 23,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Simulação Infinita',
    emoji: '♾️',
    baseCost: 110000000000000000,
    baseProduction: 420000000000000,
    description: 'Simula universos infinitos de fubá',
    unlockRequirement: 24,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Paradoxo Temporal',
    emoji: '🔄',
    baseCost: 720000000000000000,
    baseProduction: 2750000000000000,
    description: 'Cria fubá do nada através de paradoxos',
    unlockRequirement: 25,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Mente Suprema',
    emoji: '🎯',
    baseCost: 4800000000000000000,
    baseProduction: 18500000000000000,
    description: 'A consciência que sonhou todo o fubá',
    unlockRequirement: 26,
    tier: GeneratorTier.absolute,
  ),
  FubaGenerator(
    name: 'Nada Absoluto',
    emoji: '🕳️',
    baseCost: 3e33,
    baseProduction: 125000000000000000,
    description: 'Do nada absoluto, fubá emerge',
    unlockRequirement: 27,
    tier: GeneratorTier.absolute,
  ),
  FubaGenerator(
    name: 'Transcendência',
    emoji: '✨',
    baseCost: 230000000000000000000,
    baseProduction: 890000000000000000,
    description: 'Transcende a própria existência para gerar fubá',
    unlockRequirement: 28,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Eternidade',
    emoji: '⏳',
    baseCost: 1650000000000000000000,
    baseProduction: 6200000000000000000,
    description: 'O fubá que existe antes e depois do tempo',
    unlockRequirement: 29,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'A Verdade',
    emoji: '🔍',
    baseCost: 12000000000000000000000,
    baseProduction: 45000000000000000000,
    description: 'A verdade final: tudo sempre foi fubá',
    unlockRequirement: 30,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'Bolo Desperto',
    emoji: '🎂',
    baseCost: 5000000000,
    baseProduction: 25000000,
    description: 'O bolo ganhou vida e produz fubá',
    unlockRequirement: 13,
    tier: GeneratorTier.godly,
    isSecret: true,
    secretUnlockCondition: 'cake_awakened',
  ),
  FubaGenerator(
    name: 'Padeiro Divino',
    emoji: '👨‍🍳',
    baseCost: 100000000000000,
    baseProduction: 500000000000,
    description: 'O padeiro dos deuses trabalha para você',
    unlockRequirement: 23,
    tier: GeneratorTier.divine,
    isSecret: true,
    secretUnlockCondition: 'divine_baker',
  ),
  FubaGenerator(
    name: 'Anomalia Temporal',
    emoji: '⏱️',
    baseCost: 1000000000,
    baseProduction: 5000000,
    description: 'Uma falha no espaço-tempo produz fubá infinito',
    unlockRequirement: 10,
    tier: GeneratorTier.legendary,
    isSecret: true,
    secretUnlockCondition: 'temporal_anomaly',
  ),
];
