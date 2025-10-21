import 'dart:math';
import 'package:flutter/material.dart';
import 'package:big_decimal/big_decimal.dart';

/// Tier dos geradores para classificação visual
enum GeneratorTier {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythical,
  godly,
  cosmic,
  stellar,
  divine,
  celestial,
  absolute,
  transcendent,
  eternal,
  primordial,
  truth,
  infinity,
  omnipotent,
  supreme,
  ultimate,
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

  /// Calcula o custo baseado na quantidade já possuída (crescimento exponencial suavizado)
  BigDecimal getCost(int owned) {
    // Fórmula suavizada: custo cresce mais devagar conforme a quantidade aumenta
    if (owned <= 50) {
      // Até 50: crescimento normal (1.15)
      return baseCost * BigDecimal.parse(pow(1.15, owned).toString());
    } else if (owned <= 200) {
      // 51-200: crescimento reduzido (1.12)
      final baseCost50 = baseCost * BigDecimal.parse(pow(1.15, 50).toString());
      final excessOwned = owned - 50;
      return baseCost50 * BigDecimal.parse(pow(1.12, excessOwned).toString());
    } else if (owned <= 500) {
      // 201-500: crescimento ainda mais suave (1.10)
      final baseCost50 = baseCost * BigDecimal.parse(pow(1.15, 50).toString());
      final baseCost200 = baseCost50 * BigDecimal.parse(pow(1.12, 150).toString());
      final excessOwned = owned - 200;
      return baseCost200 * BigDecimal.parse(pow(1.10, excessOwned).toString());
    } else {
      // 501+: crescimento muito suave (1.08)
      final baseCost50 = baseCost * BigDecimal.parse(pow(1.15, 50).toString());
      final baseCost200 = baseCost50 * BigDecimal.parse(pow(1.12, 150).toString());
      final baseCost500 = baseCost200 * BigDecimal.parse(pow(1.10, 300).toString());
      final excessOwned = owned - 500;
      return baseCost500 * BigDecimal.parse(pow(1.08, excessOwned).toString());
    }
  }

  /// Calcula a produção total baseada na quantidade possuída (crescimento em tiers balanceado)
  BigDecimal getProduction(int owned) {
    if (owned <= 0) return BigDecimal.zero;

    // Tier 1 (1-100): Crescimento linear
    if (owned <= 100) {
      return baseProduction * BigDecimal.parse(owned.toString());
    }

    // Tier 2 (101-300): Crescimento suave (expoente 1.25)
    if (owned <= 300) {
      final linearBase = baseProduction * BigDecimal.parse('100');
      final excessOwned = owned - 100;
      final exponentialFactor = pow(1 + (excessOwned / 100), 12.7);
      return linearBase * BigDecimal.parse(exponentialFactor.toString());
    }

    // Tier 3 (301-600): Crescimento moderado (expoente 1.5)
    if (owned <= 700) {
      final tier2Value = _calculateTier2Max();
      final excessOwned = owned - 300;
      final exponentialFactor = pow(1 + (excessOwned / 300), 35.5);
      return tier2Value * BigDecimal.parse(exponentialFactor.toString());
    }

    // Tier 4 (601+): Crescimento forte mas controlado (expoente 1.7)
    final tier3Value = _calculateTier3Max();
    final excessOwned = owned - 700;
    final exponentialFactor = pow(1 + (excessOwned / 700), 100.7);
    return tier3Value * BigDecimal.parse(exponentialFactor.toString());
  }

  /// Calcula o valor máximo do Tier 2 (300 geradores)
  BigDecimal _calculateTier2Max() {
    final linearBase = baseProduction * BigDecimal.parse('100');
    final exponentialFactor = pow(1 + (200 / 100), 1.25); // 200 excessOwned para 300 total
    return linearBase * BigDecimal.parse(exponentialFactor.toString());
  }

