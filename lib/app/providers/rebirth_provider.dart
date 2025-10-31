import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/efficient_number.dart';
import '../models/rebirth_data.dart';
import '../models/fuba_generator.dart';
import 'game_providers.dart';
import 'accessory_provider.dart';
import 'save_provider.dart';
import 'rebirth_upgrade_provider.dart';
 
final rebirthDataProvider = StateProvider<RebirthData>((ref) {
  return const RebirthData();
});

final rebirthMultiplierProvider = Provider<EfficientNumber>((ref) {
  return ref.watch(rebirthDataProvider).getTotalMultiplier();
});


final oneTimeMultiplierProvider = Provider<EfficientNumber>((ref) {
  final rebirthData = ref.watch(rebirthDataProvider);
  if (rebirthData.usedCoupons.contains('fubaadm')) {
    return EfficientNumber.parse('99999');
  }
  return rebirthData.hasUsedOneTimeMultiplier ? EfficientNumber.parse('100') : const EfficientNumber.one();
});

final canRebirthProvider = Provider.family<bool, RebirthTier>((ref, tier) {
  final fuba = ref.watch(fubaProvider);
  final rebirthData = ref.watch(rebirthDataProvider);

  final double requirement;
  switch (tier) {
    case RebirthTier.rebirth:
      requirement = tier.getRequirement(rebirthData.rebirthCount);
      break;
    case RebirthTier.ascension:
      requirement = tier.getRequirement(rebirthData.ascensionCount);
      break;
    case RebirthTier.transcendence:
      requirement = tier.getRequirement(rebirthData.transcendenceCount);
      break;
  }

  if (!requirement.isFinite) {
    return false;
  }
  return fuba.compareTo(EfficientNumber.fromDouble(requirement)) >= 0;
});

class RebirthNotifier {
  RebirthNotifier(this.ref);
  final Ref ref;

  void performRebirth(RebirthTier tier) {
    final currentData = ref.read(rebirthDataProvider);
    final canRebirth = ref.read(canRebirthProvider(tier));

    if (!canRebirth) return;

    final double tokenReward;
    switch (tier) {
      case RebirthTier.rebirth:
        tokenReward = tier.getTokenReward(currentData.rebirthCount);
        break;
      case RebirthTier.ascension:
        tokenReward = tier.getTokenReward(currentData.ascensionCount);
        break;
      case RebirthTier.transcendence:
        tokenReward = tier.getTokenReward(currentData.transcendenceCount);
        break;
    }

    _resetProgress(tier);

    switch (tier) {
      case RebirthTier.rebirth:
        ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
          rebirthCount: currentData.rebirthCount + 1,
          celestialTokens: currentData.celestialTokens + tokenReward,
        );
        break;
      case RebirthTier.ascension:
        ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
          ascensionCount: currentData.ascensionCount + 1,
          celestialTokens: currentData.celestialTokens + tokenReward,
        );
        break;
      case RebirthTier.transcendence:
        ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
          transcendenceCount: currentData.transcendenceCount + 1,
          celestialTokens: currentData.celestialTokens + tokenReward,
        );
        break;
    }
  }

  void _resetProgress(RebirthTier tier) {
    ref.read(fubaProvider.notifier).state = const EfficientNumber.zero();
    ref.read(generatorsProvider.notifier).state =
        List.filled(availableGenerators.length, 0);

    final upgradeNotifier = ref.read(upgradeNotifierProvider);
    final shouldKeepItems = upgradeNotifier.shouldKeepItems();

    switch (tier) {
      case RebirthTier.rebirth:
        break;
      case RebirthTier.ascension:
        if (!shouldKeepItems) {
          ref.read(inventoryProvider.notifier).state = {};
          ref.read(equippedAccessoriesProvider.notifier).state = [];
        }
        break;
      case RebirthTier.transcendence:
        if (!shouldKeepItems) {
          ref.read(inventoryProvider.notifier).state = {};
          ref.read(equippedAccessoriesProvider.notifier).state = [];
        }
        break;
    }
    
    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }

  void spendTokens(double amount) {
    final currentData = ref.read(rebirthDataProvider);
    if (currentData.celestialTokens >= amount) {
      ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
        celestialTokens: currentData.celestialTokens - amount,
      );
    }
  }

  void addDebugRebirth(RebirthTier tier, int amount) {
    final currentData = ref.read(rebirthDataProvider);

    switch (tier) {
      case RebirthTier.rebirth:
        ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
          rebirthCount: currentData.rebirthCount + amount,
        );
        break;
      case RebirthTier.ascension:
        ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
          ascensionCount: currentData.ascensionCount + amount,
        );
        break;
      case RebirthTier.transcendence:
        ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
          transcendenceCount: currentData.transcendenceCount + amount,
        );
        break;
    }

    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }


  void performMultipleRebirth(RebirthTier tier, int count) {
    if (count <= 0) return;

    final currentData = ref.read(rebirthDataProvider);
    final fuba = ref.read(fubaProvider);

    final int currentTierCount;
    switch (tier) {
      case RebirthTier.rebirth:
        currentTierCount = currentData.rebirthCount;
        break;
      case RebirthTier.ascension:
        currentTierCount = currentData.ascensionCount;
        break;
      case RebirthTier.transcendence:
        currentTierCount = currentData.transcendenceCount;
        break;
    }

    // Limites máximos por operação
    const maxRebirths = 50;
    const maxAscensions = 10;
    const maxTranscendences = 5;

    int maxAllowed;
    switch (tier) {
      case RebirthTier.rebirth:
        maxAllowed = maxRebirths;
        break;
      case RebirthTier.ascension:
        maxAllowed = maxAscensions;
        break;
      case RebirthTier.transcendence:
        maxAllowed = maxTranscendences;
        break;
    }

    final int maxByResources = calculateMaxOperations(tier, fuba, currentData);
    final int actualCount = [count, maxAllowed, maxByResources].reduce((a, b) => a < b ? a : b);

    if (actualCount == 0) return;

    double totalTokenReward = 0.0;
    for (int i = 0; i < actualCount; i++) {
      totalTokenReward += tier.getTokenReward(currentTierCount + i);
    }

    _resetProgress(tier);

    switch (tier) {
      case RebirthTier.rebirth:
        ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
          rebirthCount: currentData.rebirthCount + actualCount,
          celestialTokens: currentData.celestialTokens + totalTokenReward,
        );
        break;
      case RebirthTier.ascension:
        ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
          ascensionCount: currentData.ascensionCount + actualCount,
          celestialTokens: currentData.celestialTokens + totalTokenReward,
        );
        break;
      case RebirthTier.transcendence:
        ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
          transcendenceCount: currentData.transcendenceCount + actualCount,
          celestialTokens: currentData.celestialTokens + totalTokenReward,
        );
        break;
    }
  }
}

