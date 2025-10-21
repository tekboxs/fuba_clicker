import 'dart:math';
import 'package:flutter/material.dart';
import 'package:big_decimal/big_decimal.dart';

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
  final BigDecimal baseCost;
  final BigDecimal baseProduction;
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
  BigDecimal getCost(int owned) {
    return baseCost * BigDecimal.parse(pow(1.15, owned).toString());
  }

  /// Calcula a produção total baseada na quantidade possuída (crescimento exponencial balanceado)
  BigDecimal getProduction(int owned) {
    if (owned <= 0) return BigDecimal.zero;

    // Até 100 geradores: crescimento linear normal
    if (owned <= 100) {
      return baseProduction * BigDecimal.parse(owned.toString());
    }

    // Após 100 geradores: crescimento exponencial balanceado
    // Fórmula: baseProduction * 100 * (owned/100)^1.1
    // Isso garante continuidade com o valor linear aos 100
    final linearAt100 = baseProduction * BigDecimal.parse('100');
    final exponentialFactor = pow(owned, owned * 0.015);
    return linearAt100 * BigDecimal.parse(exponentialFactor.toString());
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

    final requiredGeneratorIndex = unlockRequirement - 1;
    if (requiredGeneratorIndex >= generatorsOwned.length) return false;

    return generatorsOwned[requiredGeneratorIndex] > 0;
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
final availableGenerators = [
  FubaGenerator(
    name: 'Espiga',
    emoji: '🌽',
    baseCost: BigDecimal.parse('10'),
    baseProduction: BigDecimal.parse('0.08'),
    description: 'Um milho solitário que produz fubá',
    unlockRequirement: 0,
    tier: GeneratorTier.common,
  ),
  FubaGenerator(
    name: 'Pé de Milho',
    emoji: '🌾',
    baseCost: BigDecimal.parse('50'),
    baseProduction: BigDecimal.parse('0.4'),
    description: 'Um pé de milho completo',
    unlockRequirement: 1,
    tier: GeneratorTier.common,
  ),
  FubaGenerator(
    name: 'Moedor Manual',
    emoji: '⚙️',
    baseCost: BigDecimal.parse('200'),
    baseProduction: BigDecimal.parse('2.4'),
    description: 'Moedor antigo mas eficiente',
    unlockRequirement: 2,
    tier: GeneratorTier.common,
  ),
  FubaGenerator(
    name: 'Fábrica de Fubá',
    emoji: '🏭',
    baseCost: BigDecimal.parse('1000'),
    baseProduction: BigDecimal.parse('4'),
    description: 'Produção industrial de fubá',
    unlockRequirement: 3,
    tier: GeneratorTier.rare,
  ),
  FubaGenerator(
    name: 'Moinho Gigante',
    emoji: '🌪️',
    baseCost: BigDecimal.parse('5000'),
    baseProduction: BigDecimal.parse('16'),
    description: 'Moinho movido pelo fubá',
    unlockRequirement: 4,
    tier: GeneratorTier.rare,
  ),
  FubaGenerator(
    name: 'Plantação de Milho',
    emoji: '🌄',
    baseCost: BigDecimal.parse('15000'),
    baseProduction: BigDecimal.parse('40'),
    description: 'Uma plantação inteira dedicada ao fubá',
    unlockRequirement: 5,
    tier: GeneratorTier.rare,
  ),
  FubaGenerator(
    name: 'Moinho de Vento',
    emoji: '💨',
    baseCost: BigDecimal.parse('50000'),
    baseProduction: BigDecimal.parse('120'),
    description: 'Moinho movido pela força dos ventos',
    unlockRequirement: 6,
    tier: GeneratorTier.epic,
  ),
  FubaGenerator(
    name: 'Fábrica Quântica',
    emoji: '⚛️',
    baseCost: BigDecimal.parse('150000'),
    baseProduction: BigDecimal.parse('400'),
    description: 'Produção de fubá usando física quântica',
    unlockRequirement: 7,
    tier: GeneratorTier.epic,
  ),
  FubaGenerator(
    name: 'Dimensão do Fubá',
    emoji: '🌀',
    baseCost: BigDecimal.parse('500000'),
    baseProduction: BigDecimal.parse('1200'),
    description: 'Um portal para uma dimensão feita de fubá',
    unlockRequirement: 8,
    tier: GeneratorTier.epic,
  ),
  FubaGenerator(
    name: 'Galáxia de Milho',
    emoji: '🌌',
    baseCost: BigDecimal.parse('1500000'),
    baseProduction: BigDecimal.parse('4000'),
    description: 'Uma galáxia inteira cultivando milho',
    unlockRequirement: 9,
    tier: GeneratorTier.legendary,
  ),
  FubaGenerator(
    name: 'Universo Fubá',
    emoji: '🌍',
    baseCost: BigDecimal.parse('5000000'),
    baseProduction: BigDecimal.parse('12000'),
    description: 'Múltiplos universos dedicados ao fubá',
    unlockRequirement: 10,
    tier: GeneratorTier.legendary,
  ),
  FubaGenerator(
    name: 'Máquina do Tempo',
    emoji: '⏰',
    baseCost: BigDecimal.parse('15000000'),
    baseProduction: BigDecimal.parse('40000'),
    description: 'Produz fubá de todas as eras temporais',
    unlockRequirement: 11,
    tier: GeneratorTier.legendary,
  ),
  FubaGenerator(
    name: 'Deus do Fubá',
    emoji: '👑',
    baseCost: BigDecimal.parse('50000000'),
    baseProduction: BigDecimal.parse('120000'),
    description: 'A divindade suprema do fubá',
    unlockRequirement: 12,
    tier: GeneratorTier.mythical,
  ),
  FubaGenerator(
    name: 'Fubá Ancestral',
    emoji: '💫',
    baseCost: BigDecimal.parse('750000000'),
    baseProduction: BigDecimal.parse('2000000'),
    description: 'A essência original de todo fubá existente',
    unlockRequirement: 13,
    tier: GeneratorTier.mythical,
  ),
  FubaGenerator(
    name: 'Laboratório Alquímico',
    emoji: '🧪',
    baseCost: BigDecimal.parse('3500000000'),
    baseProduction: BigDecimal.parse('9600000'),
    description: 'Transforma matéria em fubá puro',
    unlockRequirement: 14,
    tier: GeneratorTier.godly,
  ),
  FubaGenerator(
    name: 'Fubátron 3000',
    emoji: '🤖',
    baseCost: BigDecimal.parse('18000000000'),
    baseProduction: BigDecimal.parse('52000000'),
    description: 'IA avançada especializada em produção de fubá',
    unlockRequirement: 15,
    tier: GeneratorTier.godly,
  ),
  FubaGenerator(
    name: 'Portal Interdimensional',
    emoji: '🚪',
    baseCost: BigDecimal.parse('95000000000'),
    baseProduction: BigDecimal.parse('280000000'),
    description: 'Importa fubá de dimensões paralelas',
    unlockRequirement: 16,
    tier: GeneratorTier.godly,
  ),
  FubaGenerator(
    name: 'Colmeia de Abelhas Milho',
    emoji: '🐝',
    baseCost: BigDecimal.parse('500000000000'),
    baseProduction: BigDecimal.parse('1440000000'),
    description: 'Abelhas geneticamente modificadas para fazer fubá',
    unlockRequirement: 17,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Sexta Dimensão',
    emoji: '🔮',
    baseCost: BigDecimal.parse('2800000000000'),
    baseProduction: BigDecimal.parse('7600000000'),
    description: 'Acessa dimensões onde fubá é a lei da física',
    unlockRequirement: 18,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Máquina de Realidade',
    emoji: '🎭',
    baseCost: BigDecimal.parse('15000000000000'),
    baseProduction: BigDecimal.parse('44000000000'),
    description: 'Manipula a própria realidade para gerar fubá',
    unlockRequirement: 19,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Consciência Coletiva',
    emoji: '🧠',
    baseCost: BigDecimal.parse('85000000000000'),
    baseProduction: BigDecimal.parse('256000000000'),
    description: 'Toda a humanidade pensando em fubá',
    unlockRequirement: 20,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Big Bang Fubá',
    emoji: '💥',
    baseCost: BigDecimal.parse('480000000000000'),
    baseProduction: BigDecimal.parse('1440000000000'),
    description: 'Recria o Big Bang, mas desta vez com fubá',
    unlockRequirement: 21,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Matriz do Fubá',
    emoji: '🔢',
    baseCost: BigDecimal.parse('2800000000000000'),
    baseProduction: BigDecimal.parse('8400000000000'),
    description: 'O código fonte da realidade onde tudo é fubá',
    unlockRequirement: 22,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Eldritch Horror',
    emoji: '👁️',
    baseCost: BigDecimal.parse('17500000000000000'),
    baseProduction: BigDecimal.parse('52000000000000'),
    description: 'Entidade cósmica que se alimenta de fubá',
    unlockRequirement: 23,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Simulação Infinita',
    emoji: '♾️',
    baseCost: BigDecimal.parse('110000000000000000'),
    baseProduction: BigDecimal.parse('336000000000000'),
    description: 'Simula universos infinitos de fubá',
    unlockRequirement: 24,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Paradoxo Temporal',
    emoji: '🔄',
    baseCost: BigDecimal.parse('720000000000000000'),
    baseProduction: BigDecimal.parse('2200000000000000'),
    description: 'Cria fubá do nada através de paradoxos',
    unlockRequirement: 25,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Mente Suprema',
    emoji: '🎯',
    baseCost: BigDecimal.parse('4800000000000000000'),
    baseProduction: BigDecimal.parse('14800000000000000'),
    description: 'A consciência que sonhou todo o fubá',
    unlockRequirement: 26,
    tier: GeneratorTier.absolute,
  ),
  FubaGenerator(
    name: 'Nada Absoluto',
    emoji: '🕳️',
    baseCost: BigDecimal.parse('1e50'),
    baseProduction: BigDecimal.parse('1e30'),
    description: 'Do nada absoluto, fubá emerge',
    unlockRequirement: 27,
    tier: GeneratorTier.absolute,
  ),
  FubaGenerator(
    name: 'Nexus Primordial',
    emoji: '🔮',
    baseCost: BigDecimal.parse('1e80'),
    baseProduction: BigDecimal.parse('1e50'),
    description:
        'O ponto de convergência onde todas as realidades se encontram para gerar fubá',
    unlockRequirement: 28,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Eternidade',
    emoji: '⏳',
    baseCost: BigDecimal.parse('1e120'),
    baseProduction: BigDecimal.parse('1e70'),
    description: 'O fubá que existe antes e depois do tempo',
    unlockRequirement: 29,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'A Verdade',
    emoji: '🔍',
    baseCost: BigDecimal.parse('1e170'),
    baseProduction: BigDecimal.parse('1e100'),
    description: 'A verdade final: tudo sempre foi fubá',
    unlockRequirement: 30,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'Bolo Desperto',
    emoji: '🎂',
    baseCost: BigDecimal.parse('1e220'),
    baseProduction: BigDecimal.parse('1e130'),
    description: 'O bolo ganhou vida e produz fubá',
    unlockRequirement: 31,
    tier: GeneratorTier.godly,
  ),
  FubaGenerator(
    name: 'Padeiro Divino',
    emoji: '👨‍🍳',
    baseCost: BigDecimal.parse('1e280'),
    baseProduction: BigDecimal.parse('1e160'),
    description: 'O padeiro dos deuses trabalha para você',
    unlockRequirement: 32,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'A grande barreira da realidade',
    emoji: '▓',
    baseCost: BigDecimal.parse('1e350'),
    baseProduction: BigDecimal.parse('1e200'),
    description: 'O maior desafio para a produção de fubá inifita',
    unlockRequirement: 33,
    tier: GeneratorTier.legendary,
  ),
];
