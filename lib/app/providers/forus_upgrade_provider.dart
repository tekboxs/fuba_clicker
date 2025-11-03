import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/forus_upgrade.dart';
import 'rebirth_provider.dart';
import 'save_provider.dart';

final forusUpgradesOwnedProvider = StateProvider<Set<String>>((ref) {
  return {};
});

class ForusUpgradeNotifier {
  ForusUpgradeNotifier(this.ref);
  final Ref ref;

  bool hasUpgrade(String upgradeId) {
    return ref.read(forusUpgradesOwnedProvider).contains(upgradeId);
  }

  bool canPurchase(ForusUpgrade upgrade) {
    final ownedUpgrades = ref.read(forusUpgradesOwnedProvider);
    if (ownedUpgrades.contains(upgrade.id) && upgrade.isOneTime) {
      return false;
    }

    final rebirthData = ref.read(rebirthDataProvider);
    return rebirthData.forus >= upgrade.forusCost;
  }

  void purchaseUpgrade(ForusUpgrade upgrade) {
    if (!canPurchase(upgrade)) return;

    final rebirthData = ref.read(rebirthDataProvider);
    if (rebirthData.forus < upgrade.forusCost) return;

    ref.read(rebirthDataProvider.notifier).state =
        rebirthData.copyWith(forus: rebirthData.forus - upgrade.forusCost);

    final owned = ref.read(forusUpgradesOwnedProvider);
    final newOwned = Set<String>.from(owned);
    newOwned.add(upgrade.id);
    ref.read(forusUpgradesOwnedProvider.notifier).state = newOwned;

    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }
}

final forusUpgradeNotifierProvider = Provider<ForusUpgradeNotifier>((ref) {
  return ForusUpgradeNotifier(ref);
});

