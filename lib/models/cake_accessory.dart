import 'package:flutter/material.dart';

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
}

class CakeAccessory {
  final String id;
  final String name;
  final String emoji;
  final AccessoryRarity rarity;
  final String description;

  const CakeAccessory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.rarity,
    required this.description,
  });
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
  ),
  CakeAccessory(
    id: 'sparkles',
    name: 'Brilhos',
    emoji: '✨',
    rarity: AccessoryRarity.epic,
    description: 'Brilhos mágicos',
  ),
  CakeAccessory(
    id: 'fire',
    name: 'Fogo',
    emoji: '🔥',
    rarity: AccessoryRarity.epic,
    description: 'Chamas ardentes',
  ),
  CakeAccessory(
    id: 'lightning',
    name: 'Raio',
    emoji: '⚡',
    rarity: AccessoryRarity.epic,
    description: 'Energia elétrica',
  ),
  CakeAccessory(
    id: 'crown',
    name: 'Coroa',
    emoji: '👑',
    rarity: AccessoryRarity.legendary,
    description: 'Uma coroa real',
  ),
  CakeAccessory(
    id: 'diamond',
    name: 'Diamante',
    emoji: '💎',
    rarity: AccessoryRarity.legendary,
    description: 'Um diamante precioso',
  ),
  CakeAccessory(
    id: 'rainbow',
    name: 'Arco-íris',
    emoji: '🌈',
    rarity: AccessoryRarity.legendary,
    description: 'Um arco-íris colorido',
  ),
  CakeAccessory(
    id: 'galaxy',
    name: 'Galáxia',
    emoji: '🌌',
    rarity: AccessoryRarity.mythical,
    description: 'Uma galáxia inteira',
  ),
  CakeAccessory(
    id: 'universe',
    name: 'Universo',
    emoji: '🌍',
    rarity: AccessoryRarity.mythical,
    description: 'O universo completo',
  ),
  CakeAccessory(
    id: 'portal',
    name: 'Portal',
    emoji: '🌀',
    rarity: AccessoryRarity.mythical,
    description: 'Um portal dimensional',
  ),
];

