import 'package:flutter/material.dart';

enum VisualEffect {
  none,
  sparkle,
  glow,
  pulse,
  orbit,
  flames,
  lightning,
  cosmic,
  rainbow,
}

enum SpecialAbility { none, criticalClick, luckyBox, autoClicker, timeWarp }

enum AccessoryShape { circle, triangle, square, pentagon, hexagon, octagon }

enum AccessoryRarity {
  common(1),
  uncommon(2),
  rare(3),
  epic(4),
  legendary(5),
  mythical(6),
  divine(7),
  transcendent(8),
  primordial(9),
  cosmic(10),
  infinite(11),
  omniversal(12),
  reality(13),
  tek(14),
  absolute(15),
  perfected(16);

  final int value;
  const AccessoryRarity(this.value);

  Color get color {
    switch (this) {
      case AccessoryRarity.common:
        return Colors.grey;
      case AccessoryRarity.uncommon:
        return Colors.green;
      case AccessoryRarity.rare:
        return Colors.blue;
      case AccessoryRarity.epic:
        return Colors.purple;
      case AccessoryRarity.legendary:
        return Colors.orange;
      case AccessoryRarity.mythical:
        return Colors.pink;
      case AccessoryRarity.divine:
        return Colors.cyan;
      case AccessoryRarity.transcendent:
        return Colors.white;
      case AccessoryRarity.primordial:
        return Colors.deepPurple;
      case AccessoryRarity.cosmic:
        return Colors.indigo;
      case AccessoryRarity.infinite:
        return Colors.amber;
      case AccessoryRarity.omniversal:
        return Colors.teal;
      case AccessoryRarity.reality:
        return Colors.pink;
      case AccessoryRarity.tek:
        return Colors.lime;
      case AccessoryRarity.absolute:
        return Colors.red;
      case AccessoryRarity.perfected:
        return Colors.white;
    }
  }

  String get displayName {
    switch (this) {
      case AccessoryRarity.common:
        return 'Comum';
      case AccessoryRarity.uncommon:
        return 'Incomum';
      case AccessoryRarity.rare:
        return 'Raro';
      case AccessoryRarity.epic:
        return 'Épico';
      case AccessoryRarity.legendary:
        return 'Lendário';
      case AccessoryRarity.mythical:
        return 'Mítico';
      case AccessoryRarity.divine:
        return 'Divino';
      case AccessoryRarity.transcendent:
        return 'Transcendente';
      case AccessoryRarity.primordial:
        return 'Primordial';
      case AccessoryRarity.cosmic:
        return 'Cósmico';
      case AccessoryRarity.infinite:
        return 'Infinito';
      case AccessoryRarity.omniversal:
        return 'Omniversal';
      case AccessoryRarity.reality:
        return 'Realidade';
      case AccessoryRarity.tek:
        return 'Tek';
      case AccessoryRarity.absolute:
        return 'Absoluto';
      case AccessoryRarity.perfected:
        return 'Perfeito';
    }
  }

  double get dropChance {
    switch (this) {
      case AccessoryRarity.common:
        return 0.40;
      case AccessoryRarity.uncommon:
        return 0.30;
      case AccessoryRarity.rare:
        return 0.15;
      case AccessoryRarity.epic:
        return 0.08;
      case AccessoryRarity.legendary:
        return 0.04;
      case AccessoryRarity.mythical:
        return 0.02;
      case AccessoryRarity.divine:
        return 0.007;
      case AccessoryRarity.transcendent:
        return 0.003;
      case AccessoryRarity.primordial:
        return 0.001;
      case AccessoryRarity.cosmic:
        return 0.0005;
      case AccessoryRarity.infinite:
        return 0.0001;
      case AccessoryRarity.omniversal:
        return 0.00005;
      case AccessoryRarity.reality:
        return 0.00001;
      case AccessoryRarity.tek:
        return 0.000005;
      case AccessoryRarity.absolute:
        return 0.000001;
      case AccessoryRarity.perfected:
        return 0.0;
    }
  }

