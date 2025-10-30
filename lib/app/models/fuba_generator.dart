import 'package:flutter/material.dart';
import '../core/utils/efficient_number.dart';

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
  final EfficientNumber baseCost;
  final EfficientNumber baseProduction;
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
  EfficientNumber getCost(int owned) {
    if (owned <= 50) {
      return baseCost * EfficientNumber.fromPower(1.15, owned.toDouble());
    } else if (owned <= 200) {
      final baseCost50 = baseCost * EfficientNumber.fromPower(1.15, 50.0);
      final excessOwned = owned - 50;
      return baseCost50 * EfficientNumber.fromPower(1.12, excessOwned.toDouble());
    } else if (owned <= 500) {
      final baseCost50 = baseCost * EfficientNumber.fromPower(1.15, 50.0);
      final baseCost200 = baseCost50 * EfficientNumber.fromPower(1.12, 150.0);
      final excessOwned = owned - 200;
      return baseCost200 * EfficientNumber.fromPower(1.10, excessOwned.toDouble());
    } else {
      final baseCost50 = baseCost * EfficientNumber.fromPower(1.15, 50.0);
      final baseCost200 = baseCost50 * EfficientNumber.fromPower(1.12, 150.0);
      final baseCost500 = baseCost200 * EfficientNumber.fromPower(1.10, 300.0);
      final excessOwned = owned - 500;
      
      if (excessOwned > 1000) {
        const maxExponent = 1000;
        final cappedExcess = excessOwned > maxExponent ? maxExponent : excessOwned;
        final multiplier = EfficientNumber.fromPower(1.08, cappedExcess.toDouble());
        
        if (excessOwned > maxExponent) {
          final additionalMultiplier = EfficientNumber.fromValues(
              (excessOwned - maxExponent).toDouble(), 0);
          return baseCost500 * multiplier * additionalMultiplier;
        }
        
        return baseCost500 * multiplier;
      }
      
      return baseCost500 * EfficientNumber.fromPower(1.08, excessOwned.toDouble());
    }
  }

  /// Calcula a produção total baseada na quantidade possuída (crescimento em tiers balanceado)
  EfficientNumber getProduction(int owned) {
    if (owned <= 0) return const EfficientNumber.zero();

    if (owned <= 100) {
      return baseProduction * EfficientNumber.fromValues(owned.toDouble(), 0);
    }

    if (owned <= 300) {
      final linearBase = baseProduction * EfficientNumber.fromValues(100.0, 0);
      final excessOwned = owned - 100;
      final power = excessOwned / 100.0;
      return linearBase * EfficientNumber.fromPower(1 + power, 12.7);
    }

    if (owned <= 700) {
      final tier2Value = _calculateTier2Max();
      final excessOwned = owned - 300;
      final power = excessOwned / 300.0;
      return tier2Value * EfficientNumber.fromPower(1 + power, 35.5);
    }

    final tier3Value = _calculateTier3Max();
    final excessOwned = owned - 700;
    
    if (excessOwned > 10000) {
      const maxExponent = 10000;
      final cappedExcess = excessOwned > maxExponent ? maxExponent : excessOwned;
      final power = cappedExcess / 700.0;
      final baseResult = tier3Value * EfficientNumber.fromPower(1 + power, 100.7);
      
      if (excessOwned > maxExponent) {
        final additionalMultiplier = EfficientNumber.fromValues(
            (excessOwned - maxExponent).toDouble(), 0);
        return baseResult * additionalMultiplier;
      }
      
      return baseResult;
    }
    
    final power = excessOwned / 700.0;
    return tier3Value * EfficientNumber.fromPower(1 + power, 100.7);
  }

  EfficientNumber _calculateTier2Max() {
    final linearBase = baseProduction * EfficientNumber.fromValues(100.0, 0);
    return linearBase * EfficientNumber.fromPower(3.0, 1.25);
  }

  EfficientNumber _calculateTier3Max() {
    final tier2Value = _calculateTier2Max();
    return tier2Value * EfficientNumber.fromPower(2.0, 1.5);
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
        return const Color.fromARGB(255, 23, 109, 15);
      case GeneratorTier.uncommon:
        return const Color.fromARGB(255, 39, 136, 43);
      case GeneratorTier.rare:
        return const Color(0xFF2196F3);
      case GeneratorTier.epic:
        return const Color(0xFF9C27B0);
      case GeneratorTier.legendary:
        return const Color(0xFFFF9800);
      case GeneratorTier.mythical:
        return const Color(0xFFE91E63);
      case GeneratorTier.godly:
        return const Color(0xFFF44336);
      case GeneratorTier.cosmic:
        return const Color(0xFF00BCD4);
      case GeneratorTier.stellar:
        return const Color(0xFF3F51B5);
      case GeneratorTier.divine:
        return const Color(0xFFFFC107);
      case GeneratorTier.celestial:
        return const Color(0xFF7E57C2);
      case GeneratorTier.absolute:
        return Colors.black;
      case GeneratorTier.transcendent:
        return const Color(0xFF00695C);
      case GeneratorTier.eternal:
        return const Color(0xFF283593);
      case GeneratorTier.primordial:
        return const Color(0xFF4527A0);
      case GeneratorTier.truth:
        return const Color(0xFF111827);
      case GeneratorTier.infinity:
        return const Color(0xFFD84315);
      case GeneratorTier.omnipotent:
        return const Color(0xFF2E7D32);
      case GeneratorTier.supreme:
        return const Color(0xFF4E342E);
      case GeneratorTier.ultimate:
        return const Color(0xFF424242);
    }
  }
}

