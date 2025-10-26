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
  transcendent(6),
  primordial(7),
  cosmic(8),
  infinite(9),
  reality(10),
  omniversal(11),
  tek(12),
  absolute(13);

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
      case LootBoxTier.primordial:
        return 'Caixa Primordial';
      case LootBoxTier.cosmic:
        return 'Caixa Cósmica';
      case LootBoxTier.infinite:
        return 'Caixa Infinita';
      case LootBoxTier.reality:
        return 'Caixa da Realidade';
      case LootBoxTier.omniversal:
        return 'Caixa Omniversal';
      case LootBoxTier.tek:
        return 'Caixas de Tek';
      case LootBoxTier.absolute:
        return 'Caixa Absoluta';
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
      case LootBoxTier.primordial:
        return '🌌';
      case LootBoxTier.cosmic:
        return '🌠';
      case LootBoxTier.infinite:
        return '♾️';
      case LootBoxTier.reality:
        return '🔮';
      case LootBoxTier.omniversal:
        return '🌐';
      case LootBoxTier.tek:
        return '💻';
      case LootBoxTier.absolute:
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
      case LootBoxTier.divine:
        return Colors.cyan;
      case LootBoxTier.transcendent:
        return Colors.white;
      case LootBoxTier.primordial:
        return Colors.deepPurple;
      case LootBoxTier.cosmic:
        return Colors.indigo;
      case LootBoxTier.infinite:
        return Colors.amber;
      case LootBoxTier.reality:
        return Colors.pink;
      case LootBoxTier.omniversal:
        return Colors.teal;
      case LootBoxTier.tek:
        return Colors.lime;
      case LootBoxTier.absolute:
        return Colors.red;
    }
  }

  BigDecimal getCost([BigDecimal? currentFuba]) {
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
      case LootBoxTier.primordial:
        if (currentFuba != null) {
          final baseCost = BigDecimal.parse('1e80');
          if (currentFuba.compareTo(baseCost) > 0) {
            return currentFuba.divide(BigDecimal.parse('30'), scale: 0, roundingMode: RoundingMode.DOWN);
          }
          return baseCost;
        }
        return BigDecimal.parse('1e80');
      case LootBoxTier.cosmic:
        if (currentFuba != null) {
          final baseCost = BigDecimal.parse('1e120');
          if (currentFuba.compareTo(baseCost) > 0) {
            return currentFuba.divide(BigDecimal.parse('50'), scale: 0, roundingMode: RoundingMode.DOWN);
          }
          return baseCost;
        }
        return BigDecimal.parse('1e120');
      case LootBoxTier.infinite:
        if (currentFuba != null) {
          final baseCost = BigDecimal.parse('1e200');
          if (currentFuba.compareTo(baseCost) > 0) {
            return currentFuba.divide(BigDecimal.parse('100'), scale: 0, roundingMode: RoundingMode.DOWN);
          }
          return baseCost;
        }
        return BigDecimal.parse('1e200');
      case LootBoxTier.reality:
        if (currentFuba != null) {
          final baseCost = BigDecimal.parse('1e300');
          if (currentFuba.compareTo(baseCost) > 0) {
            return currentFuba.divide(BigDecimal.parse('200'), scale: 0, roundingMode: RoundingMode.DOWN);
          }
          return baseCost;
        }
        return BigDecimal.parse('1e300');
      case LootBoxTier.omniversal:
        if (currentFuba != null) {
          final baseCost = BigDecimal.parse('1e400');
          if (currentFuba.compareTo(baseCost) > 0) {
            return currentFuba.divide(BigDecimal.parse('500'), scale: 0, roundingMode: RoundingMode.DOWN);
          }
          return baseCost;
        }
        return BigDecimal.parse('1e400');
      case LootBoxTier.tek:
        if (currentFuba != null) {
          final baseCost = BigDecimal.parse('1e500');
          if (currentFuba.compareTo(baseCost) > 0) {
            return currentFuba.divide(BigDecimal.parse('1000'), scale: 0, roundingMode: RoundingMode.DOWN);
          }
          return baseCost;
        }
        return BigDecimal.parse('1e500');
      case LootBoxTier.absolute:
        if (currentFuba != null) {
          final baseCost = BigDecimal.parse('1e600');
          if (currentFuba.compareTo(baseCost) > 0) {
            return currentFuba.divide(BigDecimal.parse('2000'), scale: 0, roundingMode: RoundingMode.DOWN);
          }
          return baseCost;
        }
        return BigDecimal.parse('1e600');
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
      case LootBoxTier.primordial:
        return 'Acessórios ultra-raros primordiais, cósmicos e infinitos';
      case LootBoxTier.cosmic:
        return 'Tesouros cósmicos e primordiais';
      case LootBoxTier.infinite:
        return 'Relíquias infinitas e cósmicas';
      case LootBoxTier.reality:
        return 'Fragmentos da própria realidade';
      case LootBoxTier.omniversal:
        return 'Tesouros de todos os universos';
      case LootBoxTier.tek:
        return 'Tecnologia avançada e artefatos';
      case LootBoxTier.absolute:
        return 'Poder absoluto e definitivo';
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
          AccessoryRarity.primordial: 0.0,
          AccessoryRarity.cosmic: 0.0,
          AccessoryRarity.infinite: 0.0,
          AccessoryRarity.omniversal: 0.0,
          AccessoryRarity.reality: 0.0,
          AccessoryRarity.tek: 0.0,
          AccessoryRarity.absolute: 0.0,
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
          AccessoryRarity.primordial: 0.0,
          AccessoryRarity.cosmic: 0.0,
          AccessoryRarity.infinite: 0.0,
          AccessoryRarity.omniversal: 0.0,
          AccessoryRarity.reality: 0.0,
          AccessoryRarity.tek: 0.0,
          AccessoryRarity.absolute: 0.0,
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
          AccessoryRarity.primordial: 0.0,
          AccessoryRarity.cosmic: 0.0,
          AccessoryRarity.infinite: 0.0,
          AccessoryRarity.omniversal: 0.0,
          AccessoryRarity.reality: 0.0,
          AccessoryRarity.tek: 0.0,
          AccessoryRarity.absolute: 0.0,
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
          AccessoryRarity.primordial: 0.0,
          AccessoryRarity.cosmic: 0.0,
          AccessoryRarity.infinite: 0.0,
          AccessoryRarity.omniversal: 0.0,
          AccessoryRarity.reality: 0.0,
          AccessoryRarity.tek: 0.0,
          AccessoryRarity.absolute: 0.0,
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
          AccessoryRarity.primordial: 0.0,
          AccessoryRarity.cosmic: 0.0,
          AccessoryRarity.infinite: 0.0,
          AccessoryRarity.omniversal: 0.0,
          AccessoryRarity.reality: 0.0,
          AccessoryRarity.tek: 0.0,
          AccessoryRarity.absolute: 0.0,
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
          AccessoryRarity.primordial: 0.0,
          AccessoryRarity.cosmic: 0.0,
          AccessoryRarity.infinite: 0.0,
          AccessoryRarity.omniversal: 0.0,
          AccessoryRarity.reality: 0.0,
          AccessoryRarity.tek: 0.0,
          AccessoryRarity.absolute: 0.0,
        };
      case LootBoxTier.primordial:
        return {
          AccessoryRarity.common: 0.0,
          AccessoryRarity.uncommon: 0.0,
          AccessoryRarity.rare: 0.0,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
          AccessoryRarity.divine: 0.40,
          AccessoryRarity.transcendent: 0.20,
          AccessoryRarity.primordial: 0.06,
          AccessoryRarity.cosmic: 0.03,
          AccessoryRarity.infinite: 0.001,
        };
      case LootBoxTier.cosmic:
        return {
          AccessoryRarity.common: 0.0,
          AccessoryRarity.uncommon: 0.0,
          AccessoryRarity.rare: 0.0,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
          AccessoryRarity.divine: 0.20,
          AccessoryRarity.transcendent: 0.30,
          AccessoryRarity.primordial: 0.25,
          AccessoryRarity.cosmic: 0.20,
          AccessoryRarity.infinite: 0.05,
        };
      case LootBoxTier.infinite:
        return {
          AccessoryRarity.common: 0.0,
          AccessoryRarity.uncommon: 0.0,
          AccessoryRarity.rare: 0.0,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
          AccessoryRarity.divine: 0.10,
          AccessoryRarity.transcendent: 0.20,
          AccessoryRarity.primordial: 0.30,
          AccessoryRarity.cosmic: 0.25,
          AccessoryRarity.infinite: 0.15,
        };
      case LootBoxTier.reality:
        return {
          AccessoryRarity.common: 0.0,
          AccessoryRarity.uncommon: 0.0,
          AccessoryRarity.rare: 0.0,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
          AccessoryRarity.divine: 0.05,
          AccessoryRarity.transcendent: 0.15,
          AccessoryRarity.primordial: 0.25,
          AccessoryRarity.cosmic: 0.30,
          AccessoryRarity.infinite: 0.25,
          AccessoryRarity.omniversal: 0.0001,
          AccessoryRarity.reality: 0.0001,
          AccessoryRarity.tek: 0.0,
          AccessoryRarity.absolute: 0.0,
        };
      case LootBoxTier.omniversal:
        return {
          AccessoryRarity.common: 0.0,
          AccessoryRarity.uncommon: 0.0,
          AccessoryRarity.rare: 0.0,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
          AccessoryRarity.divine: 0.0,
          AccessoryRarity.transcendent: 0.10,
          AccessoryRarity.primordial: 0.20,
          AccessoryRarity.cosmic: 0.25,
          AccessoryRarity.infinite: 0.30,
          AccessoryRarity.omniversal: 0.015,
          AccessoryRarity.reality: 0.0001,
          AccessoryRarity.tek: 0.0,
          AccessoryRarity.absolute: 0.0,
        };
      case LootBoxTier.tek:
        return {
          AccessoryRarity.common: 0.0,
          AccessoryRarity.uncommon: 0.0,
          AccessoryRarity.rare: 0.0,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
          AccessoryRarity.divine: 0.0,
          AccessoryRarity.transcendent: 0.05,
          AccessoryRarity.primordial: 0.15,
          AccessoryRarity.cosmic: 0.20,
          AccessoryRarity.infinite: 0.25,
          AccessoryRarity.omniversal: 0.020,
          AccessoryRarity.reality: 0.015,
          AccessoryRarity.tek: 0.001,
          AccessoryRarity.absolute: 0.000001,
        };
      case LootBoxTier.absolute:
        return {
          AccessoryRarity.common: 0.0,
          AccessoryRarity.uncommon: 0.0,
          AccessoryRarity.rare: 0.0,
          AccessoryRarity.epic: 0.0,
          AccessoryRarity.legendary: 0.0,
          AccessoryRarity.mythical: 0.0,
          AccessoryRarity.divine: 0.0,
          AccessoryRarity.transcendent: 0.0,
          AccessoryRarity.primordial: 0.10,
          AccessoryRarity.cosmic: 0.15,
          AccessoryRarity.infinite: 0.20,
          AccessoryRarity.omniversal: 0.25,
          AccessoryRarity.reality: 0.20,
          AccessoryRarity.tek: 0.01,
          AccessoryRarity.absolute: 0.00001,
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