final rebirthNotifierProvider = Provider<RebirthNotifier>((ref) {
  return RebirthNotifier(ref);
});

int calculateMaxOperations(RebirthTier tier, EfficientNumber fuba, RebirthData rebirthData) {
  int count = 0;

  final int currentCount;
  switch (tier) {
    case RebirthTier.rebirth:
      currentCount = rebirthData.rebirthCount;
      break;
    case RebirthTier.ascension:
      currentCount = rebirthData.ascensionCount;
      break;
    case RebirthTier.transcendence:
      currentCount = rebirthData.transcendenceCount;
      break;
  }
  
  // Limites máximos seguros para evitar travamentos
  const maxRebirths = 50;
  const maxAscensions = 10;
  const maxTranscendences = 5;
  
  // Determina limite baseado no tier
  int maxAllowed;
  switch (tier) {
    case RebirthTier.rebirth:
      maxAllowed = maxRebirths;
      break;
    case RebirthTier.ascension:
      maxAllowed = maxAscensions;
      break;
    case RebirthTier.transcendence:
      maxAllowed = maxTranscendences;
      break;
  }
  
  // Rebirth e Transcendence resetam fubá; bulk deve ser no máximo 1
  // if (tier == RebirthTier.rebirth || tier == RebirthTier.transcendence) {
  //   final requirement = tier.getRequirement(currentCount);
  //   if (!requirement.isFinite || requirement <= 0) return 0;
  //   final requirementEff = EfficientNumber.fromDouble(requirement);
  //   return fuba.compareTo(requirementEff) >= 0 ? 1 : 0;
  // }

  // Ascension: pode usar a verificação incremental padrão
  final maxIterations = maxAllowed;
  for (int i = 0; i < maxIterations; i++) {
    final requirement = tier.getRequirement(currentCount + count);
    if (requirement.isInfinite || requirement.isNaN || requirement <= 0) {
      break;
    }
    final requirementEff = EfficientNumber.fromDouble(requirement);
    if (fuba.compareTo(requirementEff) >= 0) {
      count++;
    } else {
      break;
    }
  }
  
  return count;
}

/// Calcula multiplicador progressivo para compras múltiplas
// removido: multiplicador progressivo não é usado no cálculo de múltiplos