  /// Calcula o valor máximo do Tier 3 (600 geradores)
  BigDecimal _calculateTier3Max() {
    final tier2Value = _calculateTier2Max();
    final exponentialFactor = pow(1 + (300 / 300), 1.5); // 300 excessOwned para 600 total
    return tier2Value * BigDecimal.parse(exponentialFactor.toString());
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
      case GeneratorTier.uncommon:
        return Colors.lightGreen;
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
      case GeneratorTier.stellar:
        return Colors.lightBlue;
      case GeneratorTier.divine:
        return Colors.yellow;
      case GeneratorTier.celestial:
        return Colors.amber;
      case GeneratorTier.absolute:
        return Colors.black;
      case GeneratorTier.transcendent:
        return Colors.teal;
      case GeneratorTier.eternal:
        return Colors.indigo;
      case GeneratorTier.primordial:
        return Colors.deepPurple;
      case GeneratorTier.truth:
        return Colors.white;
      case GeneratorTier.infinity:
        return Colors.deepOrange;
      case GeneratorTier.omnipotent:
        return Colors.lime;
      case GeneratorTier.supreme:
        return Colors.brown;
      case GeneratorTier.ultimate:
        return Colors.grey;
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
    tier: GeneratorTier.uncommon,
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
    tier: GeneratorTier.epic,
  ),
  FubaGenerator(
    name: 'Moinho de Vento',
    emoji: '💨',
    baseCost: BigDecimal.parse('50000'),
    baseProduction: BigDecimal.parse('120'),
    description: 'Moinho movido pela força dos ventos',
    unlockRequirement: 6,
    tier: GeneratorTier.legendary,
  ),
  FubaGenerator(
    name: 'Fábrica Quântica',
    emoji: '⚛️',
    baseCost: BigDecimal.parse('150000'),
    baseProduction: BigDecimal.parse('400'),
    description: 'Produção de fubá usando física quântica',
    unlockRequirement: 7,
    tier: GeneratorTier.mythical,
  ),
  FubaGenerator(
    name: 'Dimensão do Fubá',
    emoji: '🌀',
    baseCost: BigDecimal.parse('500000'),
    baseProduction: BigDecimal.parse('1200'),
    description: 'Um portal para uma dimensão feita de fubá',
    unlockRequirement: 8,
    tier: GeneratorTier.godly,
  ),
  FubaGenerator(
    name: 'Galáxia de Milho',
    emoji: '🌌',
    baseCost: BigDecimal.parse('1500000'),
    baseProduction: BigDecimal.parse('4000'),
    description: 'Uma galáxia inteira cultivando milho',
    unlockRequirement: 9,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Universo Fubá',
    emoji: '🌍',
    baseCost: BigDecimal.parse('5000000'),
    baseProduction: BigDecimal.parse('12000'),
    description: 'Múltiplos universos dedicados ao fubá',
    unlockRequirement: 10,
    tier: GeneratorTier.stellar,
  ),
  FubaGenerator(
    name: 'Máquina do Tempo',
    emoji: '⏰',
    baseCost: BigDecimal.parse('15000000'),
    baseProduction: BigDecimal.parse('40000'),
    description: 'Produz fubá de todas as eras temporais',
    unlockRequirement: 11,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Deus do Fubá',
    emoji: '👑',
    baseCost: BigDecimal.parse('50000000'),
    baseProduction: BigDecimal.parse('120000'),
    description: 'A divindade suprema do fubá',
    unlockRequirement: 12,
    tier: GeneratorTier.celestial,
  ),
  FubaGenerator(
    name: 'Fubá Ancestral',
    emoji: '💫',
    baseCost: BigDecimal.parse('750000000'),
    baseProduction: BigDecimal.parse('2000000'),
    description: 'A essência original de todo fubá existente',
    unlockRequirement: 13,
    tier: GeneratorTier.absolute,
  ),
  FubaGenerator(
    name: 'Laboratório Alquímico',
    emoji: '🧪',
    baseCost: BigDecimal.parse('3500000000'),
    baseProduction: BigDecimal.parse('9600000'),
    description: 'Transforma matéria em fubá puro',
    unlockRequirement: 14,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Fubátron 3000',
    emoji: '🤖',
    baseCost: BigDecimal.parse('18000000000'),
    baseProduction: BigDecimal.parse('52000000'),
    description: 'IA avançada especializada em produção de fubá',
    unlockRequirement: 15,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'Portal Interdimensional',
    emoji: '🚪',
    baseCost: BigDecimal.parse('95000000000'),
    baseProduction: BigDecimal.parse('280000000'),
    description: 'Importa fubá de dimensões paralelas',
    unlockRequirement: 16,
    tier: GeneratorTier.primordial,
  ),
  FubaGenerator(
    name: 'Colmeia de Abelhas Milho',
    emoji: '🐝',
    baseCost: BigDecimal.parse('500000000000'),
    baseProduction: BigDecimal.parse('1440000000'),
    description: 'Abelhas geneticamente modificadas para fazer fubá',
    unlockRequirement: 17,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'Sexta Dimensão',
    emoji: '🌠',
    baseCost: BigDecimal.parse('2800000000000'),
    baseProduction: BigDecimal.parse('7600000000'),
    description: 'Acessa dimensões onde fubá é a lei da física',
    unlockRequirement: 18,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'Máquina de Realidade',
    emoji: '🎭',
    baseCost: BigDecimal.parse('15000000000000'),
    baseProduction: BigDecimal.parse('44000000000'),
    description: 'Manipula a própria realidade para gerar fubá',
    unlockRequirement: 19,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'Consciência Coletiva',
    emoji: '🧠',
    baseCost: BigDecimal.parse('85000000000000'),
    baseProduction: BigDecimal.parse('256000000000'),
    description: 'Toda a humanidade pensando em fubá',
    unlockRequirement: 20,
    tier: GeneratorTier.supreme,
  ),
  FubaGenerator(
    name: 'Big Bang Fubá',
    emoji: '💥',
    baseCost: BigDecimal.parse('480000000000000'),
    baseProduction: BigDecimal.parse('1440000000000'),
    description: 'Recria o Big Bang, mas desta vez com fubá',
    unlockRequirement: 21,
    tier: GeneratorTier.ultimate,
  ),
  FubaGenerator(
    name: 'Matriz do Fubá',
    emoji: '🔢',
    baseCost: BigDecimal.parse('2800000000000000'),
    baseProduction: BigDecimal.parse('8400000000000'),
    description: 'O código fonte da realidade onde tudo é fubá',
    unlockRequirement: 22,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Eldritch Horror',
    emoji: '👁️',
    baseCost: BigDecimal.parse('17500000000000000'),
    baseProduction: BigDecimal.parse('52000000000000'),
    description: 'Entidade cósmica que se alimenta de fubá',
    unlockRequirement: 23,
    tier: GeneratorTier.stellar,
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
    tier: GeneratorTier.celestial,
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
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Nexus Primordial',
    emoji: '🌟',
    baseCost: BigDecimal.parse('1e80'),
    baseProduction: BigDecimal.parse('1e50'),
    description:
        'O ponto de convergência onde todas as realidades se encontram para gerar fubá',
    unlockRequirement: 28,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'Eternidade',
    emoji: '⏳',
    baseCost: BigDecimal.parse('1e120'),
    baseProduction: BigDecimal.parse('1e70'),
    description: 'O fubá que existe antes e depois do tempo',
    unlockRequirement: 29,
    tier: GeneratorTier.primordial,
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
    emoji: '🧁',
    baseCost: BigDecimal.parse('1e220'),
    baseProduction: BigDecimal.parse('1e130'),
    description: 'O bolo ganhou vida e produz fubá',
    unlockRequirement: 31,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'Padeiro Divino',
    emoji: '👨‍🍳',
    baseCost: BigDecimal.parse('1e280'),
    baseProduction: BigDecimal.parse('1e160'),
    description: 'O padeiro dos deuses trabalha para você',
    unlockRequirement: 32,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'A grande barreira da realidade',
    emoji: '▓',
    baseCost: BigDecimal.parse('1e350'),
    baseProduction: BigDecimal.parse('1e200'),
    description: 'O maior desafio para a produção de fubá inifita',
    unlockRequirement: 33,
    tier: GeneratorTier.supreme,
  ),
  // Smooth Section (34-42): Bridge to first wall
  FubaGenerator(
    name: 'Fubá Ancestral',
    emoji: '🏺',
    baseCost: BigDecimal.parse('1e400'),
    baseProduction: BigDecimal.parse('1e230'),
    description: 'O fubá dos primeiros tempos, guardado em ânforas sagradas',
    unlockRequirement: 34,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Moedor Cósmico',
    emoji: '⭐',
    baseCost: BigDecimal.parse('1e450'),
    baseProduction: BigDecimal.parse('1e260'),
    description: 'Um moedor que tritura estrelas em fubá',
    unlockRequirement: 35,
    tier: GeneratorTier.stellar,
  ),
  FubaGenerator(
    name: 'Memória do Fubá',
    emoji: '💾',
    baseCost: BigDecimal.parse('1e500'),
    baseProduction: BigDecimal.parse('1e290'),
    description: 'A memória coletiva de todo fubá já produzido',
    unlockRequirement: 36,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Forno Primordial',
    emoji: '🔥',
    baseCost: BigDecimal.parse('1e550'),
    baseProduction: BigDecimal.parse('1e320'),
    description: 'O primeiro forno que existiu, antes do tempo',
    unlockRequirement: 37,
    tier: GeneratorTier.celestial,
  ),
  FubaGenerator(
    name: 'Receita Universal',
    emoji: '📜',
    baseCost: BigDecimal.parse('1e600'),
    baseProduction: BigDecimal.parse('1e350'),
    description: 'A receita que criou o próprio fubá',
    unlockRequirement: 38,
    tier: GeneratorTier.absolute,
  ),
  FubaGenerator(
    name: 'Sonho de Fubá',
    emoji: '💭',
    baseCost: BigDecimal.parse('1e650'),
    baseProduction: BigDecimal.parse('1e380'),
    description: 'Onde os sonhos se tornam fubá tangível',
    unlockRequirement: 39,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Tempo do Fubá',
    emoji: '⏰',
    baseCost: BigDecimal.parse('1e700'),
    baseProduction: BigDecimal.parse('1e410'),
    description: 'O tempo em si produz fubá em todas as direções',
    unlockRequirement: 40,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'O Observador do Fubá',
    emoji: '👀',
    baseCost: BigDecimal.parse('1e750'),
    baseProduction: BigDecimal.parse('1e440'),
    description: 'A consciência que observa e cria fubá pela observação',
    unlockRequirement: 41,
    tier: GeneratorTier.primordial,
  ),
  FubaGenerator(
    name: 'Fubá do Vazio',
    emoji: '🌑',
    baseCost: BigDecimal.parse('1e800'),
    baseProduction: BigDecimal.parse('1e470'),
    description: 'Do nada absoluto, fubá emerge espontaneamente',
    unlockRequirement: 42,
    tier: GeneratorTier.truth,
  ),
  // First Wall (43-48): Requires multiple ascensions
  FubaGenerator(
    name: 'A Primeira Receita',
    emoji: '📋',
    baseCost: BigDecimal.parse('1e900'),
    baseProduction: BigDecimal.parse('1e540'),
    description: 'A primeira receita que criou o fubá no início de tudo',
    unlockRequirement: 43,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'Fubá Infinito',
    emoji: '∞',
    baseCost: BigDecimal.parse('1e1000'),
    baseProduction: BigDecimal.parse('1e610'),
    description: 'Um fubá que pode ser contado infinitamente',
    unlockRequirement: 44,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'O Paradoxo do Fubá',
    emoji: '🌀',
    baseCost: BigDecimal.parse('1e1100'),
    baseProduction: BigDecimal.parse('1e680'),
    description: 'Um paradoxo que se resolve em fubá puro',
    unlockRequirement: 45,
    tier: GeneratorTier.supreme,
  ),
  FubaGenerator(
    name: 'A Última Pergunta do Fubá',
    emoji: '❔',
    baseCost: BigDecimal.parse('1e1200'),
    baseProduction: BigDecimal.parse('1e750'),
    description: 'A pergunta cuja resposta é sempre fubá',
    unlockRequirement: 46,
    tier: GeneratorTier.ultimate,
  ),
  FubaGenerator(
    name: 'O Jogo do Fubá',
    emoji: '🎮',
    baseCost: BigDecimal.parse('1e1300'),
    baseProduction: BigDecimal.parse('1e820'),
    description: 'O jogo que joga a si mesmo, gerando fubá',
    unlockRequirement: 47,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Barreira do Fubá',
    emoji: '🚧',
    baseCost: BigDecimal.parse('1e1400'),
    baseProduction: BigDecimal.parse('1e890'),
    description: 'A barreira final que protege o fubá supremo',
    unlockRequirement: 48,
    tier: GeneratorTier.truth,
  ),
  // Smooth Section (49-53): Post-wall progression
  FubaGenerator(
    name: 'O Armazém do Fubá',
    emoji: '🏬',
    baseCost: BigDecimal.parse('1e1250'),
    baseProduction: BigDecimal.parse('1e800'),
    description: 'O armazém que contém todo o fubá já produzido',
    unlockRequirement: 49,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Variável do Fubá',
    emoji: '🌐',
    baseCost: BigDecimal.parse('1e1300'),
    baseProduction: BigDecimal.parse('1e850'),
    description: 'A variável que controla todo o fubá do universo',
    unlockRequirement: 50,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Ciclo Eterno do Fubá',
    emoji: '♻️',
    baseCost: BigDecimal.parse('1e1350'),
    baseProduction: BigDecimal.parse('1e900'),
    description: 'Um ciclo que nunca termina, gerando fubá eternamente',
    unlockRequirement: 51,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Receita Recursiva',
    emoji: '📝',
    baseCost: BigDecimal.parse('1e1400'),
    baseProduction: BigDecimal.parse('1e950'),
    description: 'Uma receita que se chama a si mesma, criando fubá',
    unlockRequirement: 52,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Coletor de Fubá',
    emoji: '🗑️',
    baseCost: BigDecimal.parse('1e1450'),
    baseProduction: BigDecimal.parse('1e1000'),
    description: 'Coleta restos e os transforma em fubá puro',
    unlockRequirement: 53,
    tier: GeneratorTier.truth,
  ),
  // Final Wall (54-60): Endgame requiring transcendences
  FubaGenerator(
    name: 'O Compilador de Fubá',
    emoji: '🔧',
    baseCost: BigDecimal.parse('1e1475'),
    baseProduction: BigDecimal.parse('1e1050'),
    description: 'Compila a realidade em fubá executável',
    unlockRequirement: 54,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Biblioteca do Fubá',
    emoji: '📖',
    baseCost: BigDecimal.parse('1e1485'),
    baseProduction: BigDecimal.parse('1e1100'),
    description: 'A biblioteca infinita de conhecimento sobre fubá',
    unlockRequirement: 55,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Detector de Fubá',
    emoji: '🔎',
    baseCost: BigDecimal.parse('1e1490'),
    baseProduction: BigDecimal.parse('1e1150'),
    description: 'Encontra e corrige problemas na produção de fubá',
    unlockRequirement: 56,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Exceção do Fubá',
    emoji: '🚨',
    baseCost: BigDecimal.parse('1e1495'),
    baseProduction: BigDecimal.parse('1e1200'),
    description: 'Uma exceção que quebra as regras e cria fubá',
    unlockRequirement: 57,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Ponto Nulo do Fubá',
    emoji: '📍',
    baseCost: BigDecimal.parse('1e1498'),
    baseProduction: BigDecimal.parse('1e1250'),
    description: 'O ponto nulo que aponta para fubá infinito',
    unlockRequirement: 58,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Última Receita',
    emoji: '📄',
    baseCost: BigDecimal.parse('1e1499'),
    baseProduction: BigDecimal.parse('1e1300'),
    description: 'A receita final que encerra e recria tudo em fubá',
    unlockRequirement: 59,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Fubá Absoluto',
    emoji: '🎂',
    baseCost: BigDecimal.parse('1e1500'),
    baseProduction: BigDecimal.parse('1e1350'),
    description: 'O fubá que transcende a própria existência',
    unlockRequirement: 60,
    tier: GeneratorTier.truth,
  ),
];
