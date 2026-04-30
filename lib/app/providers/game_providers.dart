import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fuba_generator.dart';
import '../core/utils/efficient_number.dart';
import 'accessory_provider.dart';
import 'rebirth_provider.dart';
import 'rebirth_upgrade_provider.dart';
import 'achievement_provider.dart';
import 'potion_provider.dart';
import 'random_event_provider.dart';
import '../models/potion_effect.dart';


final fubaProvider = StateProvider<EfficientNumber>((ref) {
  return const EfficientNumber.zero();
});

final generatorsProvider = StateProvider<List<int>>((ref) {
  return List.filled(availableGenerators.length, 0);
});

double _generatorEvolutionMultiplier(int owned) {
  if (owned >= 1000) return 5.0;
  if (owned >= 500) return 2.5;
  if (owned >= 250) return 1.75;
  if (owned >= 100) return 1.25;
  return 1.0;
}

final baseAutoProductionProvider = Provider<EfficientNumber>((ref) {
  final generators = ref.watch(generatorsProvider);
  EfficientNumber totalProduction = const EfficientNumber.zero();

  for (int i = 0; i < availableGenerators.length; i++) {
    final owned = generators[i];
    var prod = availableGenerators[i].getProduction(owned);
    final evo = _generatorEvolutionMultiplier(owned);
    if (evo > 1.0) prod *= EfficientNumber.fromValues(evo, 0);
    totalProduction += prod;
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
  final eventMultiplier = ref.watch(eventProductionMultiplierProvider);

  final potionMultiplierEfficient = EfficientNumber.fromValues(potionMultiplier, 0);
  final eventMultiplierEfficient = EfficientNumber.fromValues(eventMultiplier, 0);

  final totalMultiplier = rebirthMultiplier *
      upgradeMultiplier *
      achievementMultiplier *
      oneTimeMultiplier *
      accessoryMultiplier *
      potionMultiplierEfficient *
      eventMultiplierEfficient;

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
