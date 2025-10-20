import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../services/save_service.dart';
import '../models/fuba_generator.dart';
import 'game_providers.dart';
import 'accessory_provider.dart';
import 'rebirth_provider.dart';
import 'achievement_provider.dart';
import 'rebirth_upgrade_provider.dart';
import 'secret_provider.dart';

class SaveNotifier extends StateNotifier<bool> {
  SaveNotifier(this.ref) : super(false) {
    _startPeriodicSave();
  }

  final Ref ref;
  final SaveService _saveService = SaveService();
  Timer? _periodicTimer;

  void _startPeriodicSave() {
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => saveGame(),
    );
  }

  Future<void> saveGame() async {
    try {
      state = true;
      final fuba = ref.read(fubaProvider);
      final generators = ref.read(generatorsProvider);
      final inventory = ref.read(inventoryProvider);
      final equipped = ref.read(equippedAccessoriesProvider);
      final rebirthData = ref.read(rebirthDataProvider);
      final achievements = ref.read(unlockedAchievementsProvider);
      final achievementStats = ref.read(achievementStatsProvider);
      final upgrades = ref.read(upgradesLevelProvider);
      final secrets = ref.read(unlockedSecretsProvider);

      await _saveService.saveGame(
        fuba: fuba.toDouble(),
        generators: generators,
        inventory: inventory,
        equipped: equipped,
        rebirthData: rebirthData,
        achievements: achievements,
        achievementStats: achievementStats,
        upgrades: upgrades,
        secrets: secrets,
      );
      state = false;
    } catch (e) {
      state = false;
    }
  }

  Future<void> saveImmediate() async {
    await saveGame();
  }

  Future<void> loadGame() async {
    try {
      final data = await _saveService.loadGame();

      ref.read(fubaProvider.notifier).state = BigDecimal.parse(
        data.fuba.toString(),
      );

      if (data.generators.isNotEmpty) {
        final loadedGenerators = List<int>.from(data.generators);

        while (loadedGenerators.length < availableGenerators.length) {
          loadedGenerators.add(0);
        }

        ref.read(generatorsProvider.notifier).state = loadedGenerators;
      }

      ref.read(inventoryProvider.notifier).state = data.inventory;
      ref.read(equippedAccessoriesProvider.notifier).state = data.equipped;
      ref.read(rebirthDataProvider.notifier).state = data.rebirthData;
      ref.read(unlockedAchievementsProvider.notifier).state = data.achievements;
      ref.read(achievementStatsProvider.notifier).state = data.achievementStats;
      ref.read(upgradesLevelProvider.notifier).state = data.upgrades;
      ref.read(unlockedSecretsProvider.notifier).state = data.secrets;
    } catch (e) {
      return;
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }
}

final saveNotifierProvider = StateNotifierProvider<SaveNotifier, bool>((ref) {
  return SaveNotifier(ref);
});
