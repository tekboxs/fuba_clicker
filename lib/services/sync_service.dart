import 'dart:async';
import 'auth_service.dart';
import '../models/game_save_data.dart';
import '../models/user_data.dart';
import '../models/rebirth_data.dart';

class SyncService {
  final AuthService _authService = AuthService();
  Timer? _syncTimer;
  DateTime? _lastSyncTime;

  Future<void> init() async {
    await _authService.init();
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncToCloud(),
    );
  }

  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  Future<UserData?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  Future<void> syncToCloud() async {
    if (!await isAuthenticated()) return;

    try {
      final saveData = _getCurrentGameData();
      
      await _authService.updateUserData(saveData.toJson());
      _lastSyncTime = DateTime.now();
    } catch (e) {
      print('Erro ao sincronizar para nuvem: $e');
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

  GameSaveData _getCurrentGameData() {
    return GameSaveData(
      fuba: 0.0,
      generators: [],
      inventory: {},
      equipped: [],
      rebirthData: const RebirthData(),
      achievements: [],
      achievementStats: {},
      upgrades: {},
    );
  }

  void _applyCloudDataToLocal(UserData userData) {
    if (userData.fuba.isNotEmpty) {
      try {
        // Aplicar dados da nuvem aos providers locais
        // Esta implementação será expandida quando integrarmos com os providers
      } catch (e) {
        print('Erro ao aplicar dados da nuvem: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> getCloudSaveData() async {
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

  void dispose() {
    _syncTimer?.cancel();
  }
}
