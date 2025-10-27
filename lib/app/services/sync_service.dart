import 'dart:async';
import 'package:flutter/foundation.dart';
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

class SyncService extends StateNotifier<bool> {
  final Ref _ref;
  final AuthService _authService = AuthService();
  Timer? _syncTimer;
  DateTime? _lastSyncTime;
  bool _hasConflict = false;
  GameSaveData? _conflictingLocalSave;
  UserData? _conflictingCloudSave;

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

  Future<bool> syncToCloud({bool forceUpload = false}) async {
    if (!await isAuthenticated()) return false;

    try {
      final localSaveData = await _getCurrentGameData();

      if (!forceUpload) {
        try {
          final cloudUserData = await _authService.fetchUserData();
          final isSmaller =
              SaveValidation.isLocalSaveSmaller(localSaveData, cloudUserData);

          if (isSmaller) {
            _hasConflict = true;
            _conflictingLocalSave = localSaveData;
            _conflictingCloudSave = cloudUserData;
            // Most basic dialog example using Flutter:

            print(
                'Aviso: Save local tem menos rebirths que o da nuvem. Conflito detectado.');
            return false;
          }
        } catch (e) {
          print('Erro ao verificar save da nuvem: $e');
        }
      }

      _hasConflict = false;
      _conflictingLocalSave = null;
      _conflictingCloudSave = null;

      await _authService.updateUserData(localSaveData.toJson());
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      print('Erro ao sincronizar para nuvem: $e');
      return false;
    }
  }

  Future<bool> loadFromCloud() async {
    if (!await isAuthenticated()) return false;

    try {
      final userData = await _authService.fetchUserData();
      if (userData.fuba.isNotEmpty) {
        _applyCloudDataToLocal(userData);
        _lastSyncTime = DateTime.now();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro ao carregar da nuvem: $e');
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
    if (userData.fuba.isNotEmpty) {
      try {
        await SaveService().saveGame(
          fuba: double.tryParse(userData.fuba) ?? 0.0,
          generators: userData.generators ?? [],
          inventory: userData.inventory ?? {},
          equipped: userData.equipped ?? [],
          rebirthData: RebirthData.fromJson(userData.rebirthData ?? {}),
          achievements: userData.achievements ?? [],
          achievementStats: userData.achievementStats ?? {},
          upgrades: userData.upgrades ?? {},
        );
        _lastSyncTime = DateTime.now();

        _ref.read(syncNotifierProvider.notifier).notifyDataLoaded();
      } catch (e) {
        print('Erro ao aplicar dados da nuvem: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> getCloudSaveDataJson() async {
    if (!await isAuthenticated()) return null;

    try {
      final userData = await _authService.getCurrentUser();
      if (userData?.fuba.isNotEmpty == true) {
        return {
          'fuba': double.tryParse(userData!.fuba) ?? 0.0,
          'generators': userData.generators ?? [],
          'inventory': userData.inventory ?? {},
          'equipped': userData.equipped ?? [],
          'rebirthData': userData.rebirthData ?? {},
          'achievements': userData.achievements ?? [],
          'achievementStats': userData.achievementStats ?? {},
          'upgrades': userData.upgrades ?? {},
        };
      }
      return null;
    } catch (e) {
      print('Erro ao obter dados da nuvem: $e');
      return null;
    }
  }

  DateTime? getLastSyncTime() {
    return _lastSyncTime;
  }

  Future<void> syncOnAppStart() async {
    if (await isAuthenticated()) {
      await loadFromCloud();
    }
  }

  Future<void> syncOnAppClose() async {
    if (await isAuthenticated()) {
      await syncToCloud();
    }
  }

  bool hasConflict() {
    return _hasConflict;
  }

  GameSaveData? getLocalSaveData() {
    return _conflictingLocalSave;
  }

  UserData? getCloudSaveData() {
    return _conflictingCloudSave;
  }

  Future<void> forceUploadLocalSave() async {
    if (_conflictingLocalSave == null) return;

    final success = await syncToCloud(forceUpload: true);
    if (success) {
      _hasConflict = false;
      _conflictingLocalSave = null;
      _conflictingCloudSave = null;
    }
  }

  Future<void> forceDownloadCloudSave() async {
    if (_conflictingCloudSave == null) return;

    await _applyCloudDataToLocal(_conflictingCloudSave!);
    _hasConflict = false;
    _conflictingLocalSave = null;
    _conflictingCloudSave = null;
  }

  void clearConflict() {
    _hasConflict = false;
    _conflictingLocalSave = null;
    _conflictingCloudSave = null;
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
