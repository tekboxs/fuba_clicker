import 'package:flutter/material.dart';
import 'cake_accessory.dart';

enum CakeVisualTier {
  normal,
  enhanced,
  rare,
  epic,
  legendary,
  mythical,
  cosmic,
}

extension CakeVisualTierExtension on CakeVisualTier {
  Color get primaryColor {
    switch (this) {
      case CakeVisualTier.normal:
        return Colors.orange;
      case CakeVisualTier.enhanced:
        return Colors.green;
      case CakeVisualTier.rare:
        return Colors.blue;
      case CakeVisualTier.epic:
        return Colors.purple;
      case CakeVisualTier.legendary:
        return Colors.amber;
      case CakeVisualTier.mythical:
        return Colors.pink;
      case CakeVisualTier.cosmic:
        return Colors.cyan;
    }
  }

  Color get secondaryColor {
    switch (this) {
      case CakeVisualTier.normal:
        return Colors.deepOrange;
      case CakeVisualTier.enhanced:
        return Colors.lightGreen;
      case CakeVisualTier.rare:
        return Colors.lightBlue;
      case CakeVisualTier.epic:
        return Colors.deepPurple;
      case CakeVisualTier.legendary:
        return Colors.orange;
      case CakeVisualTier.mythical:
        return Colors.pinkAccent;
      case CakeVisualTier.cosmic:
        return Colors.cyanAccent;
    }
  }

  double get glowIntensity {
    switch (this) {
      case CakeVisualTier.normal:
        return 0.0;
      case CakeVisualTier.enhanced:
        return 5.0;
      case CakeVisualTier.rare:
        return 10.0;
      case CakeVisualTier.epic:
        return 15.0;
      case CakeVisualTier.legendary:
        return 20.0;
      case CakeVisualTier.mythical:
        return 30.0;
      case CakeVisualTier.cosmic:
        return 40.0;
    }
  }

  double get scaleBonus {
    switch (this) {
      case CakeVisualTier.normal:
        return 1.0;
      case CakeVisualTier.enhanced:
        return 1.02;
      case CakeVisualTier.rare:
        return 1.04;
      case CakeVisualTier.epic:
        return 1.06;
      case CakeVisualTier.legendary:
        return 1.08;
      case CakeVisualTier.mythical:
        return 1.10;
      case CakeVisualTier.cosmic:
        return 1.12;
    }
  }

  int get pulseSpeed {
    switch (this) {
      case CakeVisualTier.normal:
        return 0;
      case CakeVisualTier.enhanced:
        return 3000;
      case CakeVisualTier.rare:
        return 2500;
      case CakeVisualTier.epic:
        return 2000;
      case CakeVisualTier.legendary:
        return 1500;
      case CakeVisualTier.mythical:
        return 1000;
      case CakeVisualTier.cosmic:
        return 800;
    }
  }

  static CakeVisualTier fromAccessories(List<CakeAccessory> accessories) {
    if (accessories.isEmpty) return CakeVisualTier.normal;

    final rarityScores = <AccessoryRarity, int>{};
    for (final acc in accessories) {
      rarityScores[acc.rarity] = (rarityScores[acc.rarity] ?? 0) + 1;
    }

    AccessoryRarity? dominantRarity;
    int maxCount = 0;
    for (final entry in rarityScores.entries) {
      if (entry.value > maxCount ||
          (entry.value == maxCount &&
              entry.key.value > (dominantRarity?.value ?? 0))) {
        dominantRarity = entry.key;
        maxCount = entry.value;
      }
    }

    if (dominantRarity == null) return CakeVisualTier.normal;

    if (accessories.length >= 6) {
      if (dominantRarity == AccessoryRarity.mythical) {
        return CakeVisualTier.cosmic;
      }
    }

    switch (dominantRarity) {
      case AccessoryRarity.common:
        return CakeVisualTier.enhanced;
      case AccessoryRarity.uncommon:
        return CakeVisualTier.enhanced;
      case AccessoryRarity.rare:
        return CakeVisualTier.rare;
      case AccessoryRarity.epic:
        return CakeVisualTier.epic;
      case AccessoryRarity.legendary:
        return CakeVisualTier.legendary;
      case AccessoryRarity.mythical:
        return CakeVisualTier.mythical;
    }
  }
}

