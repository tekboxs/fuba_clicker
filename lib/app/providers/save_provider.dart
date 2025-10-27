import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import 'package:fuba_clicker/app/models/fuba_generator.dart';
import '../services/save_service.dart';
import '../services/sync_service.dart';
import 'game_providers.dart';
import 'accessory_provider.dart';
import 'rebirth_provider.dart';
import 'achievement_provider.dart';
import 'rebirth_upgrade_provider.dart';
import 'visual_settings_provider.dart';
import 'auth_provider.dart';
import 'sync_notifier.dart';

class SaveNotifier extends StateNotifier<bool> {
  SaveNotifier(this.ref) : super(false) {
    _startPeriodicSave();
    _listenToSyncNotifier();
  }

  final Ref ref;
  final SaveService _saveService = SaveService();
  Timer? _periodicTimer;

  void _startPeriodicSave() {
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => saveGame(),
    );
  }

  void _listenToSyncNotifier() {
    ref.listen<SyncConflictType>(syncNotifierProvider, (previous, next) {
      if (next == SyncConflictType.needsConfirmation) {
        return;
      }
      if (previous == SyncConflictType.needsConfirmation && next == SyncConflictType.none) {
        loadGame();
        ref.read(syncNotifierProvider.notifier).reset();
      }
    });
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

      await _saveService.saveGame(
        fuba: fuba,
        generators: generators,
        inventory: inventory,
        equipped: equipped,
        rebirthData: rebirthData,
        achievements: achievements,
        achievementStats: achievementStats,
        upgrades: upgrades,
      );

      final isAuthenticated = ref.read(isAuthenticatedProvider);
      if (isAuthenticated) {
        try {
          final success = await ref.read(syncServiceProvider.notifier).syncToCloud();
          
          if (!success) {
            final hasConflict = ref.read(syncServiceProvider.notifier).hasConflict();
            if (hasConflict) {
              ref.read(syncNotifierProvider.notifier).notifyConflict();
            }
          }
        } catch (e) {
          print('Erro ao sincronizar para nuvem: $e');
        }
      }

      await _optimizeStorageIfNeeded();
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

      ref.read(fubaProvider.notifier).state = data.fuba;

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
      // Mesclar estatísticas salvas com valores padrão
      final defaultStats = <String, double>{
        'total_clicks': 0,
        'total_production': 0,
        'different_generators': 0,
        'lootboxes_opened': 0,
        'legendary_count': 0,
        'mythical_count': 0,
        'equipped_count': 0,
        'clicks_per_second': 0,
        'max_clicks_per_second': 0,
        'click_streak': 0,
        'max_click_streak': 0,
        'fuba_per_click': 0,
        'max_fuba_per_click': 0,
        'clicks_in_10_seconds': 0,
        'time_since_last_click': 0,
        'total_click_fuba': 0,
        'all_mythical_equipped': 0,
        'total_inventory_accessories': 0,
        'legendary_lootbox_streak': 0,
        'time_without_clicking': 0,
        'max_time_without_clicking': 0,
        'consecutive_play_time': 0,
        'max_consecutive_play_time': 0,
      };
      
      final mergedStats = {...defaultStats, ...data.achievementStats};
      ref.read(achievementStatsProvider.notifier).state = Map<String, double>.from(mergedStats);
      ref.read(upgradesLevelProvider.notifier).state = data.upgrades;

      // Carregar configurações visuais
      final visualSettings = await _saveService.loadVisualSettings();
      if (visualSettings != null) {
        ref.read(visualSettingsProvider.notifier).loadSettings(visualSettings);
      }
    } catch (e) {
      return;
    }
  }

  Future<void> _optimizeStorageIfNeeded() async {
    try {
      final boxSize = await _saveService.getBoxSize();
      if (boxSize > 50) {
        await _saveService.optimizeStorage();
      }
    } catch (e) {
      print('Erro ao otimizar storage: $e');
    }
  }

  Future<void> forceOptimizeStorage() async {
    await _saveService.optimizeStorage();
  }

  Future<int> getStorageSize() async {
    return await _saveService.getBoxSize();
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
