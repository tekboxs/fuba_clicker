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

  double _getLateGameCostMultiplier() {
    if (unlockRequirement >= 50) {
      return 2.0;
    } else if (unlockRequirement >= 40) {
      return 1.7;
    } else if (unlockRequirement >= 30) {
      return 1.4;
    } else if (unlockRequirement >= 25) {
      return 1.2;
    }
    return 1.0;
  }

  double _getLateGameProductionMultiplier() {
    if (unlockRequirement >= 50) {
      return 0.55;
    } else if (unlockRequirement >= 40) {
      return 0.65;
    } else if (unlockRequirement >= 30) {
      return 0.75;
    } else if (unlockRequirement >= 25) {
      return 0.85;
    }
    return 1.0;
  }

  /// Calcula o custo baseado na quantidade já possuída (crescimento exponencial suavizado)
  EfficientNumber getCost(int owned) {
    final lateGameCostMultiplier = _getLateGameCostMultiplier();
    final adjustedBaseCost =
        baseCost * EfficientNumber.fromValues(lateGameCostMultiplier, 0);

    if (owned <= 50) {
      return adjustedBaseCost *
          EfficientNumber.fromPower(1.20, owned.toDouble());
    } else if (owned <= 200) {
      final baseCost50 =
          adjustedBaseCost * EfficientNumber.fromPower(1.20, 50.0);
      final excessOwned = owned - 50;
      return baseCost50 *
          EfficientNumber.fromPower(1.18, excessOwned.toDouble());
    } else if (owned <= 500) {
      final baseCost50 =
          adjustedBaseCost * EfficientNumber.fromPower(1.20, 50.0);
      final baseCost200 = baseCost50 * EfficientNumber.fromPower(1.18, 150.0);
      final excessOwned = owned - 200;
      return baseCost200 *
          EfficientNumber.fromPower(1.15, excessOwned.toDouble());
    } else {
      final baseCost50 =
          adjustedBaseCost * EfficientNumber.fromPower(1.20, 50.0);
      final baseCost200 = baseCost50 * EfficientNumber.fromPower(1.18, 150.0);
      final baseCost500 = baseCost200 * EfficientNumber.fromPower(1.15, 300.0);
      final excessOwned = owned - 500;

      final rate = 1.12 - (excessOwned / 10000.0).clamp(0.0, 0.05);
      return baseCost500 *
          EfficientNumber.fromPower(rate, excessOwned.toDouble());
    }
  }

  /// Calcula a produção total baseada na quantidade possuída (crescimento em tiers balanceado)
  EfficientNumber getProduction(int owned) {
    if (owned <= 0) return const EfficientNumber.zero();

    final lateGameProductionMultiplier = _getLateGameProductionMultiplier();
    final adjustedBaseProduction = baseProduction *
        EfficientNumber.fromValues(lateGameProductionMultiplier, 0);

    if (owned <= 50) {
      return adjustedBaseProduction *
          EfficientNumber.fromValues(owned.toDouble(), 0);
    }

    if (owned <= 100) {
      final linearBase =
          adjustedBaseProduction * EfficientNumber.fromValues(50.0, 0);
      final excessOwned = owned - 50;
      final diminishingFactor = 1.0 - (excessOwned / 50.0) * 0.3;
      return linearBase *
          EfficientNumber.fromValues(
              1.0 + (excessOwned * diminishingFactor / 50.0), 0);
    }

    if (owned <= 300) {
      final tier1Max =
          adjustedBaseProduction * EfficientNumber.fromValues(100.0, 0);
      final excessOwned = owned - 100;
      final power = excessOwned / 200.0;
      return tier1Max * EfficientNumber.fromPower(1 + power * 0.5, 8.0);
    }

    if (owned <= 700) {
      final tier2Value = _calculateTier2Max(adjustedBaseProduction);
      final excessOwned = owned - 300;
      final power = excessOwned / 400.0;
      return tier2Value * EfficientNumber.fromPower(1 + power * 0.3, 20.0);
    }

    final tier3Value = _calculateTier3Max(adjustedBaseProduction);
    final excessOwned = owned - 700;
    final power = excessOwned / 700.0;
    final diminishingRate = 0.2 - (excessOwned / 50000.0).clamp(0.0, 0.1);
    return tier3Value *
        EfficientNumber.fromPower(1 + power * diminishingRate, 50.0);
  }

  EfficientNumber _calculateTier2Max(EfficientNumber adjustedBaseProduction) {
    final linearBase =
        adjustedBaseProduction * EfficientNumber.fromValues(100.0, 0);
    return linearBase * EfficientNumber.fromPower(2.0, 1.0);
  }

  EfficientNumber _calculateTier3Max(EfficientNumber adjustedBaseProduction) {
    final tier2Value = _calculateTier2Max(adjustedBaseProduction);
    return tier2Value * EfficientNumber.fromPower(1.5, 1.0);
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
    baseCost: EfficientNumber.parse('1e22'),
    baseProduction: EfficientNumber.parse('1e19'),
    description: 'Cria fubá do nada através de paradoxos',
    unlockRequirement: 25,
    tier: GeneratorTier.celestial,
  ),
  FubaGenerator(
    name: 'Mente Suprema',
    emoji: '🎯',
    baseCost: EfficientNumber.parse('1e31'),
    baseProduction: EfficientNumber.parse('1e28'),
    description: 'A consciência que sonhou todo o fubá',
    unlockRequirement: 26,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Nada Absoluto',
    emoji: '🕳️',
    baseCost: EfficientNumber.parse('1e40'),
    baseProduction: EfficientNumber.parse('1e36'),
    description: 'Do nada absoluto, fubá emerge',
    unlockRequirement: 27,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Nexus Primordial',
    emoji: '🌟',
    baseCost: EfficientNumber.parse('1e48'),
    baseProduction: EfficientNumber.parse('1e44'),
    description:
        'O ponto de convergência onde todas as realidades se encontram para gerar fubá',
    unlockRequirement: 28,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'Eternidade',
    emoji: '⏳',
    baseCost: EfficientNumber.parse('1e57'),
    baseProduction: EfficientNumber.parse('1e52'),
    description: 'O fubá que existe antes e depois do tempo',
    unlockRequirement: 29,
    tier: GeneratorTier.primordial,
  ),
  FubaGenerator(
    name: 'A Verdade',
    emoji: '🔍',
    baseCost: EfficientNumber.parse('1e67'),
    baseProduction: EfficientNumber.parse('1e61'),
    description: 'A verdade final: tudo sempre foi fubá',
    unlockRequirement: 30,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'Bolo Desperto',
    emoji: '🧁',
    baseCost: EfficientNumber.parse('1e78'),
    baseProduction: EfficientNumber.parse('1e71'),
    description: 'O bolo ganhou vida e produz fubá',
    unlockRequirement: 31,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'Padeiro Divino',
    emoji: '👨‍🍳',
    baseCost: EfficientNumber.parse('1e90'),
    baseProduction: EfficientNumber.parse('1e82'),
    description: 'O padeiro dos deuses trabalha para você',
    unlockRequirement: 32,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'A grande barreira da realidade',
    emoji: '▓',
    baseCost: EfficientNumber.parse('1e103'),
    baseProduction: EfficientNumber.parse('1e94'),
    description: 'O maior desafio para a produção de fubá inifita',
    unlockRequirement: 33,
    tier: GeneratorTier.supreme,
  ),
  // Smooth Section (34-42): Bridge to first wall
  FubaGenerator(
    name: 'Fubá Ancestral',
    emoji: '🏺',
    baseCost: EfficientNumber.parse('1e117'),
    baseProduction: EfficientNumber.parse('1e107'),
    description: 'O fubá dos primeiros tempos, guardado em ânforas sagradas',
    unlockRequirement: 34,
    tier: GeneratorTier.cosmic,
  ),
  FubaGenerator(
    name: 'Moedor Cósmico',
    emoji: '⭐',
    baseCost: EfficientNumber.parse('1e132'),
    baseProduction: EfficientNumber.parse('1e121'),
    description: 'Um moedor que tritura estrelas em fubá',
    unlockRequirement: 35,
    tier: GeneratorTier.stellar,
  ),
  FubaGenerator(
    name: 'Memória do Fubá',
    emoji: '💾',
    baseCost: EfficientNumber.parse('1e148'),
    baseProduction: EfficientNumber.parse('1e136'),
    description: 'A memória coletiva de todo fubá já produzido',
    unlockRequirement: 36,
    tier: GeneratorTier.divine,
  ),
  FubaGenerator(
    name: 'Forno Primordial',
    emoji: '🔥',
    baseCost: EfficientNumber.parse('1e165'),
    baseProduction: EfficientNumber.parse('1e151'),
    description: 'O primeiro forno que existiu, antes do tempo',
    unlockRequirement: 37,
    tier: GeneratorTier.celestial,
  ),
  FubaGenerator(
    name: 'Receita Universal',
    emoji: '📜',
    baseCost: EfficientNumber.parse('1e183'),
    baseProduction: EfficientNumber.parse('1e167'),
    description: 'A receita que criou o próprio fubá',
    unlockRequirement: 38,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'Sonho de Fubá',
    emoji: '💭',
    baseCost: EfficientNumber.parse('1e202'),
    baseProduction: EfficientNumber.parse('1e184'),
    description: 'Onde os sonhos se tornam fubá tangível',
    unlockRequirement: 39,
    tier: GeneratorTier.transcendent,
  ),
  FubaGenerator(
    name: 'Tempo do Fubá',
    emoji: '⏰',
    baseCost: EfficientNumber.parse('1e222'),
    baseProduction: EfficientNumber.parse('1e203'),
    description: 'O tempo em si produz fubá em todas as direções',
    unlockRequirement: 40,
    tier: GeneratorTier.eternal,
  ),
  FubaGenerator(
    name: 'O Observador do Fubá',
    emoji: '👀',
    baseCost: EfficientNumber.parse('1e243'),
    baseProduction: EfficientNumber.parse('1e223'),
    description: 'A consciência que observa e cria fubá pela observação',
    unlockRequirement: 41,
    tier: GeneratorTier.primordial,
  ),
  FubaGenerator(
    name: 'Fubá do Vazio',
    emoji: '🌑',
    baseCost: EfficientNumber.parse('1e267'),
    baseProduction: EfficientNumber.parse('1e245'),
    description: 'Do nada absoluto, fubá emerge espontaneamente',
    unlockRequirement: 42,
    tier: GeneratorTier.truth,
  ),
  // First Wall (43-48): Requires multiple ascensions
  FubaGenerator(
    name: 'A Primeira Receita',
    emoji: '📋',
    baseCost: EfficientNumber.parse('1e293'),
    baseProduction: EfficientNumber.parse('1e269'),
    description: 'A primeira receita que criou o fubá no início de tudo',
    unlockRequirement: 43,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'Fubá Infinito',
    emoji: '∞',
    baseCost: EfficientNumber.parse('1e322'),
    baseProduction: EfficientNumber.parse('1e296'),
    description: 'Um fubá que pode ser contado infinitamente',
    unlockRequirement: 44,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'O Paradoxo do Fubá',
    emoji: '🌀',
    baseCost: EfficientNumber.parse('1e354'),
    baseProduction: EfficientNumber.parse('1e326'),
    description: 'Um paradoxo que se resolve em fubá puro',
    unlockRequirement: 45,
    tier: GeneratorTier.supreme,
  ),
  FubaGenerator(
    name: 'A Última Pergunta do Fubá',
    emoji: '❔',
    baseCost: EfficientNumber.parse('1e388'),
    baseProduction: EfficientNumber.parse('1e357'),
    description: 'A pergunta cuja resposta é sempre fubá',
    unlockRequirement: 46,
    tier: GeneratorTier.ultimate,
  ),
  FubaGenerator(
    name: 'O Jogo do Fubá',
    emoji: '🎮',
    baseCost: EfficientNumber.parse('1e425'),
    baseProduction: EfficientNumber.parse('1e391'),
    description: 'O jogo que joga a si mesmo, gerando fubá',
    unlockRequirement: 47,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Barreira do Fubá',
    emoji: '🚧',
    baseCost: EfficientNumber.parse('1e465'),
    baseProduction: EfficientNumber.parse('1e429'),
    description: 'A barreira final que protege o fubá supremo',
    unlockRequirement: 48,
    tier: GeneratorTier.truth,
  ),
  // Smooth Section (49-53): Post-wall progression
  FubaGenerator(
    name: 'O Armazém do Fubá',
    emoji: '🏬',
    baseCost: EfficientNumber.parse('1e508'),
    baseProduction: EfficientNumber.parse('1e470'),
    description: 'O armazém que contém todo o fubá já produzido',
    unlockRequirement: 49,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Variável do Fubá',
    emoji: '🌐',
    baseCost: EfficientNumber.parse('1e554'),
    baseProduction: EfficientNumber.parse('1e515'),
    description: 'A variável que controla todo o fubá do universo',
    unlockRequirement: 50,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Ciclo Eterno do Fubá',
    emoji: '♻️',
    baseCost: EfficientNumber.parse('1e603'),
    baseProduction: EfficientNumber.parse('1e563'),
    description: 'Um ciclo que nunca termina, gerando fubá eternamente',
    unlockRequirement: 51,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Receita Recursiva',
    emoji: '📝',
    baseCost: EfficientNumber.parse('1e660'),
    baseProduction: EfficientNumber.parse('1e619'),
    description: 'Uma receita que se chama a si mesma, criando fubá',
    unlockRequirement: 52,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Coletor de Fubá',
    emoji: '🗑️',
    baseCost: EfficientNumber.parse('1e722'),
    baseProduction: EfficientNumber.parse('1e680'),
    description: 'Coleta restos e os transforma em fubá puro',
    unlockRequirement: 53,
    tier: GeneratorTier.truth,
  ),
  // Final Wall (54-60): Endgame requiring transcendences
  FubaGenerator(
    name: 'O Compilador de Fubá',
    emoji: '🔧',
    baseCost: EfficientNumber.parse('1e790'),
    baseProduction: EfficientNumber.parse('1e747'),
    description: 'Compila a realidade em fubá executável',
    unlockRequirement: 54,
    tier: GeneratorTier.infinity,
  ),
  FubaGenerator(
    name: 'A Biblioteca do Fubá',
    emoji: '📖',
    baseCost: EfficientNumber.parse('1e864'),
    baseProduction: EfficientNumber.parse('1e821'),
    description: 'A biblioteca infinita de conhecimento sobre fubá',
    unlockRequirement: 55,
    tier: GeneratorTier.omnipotent,
  ),
  FubaGenerator(
    name: 'O Detector de Fubá',
    emoji: '🔎',
    baseCost: EfficientNumber.parse('1e945'),
    baseProduction: EfficientNumber.parse('1e901'),
    description: 'Encontra e corrige problemas na produção de fubá',
    unlockRequirement: 56,
    tier: GeneratorTier.supreme,
  ),
  FubaGenerator(
    name: 'A Exceção do Fubá',
    emoji: '🚨',
    baseCost: EfficientNumber.parse('1e1034'),
    baseProduction: EfficientNumber.parse('1e990'),
    description: 'Uma exceção que quebra as regras e cria fubá',
    unlockRequirement: 57,
    tier: GeneratorTier.ultimate,
  ),
  FubaGenerator(
    name: 'O Ponto Nulo do Fubá',
    emoji: '📍',
    baseCost: EfficientNumber.parse('1e1132'),
    baseProduction: EfficientNumber.parse('1e1089'),
    description: 'O ponto nulo que aponta para fubá infinito',
    unlockRequirement: 58,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'A Última Receita',
    emoji: '📄',
    baseCost: EfficientNumber.parse('1e1240'),
    baseProduction: EfficientNumber.parse('1e1198'),
    description: 'A receita final que encerra e recria tudo em fubá',
    unlockRequirement: 59,
    tier: GeneratorTier.truth,
  ),
  FubaGenerator(
    name: 'O Fubá Absoluto',
    emoji: '🎂',
    baseCost: EfficientNumber.parse('1e1360'),
    baseProduction: EfficientNumber.parse('1e1320'),
    description: 'O fubá que transcende a própria existência',
    unlockRequirement: 60,
    tier: GeneratorTier.absolute,
  ),
];
