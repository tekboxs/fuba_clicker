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
  ),
];

