import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../models/rebirth_data.dart';
import '../models/fuba_generator.dart';
import 'game_providers.dart';
import 'accessory_provider.dart';
import 'save_provider.dart';

final rebirthDataProvider = StateProvider<RebirthData>((ref) {
  return const RebirthData();
});

final rebirthMultiplierProvider = Provider<double>((ref) {
  return ref.watch(rebirthDataProvider).getTotalMultiplier();
});

final oneTimeMultiplierProvider = Provider<double>((ref) {
  final rebirthData = ref.watch(rebirthDataProvider);
  return rebirthData.hasUsedOneTimeMultiplier ? 100.0 : 1.0;
});

final canRebirthProvider = Provider.family<bool, RebirthTier>((ref, tier) {
  final fuba = ref.watch(fubaProvider);
  final rebirthData = ref.watch(rebirthDataProvider);

  final requirement = switch (tier) {
    RebirthTier.rebirth => tier.getRequirement(rebirthData.rebirthCount),
    RebirthTier.ascension => tier.getRequirement(rebirthData.ascensionCount),
    RebirthTier.transcendence =>
      tier.getRequirement(rebirthData.transcendenceCount),
  };

  return fuba.compareTo(BigDecimal.parse(requirement.toString())) >= 0;
});

class RebirthNotifier {
  RebirthNotifier(this.ref);
  final Ref ref;

  void performRebirth(RebirthTier tier) {
    final currentData = ref.read(rebirthDataProvider);
    final canRebirth = ref.read(canRebirthProvider(tier));

    if (!canRebirth) return;

    final tokenReward = switch (tier) {
      RebirthTier.rebirth => tier.getTokenReward(currentData.rebirthCount),
      RebirthTier.ascension => tier.getTokenReward(currentData.ascensionCount),
      RebirthTier.transcendence =>
        tier.getTokenReward(currentData.transcendenceCount),
    };

    _resetProgress(tier);

    ref.read(rebirthDataProvider.notifier).state = switch (tier) {
      RebirthTier.rebirth => currentData.copyWith(
          rebirthCount: currentData.rebirthCount + 1,
          celestialTokens: currentData.celestialTokens + tokenReward,
        ),
      RebirthTier.ascension => currentData.copyWith(
          ascensionCount: currentData.ascensionCount + 1,
          celestialTokens: currentData.celestialTokens + tokenReward,
        ),
      RebirthTier.transcendence => currentData.copyWith(
          transcendenceCount: currentData.transcendenceCount + 1,
          celestialTokens: currentData.celestialTokens + tokenReward,
        ),
    };
  }

  void _resetProgress(RebirthTier tier) {
    ref.read(fubaProvider.notifier).state = BigDecimal.zero;
    ref.read(generatorsProvider.notifier).state =
        List.filled(availableGenerators.length, 0);

    switch (tier) {
      case RebirthTier.rebirth:
        break;
      case RebirthTier.ascension:
        ref.read(inventoryProvider.notifier).state = {};
        ref.read(equippedAccessoriesProvider.notifier).state = [];
        break;
      case RebirthTier.transcendence:
        ref.read(inventoryProvider.notifier).state = {};
        ref.read(equippedAccessoriesProvider.notifier).state = [];
        break;
    }
    
    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }

  void spendTokens(int amount) {
    final currentData = ref.read(rebirthDataProvider);
    if (currentData.celestialTokens >= amount) {
      ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
        celestialTokens: currentData.celestialTokens - amount,
      );
    }
  }
}

final rebirthNotifierProvider = Provider<RebirthNotifier>((ref) {
  return RebirthNotifier(ref);
});

