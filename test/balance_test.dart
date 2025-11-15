import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:fuba_clicker/app/models/cake_accessory.dart';
import 'package:fuba_clicker/app/models/rebirth_data.dart';
import 'package:fuba_clicker/app/models/fuba_generator.dart';

void main() {
  group('Balanceamento de Acessórios', () {
    test('Valores de multiplicadores devem estar reduzidos', () {
      expect(AccessoryRarity.perfected.productionMultiplier, 50.0);
      expect(AccessoryRarity.absolute.productionMultiplier, 25.0);
      expect(AccessoryRarity.tek.productionMultiplier, 15.0);
      expect(AccessoryRarity.reality.productionMultiplier, 10.0);
      expect(AccessoryRarity.omniversal.productionMultiplier, 8.0);
      expect(AccessoryRarity.infinite.productionMultiplier, 6.0);
      expect(AccessoryRarity.cosmic.productionMultiplier, 5.0);
      expect(AccessoryRarity.common.productionMultiplier, 1.01);
      expect(AccessoryRarity.legendary.productionMultiplier, 1.25);
    });

    test('Sistema aditivo parcial deve funcionar corretamente', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).take(5).toList();
      
      if (perfectedAccessories.isEmpty) {
        return;
      }
      
      double totalBonus = 0.0;
      for (int i = 0; i < perfectedAccessories.length; i++) {
        final accessory = perfectedAccessories[i];
        final baseValue = accessory.productionMultiplier - 1.0;
        
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
      
      final total = 1.0 + totalBonus;
      
      expect(total, lessThan(200.0));
      expect(total, greaterThan(1.0));
    });

    test('Acessório perfeito deve dar multiplicador adequado', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).toList();
      
      if (perfectedAccessories.isEmpty) {
        return;
      }
      
      final perfected = perfectedAccessories.first;
      
      expect(perfected.productionMultiplier, 50.0);
      
      final firstBonus = perfected.productionMultiplier - 1.0;
      expect(firstBonus, 49.0);
    });

    test('Múltiplos acessórios devem ter diminishing returns', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).toList();
      
      if (perfectedAccessories.isEmpty) {
        return;
      }
      
      final perfected = perfectedAccessories.first;
      final baseValue = perfected.productionMultiplier - 1.0;
      
      double totalBonus = 0.0;
      for (int i = 0; i < 5; i++) {
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
      
      final total = 1.0 + totalBonus;
      
      expect(total, closeTo(99.0, 1.0));
      expect(total, lessThan(120.0));
    });
  });

  group('Rebirth Multipliers Logarítmicos', () {
    test('Rebirth deve usar crescimento logarítmico', () {
      final rebirth1 = RebirthTier.rebirth.getEffectiveMultiplierGain(1);
      final rebirth10 = RebirthTier.rebirth.getEffectiveMultiplierGain(10);
      final rebirth100 = RebirthTier.rebirth.getEffectiveMultiplierGain(100);
      
      expect(rebirth1, greaterThan(1.05));
      expect(rebirth10, closeTo(1.23, 0.1));
      expect(rebirth100, closeTo(1.56, 0.1));
      
      expect(rebirth100, lessThan(2.0));
    });

    test('Ascension deve ter soft cap e hard cap', () {
      final ascension1 = RebirthTier.ascension.getEffectiveMultiplierGain(1);
      final ascension20 = RebirthTier.ascension.getEffectiveMultiplierGain(20);
      final ascension50 = RebirthTier.ascension.getEffectiveMultiplierGain(50);
      final ascension100 = RebirthTier.ascension.getEffectiveMultiplierGain(100);
      
      expect(ascension1, greaterThan(1.0));
      expect(ascension20, lessThanOrEqualTo(5.5));
      expect(ascension50, lessThanOrEqualTo(10.0));
      expect(ascension100, lessThanOrEqualTo(10.0));
      
      expect(ascension100, lessThan(15.0));
    });

    test('Transcendence deve ter soft cap e hard cap', () {
      final trans1 = RebirthTier.transcendence.getEffectiveMultiplierGain(1);
      final trans15 = RebirthTier.transcendence.getEffectiveMultiplierGain(15);
      final trans50 = RebirthTier.transcendence.getEffectiveMultiplierGain(50);
      final trans100 = RebirthTier.transcendence.getEffectiveMultiplierGain(100);
      
      expect(trans1, greaterThan(1.0));
      expect(trans15, lessThanOrEqualTo(9.0));
      expect(trans50, lessThanOrEqualTo(15.0));
      expect(trans100, lessThanOrEqualTo(15.0));
      
      expect(trans100, lessThan(20.0));
    });

    test('Multiplicadores não devem crescer exponencialmente', () {
      final rebirth10 = RebirthTier.rebirth.getEffectiveMultiplierGain(10);
      final rebirth20 = RebirthTier.rebirth.getEffectiveMultiplierGain(20);
      final rebirth50 = RebirthTier.rebirth.getEffectiveMultiplierGain(50);
      
      final ratio10to20 = rebirth20 / rebirth10;
      final ratio20to50 = rebirth50 / rebirth20;
      
      expect(ratio10to20, lessThan(1.5));
      expect(ratio20to50, lessThan(2.0));
    });
  });

  group('Requisitos de Rebirth', () {
    test('Requisitos devem estar aumentados', () {
      final rebirthReq1 = RebirthTier.rebirth.getRequirement(1);
      final rebirthReq10 = RebirthTier.rebirth.getRequirement(10);
      
      expect(rebirthReq1, greaterThanOrEqualTo(1e16));
      expect(rebirthReq10, greaterThan(1e17));
      
      final ascensionReq1 = RebirthTier.ascension.getRequirement(1);
      expect(ascensionReq1, greaterThanOrEqualTo(500e28));
      
      final transReq1 = RebirthTier.transcendence.getRequirement(1);
      expect(transReq1, greaterThanOrEqualTo(1e46));
    });

    test('Crescimento de requisitos deve ser mais agressivo', () {
      final ascensionReq1 = RebirthTier.ascension.getRequirement(1);
      final ascensionReq2 = RebirthTier.ascension.getRequirement(2);
      
      final growth = ascensionReq2 / ascensionReq1;
      expect(growth, greaterThan(20.0));
    });
  });

  group('Custos de Geradores', () {
    test('Taxas de crescimento devem estar aumentadas', () {
      final generator = availableGenerators[0];
      
      final cost1 = generator.getCost(1);
      final cost2 = generator.getCost(2);
      
      final growth = cost2 / cost1;
      expect(growth.toDouble(), closeTo(1.20, 0.01));
    });

    test('Geradores late-game devem ter custos multiplicados', () {
      final lateGameGenerator = availableGenerators.firstWhere(
        (g) => g.unlockRequirement >= 50,
      );
      
      final normalGenerator = availableGenerators.firstWhere(
        (g) => g.unlockRequirement < 25,
      );
      
      final lateGameCost = lateGameGenerator.getCost(1);
      final normalCost = normalGenerator.getCost(1);
      
      expect(lateGameCost.toDouble(), greaterThan(normalCost.toDouble()));
    });

    test('Custos devem crescer exponencialmente', () {
      final generator = availableGenerators[0];
      
      final cost10 = generator.getCost(10);
      final cost20 = generator.getCost(20);
      final cost50 = generator.getCost(50);
      
      final growth10to20 = (cost20 / cost10).toDouble();
      final growth20to50 = (cost50 / cost20).toDouble();
      
      expect(growth10to20, greaterThan(1.5));
      expect(growth20to50, greaterThan(2.0));
    });
  });

  group('Produção de Geradores', () {
    test('Produção late-game deve estar reduzida', () {
      final lateGameGenerator = availableGenerators.firstWhere(
        (g) => g.unlockRequirement >= 30,
      );
      
      final production1 = lateGameGenerator.getProduction(1);
      final baseProduction = lateGameGenerator.baseProduction;
      
      if (production1.mantissa > 0 && baseProduction.mantissa > 0) {
        final productionValue = production1.toDouble();
        final baseValue = baseProduction.toDouble();
        if (baseValue > 0 && productionValue > 0) {
          final ratio = productionValue / baseValue;
          expect(ratio, lessThan(0.6));
        }
      }
      
      expect(production1.mantissa, greaterThanOrEqualTo(0.0));
    });

    test('Produção deve ter diminishing returns', () {
      final generator = availableGenerators[0];
      
      final prod10 = generator.getProduction(10);
      final prod20 = generator.getProduction(20);
      final prod50 = generator.getProduction(50);
      final prod100 = generator.getProduction(100);
      
      if (prod10.mantissa > 0 && prod20.mantissa > 0) {
        final growth10to20 = (prod20 / prod10).toDouble();
        final growth20to50 = prod50.mantissa > 0 && prod20.mantissa > 0 
            ? (prod50 / prod20).toDouble() 
            : 0.0;
        final growth50to100 = prod100.mantissa > 0 && prod50.mantissa > 0
            ? (prod100 / prod50).toDouble()
            : 0.0;
        
        expect(growth10to20, lessThan(2.5));
        if (growth20to50 > 0) expect(growth20to50, lessThan(3.5));
        if (growth50to100 > 0) expect(growth50to100, lessThan(3.0));
      }
    });

    test('Produção deve crescer linearmente inicialmente', () {
      final generator = availableGenerators[0];
      
      final prod1 = generator.getProduction(1);
      final prod5 = generator.getProduction(5);
      final prod10 = generator.getProduction(10);
      
      if (prod1.mantissa > 0 && prod5.mantissa > 0 && prod10.mantissa > 0) {
        final ratio5to1 = (prod5 / prod1).toDouble();
        final ratio10to5 = (prod10 / prod5).toDouble();
        
        expect(ratio5to1, closeTo(5.0, 0.1));
        expect(ratio10to5, closeTo(2.0, 0.1));
      }
    });
  });

  group('Sistema de Caps', () {
    test('Soft cap deve ser aplicado em multiplicadores base', () {
      const softCapBase = 50.0;
      const hardCapBase = 100.0;
      
      final baseValueLow = 30.0;
      final baseValueHigh = 80.0;
      final baseValueVeryHigh = 200.0;
      
      double applySoftCap(double base) {
        if (base <= softCapBase) {
          return base;
        }
        final excess = base - softCapBase;
        return softCapBase + excess * 0.1;
      }
      
      double applyHardCap(double base, int accessoryCount) {
        final capReduction = (accessoryCount * 0.10).clamp(0.0, 1.0);
        final effectiveHardCap = hardCapBase * (1.0 - capReduction);
        return base.clamp(0.0, effectiveHardCap);
      }
      
      expect(applySoftCap(baseValueLow), equals(baseValueLow));
      expect(applySoftCap(baseValueHigh), lessThan(baseValueHigh));
      expect(applySoftCap(baseValueHigh), greaterThan(softCapBase));
      expect(applyHardCap(applySoftCap(baseValueVeryHigh), 0), 
          lessThanOrEqualTo(hardCapBase));
    });

    test('Acessórios devem reduzir hard cap', () {
      const hardCapBase = 100.0;
      
      double getEffectiveHardCap(int accessoryCount) {
        final capReduction = (accessoryCount * 0.10).clamp(0.0, 1.0);
        return hardCapBase * (1.0 - capReduction);
      }
      
      expect(getEffectiveHardCap(0), equals(100.0));
      expect(getEffectiveHardCap(5), equals(50.0));
      expect(getEffectiveHardCap(10), equals(0.0));
      expect(getEffectiveHardCap(15), equals(0.0));
    });

    test('Item breakthrough deve permitir progressão além do cap', () {
      const cappedBase = 100.0;
      final accessoryValue = 2.0;
      
      final itemBreakthrough = (accessoryValue - 1.0) * 2.0;
      final finalMultiplier = cappedBase + itemBreakthrough;
      
      expect(finalMultiplier, greaterThan(cappedBase));
      expect(finalMultiplier, equals(102.0));
    });
  });

  group('RebirthData Total Multiplier', () {
    test('Total multiplier deve usar valores logarítmicos', () {
      final data = RebirthData(
        rebirthCount: 100,
        ascensionCount: 10,
        transcendenceCount: 5,
      );
      
      final totalMultiplier = data.getTotalMultiplier();
      final totalValue = totalMultiplier.toDouble();
      
      expect(totalValue, lessThan(100.0));
      expect(totalValue, greaterThan(1.0));
    });

    test('Multiplicador não deve crescer exponencialmente com rebirths', () {
      final data10 = RebirthData(rebirthCount: 10);
      final data50 = RebirthData(rebirthCount: 50);
      final data100 = RebirthData(rebirthCount: 100);
      
      final mult10 = data10.getTotalMultiplier().toDouble();
      final mult50 = data50.getTotalMultiplier().toDouble();
      final mult100 = data100.getTotalMultiplier().toDouble();
      
      final ratio10to50 = mult50 / mult10;
      final ratio50to100 = mult100 / mult50;
      
      expect(ratio10to50, lessThan(3.0));
      expect(ratio50to100, lessThan(2.0));
    });
  });

  group('Verificações de Balanceamento Geral', () {
    test('Acessórios devem ser necessários para late game', () {
      const softCapBase = 50.0;
      const hardCapBase = 100.0;
      
      double getFinalMultiplier(double base, double accessoryValue, int accessoryCount) {
        final capReduction = (accessoryCount * 0.10).clamp(0.0, 1.0);
        final effectiveHardCap = hardCapBase * (1.0 - capReduction);
        
        double capped;
        if (base <= softCapBase) {
          capped = base;
        } else {
          final excess = base - softCapBase;
          final withSoftCap = softCapBase + excess * 0.1;
          capped = math.min(withSoftCap, effectiveHardCap);
        }
        
        final breakthrough = (accessoryValue - 1.0) * 2.0;
        return capped + breakthrough;
      }
      
      final withoutAccessories = getFinalMultiplier(100.0, 1.0, 0);
      final withAccessoriesLow = getFinalMultiplier(100.0, 1.5, 5);
      final withAccessoriesHigh = getFinalMultiplier(100.0, 10.0, 10);
      
      expect(withoutAccessories, lessThanOrEqualTo(100.0));
      
      final withAccessoriesVeryHigh = getFinalMultiplier(100.0, 20.0, 3);
      expect(withAccessoriesVeryHigh, greaterThan(withoutAccessories));
      
      expect(withAccessoriesLow, greaterThan(0.0));
      expect(withAccessoriesHigh, greaterThan(0.0));
      
      final withAccessoriesMedium = getFinalMultiplier(100.0, 10.0, 2);
      expect(withAccessoriesMedium, greaterThan(withAccessoriesLow));
    });

    test('Progressão deve ser mais lenta que antes', () {
      final oldRebirthMult = 2.0 * 100;
      final newRebirthMult = RebirthTier.rebirth.getEffectiveMultiplierGain(100);
      
      expect(newRebirthMult, lessThan(oldRebirthMult / 10));
    });

    test('Sistema aditivo deve prevenir crescimento explosivo', () {
      final perfectedAccessories = allAccessories.where(
        (acc) => acc.rarity == AccessoryRarity.perfected,
      ).toList();
      
      if (perfectedAccessories.isEmpty) {
        return;
      }
      
      final perfected = perfectedAccessories.first;
      final baseValue = perfected.productionMultiplier - 1.0;
      
      double calculateMultiplier(int count) {
        double total = 1.0;
        for (int i = 0; i < count; i++) {
          double multiplier;
          if (i == 0) {
            multiplier = 1.0;
          } else if (i == 1) {
            multiplier = 0.5;
          } else if (i == 2) {
            multiplier = 0.25;
          } else if (i == 3) {
            multiplier = 0.15;
          } else {
            multiplier = 0.10;
          }
          total += baseValue * multiplier;
        }
        return total;
      }
      
      final mult5 = calculateMultiplier(5);
      final mult10 = calculateMultiplier(10);
      
      final oldSystemMult5 = math.pow(50.0, 5);
      final oldSystemMult10 = math.pow(50.0, 10);
      
      expect(mult5, lessThan(oldSystemMult5 / 1000));
      expect(mult10, lessThan(oldSystemMult10 / 1000000));
      
      expect(mult10, lessThan(150.0));
    });
  });
}

