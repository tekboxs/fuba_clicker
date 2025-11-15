import 'cake_accessory.dart';

class CraftRecipe {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final List<String> inputIds;
  final List<int> inputQuantities;
  final String outputId;
  final double forusCost;
  final double celestialTokensCost;

  const CraftRecipe({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.inputIds,
    required this.inputQuantities,
    required this.outputId,
    this.forusCost = 1.0,
    this.celestialTokensCost = 1000.0,
  });

  bool canCraft(Map<String, int> inventory, List<String> equipped, {
    double forus = 0.0,
    double celestialTokens = 0.0,
  }) {
    if (forus < forusCost || celestialTokens < celestialTokensCost) {
      return false;
    }

    for (int i = 0; i < inputIds.length; i++) {
      final itemId = inputIds[i];
      final requiredQuantity = inputQuantities[i];
      
      final totalQuantity = inventory[itemId] ?? 0;
      final equippedCount = equipped.where((id) => id == itemId).length;
      final availableQuantity = totalQuantity - equippedCount;
      
      if (availableQuantity < requiredQuantity) {
        return false;
      }
    }
    return true;
  }

  List<String> getMissingItems(Map<String, int> inventory, List<String> equipped, {
    double forus = 0.0,
    double celestialTokens = 0.0,
  }) {
    final missing = <String>[];
    
    if (forus < forusCost) {
      missing.add('💎 Forus: ${forusCost.toStringAsFixed(0)}');
    }
    if (celestialTokens < celestialTokensCost) {
      missing.add('🌙 Tokens Celestiais: ${celestialTokensCost.toStringAsFixed(0)}');
    }

    for (int i = 0; i < inputIds.length; i++) {
      final itemId = inputIds[i];
      final requiredQuantity = inputQuantities[i];
      
      final totalQuantity = inventory[itemId] ?? 0;
      final equippedCount = equipped.where((id) => id == itemId).length;
      final availableQuantity = totalQuantity - equippedCount;
      
      if (availableQuantity < requiredQuantity) {
        final accessory = allAccessories.firstWhere((a) => a.id == itemId);
        final missingCount = requiredQuantity - availableQuantity;
        missing.add('${accessory.emoji} ${accessory.name} x$missingCount');
      }
    }
    return missing;
  }
}

