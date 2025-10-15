import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fuba_generator.dart';
import 'accessory_provider.dart';
import 'rebirth_provider.dart';
import 'rebirth_upgrade_provider.dart';
import 'achievement_provider.dart';

final fubaProvider = StateProvider<double>((ref) {
  return 0;
});

final generatorsProvider = StateProvider<List<int>>((ref) {
  return List.filled(availableGenerators.length, 0);
});

final baseAutoProductionProvider = Provider<double>((ref) {
  final generators = ref.watch(generatorsProvider);
  double totalProduction = 0;

  for (int i = 0; i < availableGenerators.length; i++) {
    totalProduction += availableGenerators[i].getProduction(generators[i]);
  }

  return totalProduction;
});

final autoProductionProvider = Provider<double>((ref) {
  final baseProduction = ref.watch(baseAutoProductionProvider);
  if (baseProduction == 0) return 0;

  double totalProduction = baseProduction;

  final accessoryMultiplier = ref.watch(accessoryMultiplierProvider);
  totalProduction *= accessoryMultiplier;

  final rebirthMultiplier = ref.watch(rebirthMultiplierProvider);
  totalProduction *= rebirthMultiplier;

  final upgradeMultiplier = ref.watch(upgradeProductionMultiplierProvider);
  totalProduction *= upgradeMultiplier;

  final achievementMultiplier = ref.watch(achievementMultiplierProvider);
  totalProduction *= achievementMultiplier;

  return double.parse(totalProduction.toStringAsFixed(1));
});

final totalMultiplierProvider = Provider<double>((ref) {
  double total = 1.0;
  total *= ref.watch(accessoryMultiplierProvider);
  total *= ref.watch(rebirthMultiplierProvider);
  total *= ref.watch(upgradeProductionMultiplierProvider);
  total *= ref.watch(achievementMultiplierProvider);
  return total;
});
