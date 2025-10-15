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

enum SpecialAbility {
  none,
  criticalClick,
  luckyBox,
  autoClicker,
  timeWarp,
}

enum AccessoryRarity {
  common(1),
  uncommon(2),
  rare(3),
  epic(4),
  legendary(5),
  mythical(6);

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
    }
  }

  double get dropChance {
    switch (this) {
      case AccessoryRarity.common:
        return 0.45;
      case AccessoryRarity.uncommon:
        return 0.30;
      case AccessoryRarity.rare:
        return 0.15;
      case AccessoryRarity.epic:
        return 0.07;
      case AccessoryRarity.legendary:
        return 0.025;
      case AccessoryRarity.mythical:
        return 0.005;
    }
  }

  double get productionMultiplier {
    switch (this) {
      case AccessoryRarity.common:
        return 1.05;
      case AccessoryRarity.uncommon:
        return 1.10;
      case AccessoryRarity.rare:
        return 1.25;
      case AccessoryRarity.epic:
        return 1.50;
      case AccessoryRarity.legendary:
        return 2.0;
      case AccessoryRarity.mythical:
        return 2.5;
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

  const CakeAccessory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.rarity,
    required this.description,
    this.visualEffect = VisualEffect.none,
    this.specialAbility = SpecialAbility.none,
  });

  double get productionMultiplier => rarity.productionMultiplier;
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
    rarity: AccessoryRarity.rare,
    description: 'Um abacate cremoso',
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
    rarity: AccessoryRarity.epic,
    description: 'Chamas ardentes',
    visualEffect: VisualEffect.flames,
    specialAbility: SpecialAbility.criticalClick,
  ),
  CakeAccessory(
    id: 'lightning',
    name: 'Raio',
    emoji: '⚡',
    rarity: AccessoryRarity.epic,
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
];