  double get productionMultiplier {
    switch (this) {
      case AccessoryRarity.common:
        return 1.01;
      case AccessoryRarity.uncommon:
        return 1.02;
      case AccessoryRarity.rare:
        return 1.05;
      case AccessoryRarity.epic:
        return 1.10;
      case AccessoryRarity.legendary:
        return 1.25;
      case AccessoryRarity.mythical:
        return 1.50;
      case AccessoryRarity.divine:
        return 2.0;
      case AccessoryRarity.transcendent:
        return 3.0;
      case AccessoryRarity.primordial:
        return 4.0;
      case AccessoryRarity.cosmic:
        return 5.0;
      case AccessoryRarity.infinite:
        return 6.0;
      case AccessoryRarity.omniversal:
        return 8.0;
      case AccessoryRarity.reality:
        return 10.0;
      case AccessoryRarity.tek:
        return 15.0;
      case AccessoryRarity.absolute:
        return 25.0;
      case AccessoryRarity.perfected:
        return 50.0;
    }
  }

  AccessoryShape get shape {
    switch (this) {
      case AccessoryRarity.common:
        return AccessoryShape.circle;
      case AccessoryRarity.uncommon:
        return AccessoryShape.triangle;
      case AccessoryRarity.rare:
        return AccessoryShape.square;
      case AccessoryRarity.epic:
        return AccessoryShape.pentagon;
      case AccessoryRarity.legendary:
        return AccessoryShape.hexagon;
      case AccessoryRarity.mythical:
        return AccessoryShape.octagon;
      case AccessoryRarity.divine:
        return AccessoryShape.hexagon;
      case AccessoryRarity.transcendent:
        return AccessoryShape.octagon;
      case AccessoryRarity.primordial:
        return AccessoryShape.hexagon;
      case AccessoryRarity.cosmic:
        return AccessoryShape.octagon;
      case AccessoryRarity.infinite:
        return AccessoryShape.octagon;
      case AccessoryRarity.omniversal:
        return AccessoryShape.octagon;
      case AccessoryRarity.reality:
        return AccessoryShape.octagon;
      case AccessoryRarity.tek:
        return AccessoryShape.octagon;
      case AccessoryRarity.absolute:
        return AccessoryShape.octagon;
      case AccessoryRarity.perfected:
        return AccessoryShape.octagon;
    }
  }
}

class CakeAccessory {
  final String id;
  final String name;
  final String emoji;
  final AccessoryRarity rarity;
  final String description;
  final VisualEffect visualEffect;
  final SpecialAbility specialAbility;
  final double? customMultiplier;

  const CakeAccessory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.rarity,
    required this.description,
    this.visualEffect = VisualEffect.none,
    this.specialAbility = SpecialAbility.none,
    this.customMultiplier,
  });

  double get productionMultiplier => customMultiplier ?? rarity.productionMultiplier;
  AccessoryShape get shape => rarity.shape;
}

