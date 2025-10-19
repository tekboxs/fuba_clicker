import 'dart:math';
import 'package:flutter/material.dart';
import 'package:big_decimal/big_decimal.dart';
import 'cake_accessory.dart';

enum LootBoxTier {
  basic(1),
  advanced(2),
  premium(3),
  ultimate(4),
  divine(5),
  transcendent(6);

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
      case LootBoxTier.divine:
        return 'Caixa Divina';
      case LootBoxTier.transcendent:
        return 'Caixa Transcendente';
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
      case LootBoxTier.divine:
        return '💎';
      case LootBoxTier.transcendent:
        return '🌟';
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
      case LootBoxTier.divine:
        return Colors.cyan;
      case LootBoxTier.transcendent:
        return Colors.white;
    }
  }

  BigDecimal get cost {
    switch (this) {
      case LootBoxTier.basic:
        return BigDecimal.parse('1000');
      case LootBoxTier.advanced:
        return BigDecimal.parse('25000');
      case LootBoxTier.premium:
        return BigDecimal.parse('500000');
      case LootBoxTier.ultimate:
        return BigDecimal.parse('10000000');
      case LootBoxTier.divine:
        return BigDecimal.parse('500000000');
      case LootBoxTier.transcendent:
        return BigDecimal.parse('50000000000');
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
        return 'Itens até lendários';
      case LootBoxTier.divine:
        return 'Itens até míticos';
      case LootBoxTier.transcendent:
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
          AccessoryRarity.divine: 0.0,
          AccessoryRarity.transcendent: 0.0,
        };
      case LootBoxTier.advanced:
        return {
          AccessoryRarity.common: 0.50,
          AccessoryRarity.uncommon: 0.35,
          AccessoryRarity.rare: 0.15,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
          AccessoryRarity.divine: 0.0,
          AccessoryRarity.transcendent: 0.0,
        };
      case LootBoxTier.premium:
        return {
          AccessoryRarity.common: 0.30,
          AccessoryRarity.uncommon: 0.35,
          AccessoryRarity.rare: 0.25,
          AccessoryRarity.epic: 0.10,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
          AccessoryRarity.divine: 0.0,
          AccessoryRarity.transcendent: 0.0,
        };
      case LootBoxTier.ultimate:
        return {
          AccessoryRarity.common: 0.20,
          AccessoryRarity.uncommon: 0.25,
          AccessoryRarity.rare: 0.25,
          AccessoryRarity.epic: 0.20,
          AccessoryRarity.legendary: 0.08,
          AccessoryRarity.mythical: 0.02,
          AccessoryRarity.divine: 0.0,
          AccessoryRarity.transcendent: 0.0,
        };
      case LootBoxTier.divine:
        return {
          AccessoryRarity.common: 0.15,
          AccessoryRarity.uncommon: 0.20,
          AccessoryRarity.rare: 0.25,
          AccessoryRarity.epic: 0.20,
          AccessoryRarity.legendary: 0.15,
          AccessoryRarity.mythical: 0.04,
          AccessoryRarity.divine: 0.01,
          AccessoryRarity.transcendent: 0.0,
        };
      case LootBoxTier.transcendent:
        return {
          AccessoryRarity.common: 0.10,
          AccessoryRarity.uncommon: 0.15,
          AccessoryRarity.rare: 0.20,
          AccessoryRarity.epic: 0.20,
          AccessoryRarity.legendary: 0.20,
          AccessoryRarity.mythical: 0.10,
          AccessoryRarity.divine: 0.04,
          AccessoryRarity.transcendent: 0.01,
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

