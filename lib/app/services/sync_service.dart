import 'dart:async';

import '../core/utils/efficient_number.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuba_clicker/app/core/utils/navigator.dart';
import 'package:fuba_clicker/app/services/save_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import '../models/game_save_data.dart';
import '../models/user_data.dart';
import '../models/rebirth_data.dart';
import '../providers/sync_notifier.dart';
import '../providers/game_providers.dart';
import '../providers/accessory_provider.dart';
import '../providers/rebirth_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/rebirth_upgrade_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/potion_provider.dart';
import '../providers/forus_upgrade_provider.dart';
import '../core/utils/save_validation.dart';
import '../models/fuba_generator.dart';
import '../models/potion_color.dart';
import '../models/potion_effect.dart';

class CloudSaveData {
  final UserData userData;
  final DateTime lastSync;

  CloudSaveData({
    required this.userData,
    required this.lastSync,
  });

  bool get isEmpty => userData.isEmpty;
}

class SyncService extends StateNotifier<bool> {
  final Ref _ref;
  final AuthService _authService = AuthService();
  Timer? _syncTimer;
  DateTime? _lastSyncTime;
  CloudSaveData? _cloudSaveData;

  SyncService(this._ref) : super(false);

  Future<void> init() async {
    await _authService.init();
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) {
        if (!kDebugMode) {
          syncToCloud();
        }
      },
    );
  }

  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  Future<UserData?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  Future<bool> syncToCloud({bool forceSync = false}) async {
    if (!await isAuthenticated()) return false;

    try {
      final localData = await _getCurrentGameData();
      final currentUser = await getCurrentUser();
      final userDataJson = localData.toJson();

      if (currentUser?.profile != null) {
        userDataJson['profile'] = currentUser!.profile!.toJson();
      }

      if (!forceSync && _cloudSaveData != null) {
        final isLocalSmaller = SaveValidation.isLocalSaveSmaller(
          localData,
          _cloudSaveData!.userData,
        );
 
        if (isLocalSmaller) {
          final dialogContext = kGlobalKeyNavigator.currentContext;
          if (dialogContext == null || !dialogContext.mounted) {
            return false;
          }
          
          final result = await Future(() async => await showDialog(
                    context: dialogContext,
                    builder: (context) => AlertDialog(
                      title: const Text('Erro ao sincronizar para nuvem'),
                      content: const Text(
                          'O save local é menor que o save da nuvem'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Forçar Upload'),
                        ),
                      ],
                    ),
                  )) ??
              false;
          if (!result) {
            return false;
          }
        }
      }

      await _authService.updateUserData(userDataJson);
      _lastSyncTime = DateTime.now();

      final updatedUserData = await _authService.fetchUserData();
      _cloudSaveData = CloudSaveData(
        userData: updatedUserData,
        lastSync: _lastSyncTime!,
      );

      _ref.read(authNotifierProvider.notifier).state =
          AuthState.authenticated(updatedUserData);

      return true;
    } catch (e) {
      print('Erro ao sincronizar para nuvem: $e');
      return false;
    }
  }

  Future<bool> syncFromCloud() async {
    if (!await isAuthenticated()) return false;

    try {
      final userData = await _authService.fetchUserData();
      _lastSyncTime = DateTime.now();

      _cloudSaveData = CloudSaveData(
        userData: userData,
        lastSync: _lastSyncTime!,
      );

      _ref.read(authNotifierProvider.notifier).state =
          AuthState.authenticated(userData);

      if (!userData.isEmpty) {
        await _applyCloudDataToLocal(userData);
        _ref.read(syncNotifierProvider.notifier).notifyDataLoaded();
      }

      return true;
    } catch (e) {
      print('Erro ao carregar da nuvem: $e');
      return false;
    }
  }

  Future<void> forceSync() async {
    if (!await isAuthenticated()) return;

    await syncToCloud(forceSync: true);
  }

  CloudSaveData? getCloudSaveData() {
    return _cloudSaveData;
  }

  Future<bool> uploadLocalToCloud() async {
    if (!await isAuthenticated()) return false;

    try {
      final localData = await _getCurrentGameData();
      final currentUser = await getCurrentUser();
      final userDataJson = localData.toJson();

      if (currentUser?.profile != null) {
        userDataJson['profile'] = currentUser!.profile!.toJson();
      }

      await _authService.updateUserData(userDataJson);
      _lastSyncTime = DateTime.now();

      final updatedUserData = await _authService.fetchUserData();
      _cloudSaveData = CloudSaveData(
        userData: updatedUserData,
        lastSync: _lastSyncTime!,
      );

      _ref.read(authNotifierProvider.notifier).state =
          AuthState.authenticated(updatedUserData);

      return true;
    } catch (e) {
      print('Erro ao fazer upload para nuvem: $e');
      return false;
    }
  }

  Future<bool> downloadCloudToLocal() async {
    if (!await isAuthenticated()) return false;

    try {
      final userData = await _authService.fetchUserData();
      _lastSyncTime = DateTime.now();

      _cloudSaveData = CloudSaveData(
        userData: userData,
        lastSync: _lastSyncTime!,
      );

      _ref.read(authNotifierProvider.notifier).state =
          AuthState.authenticated(userData);

      if (!userData.isEmpty) {
        await _applyCloudDataToLocal(userData);
        _ref.read(syncNotifierProvider.notifier).notifyDataLoaded();
      }

      return true;
    } catch (e) {
      print('Erro ao fazer download da nuvem: $e');
      return false;
    }
  }

  Future<GameSaveData> _getCurrentGameData() async {
    try {
      final fuba = _ref.read(fubaProvider);
      final generators = _ref.read(generatorsProvider);
      final inventory = _ref.read(inventoryProvider);
      final equipped = _ref.read(equippedAccessoriesProvider);
      final rebirthData = _ref.read(rebirthDataProvider);
      final achievements = _ref.read(unlockedAchievementsProvider);
      final achievementStats = _ref.read(achievementStatsProvider);
      final upgrades = _ref.read(upgradesLevelProvider);
      final forusUpgrades = _ref.read(forusUpgradesOwnedProvider);
      final upgradesWithForus = Map<String, int>.from(upgrades);
      for (var upgradeId in forusUpgrades) {
        upgradesWithForus['forus_$upgradeId'] = 1;
      }
      final cauldron = _ref.read(cauldronProvider);
      final activeEffects = _ref.read(activePotionEffectsProvider);
      final permanentMultiplier = _ref.read(permanentPotionMultiplierProvider);
      final activePotionCount = _ref.read(activePotionCountProvider);

      final cauldronJson = <String, int>{};
      cauldron.forEach((color, value) {
        cauldronJson[color.name] = value;
      });

      final activeEffectsJson = activeEffects.map((effect) => effect.toJson()).toList();

      return GameSaveData(
        fuba: fuba,
        generators: generators,
        inventory: inventory,
        equipped: equipped,
        rebirthData: rebirthData,
        achievements: achievements,
        achievementStats: achievementStats,
        upgrades: upgradesWithForus,
        cauldron: cauldronJson,
        activePotionEffects: activeEffectsJson,
        permanentPotionMultiplier: permanentMultiplier,
        activePotionCount: activePotionCount,
      );
    } catch (e) {
      print('Erro ao obter dados atuais dos providers: $e');
      return await SaveService().loadGame();
    }
  }

  Future<void> _applyCloudDataToLocal(UserData userData) async {
    try {
      final fuba = EfficientNumber.parse(userData.fuba);
      _ref.read(fubaProvider.notifier).state = fuba;

      final generators = List<int>.from(userData.generators ?? []);
      while (generators.length < availableGenerators.length) {
        generators.add(0);
      }
      _ref.read(generatorsProvider.notifier).state = generators;

      _ref.read(inventoryProvider.notifier).state =
          Map<String, int>.from(userData.inventory ?? {});
      _ref.read(equippedAccessoriesProvider.notifier).state =
          List<String>.from(userData.equipped ?? []);
      _ref.read(rebirthDataProvider.notifier).state =
          RebirthData.fromJson(userData.rebirthData ?? {});
      _ref.read(unlockedAchievementsProvider.notifier).state =
          List<String>.from(userData.achievements ?? []);

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
      final mergedStats = {
        ...defaultStats,
        ...Map<String, double>.from(userData.achievementStats ?? {}),
      };
      _ref.read(achievementStatsProvider.notifier).state = mergedStats;
      
      final rebirthUpgrades = <String, int>{};
      final forusUpgradesOwned = <String>{};
      
      (userData.upgrades ?? {}).forEach((key, value) {
        if (key.startsWith('forus_')) {
          forusUpgradesOwned.add(key.substring(6));
        } else {
          rebirthUpgrades[key] = value;
        }
      });
      
      _ref.read(upgradesLevelProvider.notifier).state = rebirthUpgrades;
      _ref.read(forusUpgradesOwnedProvider.notifier).state = forusUpgradesOwned;

      final cauldronJson = userData.cauldron ?? {};
      final cauldron = <PotionColor, int>{};
      cauldronJson.forEach((colorName, value) {
        final color = PotionColor.values.firstWhere(
          (c) => c.name == colorName,
          orElse: () => PotionColor.red,
        );
        cauldron[color] = value;
      });
      _ref.read(cauldronProvider.notifier).state = cauldron;

      final activeEffects = (userData.activePotionEffects ?? [])
          .map((json) => PotionEffect.fromJson(json))
          .where((effect) => !effect.isExpired)
          .toList();
      _ref.read(activePotionEffectsProvider.notifier).state = activeEffects;

      _ref.read(permanentPotionMultiplierProvider.notifier).state = 
          userData.permanentPotionMultiplier ?? 1.0;

      _ref.read(activePotionCountProvider.notifier).state = 
          Map<String, int>.from(userData.activePotionCount ?? {});

      await SaveService().saveGame(
        fuba: fuba,
        generators: generators,
        inventory: Map<String, int>.from(userData.inventory ?? {}),
        equipped: List<String>.from(userData.equipped ?? []),
        rebirthData: RebirthData.fromJson(userData.rebirthData ?? {}),
        achievements: List<String>.from(userData.achievements ?? []),
        achievementStats:
            Map<String, double>.from(userData.achievementStats ?? {}),
        upgrades: Map<String, int>.from(userData.upgrades ?? {}),
        cauldron: cauldronJson,
        activePotionEffects: userData.activePotionEffects ?? [],
        permanentPotionMultiplier: userData.permanentPotionMultiplier ?? 1.0,
        activePotionCount: Map<String, int>.from(userData.activePotionCount ?? {}),
      );

      _ref.read(syncNotifierProvider.notifier).notifyDataLoaded();
    } catch (e) {
      final dialogContext = kGlobalKeyNavigator.currentContext;
      if (dialogContext != null && dialogContext.mounted) {
        showDialog(
          context: dialogContext,
          builder: (context) => AlertDialog(
            title: const Text('Erro ao aplicar dados da nuvem'),
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  DateTime? getLastSyncTime() {
    return _lastSyncTime;
  }

  Future<void> syncOnAppStart() async {
    if (await isAuthenticated()) {
      await syncFromCloud();
    }
  }

  Future<void> syncOnAppClose() async {
    if (await isAuthenticated()) {
      await syncToCloud();
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}

final syncServiceProvider = StateNotifierProvider<SyncService, bool>((ref) {
  return SyncService(ref);
});
