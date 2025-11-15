import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/models/cake_accessory.dart';
import 'package:fuba_clicker/app/models/rebirth_data.dart';
import 'package:fuba_clicker/app/providers/game_providers.dart';
import 'package:fuba_clicker/app/providers/rebirth_provider.dart';
import 'package:fuba_clicker/app/providers/accessory_provider.dart';

void main() {
  group('Multiplicadores Totais com Riverpod', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Multiplicador deve ser 1.0 quando não há rebirths nem itens', () {
      final multiplier = container.read(totalMultiplierProvider);
      
      expect(multiplier.toDouble(), equals(1.0));
    });

    test('Multiplicador deve mudar ao equipar um acessório', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).toList();
      
      if (perfectedAccessories.isEmpty) {
        return;
      }
      
      final accessory = perfectedAccessories.first;
      
      final multiplierBefore = container.read(totalMultiplierProvider);
      
      container.read(equippedAccessoriesProvider.notifier).state = [accessory.id];
      
      final multiplierAfter = container.read(totalMultiplierProvider);
      
      expect(multiplierAfter.toDouble(), greaterThan(multiplierBefore.toDouble()));
      expect(multiplierAfter.toDouble(), greaterThan(1.0));
    });

    test('Multiplicador deve aumentar com múltiplos acessórios equipados', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).take(3).toList();
      
      if (perfectedAccessories.length < 3) {
        return;
      }
      
      final accessory1 = perfectedAccessories[0];
      final accessory2 = perfectedAccessories[1];
      final accessory3 = perfectedAccessories[2];
      
      container.read(equippedAccessoriesProvider.notifier).state = [accessory1.id];
      final multiplier1 = container.read(totalMultiplierProvider).toDouble();
      
      container.read(equippedAccessoriesProvider.notifier).state = [
        accessory1.id,
        accessory2.id,
      ];
      final multiplier2 = container.read(totalMultiplierProvider).toDouble();
      
      container.read(equippedAccessoriesProvider.notifier).state = [
        accessory1.id,
        accessory2.id,
        accessory3.id,
      ];
      final multiplier3 = container.read(totalMultiplierProvider).toDouble();
      
      expect(multiplier2, greaterThan(multiplier1));
      expect(multiplier3, greaterThan(multiplier2));
      expect(multiplier3, greaterThan(1.0));
    });

    test('Multiplicador deve mudar ao fazer rebirth', () {
      final rebirthDataBefore = container.read(rebirthDataProvider);
      final multiplierBefore = container.read(totalMultiplierProvider);
      
      container.read(rebirthDataProvider.notifier).state = 
          rebirthDataBefore.copyWith(rebirthCount: 1);
      
      final multiplierAfter = container.read(totalMultiplierProvider);
      
      expect(multiplierAfter.toDouble(), greaterThan(multiplierBefore.toDouble()));
      expect(multiplierAfter.toDouble(), greaterThan(1.0));
    });

    test('Multiplicador deve aumentar com múltiplos rebirths', () {
      container.read(rebirthDataProvider.notifier).state = 
          const RebirthData(rebirthCount: 1);
      final multiplier1 = container.read(totalMultiplierProvider).toDouble();
      
      container.read(rebirthDataProvider.notifier).state = 
          const RebirthData(rebirthCount: 10);
      final multiplier10 = container.read(totalMultiplierProvider).toDouble();
      
      container.read(rebirthDataProvider.notifier).state = 
          const RebirthData(rebirthCount: 100);
      final multiplier100 = container.read(totalMultiplierProvider).toDouble();
      
      expect(multiplier10, greaterThan(multiplier1));
      expect(multiplier100, greaterThan(multiplier10));
      expect(multiplier100, lessThan(10.0));
    });

    test('Multiplicador deve combinar rebirths e acessórios corretamente', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).toList();
      
      if (perfectedAccessories.isEmpty) {
        return;
      }
      
      final accessory = perfectedAccessories.first;
      
      container.read(rebirthDataProvider.notifier).state = 
          const RebirthData(rebirthCount: 5);
      final multiplierRebirthOnly = container.read(totalMultiplierProvider).toDouble();
      
      container.read(equippedAccessoriesProvider.notifier).state = [accessory.id];
      final multiplierRebirthAndItem = container.read(totalMultiplierProvider).toDouble();
      
      expect(multiplierRebirthAndItem, greaterThan(multiplierRebirthOnly));
    });

    test('Multiplicador deve aplicar soft cap corretamente', () {
      container.read(rebirthDataProvider.notifier).state = 
          const RebirthData(rebirthCount: 200);
      
      final multiplier = container.read(totalMultiplierProvider).toDouble();
      
      expect(multiplier, lessThan(250.0));
    });

    test('Multiplicador deve aplicar hard cap corretamente', () {
      container.read(rebirthDataProvider.notifier).state = 
          const RebirthData(
            rebirthCount: 1000,
            ascensionCount: 100,
            transcendenceCount: 100,
          );
      
      final multiplier = container.read(totalMultiplierProvider).toDouble();
      
      expect(multiplier, lessThan(400.0));
    });

    test('Acessórios devem aumentar hard cap e multiplicador', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).take(5).toList();
      
      if (perfectedAccessories.isEmpty) {
        return;
      }
      
      container.read(rebirthDataProvider.notifier).state = 
          const RebirthData(
            rebirthCount: 1000,
            ascensionCount: 100,
            transcendenceCount: 100,
          );
      
      final multiplierWithoutAccessories = container.read(totalMultiplierProvider).toDouble();
      
      container.read(equippedAccessoriesProvider.notifier).state = 
          perfectedAccessories.map((acc) => acc.id).toList();
      
      final multiplierWithAccessories = container.read(totalMultiplierProvider).toDouble();
      
      // Acessórios devem SEMPRE aumentar o multiplicador
      expect(multiplierWithAccessories, greaterThan(multiplierWithoutAccessories));
    });

    test('Breakthrough de itens deve funcionar corretamente', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).toList();
      
      if (perfectedAccessories.isEmpty) {
        return;
      }
      
      final accessory = perfectedAccessories.first;
      final baseValue = accessory.productionMultiplier - 1.0;
      
      container.read(equippedAccessoriesProvider.notifier).state = [accessory.id];
      
      final accessoryMultiplier = container.read(accessoryMultiplierProvider);
      final accessoryValue = accessoryMultiplier.toDouble();
      final itemBreakthroughValue = (accessoryValue - 1.0) * 2.0;
      
      expect(itemBreakthroughValue, greaterThan(0.0));
      expect(itemBreakthroughValue, closeTo(baseValue * 2.0, 1.0));
    });

    test('Multiplicador deve reagir a mudanças em tempo real', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).take(2).toList();
      
      if (perfectedAccessories.length < 2) {
        return;
      }
      
      final accessory1 = perfectedAccessories[0];
      final accessory2 = perfectedAccessories[1];
      
      final multiplierBefore = container.read(totalMultiplierProvider).toDouble();
      
      container.read(equippedAccessoriesProvider.notifier).state = [accessory1.id];
      final multiplierAfter1 = container.read(totalMultiplierProvider).toDouble();
      
      container.read(equippedAccessoriesProvider.notifier).state = [
        accessory1.id,
        accessory2.id,
      ];
      final multiplierAfter2 = container.read(totalMultiplierProvider).toDouble();
      
      expect(multiplierAfter1, greaterThan(multiplierBefore));
      expect(multiplierAfter2, greaterThan(multiplierAfter1));
    });

    test('Sistema aditivo parcial de acessórios deve funcionar', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).take(5).toList();
      
      if (perfectedAccessories.length < 5) {
        return;
      }
      
      final accessory = perfectedAccessories.first;
      final baseValue = accessory.productionMultiplier - 1.0;
      
      double calculateBonus(List<String> equipped) {
        double totalBonus = 0.0;
        for (int i = 0; i < equipped.length; i++) {
          double positionMultiplier;
          if (i == 0) {
            positionMultiplier = 1.0;
          } else if (i == 1) {
            positionMultiplier = 0.5;
          } else if (i == 2) {
            positionMultiplier = 0.25;
          } else if (i == 3) {
            positionMultiplier = 0.15;
          } else {
            positionMultiplier = 0.10;
          }
          totalBonus += baseValue * positionMultiplier;
        }
        return totalBonus;
      }
      
      container.read(equippedAccessoriesProvider.notifier).state = [accessory.id];
      final multiplier1 = container.read(accessoryMultiplierProvider).toDouble();
      final expected1 = 1.0 + calculateBonus([accessory.id]);
      expect(multiplier1, closeTo(expected1, 0.1));
      
      container.read(equippedAccessoriesProvider.notifier).state = 
          perfectedAccessories.take(5).map((acc) => acc.id).toList();
      final multiplier5 = container.read(accessoryMultiplierProvider).toDouble();
      final expected5 = 1.0 + calculateBonus(
        perfectedAccessories.take(5).map((acc) => acc.id).toList(),
      );
      expect(multiplier5, closeTo(expected5, 0.1));
    });

    test('Multiplicador total deve usar calculateEffectiveMultiplier corretamente', () {
      container.read(rebirthDataProvider.notifier).state = 
          const RebirthData(rebirthCount: 10);
      
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).take(2).toList();
      
      if (perfectedAccessories.length < 2) {
        return;
      }
      
      container.read(equippedAccessoriesProvider.notifier).state = 
          perfectedAccessories.map((acc) => acc.id).toList();
      
      final rebirthMultiplier = container.read(rebirthMultiplierProvider).toDouble();
      final accessoryMultiplier = container.read(accessoryMultiplierProvider).toDouble();
      final totalMultiplier = container.read(totalMultiplierProvider).toDouble();
      
      expect(rebirthMultiplier, greaterThan(1.0));
      expect(accessoryMultiplier, greaterThan(1.0));
      
      const softCapBase = 100.0;
      const hardCapBase = 200.0;
      final equippedAccessories = container.read(equippedAccessoriesProvider);
      final accessoryCount = equippedAccessories.length;
      final capIncrease = (accessoryCount * 0.05).clamp(0.0, 0.5);
      final effectiveHardCap = hardCapBase * (1.0 + capIncrease);
      
      double baseMultiplierValue = rebirthMultiplier;
      double cappedBase;
      if (baseMultiplierValue <= softCapBase) {
        cappedBase = baseMultiplierValue;
      } else {
        final excess = baseMultiplierValue - softCapBase;
        final withSoftCap = softCapBase + excess * 0.2;
        cappedBase = (withSoftCap < effectiveHardCap) ? withSoftCap : effectiveHardCap;
      }
      
      final accessoryValue = accessoryMultiplier;
      final itemBreakthroughValue = (accessoryValue - 1.0) * 2.0;
      final expectedTotal = cappedBase + itemBreakthroughValue;
      
      expect(totalMultiplier, closeTo(expectedTotal, 1.0));
    });

    test('Multiplicador não deve quebrar com valores extremos', () {
      container.read(rebirthDataProvider.notifier).state = 
          const RebirthData(
            rebirthCount: 10000,
            ascensionCount: 1000,
            transcendenceCount: 1000,
          );
      
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).take(10).toList();
      
      if (perfectedAccessories.isNotEmpty) {
        container.read(equippedAccessoriesProvider.notifier).state = 
            perfectedAccessories.map((acc) => acc.id).toList();
      }
      
      final multiplier = container.read(totalMultiplierProvider);
      
      expect(multiplier.toDouble().isFinite, isTrue);
      expect(multiplier.toDouble(), greaterThan(0.0));
      expect(multiplier.toDouble(), lessThan(1000.0));
    });

    test('Remover acessório deve reduzir multiplicador', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).take(2).toList();
      
      if (perfectedAccessories.length < 2) {
        return;
      }
      
      final accessory1 = perfectedAccessories[0];
      final accessory2 = perfectedAccessories[1];
      
      container.read(equippedAccessoriesProvider.notifier).state = [
        accessory1.id,
        accessory2.id,
      ];
      final multiplierWithBoth = container.read(totalMultiplierProvider).toDouble();
      
      container.read(equippedAccessoriesProvider.notifier).state = [accessory1.id];
      final multiplierWithOne = container.read(totalMultiplierProvider).toDouble();
      
      expect(multiplierWithOne, lessThan(multiplierWithBoth));
    });
  });
}