const List<CraftRecipe> allCraftRecipes = [
  CraftRecipe(
    id: 'star_fruit_basket',
    name: 'Cesta de Frutas Estelares',
    emoji: '⭐🧺',
    description: 'Cesta repleta de frutas brilhantes',
    inputIds: [
      'star',
      'cherry',
      'strawberry',
      'orange',
      'grapes',
    ],
    inputQuantities: [1, 2, 2, 2, 2],
    outputId: 'star_fruit_basket_item',
    forusCost: 15.0,
    celestialTokensCost: 75.0,
  ),
  CraftRecipe(
    id: 'fruit_salad',
    name: 'Salada de Frutas',
    emoji: '🥗',
    description: 'Uma deliciosa mistura de frutas tropicais',
    inputIds: [
      'cherry',
      'strawberry',
      'lemon',
      'banana',
      'orange',
      'grapes',
      'watermelon',
      'pineapple',
      'coconut',
      'mango',
    ],
    inputQuantities: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    outputId: 'fruit_salad_item',
    forusCost: 30.0,
    celestialTokensCost: 150.0,
  ),
  CraftRecipe(
    id: 'crystal_garden',
    name: 'Jardim de Cristais',
    emoji: '💠🌱',
    description: 'Jardim cultivado com cristais mágicos',
    inputIds: [
      'crystal_ball',
      'dark_matter_crystal',
      'time_crystal',
      'diamond',
    ],
    inputQuantities: [1, 1, 1, 2],
    outputId: 'crystal_garden_item',
    forusCost: 60.0,
    celestialTokensCost: 300.0,
  ),
  CraftRecipe(
    id: 'cosmic_smoothie',
    name: 'Smoothie Cósmico',
    emoji: '🥤',
    description: 'Smoothie feito com frutas das estrelas',
    inputIds: [
      'star',
      'sparkles',
      'galaxy',
    ],
    inputQuantities: [2, 2, 1],
    outputId: 'cosmic_smoothie_item',
    forusCost: 100.0,
    celestialTokensCost: 500.0,
  ),
  CraftRecipe(
    id: 'dragon_essence',
    name: 'Essência do Covro',
    emoji: '🐦‍⬛💧',
    description: 'A essência pura do corvo lendário',
    inputIds: [
      'dragon',
      'phoenix',
      'rainbow',
    ],
    inputQuantities: [1, 1, 1],
    outputId: 'dragon_essence_item',
    forusCost: 200.0,
    celestialTokensCost: 1000.0,
  ),
  CraftRecipe(
    id: 'corvo_calcinha',
    name: 'Covro de Calcinha',
    emoji: '🩲🐦‍⬛',
    description: 'Um corvo estiloso com calcinha',
    inputIds: [
      'gay_pride',
      'dragon',
    ],
    inputQuantities: [1, 1],
    outputId: 'corvo_calcinha_item',
    forusCost: 300.0,
    celestialTokensCost: 1500.0,
  ),
  CraftRecipe(
    id: 'stellar_crown',
    name: 'Coroa Estelar',
    emoji: '👑⭐',
    description: 'Coroa forjada com estrelas e brilhos',
    inputIds: [
      'crown',
      'star',
      'sparkles',
      'diamond',
    ],
    inputQuantities: [1, 3, 2, 1],
    outputId: 'stellar_crown_item',
    forusCost: 400.0,
    celestialTokensCost: 2000.0,
  ),
  CraftRecipe(
    id: 'phoenix_flame',
    name: 'Chama da Fênix',
    emoji: '🔥🦅',
    description: 'A chama eterna da fênix renascida',
    inputIds: [
      'phoenix',
      'fire',
      'lightning',
    ],
    inputQuantities: [1, 2, 1],
    outputId: 'phoenix_flame_item',
    forusCost: 500.0,
    celestialTokensCost: 2500.0,
  ),
  CraftRecipe(
    id: 'void_dragon',
    name: 'Covro do Vazio',
    emoji: '🐦‍⬛🌑',
    description: 'Corvo que habita o vazio primordial',
    inputIds: [
      'dragon',
      'void_essence',
      'black_hole_fragment',
    ],
    inputQuantities: [1, 1, 1],
    outputId: 'void_dragon_item',
    forusCost: 600.0,
    celestialTokensCost: 3000.0,
  ),
  CraftRecipe(
    id: 'quasar',
    name: 'Quasar',
    emoji: '⚡',
    description: 'O núcleo energético de uma galáxia ativa',
    inputIds: [
      'gravity_well',
      'space_dust',
      'plasma_orb',
    ],
    inputQuantities: [1, 1, 1],
    outputId: 'quasar_item',
    forusCost: 800.0,
    celestialTokensCost: 4000.0,
  ),
  CraftRecipe(
    id: 'cosmic_avocado',
    name: 'Abacate Cósmico',
    emoji: '🥑🌌',
    description: 'Abacate que veio das profundezas do espaço',
    inputIds: [
      'avocado',
      'galaxy',
      'universe',
      'nebula_core',
    ],
    inputQuantities: [1, 1, 1, 1],
    outputId: 'cosmic_avocado_item',
    forusCost: 1200.0,
    celestialTokensCost: 6000.0,
  ),
  CraftRecipe(
    id: 'time_fruit',
    name: 'Fruta Temporal',
    emoji: '⏰🍎',
    description: 'Fruta que amadurece através do tempo',
    inputIds: [
      'time_crystal',
      'quantum_butterfly',
      'pineapple',
      'mango',
    ],
    inputQuantities: [1, 1, 2, 2],
    outputId: 'time_fruit_item',
    forusCost: 2500.0,
    celestialTokensCost: 12500.0,
  ),
  CraftRecipe(
    id: 'void_berry',
    name: 'Baga do Vazio',
    emoji: '🌑🫐',
    description: 'Baga cultivada no vazio primordial',
    inputIds: [
      'void_essence',
      'void_whisper',
      'black_hole_fragment',
      'singularity_fragment',
    ],
    inputQuantities: [1, 1, 1, 1],
    outputId: 'void_berry_item',
    forusCost: 4000.0,
    celestialTokensCost: 20000.0,
  ),
  CraftRecipe(
    id: 'quantum_juice',
    name: 'Suco Quântico',
    emoji: '⚛️🧃',
    description: 'Suco que existe em superposição',
    inputIds: [
      'quantum_core',
      'quantum_butterfly',
      'quantum_entangler',
      'orange',
      'watermelon',
    ],
    inputQuantities: [1, 1, 1, 3, 2],
    outputId: 'quantum_juice_item',
    forusCost: 6000.0,
    celestialTokensCost: 30000.0,
  ),
  CraftRecipe(
    id: 'quantum_fruit_bowl',
    name: 'Tigela Quântica de Frutas',
    emoji: '🍎⚛️',
    description: 'Frutas que existem em múltiplas dimensões',
    inputIds: [
      'quantum_core',
      'fruit_salad_item',
      'portal',
    ],
    inputQuantities: [1, 1, 1],
    outputId: 'quantum_fruit_bowl_item',
    forusCost: 12000.0,
    celestialTokensCost: 60000.0,
  ),
  CraftRecipe(
    id: 'nebula_salad',
    name: 'Salada de Nebulosa',
    emoji: '🌫️🥗',
    description: 'Salada feita com poeira estelar',
    inputIds: [
      'nebula_core',
      'space_dust',
      'stellar_remnant',
      'fruit_salad_item',
    ],
    inputQuantities: [1, 3, 1, 1],
    outputId: 'nebula_salad_item',
    forusCost: 18000.0,
    celestialTokensCost: 90000.0,
  ),
  CraftRecipe(
    id: 'kotoamatsukami',
    name: 'Kotoamatsukami',
    emoji: '🌀',
    description: 'A ilusão dos deuses que manipula a realidade',
    inputIds: [
      'consciousness_core',
      'reality_fabric',
      'dragon',
    ],
    inputQuantities: [1, 1, 1],
    outputId: 'kotoamatsukami_item',
    forusCost: 40000.0,
    celestialTokensCost: 200000.0,
  ),
  CraftRecipe(
    id: 'infinity_cake',
    name: 'Bolo Infinito',
    emoji: '♾️🎂',
    description: 'Bolo que nunca acaba',
    inputIds: [
      'infinity_symbol',
      'eternal_paradox',
      'infinity_matri6x',
    ],
    inputQuantities: [1, 1, 1],
    outputId: 'infinity_cake_item',
    forusCost: 80000.0,
    celestialTokensCost: 400000.0,
  ),
  CraftRecipe(
    id: 'multiverse_mix',
    name: 'Mistura Multiversal',
    emoji: '🌐🔀',
    description: 'Mistura de ingredientes de todos os universos',
    inputIds: [
      'multiverse_core',
      'multiverse_essence',
      'dimensional_weaver',
      'quantum_entangler',
    ],
    inputQuantities: [1, 1, 1, 1],
    outputId: 'multiverse_mix_item',
    forusCost: 150000.0,
    celestialTokensCost: 750000.0,
  ),
  CraftRecipe(
    id: 'reality_soup',
    name: 'Sopa da Realidade',
    emoji: '🍲🧵',
    description: 'Sopa feita com o tecido da realidade',
    inputIds: [
      'reality_fabric',
      'reality_anchor',
      'existence_crystal',
      'truth_fragment',
    ],
    inputQuantities: [1, 1, 1, 1],
    outputId: 'reality_soup_item',
    forusCost: 400000.0,
    celestialTokensCost: 2000000.0,
  ),
  CraftRecipe(
    id: 'tek_smoothie',
    name: 'Smoothie Tek',
    emoji: '💻🥤',
    description: 'Smoothie processado por tecnologia avançada',
    inputIds: [
      'tek_processor',
      'quantum_computer',
      'neural_interface',
      'cosmic_smoothie_item',
    ],
    inputQuantities: [1, 1, 1, 1],
    outputId: 'tek_smoothie_item',
    forusCost: 800000.0,
    celestialTokensCost: 4000000.0,
  ),
  CraftRecipe(
    id: 'absolute_fusion',
    name: 'Fusão Absoluta',
    emoji: '⚛️💥',
    description: 'A fusão definitiva de todos os elementos',
    inputIds: [
      'absolute_zero',
      'infinity_engine',
      'god_mode',
      'kotoamatsukami_item',
    ],
    inputQuantities: [1, 1, 1, 1],
    outputId: 'absolute_fusion_item',
    forusCost: 4000000.0,
    celestialTokensCost: 20000000.0,
  ),
  CraftRecipe(
    id: 'infinity_snack',
    name: 'Lanche Infinito',
    emoji: '♾️🍪',
    description: 'Lanche que nunca termina',
    inputIds: [
      'infinity_symbol',
      'eternal_paradox',
      'banana',
      'coconut',
      'lemon',
    ],
    inputQuantities: [1, 1, 3, 2, 2],
    outputId: 'infinity_snack_item',
    forusCost: 1000000000.0,
    celestialTokensCost: 5000000000.0,
  ),
];