const List<CakeAccessory> allAccessories = [
  CakeAccessory(
    id: 'cherry',
    name: 'Cereja',
    emoji: '🍒',
    rarity: AccessoryRarity.common,
    description: 'Uma cereja simples',
  ),
  CakeAccessory(
    id: 'strawberry',
    name: 'Morango',
    emoji: '🍓',
    rarity: AccessoryRarity.common,
    description: 'Um morango fresco',
  ),
  CakeAccessory(
    id: 'lemon',
    name: 'Limão',
    emoji: '🍋',
    rarity: AccessoryRarity.common,
    description: 'Um limão azedo',
  ),
  CakeAccessory(
    id: 'banana',
    name: 'Banana',
    emoji: '🍌',
    rarity: AccessoryRarity.common,
    description: 'Uma banana madura',
  ),
  CakeAccessory(
    id: 'orange',
    name: 'Laranja',
    emoji: '🍊',
    rarity: AccessoryRarity.uncommon,
    description: 'Uma laranja suculenta',
  ),
  CakeAccessory(
    id: 'grapes',
    name: 'Uvas',
    emoji: '🍇',
    rarity: AccessoryRarity.uncommon,
    description: 'Um cacho de uvas',
  ),
  CakeAccessory(
    id: 'watermelon',
    name: 'Melancia',
    emoji: '🍉',
    rarity: AccessoryRarity.uncommon,
    description: 'Uma fatia de melancia',
  ),
  CakeAccessory(
    id: 'pineapple',
    name: 'Abacaxi',
    emoji: '🍍',
    rarity: AccessoryRarity.rare,
    description: 'Um abacaxi tropical',
  ),
  CakeAccessory(
    id: 'coconut',
    name: 'Coco',
    emoji: '🥥',
    rarity: AccessoryRarity.rare,
    description: 'Um coco fresco',
  ),
  CakeAccessory(
    id: 'avocado',
    name: 'Abacate',
    emoji: '🥑',
    rarity: AccessoryRarity.divine,
    description: 'Abacate pay <3',
  ),
  CakeAccessory(
    id: 'mango',
    name: 'Manga',
    emoji: '🥭',
    rarity: AccessoryRarity.rare,
    description: 'Uma manga doce',
  ),
  CakeAccessory(
    id: 'star',
    name: 'Estrela',
    emoji: '⭐',
    rarity: AccessoryRarity.epic,
    description: 'Uma estrela brilhante',
    visualEffect: VisualEffect.sparkle,
  ),
  CakeAccessory(
    id: 'sparkles',
    name: 'Brilhos',
    emoji: '✨',
    rarity: AccessoryRarity.epic,
    description: 'Brilhos mágicos',
    visualEffect: VisualEffect.glow,
  ),
  CakeAccessory(
    id: 'fire',
    name: 'Fogo',
    emoji: '🔥',
    rarity: AccessoryRarity.legendary,
    description: 'Chamas ardentes',
    visualEffect: VisualEffect.flames,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'lightning',
    name: 'Raio',
    emoji: '⚡',
    rarity: AccessoryRarity.legendary,
    description: 'Energia elétrica',
    visualEffect: VisualEffect.lightning,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'crown',
    name: 'Coroa',
    emoji: '👑',
    rarity: AccessoryRarity.legendary,
    description: 'Uma coroa real',
    visualEffect: VisualEffect.pulse,
    specialAbility: SpecialAbility.autoClicker,
  ),
  CakeAccessory(
    id: 'diamond',
    name: 'Diamante',
    emoji: '💎',
    rarity: AccessoryRarity.legendary,
    description: 'Um diamante precioso',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.luckyBox,
  ),
  CakeAccessory(
    id: 'rainbow',
    name: 'Arco-íris',
    emoji: '🌈',
    rarity: AccessoryRarity.legendary,
    description: 'Um arco-íris colorido',
    visualEffect: VisualEffect.rainbow,
  ),
  CakeAccessory(
    id: 'galaxy',
    name: 'Galáxia',
    emoji: '🌌',
    rarity: AccessoryRarity.mythical,
    description: 'Uma galáxia inteira',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'universe',
    name: 'Universo',
    emoji: '🌍',
    rarity: AccessoryRarity.mythical,
    description: 'O universo completo',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'portal',
    name: 'Portal',
    emoji: '🌀',
    rarity: AccessoryRarity.mythical,
    description: 'Um portal dimensional',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.autoClicker,
  ),
  // Novos acessórios míticos
  CakeAccessory(
    id: 'phoenix',
    name: 'Fênix',
    emoji: '🦅',
    rarity: AccessoryRarity.mythical,
    description: 'A ave lendária que renasce das cinzas',
    visualEffect: VisualEffect.flames,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'dragon',
    name: 'Covro',
    emoji: '🐦‍⬛',
    rarity: AccessoryRarity.mythical,
    description: 'Um corvo majestoso e poderoso',
    visualEffect: VisualEffect.glow,
    specialAbility: SpecialAbility.luckyBox,
  ),
  CakeAccessory(
    id: 'crystal_ball',
    name: 'Bola de Cristal',
    emoji: '🔮',
    rarity: AccessoryRarity.mythical,
    description: 'Uma bola de cristal mística',
    visualEffect: VisualEffect.pulse,
    specialAbility: SpecialAbility.timeWarp,
  ),
  // Novos acessórios divinos
  CakeAccessory(
    id: 'divine_crown',
    name: 'Coroa Divina',
    emoji: '👸',
    rarity: AccessoryRarity.divine,
    description: 'A coroa dos deuses do fubá',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.autoClicker,
  ),
  CakeAccessory(
    id: 'holy_grail',
    name: 'Café Sagrado',
    emoji: '☕',
    rarity: AccessoryRarity.divine,
    description: 'O cálice sagrado da produção',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.criticalClick,
  ),
  // Novos acessórios transcendentais
  CakeAccessory(
    id: 'infinity_symbol',
    name: 'Essencia da Eternidade',
    emoji: '♾️',
    rarity: AccessoryRarity.transcendent,
    description: 'O símbolo da eternidade e transcendência',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'quantum_core',
    name: 'Cupcake do Infinito',
    emoji: '🧁',
    rarity: AccessoryRarity.transcendent,
    description: 'Cupcake mágico que traz infinita energia',
    visualEffect: VisualEffect.lightning,
    specialAbility: SpecialAbility.autoClicker,
  ),
  // Novos acessórios primordiais
  CakeAccessory(
    id: 'void_essence',
    name: 'Essência do Vazio',
    emoji: '🌑',
    rarity: AccessoryRarity.primordial,
    description: 'A essência primordial do vazio cósmico',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'ancient_rune',
    name: 'Runa Ancestral',
    emoji: '🔯',
    rarity: AccessoryRarity.primordial,
    description: 'Runa gravada pelos primeiros seres do fubá',
    visualEffect: VisualEffect.pulse,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'primordial_flame',
    name: 'Leite Primordial',
    emoji: '🥛',
    rarity: AccessoryRarity.primordial,
    description: 'A primeira leitada',
    visualEffect: VisualEffect.flames,
    specialAbility: SpecialAbility.autoClicker,
  ),
  // Novos acessórios cósmicos
  CakeAccessory(
    id: 'nebula_core',
    name: 'Núcleo de Nebulosa',
    emoji: '🌫️',
    rarity: AccessoryRarity.cosmic,
    description: 'O coração de uma nebulosa em formação',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.luckyBox,
  ),
  CakeAccessory(
    id: 'stellar_remnant',
    name: 'Remanescente Estelar',
    emoji: '💫',
    rarity: AccessoryRarity.cosmic,
    description: 'Os restos de uma estrela que explodiu',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'black_hole_fragment',
    name: 'Fragmento de Vazio absoluto',
    emoji: '⚫',
    rarity: AccessoryRarity.cosmic,
    description: 'Um pedaço do nada espacial',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.timeWarp,
  ),
  // Novos acessórios infinitos
  CakeAccessory(
    id: 'infinity_matri6x',
    name: 'Matriz Infinita',
    emoji: '🔢',
    rarity: AccessoryRarity.infinite,
    description: 'A estrutura fundamental da realidade',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.autoClicker,
  ),
  CakeAccessory(
    id: 'eternal_paradox',
    name: 'Paradoxo Eterno',
    emoji: '🔄',
    rarity: AccessoryRarity.infinite,
    description: 'Um paradoxo que transcende o tempo e espaço',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.luckyBox,
  ),
  CakeAccessory(
    id: 'omniversal_key',
    name: 'Chave Omniversal',
    emoji: '🗝️',
    rarity: AccessoryRarity.infinite,
    description: 'A chave que abre todas as dimensões',
    visualEffect: VisualEffect.lightning,
    specialAbility: SpecialAbility.criticalClick,
  ),
  // Novos acessórios para acompanhar o novo limite
  CakeAccessory(
    id: 'quantum_butterfly',
    name: 'Flutter Quântico',
    emoji: '🦋',
    rarity: AccessoryRarity.cosmic,
    description: 'Flutter é a melhor linguagem de programação',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'neutron_star_core',
    name: 'Núcleo de Estrela de Nêutrons',
    emoji: '💫',
    rarity: AccessoryRarity.cosmic,
    description: 'O coração de uma estrela super densa',
    visualEffect: VisualEffect.pulse,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'dark_matter_crystal',
    name: 'Cristal de Matéria Escura',
    emoji: '💠',
    rarity: AccessoryRarity.primordial,
    description: 'Cristal formado pela matéria invisível do universo',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.luckyBox,
  ),
  CakeAccessory(
    id: 'time_crystal',
    name: 'Cristal Temporal',
    emoji: '⏰',
    rarity: AccessoryRarity.primordial,
    description: 'Cristal que manipula o fluxo temporal',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'singularity_fragment',
    name: 'Fragmento de Singularidade',
    emoji: '🕳️',
    rarity: AccessoryRarity.primordial,
    description: 'Pedaço de uma singularidade espacial',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.autoClicker,
  ),
  CakeAccessory(
    id: 'multiverse_essence',
    name: 'Essência Multiversal',
    emoji: '🌐',
    rarity: AccessoryRarity.transcendent,
    description: 'A essência que conecta todos os universos',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'dimensional_anchor',
    name: 'Âncora Dimensional',
    emoji: '⚓',
    rarity: AccessoryRarity.transcendent,
    description: 'Âncora que estabiliza dimensões',
    visualEffect: VisualEffect.pulse,
    specialAbility: SpecialAbility.autoClicker,
  ),
  CakeAccessory(
    id: 'reality_fabric',
    name: 'Tecido da Realidade',
    emoji: '🧵',
    rarity: AccessoryRarity.transcendent,
    description: 'O próprio tecido que compõe a realidade',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.luckyBox,
  ),
  CakeAccessory(
    id: 'consciousness_core',
    name: 'Núcleo de Consciência',
    emoji: '🧠',
    rarity: AccessoryRarity.divine,
    description: 'O núcleo da consciência universal',
    visualEffect: VisualEffect.glow,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'eternity_gem',
    name: 'Gema da Eternidade',
    emoji: '💍',
    rarity: AccessoryRarity.divine,
    description: 'Gema que contém a eternidade',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'void_whisper',
    name: 'Sussurro do Vazio',
    emoji: '👻',
    rarity: AccessoryRarity.divine,
    description: 'O sussurro do vazio primordial',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.luckyBox,
  ),
  CakeAccessory(
    id: 'cosmic_web',
    name: 'Teia Cósmica',
    emoji: '🕸️',
    rarity: AccessoryRarity.mythical,
    description: 'A teia que conecta todas as galáxias',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.autoClicker,
  ),
  CakeAccessory(
    id: 'stellar_nursery',
    name: 'Berçário Estelar',
    emoji: '🌠',
    rarity: AccessoryRarity.mythical,
    description: 'Onde as estrelas nascem',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'gravity_well',
    name: 'Poço Gravitacional',
    emoji: '🌊',
    rarity: AccessoryRarity.mythical,
    description: 'Um poço de gravidade extrema',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'plasma_orb',
    name: 'Orbe de Plasma',
    emoji: '🔴',
    rarity: AccessoryRarity.epic,
    description: 'Orbe de plasma superaquecido',
    visualEffect: VisualEffect.glow,
    specialAbility: SpecialAbility.luckyBox,
  ),
  CakeAccessory(
    id: 'magnetic_field',
    name: 'Campo Magnético',
    emoji: '🧲',
    rarity: AccessoryRarity.epic,
    description: 'Campo magnético intenso',
    visualEffect: VisualEffect.pulse,
    specialAbility: SpecialAbility.autoClicker,
  ),
  CakeAccessory(
    id: 'solar_wind',
    name: 'Vento Solar',
    emoji: '💨',
    rarity: AccessoryRarity.rare,
    description: 'Partículas energéticas do sol',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'aurora_borealis',
    name: 'Aurora Boreal',
    emoji: '🌅',
    rarity: AccessoryRarity.rare,
    description: 'Luzes dançantes do norte',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.none,
  ),
  CakeAccessory(
    id: 'meteor_shower',
    name: 'Chuva de Meteoros',
    emoji: '☄️',
    rarity: AccessoryRarity.uncommon,
    description: 'Chuva de meteoros brilhantes',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.none,
  ),
  CakeAccessory(
    id: 'comet_tail',
    name: 'Cauda de Cometa',
    emoji: '☄️',
    rarity: AccessoryRarity.uncommon,
    description: 'A cauda brilhante de um cometa',
    visualEffect: VisualEffect.glow,
    specialAbility: SpecialAbility.none,
  ),
  CakeAccessory(
    id: 'moon_rock',
    name: 'Rocha Lunar',
    emoji: '🪨',
    rarity: AccessoryRarity.common,
    description: 'Rocha trazida da lua',
    visualEffect: VisualEffect.none,
    specialAbility: SpecialAbility.none,
  ),
  CakeAccessory(
    id: 'space_dust',
    name: 'Poeira Espacial',
    emoji: '✨',
    rarity: AccessoryRarity.common,
    description: 'Poeira das estrelas distantes',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.none,
  ),
  // Novos acessórios Omniversais
  CakeAccessory(
    id: 'multiverse_core',
    name: 'Núcleo Multiversal',
    emoji: '🌐',
    rarity: AccessoryRarity.omniversal,
    description: 'O coração de todos os universos',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'dimensional_weaver',
    name: 'Tecelão Dimensional',
    emoji: '🕷️',
    rarity: AccessoryRarity.omniversal,
    description: 'Tecelão que cria novas dimensões',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'quantum_entangler',
    name: 'Emaranhador Quântico',
    emoji: '🔗',
    rarity: AccessoryRarity.omniversal,
    description: 'Conecta partículas através do espaço-tempo',
    visualEffect: VisualEffect.pulse,
    specialAbility: SpecialAbility.autoClicker,
  ),
  // Novos acessórios de Realidade
  CakeAccessory(
    id: 'reality_anchor',
    name: 'Âncora da Realidade',
    emoji: '⚓',
    rarity: AccessoryRarity.reality,
    description: 'Estabiliza a própria realidade',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'existence_crystal',
    name: 'Cristal da Existência',
    emoji: '💎',
    rarity: AccessoryRarity.reality,
    description: 'Cristal que define o que existe',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.luckyBox,
  ),
  CakeAccessory(
    id: 'truth_fragment',
    name: 'Fragmento da Verdade',
    emoji: '🔍',
    rarity: AccessoryRarity.reality,
    description: 'Um pedaço da verdade absoluta',
    visualEffect: VisualEffect.glow,
    specialAbility: SpecialAbility.timeWarp,
  ),
  // Novos acessórios Tek
  CakeAccessory(
    id: 'tek_processor',
    name: 'Processador Tek',
    emoji: '💻',
    rarity: AccessoryRarity.tek,
    description: 'Processador de tecnologia avançada',
    visualEffect: VisualEffect.lightning,
    specialAbility: SpecialAbility.autoClicker,
  ),
  CakeAccessory(
    id: 'quantum_computer',
    name: 'Computador Quântico',
    emoji: '🖥️',
    rarity: AccessoryRarity.tek,
    description: 'Computador que processa infinitas possibilidades',
    visualEffect: VisualEffect.pulse,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'neural_interface',
    name: 'Interface Neural',
    emoji: '🧠',
    rarity: AccessoryRarity.tek,
    description: 'Interface que conecta mente e máquina',
    visualEffect: VisualEffect.glow,
    specialAbility: SpecialAbility.luckyBox,
  ),
  // Novos acessórios Absolutos
  CakeAccessory(
    id: 'absolute_zero',
    name: 'Zero Absoluto',
    emoji: '❄️',
    rarity: AccessoryRarity.absolute,
    description: 'A temperatura mais baixa possível',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.timeWarp,
  ),
  CakeAccessory(
    id: 'infinity_engine',
    name: 'Motor do Infinito',
    emoji: '⚙️',
    rarity: AccessoryRarity.absolute,
    description: 'Motor que gera energia infinita',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.autoClicker,
  ),
  CakeAccessory(
    id: 'god_mode',
    name: 'Modo Deus',
    emoji: '👑',
    rarity: AccessoryRarity.absolute,
    description: 'Acesso total ao poder divino',
    visualEffect: VisualEffect.flames,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'gay_pride',
    name: 'Calcinhas do gabs',
    emoji: '🩲',
    rarity: AccessoryRarity.legendary,
    description: 'Calcinhas',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'fruit_salad_item',
    name: 'Salada de Frutas',
    emoji: '🥗',
    rarity: AccessoryRarity.perfected,
    description: 'Uma deliciosa mistura de frutas tropicais',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.luckyBox,
    customMultiplier: 50.0,
  ),
  CakeAccessory(
    id: 'corvo_calcinha_item',
    name: 'Covro de Calcinha',
    emoji: '🩲🐦‍⬛',
    rarity: AccessoryRarity.perfected,
    description: 'Um corvo estiloso com calcinha',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.criticalClick,
    customMultiplier: 55.0,
  ),
  CakeAccessory(
    id: 'quasar_item',
    name: 'Quasar',
    emoji: '⚡',
    rarity: AccessoryRarity.perfected,
    description: 'O núcleo energético de uma galáxia ativa',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.autoClicker,
    customMultiplier: 59.0,
  ),
  CakeAccessory(
    id: 'kotoamatsukami_item',
    name: 'Kotoamatsukami',
    emoji: '🌀',
    rarity: AccessoryRarity.perfected,
    description: 'A ilusão dos deuses que manipula a realidade',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.timeWarp,
    customMultiplier: 100.0,
  ),
  CakeAccessory(
    id: 'star_fruit_basket_item',
    name: 'Cesta de Frutas Estelares',
    emoji: '⭐🧺',
    rarity: AccessoryRarity.perfected,
    description: 'Cesta repleta de frutas brilhantes',
    visualEffect: VisualEffect.glow,
    specialAbility: SpecialAbility.none,
    customMultiplier: 52.0,
  ),
  CakeAccessory(
    id: 'crystal_garden_item',
    name: 'Jardim de Cristais',
    emoji: '💠🌱',
    rarity: AccessoryRarity.perfected,
    description: 'Jardim cultivado com cristais mágicos',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.luckyBox,
    customMultiplier: 53.0,
  ),
  CakeAccessory(
    id: 'cosmic_smoothie_item',
    name: 'Smoothie Cósmico',
    emoji: '🥤',
    rarity: AccessoryRarity.perfected,
    description: 'Smoothie feito com frutas das estrelas',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.luckyBox,
    customMultiplier: 54.0,
  ),
  CakeAccessory(
    id: 'dragon_essence_item',
    name: 'Essência do Covro',
    emoji: '🐦‍⬛💧',
    rarity: AccessoryRarity.perfected,
    description: 'A essência pura do corvo lendário',
    visualEffect: VisualEffect.glow,
    specialAbility: SpecialAbility.luckyBox,
    customMultiplier: 55.0,
  ),
  CakeAccessory(
    id: 'stellar_crown_item',
    name: 'Coroa Estelar',
    emoji: '👑⭐',
    rarity: AccessoryRarity.perfected,
    description: 'Coroa forjada com estrelas e brilhos',
    visualEffect: VisualEffect.glow,
    specialAbility: SpecialAbility.criticalClick,
    customMultiplier: 56.0,
  ),
  CakeAccessory(
    id: 'phoenix_flame_item',
    name: 'Chama da Fênix',
    emoji: '🔥🦅',
    rarity: AccessoryRarity.perfected,
    description: 'A chama eterna da fênix renascida',
    visualEffect: VisualEffect.flames,
    specialAbility: SpecialAbility.criticalClick,
    customMultiplier: 57.0,
  ),
  CakeAccessory(
    id: 'void_dragon_item',
    name: 'Covro do Vazio',
    emoji: '🐦‍⬛🌑',
    rarity: AccessoryRarity.perfected,
    description: 'Corvo que habita o vazio primordial',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.luckyBox,
    customMultiplier: 58.0,
  ),
  CakeAccessory(
    id: 'cosmic_avocado_item',
    name: 'Abacate Cósmico',
    emoji: '🥑🌌',
    rarity: AccessoryRarity.perfected,
    description: 'Abacate que veio das profundezas do espaço',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.criticalClick,
    customMultiplier: 60.0,
  ),
  CakeAccessory(
    id: 'time_fruit_item',
    name: 'Fruta Temporal',
    emoji: '⏰🍎',
    rarity: AccessoryRarity.perfected,
    description: 'Fruta que amadurece através do tempo',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.timeWarp,
    customMultiplier: 65.0,
  ),
  CakeAccessory(
    id: 'void_berry_item',
    name: 'Baga do Vazio',
    emoji: '🌑🫐',
    rarity: AccessoryRarity.perfected,
    description: 'Baga cultivada no vazio primordial',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.luckyBox,
    customMultiplier: 70.0,
  ),
  CakeAccessory(
    id: 'quantum_juice_item',
    name: 'Suco Quântico',
    emoji: '⚛️🧃',
    rarity: AccessoryRarity.perfected,
    description: 'Suco que existe em superposição',
    visualEffect: VisualEffect.pulse,
    specialAbility: SpecialAbility.autoClicker,
    customMultiplier: 75.0,
  ),
  CakeAccessory(
    id: 'quantum_fruit_bowl_item',
    name: 'Tigela Quântica de Frutas',
    emoji: '🍎⚛️',
    rarity: AccessoryRarity.perfected,
    description: 'Frutas que existem em múltiplas dimensões',
    visualEffect: VisualEffect.orbit,
    specialAbility: SpecialAbility.timeWarp,
    customMultiplier: 50.0,
  ),
  CakeAccessory(
    id: 'nebula_salad_item',
    name: 'Salada de Nebulosa',
    emoji: '🌫️🥗',
    rarity: AccessoryRarity.perfected,
    description: 'Salada feita com poeira estelar',
    visualEffect: VisualEffect.cosmic,
    specialAbility: SpecialAbility.autoClicker,
    customMultiplier: 75.0,
  ),
  CakeAccessory(
    id: 'infinity_cake_item',
    name: 'Bolo Infinito',
    emoji: '♾️🎂',
    rarity: AccessoryRarity.perfected,
    description: 'Bolo que nunca acaba',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.autoClicker,
    customMultiplier: 200.0,
  ),
  CakeAccessory(
    id: 'multiverse_mix_item',
    name: 'Mistura Multiversal',
    emoji: '🌐🔀',
    rarity: AccessoryRarity.perfected,
    description: 'Mistura de ingredientes de todos os universos',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.criticalClick,
    customMultiplier: 500.0,
  ),
  CakeAccessory(
    id: 'reality_soup_item',
    name: 'Sopa da Realidade',
    emoji: '🍲🧵',
    rarity: AccessoryRarity.perfected,
    description: 'Sopa feita com o tecido da realidade',
    visualEffect: VisualEffect.sparkle,
    specialAbility: SpecialAbility.timeWarp,
    customMultiplier: 1000.0,
  ),
  CakeAccessory(
    id: 'tek_smoothie_item',
    name: 'Smoothie Tek',
    emoji: '💻🥤',
    rarity: AccessoryRarity.perfected,
    description: 'Smoothie processado por tecnologia avançada',
    visualEffect: VisualEffect.lightning,
    specialAbility: SpecialAbility.autoClicker,
    customMultiplier: 2000.0,
  ),
  CakeAccessory(
    id: 'absolute_fusion_item',
    name: 'Fusão Absoluta',
    emoji: '⚛️💥',
    rarity: AccessoryRarity.perfected,
    description: 'A fusão definitiva de todos os elementos',
    visualEffect: VisualEffect.flames,
    specialAbility: SpecialAbility.criticalClick,
    customMultiplier: 5000.0,
  ),
  CakeAccessory(
    id: 'infinity_snack_item',
    name: 'Lanche Infinito',
    emoji: '♾️🍪',
    rarity: AccessoryRarity.perfected,
    description: 'Lanche que nunca termina',
    visualEffect: VisualEffect.rainbow,
    specialAbility: SpecialAbility.luckyBox,
    customMultiplier: 100000000.0,
  ),
];
