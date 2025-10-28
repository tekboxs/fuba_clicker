import 'dart:async';

import 'package:big_decimal/big_decimal.dart';
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
import '../core/utils/save_validation.dart';

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

      if (!forceSync && _cloudSaveData != null) {
        final isLocalSmaller = SaveValidation.isLocalSaveSmaller(
          localData,
          _cloudSaveData!.userData,
        );

        if (isLocalSmaller) {
          final result = await Future(() async => await showDialog(
                    context: kGlobalKeyNavigator.currentContext!,
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

      await _authService.updateUserData(localData.toJson());
      _lastSyncTime = DateTime.now();

      final updatedUserData = await _authService.fetchUserData();
      _cloudSaveData = CloudSaveData(
        userData: updatedUserData,
        lastSync: _lastSyncTime!,
      );

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
      await _authService.updateUserData(localData.toJson());
      _lastSyncTime = DateTime.now();

      final updatedUserData = await _authService.fetchUserData();
      _cloudSaveData = CloudSaveData(
        userData: updatedUserData,
        lastSync: _lastSyncTime!,
      );

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

      return GameSaveData(
        fuba: fuba,
        generators: generators,
        inventory: inventory,
        equipped: equipped,
        rebirthData: rebirthData,
        achievements: achievements,
        achievementStats: achievementStats,
        upgrades: upgrades,
      );
    } catch (e) {
      print('Erro ao obter dados atuais dos providers: $e');
      return await SaveService().loadGame();
    }
  }

  Future<void> _applyCloudDataToLocal(UserData userData) async {
    try {
      final fuba = BigDecimal.parse(userData.fuba);
      await SaveService().saveGame(
        fuba: fuba,
        generators: userData.generators ?? [],
        inventory: userData.inventory ?? {},
        equipped: userData.equipped ?? [],
        rebirthData: RebirthData.fromJson(userData.rebirthData ?? {}),
        achievements: userData.achievements ?? [],
        achievementStats: userData.achievementStats ?? {},
        upgrades: userData.upgrades ?? {},
      );

      _ref.read(syncNotifierProvider.notifier).notifyDataLoaded();
    } catch (e) {
      showDialog(
        context: kGlobalKeyNavigator.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Erro ao aplicar dados da nuvem'),
          content: Text(e.toString()),
        ),
      );
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