/// Lista de geradores disponíveis no jogo
final availableGenerators = [
  FubaGenerator(
    name: 'Espiga',
    emoji: '🌽',
    baseCost: EfficientNumber.parse('10'),
    baseProduction: EfficientNumber.parse('0.08'),
    description: 'Um milho solitário que produz fubá',
    unlockRequirement: 0,
    tier: GeneratorTier.common,
  ),
  FubaGenerator(
    name: 'Pé de Milho',
    emoji: '🌾',
    baseCost: EfficientNumber.parse('50'),
    baseProduction: EfficientNumber.parse('0.4'),
    description: 'Um pé de milho completo',
    unlockRequirement: 1,
    tier: GeneratorTier.common,
  ),
  FubaGenerator(
    name: 'Moedor Manual',
    emoji: '⚙️',
    baseCost: EfficientNumber.parse('200'),
    baseProduction: EfficientNumber.parse('2.4'),
    description: 'Moedor antigo mas eficiente',
    unlockRequirement: 2,
    tier: GeneratorTier.common,
  ),
  FubaGenerator(
    name: 'Fábrica de Fubá',
    emoji: '🏭',
    baseCost: EfficientNumber.parse('1000'),
    baseProduction: EfficientNumber.parse('4'),
    description: 'Produção industrial de fubá',
    unlockRequirement: 3,
    tier: GeneratorTier.uncommon,
  ),
  FubaGenerator(
    name: 'Moinho Gigante',
    emoji: '🌪️',
    baseCost: EfficientNumber.parse('5000'),
    baseProduction: EfficientNumber.parse('16'),
    description: 'Moinho movido pelo fubá',
    unlockRequirement: 4,
    tier: GeneratorTier.rare,
  ),
  FubaGenerator(
    name: 'Plantação de Milho',
    emoji: '🌄',
    baseCost: EfficientNumber.parse('15000'),
    baseProduction: EfficientNumber.parse('40'),
    description: 'Uma plantação inteira dedicada ao fubá',
    unlockRequirement: 5,
    tier: GeneratorTier.epic,
  ),
  FubaGenerator(
    name: 'Moinho de Vento',
    emoji: '💨',
    baseCost: EfficientNumber.parse('50000'),
    baseProduction: EfficientNumber.parse('120'),
    description: 'Moinho movido pela força dos ventos',
    unlockRequirement: 6,
    tier: GeneratorTier.legendary,
  ),
  FubaGenerator(
    name: 'Fábrica Quântica',
    emoji: '⚛️',
    baseCost: EfficientNumber.parse('150000'),
    baseProduction: EfficientNumber.parse('400'),
    description: 'Produção de fubá usando física quântica',
    unlockRequirement: 7,
    tier: GeneratorTier.mythical,
  ),
  FubaGenerator(
    name: 'Dimensão do Fubá',
    emoji: '🌀',
    baseCost: EfficientNumber.parse('500000'),
    baseProduction: EfficientNumber.parse('1200'),
    description: 'Um portal para uma dimensão feita de fubá',
    unlockRequirement: 8,
    tier: GeneratorTier.godly,
  ),
  FubaGenerator(
    name: 'Galáxia de Milho',
    emoji: '🌌',
    baseCost: EfficientNumber.parse('1500000'),
    baseProduction: EfficientNumber.parse('4000'),
    description: 'Uma galáxia inteira cultivando milho',
    unlockRequirement: 9,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Universo Fubá',
    emoji: '🌍',
    baseCost: EfficientNumber.parse('5000000'),
    baseProduction: EfficientNumber.parse('12000'),
    description: 'Múltiplos universos dedicados ao fubá',
    unlockRequirement: 10,
    tier: GeneratorTier.stellar,
  ),
  FubaGenerator(
    name: 'Máquina do Tempo',
    emoji: '⏰',
    baseCost: EfficientNumber.parse('15000000'),
    baseProduction: EfficientNumber.parse('40000'),
    description: 'Produz fubá de todas as eras temporais',
    unlockRequirement: 11,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Deus do Fubá',
    emoji: '👑',
    baseCost: EfficientNumber.parse('50000000'),
    baseProduction: EfficientNumber.parse('120000'),
    description: 'A divindade suprema do fubá',
    unlockRequirement: 12,
    tier: GeneratorTier.celestial,
  ),
  FubaGenerator(
    name: 'Fubá Ancestral',
    emoji: '💫',
    baseCost: EfficientNumber.parse('750000000'),
    baseProduction: EfficientNumber.parse('2000000'),
    description: 'A essência original de todo fubá existente',
    unlockRequirement: 13,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'Laboratório Alquímico',
    emoji: '🧪',
    baseCost: EfficientNumber.parse('3500000000'),
    baseProduction: EfficientNumber.parse('9600000'),
    description: 'Transforma matéria em fubá puro',
    unlockRequirement: 14,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Fubátron 3000',
    emoji: '🤖',
    baseCost: EfficientNumber.parse('18000000000'),
    baseProduction: EfficientNumber.parse('52000000'),
    description: 'IA avançada especializada em produção de fubá',
    unlockRequirement: 15,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'Portal Interdimensional',
    emoji: '🚪',
    baseCost: EfficientNumber.parse('95000000000'),
    baseProduction: EfficientNumber.parse('280000000'),
    description: 'Importa fubá de dimensões paralelas',
    unlockRequirement: 16,
    tier: GeneratorTier.primordial,
  ),
  FubaGenerator(
    name: 'Colmeia de Abelhas Milho',
    emoji: '🐝',
    baseCost: EfficientNumber.parse('500000000000'),
    baseProduction: EfficientNumber.parse('1440000000'),
    description: 'Abelhas geneticamente modificadas para fazer fubá',
    unlockRequirement: 17,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'Sexta Dimensão',
    emoji: '🌠',
    baseCost: EfficientNumber.parse('2800000000000'),
    baseProduction: EfficientNumber.parse('7600000000'),
    description: 'Acessa dimensões onde fubá é a lei da física',
    unlockRequirement: 18,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'Máquina de Realidade',
    emoji: '🎭',
    baseCost: EfficientNumber.parse('15000000000000'),
    baseProduction: EfficientNumber.parse('44000000000'),
    description: 'Manipula a própria realidade para gerar fubá',
    unlockRequirement: 19,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'Consciência Coletiva',
    emoji: '🧠',
    baseCost: EfficientNumber.parse('85000000000000'),
    baseProduction: EfficientNumber.parse('256000000000'),
    description: 'Toda a humanidade pensando em fubá',
    unlockRequirement: 20,
    tier: GeneratorTier.supreme,
  ),
  FubaGenerator(
    name: 'Big Bang Fubá',
    emoji: '💥',
    baseCost: EfficientNumber.parse('480000000000000'),
    baseProduction: EfficientNumber.parse('1440000000000'),
    description: 'Recria o Big Bang, mas desta vez com fubá',
    unlockRequirement: 21,
    tier: GeneratorTier.ultimate,
  ),
  FubaGenerator(
    name: 'Matriz do Fubá',
    emoji: '🔢',
    baseCost: EfficientNumber.parse('2800000000000000'),
    baseProduction: EfficientNumber.parse('8400000000000'),
    description: 'O código fonte da realidade onde tudo é fubá',
    unlockRequirement: 22,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Eldritch Horror',
    emoji: '👁️',
    baseCost: EfficientNumber.parse('17500000000000000'),
    baseProduction: EfficientNumber.parse('52000000000000'),
    description: 'Entidade cósmica que se alimenta de fubá',
    unlockRequirement: 23,
    tier: GeneratorTier.stellar,
  ),
  FubaGenerator(
    name: 'Simulação Infinita',
    emoji: '♾️',
    baseCost: EfficientNumber.parse('110000000000000000'),
    baseProduction: EfficientNumber.parse('336000000000000'),
    description: 'Simula universos infinitos de fubá',
    unlockRequirement: 24,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Paradoxo Temporal',
    emoji: '🔄',
    baseCost: EfficientNumber.parse('720000000000000000'),
    baseProduction: EfficientNumber.parse('2200000000000000'),
    description: 'Cria fubá do nada através de paradoxos',
    unlockRequirement: 25,
    tier: GeneratorTier.celestial,
  ),
  FubaGenerator(
    name: 'Mente Suprema',
    emoji: '🎯',
    baseCost: EfficientNumber.parse('4800000000000000000'),
    baseProduction: EfficientNumber.parse('14800000000000000'),
    description: 'A consciência que sonhou todo o fubá',
    unlockRequirement: 26,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Nada Absoluto',
    emoji: '🕳️',
    baseCost: EfficientNumber.parse('1e50'),
    baseProduction: EfficientNumber.parse('1e30'),
    description: 'Do nada absoluto, fubá emerge',
    unlockRequirement: 27,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Nexus Primordial',
    emoji: '🌟',
    baseCost: EfficientNumber.parse('1e80'),
    baseProduction: EfficientNumber.parse('1e50'),
    description:
        'O ponto de convergência onde todas as realidades se encontram para gerar fubá',
    unlockRequirement: 28,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'Eternidade',
    emoji: '⏳',
    baseCost: EfficientNumber.parse('1e120'),
    baseProduction: EfficientNumber.parse('1e70'),
    description: 'O fubá que existe antes e depois do tempo',
    unlockRequirement: 29,
    tier: GeneratorTier.primordial,
  ),
  FubaGenerator(
    name: 'A Verdade',
    emoji: '🔍',
    baseCost: EfficientNumber.parse('1e170'),
    baseProduction: EfficientNumber.parse('1e100'),
    description: 'A verdade final: tudo sempre foi fubá',
    unlockRequirement: 30,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'Bolo Desperto',
    emoji: '🧁',
    baseCost: EfficientNumber.parse('1e220'),
    baseProduction: EfficientNumber.parse('1e130'),
    description: 'O bolo ganhou vida e produz fubá',
    unlockRequirement: 31,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'Padeiro Divino',
    emoji: '👨‍🍳',
    baseCost: EfficientNumber.parse('1e280'),
    baseProduction: EfficientNumber.parse('1e160'),
    description: 'O padeiro dos deuses trabalha para você',
    unlockRequirement: 32,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'A grande barreira da realidade',
    emoji: '▓',
    baseCost: EfficientNumber.parse('1e350'),
    baseProduction: EfficientNumber.parse('1e200'),
    description: 'O maior desafio para a produção de fubá inifita',
    unlockRequirement: 33,
    tier: GeneratorTier.supreme,
  ),
  // Smooth Section (34-42): Bridge to first wall
  FubaGenerator(
    name: 'Fubá Ancestral',
    emoji: '🏺',
    baseCost: EfficientNumber.parse('1e450'),
    baseProduction: EfficientNumber.parse('1e220'),
    description: 'O fubá dos primeiros tempos, guardado em ânforas sagradas',
    unlockRequirement: 34,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Moedor Cósmico',
    emoji: '⭐',
    baseCost: EfficientNumber.parse('1e500'),
    baseProduction: EfficientNumber.parse('1e250'),
    description: 'Um moedor que tritura estrelas em fubá',
    unlockRequirement: 35,
    tier: GeneratorTier.stellar,
  ),
  FubaGenerator(
    name: 'Memória do Fubá',
    emoji: '💾',
    baseCost: EfficientNumber.parse('1e550'),
    baseProduction: EfficientNumber.parse('1e280'),
    description: 'A memória coletiva de todo fubá já produzido',
    unlockRequirement: 36,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Forno Primordial',
    emoji: '🔥',
    baseCost: EfficientNumber.parse('1e600'),
    baseProduction: EfficientNumber.parse('1e310'),
    description: 'O primeiro forno que existiu, antes do tempo',
    unlockRequirement: 37,
    tier: GeneratorTier.celestial,
  ),
  FubaGenerator(
    name: 'Receita Universal',
    emoji: '📜',
    baseCost: EfficientNumber.parse('1e650'),
    baseProduction: EfficientNumber.parse('1e340'),
    description: 'A receita que criou o próprio fubá',
    unlockRequirement: 38,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'Sonho de Fubá',
    emoji: '💭',
    baseCost: EfficientNumber.parse('1e700'),
    baseProduction: EfficientNumber.parse('1e370'),
    description: 'Onde os sonhos se tornam fubá tangível',
    unlockRequirement: 39,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Tempo do Fubá',
    emoji: '⏰',
    baseCost: EfficientNumber.parse('1e750'),
    baseProduction: EfficientNumber.parse('1e400'),
    description: 'O tempo em si produz fubá em todas as direções',
    unlockRequirement: 40,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'O Observador do Fubá',
    emoji: '👀',
    baseCost: EfficientNumber.parse('1e800'),
    baseProduction: EfficientNumber.parse('1e430'),
    description: 'A consciência que observa e cria fubá pela observação',
    unlockRequirement: 41,
    tier: GeneratorTier.primordial,
  ),
  FubaGenerator(
    name: 'Fubá do Vazio',
    emoji: '🌑',
    baseCost: EfficientNumber.parse('1e850'),
    baseProduction: EfficientNumber.parse('1e440'),
    description: 'Do nada absoluto, fubá emerge espontaneamente',
    unlockRequirement: 42,
    tier: GeneratorTier.truth,
  ),
  // First Wall (43-48): Requires multiple ascensions
  FubaGenerator(
    name: 'A Primeira Receita',
    emoji: '📋',
    baseCost: EfficientNumber.parse('1e1100'),
    baseProduction: EfficientNumber.parse('1e520'),
    description: 'A primeira receita que criou o fubá no início de tudo',
    unlockRequirement: 43,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'Fubá Infinito',
    emoji: '∞',
    baseCost: EfficientNumber.parse('1e1250'),
    baseProduction: EfficientNumber.parse('1e580'),
    description: 'Um fubá que pode ser contado infinitamente',
    unlockRequirement: 44,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'O Paradoxo do Fubá',
    emoji: '🌀',
    baseCost: EfficientNumber.parse('1e1400'),
    baseProduction: EfficientNumber.parse('1e640'),
    description: 'Um paradoxo que se resolve em fubá puro',
    unlockRequirement: 45,
    tier: GeneratorTier.supreme,
  ),
  FubaGenerator(
    name: 'A Última Pergunta do Fubá',
    emoji: '❔',
    baseCost: EfficientNumber.parse('1e1600'),
    baseProduction: EfficientNumber.parse('1e700'),
    description: 'A pergunta cuja resposta é sempre fubá',
    unlockRequirement: 46,
    tier: GeneratorTier.ultimate,
  ),
  FubaGenerator(
    name: 'O Jogo do Fubá',
    emoji: '🎮',
    baseCost: EfficientNumber.parse('1e1800'),
    baseProduction: EfficientNumber.parse('1e760'),
    description: 'O jogo que joga a si mesmo, gerando fubá',
    unlockRequirement: 47,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Barreira do Fubá',
    emoji: '🚧',
    baseCost: EfficientNumber.parse('1e2000'),
    baseProduction: EfficientNumber.parse('1e820'),
    description: 'A barreira final que protege o fubá supremo',
    unlockRequirement: 48,
    tier: GeneratorTier.truth,
  ),
  // Smooth Section (49-53): Post-wall progression
  FubaGenerator(
    name: 'O Armazém do Fubá',
    emoji: '🏬',
    baseCost: EfficientNumber.parse('1e1650'),
    baseProduction: EfficientNumber.parse('1e770'),
    description: 'O armazém que contém todo o fubá já produzido',
    unlockRequirement: 49,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Variável do Fubá',
    emoji: '🌐',
    baseCost: EfficientNumber.parse('1e1725'),
    baseProduction: EfficientNumber.parse('1e820'),
    description: 'A variável que controla todo o fubá do universo',
    unlockRequirement: 50,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Ciclo Eterno do Fubá',
    emoji: '♻️',
    baseCost: EfficientNumber.parse('1e1800'),
    baseProduction: EfficientNumber.parse('1e870'),
    description: 'Um ciclo que nunca termina, gerando fubá eternamente',
    unlockRequirement: 51,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Receita Recursiva',
    emoji: '📝',
    baseCost: EfficientNumber.parse('1e1875'),
    baseProduction: EfficientNumber.parse('1e910'),
    description: 'Uma receita que se chama a si mesma, criando fubá',
    unlockRequirement: 52,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Coletor de Fubá',
    emoji: '🗑️',
    baseCost: EfficientNumber.parse('1e1950'),
    baseProduction: EfficientNumber.parse('1e950'),
    description: 'Coleta restos e os transforma em fubá puro',
    unlockRequirement: 53,
    tier: GeneratorTier.truth,
  ),
  // Final Wall (54-60): Endgame requiring transcendences
  FubaGenerator(
    name: 'O Compilador de Fubá',
    emoji: '🔧',
    baseCost: EfficientNumber.parse('1e2100'),
    baseProduction: EfficientNumber.parse('1e900'),
    description: 'Compila a realidade em fubá executável',
    unlockRequirement: 54,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'A Biblioteca do Fubá',
    emoji: '📖',
    baseCost: EfficientNumber.parse('1e2200'),
    baseProduction: EfficientNumber.parse('1e950'),
    description: 'A biblioteca infinita de conhecimento sobre fubá',
    unlockRequirement: 55,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'O Detector de Fubá',
    emoji: '🔎',
    baseCost: EfficientNumber.parse('1e2300'),
    baseProduction: EfficientNumber.parse('1e1000'),
    description: 'Encontra e corrige problemas na produção de fubá',
    unlockRequirement: 56,
    tier: GeneratorTier.supreme,
  ),
  FubaGenerator(
    name: 'A Exceção do Fubá',
    emoji: '🚨',
    baseCost: EfficientNumber.parse('1e2450'),
    baseProduction: EfficientNumber.parse('1e1050'),
    description: 'Uma exceção que quebra as regras e cria fubá',
    unlockRequirement: 57,
    tier: GeneratorTier.ultimate,
  ),
  FubaGenerator(
    name: 'O Ponto Nulo do Fubá',
    emoji: '📍',
    baseCost: EfficientNumber.parse('1e2600'),
    baseProduction: EfficientNumber.parse('1e1100'),
    description: 'O ponto nulo que aponta para fubá infinito',
    unlockRequirement: 58,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Última Receita',
    emoji: '📄',
    baseCost: EfficientNumber.parse('1e2800'),
    baseProduction: EfficientNumber.parse('1e1150'),
    description: 'A receita final que encerra e recria tudo em fubá',
    unlockRequirement: 59,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Fubá Absoluto',
    emoji: '🎂',
    baseCost: EfficientNumber.parse('1e3000'),
    baseProduction: EfficientNumber.parse('1e1200'),
    description: 'O fubá que transcende a própria existência',
    unlockRequirement: 60,
    tier: GeneratorTier.absolute,
  ),
];
