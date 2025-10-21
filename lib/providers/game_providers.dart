import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../models/fuba_generator.dart';
import 'accessory_provider.dart';
import 'rebirth_provider.dart';
import 'rebirth_upgrade_provider.dart';
import 'achievement_provider.dart';

BigDecimal _safeParseDouble(double value) {
  if (value.isInfinite || value.isNaN) {
    return BigDecimal.parse('1e100');
  }
  return BigDecimal.parse(value.toString());
}

final fubaProvider = StateProvider<BigDecimal>((ref) {
  return BigDecimal.zero;
});

final generatorsProvider = StateProvider<List<int>>((ref) {
  return List.filled(availableGenerators.length, 0);
});

final baseAutoProductionProvider = Provider<BigDecimal>((ref) {
  final generators = ref.watch(generatorsProvider);
  BigDecimal totalProduction = BigDecimal.zero;

  for (int i = 0; i < availableGenerators.length; i++) {
    totalProduction += availableGenerators[i].getProduction(generators[i]);
  }

  return totalProduction;
});

final autoProductionProvider = Provider<BigDecimal>((ref) {
  final baseProduction = ref.watch(baseAutoProductionProvider);
  if (baseProduction.compareTo(BigDecimal.zero) == 0) return BigDecimal.zero;

  BigDecimal totalProduction = baseProduction;

  final accessoryMultiplier = ref.watch(accessoryMultiplierProvider);
  totalProduction *= _safeParseDouble(accessoryMultiplier);

  final rebirthMultiplier = ref.watch(rebirthMultiplierProvider);
  totalProduction *= _safeParseDouble(rebirthMultiplier);

  final upgradeMultiplier = ref.watch(upgradeProductionMultiplierProvider);
  totalProduction *= _safeParseDouble(upgradeMultiplier);

  final achievementMultiplier = ref.watch(achievementMultiplierProvider);
  totalProduction *= _safeParseDouble(achievementMultiplier);

  final oneTimeMultiplier = ref.watch(oneTimeMultiplierProvider);
  totalProduction *= _safeParseDouble(oneTimeMultiplier);

  return totalProduction;
});

final totalMultiplierProvider = Provider<double>((ref) {
  double total = 1.0;
  total *= ref.watch(accessoryMultiplierProvider);
  total *= ref.watch(rebirthMultiplierProvider);
  total *= ref.watch(upgradeProductionMultiplierProvider);
  total *= ref.watch(achievementMultiplierProvider);
  total *= ref.watch(oneTimeMultiplierProvider);
  return total;
});
