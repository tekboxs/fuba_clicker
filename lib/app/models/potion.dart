import 'potion_color.dart';
import 'potion_effect.dart';
import 'cake_accessory.dart';

PotionColor getItemColor(CakeAccessory accessory) {
  switch (accessory.rarity) {
    case AccessoryRarity.common:
      return PotionColor.red;
    case AccessoryRarity.uncommon:
      return PotionColor.green;
    case AccessoryRarity.rare:
      return PotionColor.blue;
    case AccessoryRarity.epic:
      return PotionColor.purple;
    case AccessoryRarity.legendary:
      return PotionColor.orange;
    case AccessoryRarity.mythical:
      return PotionColor.cyan;
    case AccessoryRarity.divine:
      return PotionColor.pink;
    case AccessoryRarity.transcendent:
      return PotionColor.white;
    case AccessoryRarity.primordial:
      return PotionColor.black;
    case AccessoryRarity.cosmic:
      return PotionColor.cyan;
    case AccessoryRarity.infinite:
      return PotionColor.white;
    case AccessoryRarity.omniversal:
      return PotionColor.purple;
    case AccessoryRarity.reality:
      return PotionColor.pink;
    case AccessoryRarity.tek:
      return PotionColor.blue;
    case AccessoryRarity.absolute:
      return PotionColor.black;
    case AccessoryRarity.perfected:
      return PotionColor.white;
  }
}

int getItemColorValue(CakeAccessory accessory) {
  final baseValue = accessory.rarity.value;
  return baseValue;
}

class Potion {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Map<PotionColor, int> colorComposition;
  final List<PotionEffect> effects;
  final int minTotalColors;
  final int maxTotalColors;

  const Potion({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.colorComposition,
    required this.effects,
    this.minTotalColors = 0,
    this.maxTotalColors = 999,
  });

  bool matches(Map<PotionColor, int> cauldron) {
    final totalColors = cauldron.values.fold(0, (sum, count) => sum + count);
    if (totalColors < minTotalColors) {
      return false;
    }

    for (final entry in colorComposition.entries) {
      final requiredColor = entry.key;
      final requiredAmount = entry.value;
      final availableAmount = cauldron[requiredColor] ?? 0;

      if (availableAmount < requiredAmount) {
        return false;
      }
    }

    for (final entry in cauldron.entries) {
      final colorInCauldron = entry.key;
      if (!colorComposition.containsKey(colorInCauldron)) {
        return false;
      }
    }

    return true;
  }

  double getPowerLevel() {
    final totalColors =
        colorComposition.values.fold(0, (sum, count) => sum + count);
    return totalColors.toDouble();
  }
}

final List<Potion> allPotions = [
  Potion(
    id: 'basic_strength',
    name: 'Poção de Força Básica',
    emoji: '⚡',
    description: 'Aumenta produção temporariamente',
    colorComposition: {PotionColor.red: 5},
    effects: [
      PotionEffect(
        type: PotionEffectType.productionMultiplier,
        value: 2.5,
        duration: const Duration(minutes: 20),
      ),
    ],
    minTotalColors: 5,
    maxTotalColors: 10,
  ),
  Potion(
    id: 'power_boost',
    name: 'Poção de Poder',
    emoji: '💪',
    description: 'Aumenta poder de clique',
    colorComposition: {PotionColor.red: 3, PotionColor.blue: 2},
    effects: [
      PotionEffect(
        type: PotionEffectType.clickPower,
        value: 7.0,
        duration: const Duration(minutes: 20),
      ),
    ],
    minTotalColors: 5,
    maxTotalColors: 15,
  ),
  Potion(
    id: 'token_elixir',
    name: 'Elixir de Tokens',
    emoji: '⭐',
    description: 'Aumenta ganho de tokens celestiais',
    colorComposition: {PotionColor.blue: 5, PotionColor.green: 3},
    effects: [
      PotionEffect(
        type: PotionEffectType.tokenGain,
        value: 50.0,
        duration: const Duration(hours: 1),
      ),
    ],
    minTotalColors: 8,
    maxTotalColors: 20,
  ),
  Potion(
    id: 'forus_boost',
    name: 'Poção de Forus',
    emoji: '💎',
    description: 'Aumenta ganho de forus',
    colorComposition: {PotionColor.purple: 5, PotionColor.orange: 5},
    effects: [
      PotionEffect(
        type: PotionEffectType.forusGain,
        value: 50.0,
        duration: const Duration(minutes: 20),
      ),
    ],
    minTotalColors: 10,
    maxTotalColors: 30,
  ),
  Potion(
    id: 'rebirth_amplifier',
    name: 'Amplificador de Rebirth',
    emoji: '🔄',
    description: 'Multiplica ganhos de rebirth',
    colorComposition: {PotionColor.cyan: 10, PotionColor.pink: 5},
    effects: [
      PotionEffect(
        type: PotionEffectType.rebirthMultiplier,
        value: 1.5,
        duration: const Duration(minutes: 20),
      ),
    ],
    minTotalColors: 15,
    maxTotalColors: 50,
  ),
  Potion(
    id: 'cosmic_essence',
    name: 'Essência Cósmica',
    emoji: '🌌',
    description: 'Boost massivo de produção',
    colorComposition: {PotionColor.white: 20, PotionColor.black: 10},
    effects: [
      PotionEffect(
        type: PotionEffectType.productionMultiplier,
        value: 5.0,
        duration: const Duration(hours: 1),
      ),
      PotionEffect(
        type: PotionEffectType.tokenGain,
        value: 200.0,
        duration: const Duration(hours: 1),
      ),
    ],
    minTotalColors: 30,
    maxTotalColors: 100,
  ),
  Potion(
    id: 'permanent_boost',
    name: 'Poção Permanente',
    emoji: '♾️',
    description: 'Multiplicador permanente (escala com late game)',
    colorComposition: {PotionColor.white: 500, PotionColor.black: 500},
    effects: [
      PotionEffect(
        type: PotionEffectType.permanentMultiplier,
        value: 1.1,
        isPermanent: true,
      ),
    ],
    minTotalColors: 1000,
    maxTotalColors: 9999,
  ),
];
