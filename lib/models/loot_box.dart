import 'dart:math';
import 'package:flutter/material.dart';
import 'cake_accessory.dart';

enum LootBoxTier {
  basic(1),
  advanced(2),
  premium(3),
  ultimate(4);

  final int value;
  const LootBoxTier(this.value);

  String get displayName {
    switch (this) {
      case LootBoxTier.basic:
        return 'Caixa Básica';
      case LootBoxTier.advanced:
        return 'Caixa Avançada';
      case LootBoxTier.premium:
        return 'Caixa Premium';
      case LootBoxTier.ultimate:
        return 'Caixa Suprema';
    }
  }

  String get emoji {
    switch (this) {
      case LootBoxTier.basic:
        return '📦';
      case LootBoxTier.advanced:
        return '🎁';
      case LootBoxTier.premium:
        return '✨';
      case LootBoxTier.ultimate:
        return '👑';
    }
  }

  Color get color {
    switch (this) {
      case LootBoxTier.basic:
        return Colors.grey;
      case LootBoxTier.advanced:
        return Colors.blue;
      case LootBoxTier.premium:
        return Colors.purple;
      case LootBoxTier.ultimate:
        return Colors.orange;
    }
  }

  double get cost {
    switch (this) {
      case LootBoxTier.basic:
        return 100;
      case LootBoxTier.advanced:
        return 1000;
      case LootBoxTier.premium:
        return 10000;
      case LootBoxTier.ultimate:
        return 100000;
    }
  }

  String get description {
    switch (this) {
      case LootBoxTier.basic:
        return 'Itens comuns e incomuns';
      case LootBoxTier.advanced:
        return 'Itens até raros';
      case LootBoxTier.premium:
        return 'Itens até épicos';
      case LootBoxTier.ultimate:
        return 'Itens de todas as raridades';
    }
  }

  Map<AccessoryRarity, double> get rarityWeights {
    switch (this) {
      case LootBoxTier.basic:
        return {
          AccessoryRarity.common: 0.70,
          AccessoryRarity.uncommon: 0.30,
          AccessoryRarity.rare: 0.0,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
        };
      case LootBoxTier.advanced:
        return {
          AccessoryRarity.common: 0.50,
          AccessoryRarity.uncommon: 0.35,
          AccessoryRarity.rare: 0.15,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
        };
      case LootBoxTier.premium:
        return {
          AccessoryRarity.common: 0.30,
          AccessoryRarity.uncommon: 0.35,
          AccessoryRarity.rare: 0.25,
          AccessoryRarity.epic: 0.10,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
        };
      case LootBoxTier.ultimate:
        return {
          AccessoryRarity.common: 0.20,
          AccessoryRarity.uncommon: 0.25,
          AccessoryRarity.rare: 0.25,
          AccessoryRarity.epic: 0.20,
          AccessoryRarity.legendary: 0.08,
          AccessoryRarity.mythical: 0.02,
        };
    }
  }
}

class LootBox {
  final LootBoxTier tier;
  final Random _random = Random();

  LootBox({required this.tier});

  CakeAccessory openBox() {
    final weights = tier.rarityWeights;
    final random = _random.nextDouble();

    double cumulativeWeight = 0.0;
    AccessoryRarity? selectedRarity;

    for (final entry in weights.entries) {
      cumulativeWeight += entry.value;
      if (random <= cumulativeWeight) {
        selectedRarity = entry.key;
        break;
      }
    }

    selectedRarity ??= AccessoryRarity.common;

    final accessoriesOfRarity = allAccessories
        .where((accessory) => accessory.rarity == selectedRarity)
        .toList();

    if (accessoriesOfRarity.isEmpty) {
      return allAccessories.first;
    }

    return accessoriesOfRarity[_random.nextInt(accessoriesOfRarity.length)];
  }
}

