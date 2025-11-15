import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fuba_generator.dart';
import '../core/utils/efficient_number.dart';
import 'accessory_provider.dart';
import 'rebirth_provider.dart';
import 'rebirth_upgrade_provider.dart';
import 'achievement_provider.dart';
import 'potion_provider.dart';
import '../models/potion_effect.dart';


final fubaProvider = StateProvider<EfficientNumber>((ref) {
  return const EfficientNumber.zero();
});

final generatorsProvider = StateProvider<List<int>>((ref) {
  return List.filled(availableGenerators.length, 0);
});

final baseAutoProductionProvider = Provider<EfficientNumber>((ref) {
  final generators = ref.watch(generatorsProvider);
  EfficientNumber totalProduction = const EfficientNumber.zero();

  for (int i = 0; i < availableGenerators.length; i++) {
    totalProduction += availableGenerators[i].getProduction(generators[i]);
  }

  return totalProduction;
});

final potionProductionMultiplierProvider = Provider<double>((ref) {
  final activeEffects = ref.watch(activePotionEffectsProvider);
  final permanentMultiplier = ref.watch(permanentPotionMultiplierProvider);
  
  double multiplier = permanentMultiplier;
  
  for (final effect in activeEffects) {
    if (!effect.isExpired && effect.type == PotionEffectType.productionMultiplier) {
      multiplier *= effect.value;
    }
  }
  
  return multiplier;
});

final potionClickPowerProvider = Provider<double>((ref) {
  final activeEffects = ref.watch(activePotionEffectsProvider);
  
  double multiplier = 1.0;
  
  for (final effect in activeEffects) {
    if (!effect.isExpired && effect.type == PotionEffectType.clickPower) {
      multiplier *= effect.value;
    }
  }
  
  return multiplier;
});

EfficientNumber calculateEffectiveMultiplier(Ref ref) {
  final rebirthMultiplier = ref.watch(rebirthMultiplierProvider);
  final upgradeMultiplier = ref.watch(upgradeProductionMultiplierProvider);
  final achievementMultiplier = ref.watch(achievementMultiplierProvider);
  final oneTimeMultiplier = ref.watch(oneTimeMultiplierProvider);
  final accessoryMultiplier = ref.watch(accessoryMultiplierProvider);
  final potionMultiplier = ref.watch(potionProductionMultiplierProvider);
  
  final potionMultiplierEfficient = EfficientNumber.fromValues(potionMultiplier, 0);
  
  final totalMultiplier = rebirthMultiplier * 
      upgradeMultiplier * 
      achievementMultiplier * 
      oneTimeMultiplier *
      accessoryMultiplier *
      potionMultiplierEfficient;
  
  if (totalMultiplier.mantissa < 1.0) {
    return const EfficientNumber.one();
  }
  
  return totalMultiplier;
}

final autoProductionProvider = Provider<EfficientNumber>((ref) {
  final baseProduction = ref.watch(baseAutoProductionProvider);
  if (baseProduction.mantissa == 0) return const EfficientNumber.zero();

  final effectiveMultiplier = calculateEffectiveMultiplier(ref);
  return baseProduction * effectiveMultiplier;
});

final totalMultiplierProvider = Provider<EfficientNumber>((ref) {
  return calculateEffectiveMultiplier(ref);
});
