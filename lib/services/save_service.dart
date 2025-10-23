import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/rebirth_data.dart';
import '../models/game_save_data.dart';
import 'save_validation_service.dart' hide GameSaveData;

class SaveService {
  static const String _boxName = 'fuba_save';
  static const String _saveKey = 'game_data';
  
  // Chaves antigas para migração
  static const String _fubaKey = 'fuba_count';
  static const String _generatorsKey = 'generators';
  static const String _inventoryKey = 'inventory';
  static const String _equippedKey = 'equipped_accessories';
  static const String _rebirthDataKey = 'rebirth_data';
  static const String _achievementsKey = 'achievements';
  static const String _achievementStatsKey = 'achievement_stats';
  static const String _upgradesKey = 'upgrades';
  
  static Box<GameSaveData>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(GameSaveDataAdapter());
    Hive.registerAdapter(RebirthDataAdapter());
    
    final key = _deriveEncryptionKey('fuba_secret_key_2024');
    
    _box = await Hive.openBox<GameSaveData>(
      _boxName,
      encryptionCipher: HiveAesCipher(key),
    );
    
    await _migrateFromSharedPreferences();
  }

  List<int> _deriveEncryptionKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.bytes;
  }

  Future<void> _migrateFromSharedPreferences() async {
    if (_box == null || _box!.isNotEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_fubaKey)) {
      final oldData = await _loadFromSharedPreferences(prefs);
      await _box!.put(_saveKey, oldData);
      await _clearSharedPreferences(prefs);
    }
  }

  Future<GameSaveData> _loadFromSharedPreferences(SharedPreferences prefs) async {
    double fuba = 0.0;

    final fubaString = prefs.getString(_fubaKey);
    if (fubaString != null) {
      fuba = double.tryParse(_decompress(fubaString)) ?? 0.0;
    } else {
      final fubaDouble = prefs.getDouble(_fubaKey);
      if (fubaDouble != null) {
        fuba = fubaDouble;
      }
    }

    final generatorsJson = prefs.getString(_generatorsKey);
    final generators = generatorsJson != null
        ? List<int>.from(jsonDecode(_decompress(generatorsJson)))
        : <int>[];

    final inventoryJson = prefs.getString(_inventoryKey);
    final inventory = inventoryJson != null
        ? Map<String, int>.from(jsonDecode(_decompress(inventoryJson)))
        : <String, int>{};

    final equippedJson = prefs.getString(_equippedKey);
    final equipped = equippedJson != null
        ? List<String>.from(jsonDecode(_decompress(equippedJson)))
        : <String>[];

    final rebirthDataJson = prefs.getString(_rebirthDataKey);
    final rebirthData = rebirthDataJson != null
        ? RebirthData.fromJson(jsonDecode(_decompress(rebirthDataJson)))
        : const RebirthData();

    final achievementsJson = prefs.getString(_achievementsKey);
    final achievements = achievementsJson != null
        ? Set<String>.from(jsonDecode(_decompress(achievementsJson)))
        : <String>{};

    final achievementStatsJson = prefs.getString(_achievementStatsKey);
    final achievementStats = achievementStatsJson != null
        ? Map<String, double>.from(
            jsonDecode(_decompress(achievementStatsJson)),
          )
        : <String, double>{};

    final upgradesJson = prefs.getString(_upgradesKey);
    final upgrades = upgradesJson != null
        ? Map<String, int>.from(jsonDecode(_decompress(upgradesJson)))
        : <String, int>{};

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
  }

  Future<void> _clearSharedPreferences(SharedPreferences prefs) async {
    await prefs.remove(_fubaKey);
    await prefs.remove(_generatorsKey);
    await prefs.remove(_inventoryKey);
    await prefs.remove(_equippedKey);
    await prefs.remove(_rebirthDataKey);
    await prefs.remove(_achievementsKey);
    await prefs.remove(_achievementStatsKey);
    await prefs.remove(_upgradesKey);
  }

  Future<void> saveGame({
    required double fuba,
    required List<int> generators,
    required Map<String, int> inventory,
    required List<String> equipped,
    required RebirthData rebirthData,
    required Set<String> achievements,
    required Map<String, double> achievementStats,
    required Map<String, int> upgrades,
  }) async {
    if (_box == null) return;

    final saveData = GameSaveData(
      fuba: fuba,
      generators: generators,
      inventory: inventory,
      equipped: equipped,
      rebirthData: rebirthData,
      achievements: achievements,
      achievementStats: achievementStats,
      upgrades: upgrades,
    );

    await _box!.put(_saveKey, saveData);
  }

  Future<GameSaveData> loadGame() async {
    if (_box == null) return _getDefaultSaveData();

    final saveData = _box!.get(_saveKey);
    if (saveData == null) return _getDefaultSaveData();

    return saveData;
  }

  Future<bool> hasSaveData() async {
    if (_box == null) return false;
    return _box!.containsKey(_saveKey);
  }

  Future<void> clearSave() async {
    if (_box == null) return;
    await _box!.clear();
  }

  String generateBackupCode({
    required double fuba,
    required List<int> generators,
    required Map<String, int> inventory,
    required List<String> equipped,
    required RebirthData rebirthData,
    required Set<String> achievements,
    required Map<String, double> achievementStats,
    required Map<String, int> upgrades,
  }) {
    // Criar dados no formato antigo para compatibilidade
    final oldSaveData = _createOldGameSaveData(
      fuba: fuba,
      generators: generators,
      inventory: inventory,
      equipped: equipped,
      rebirthData: rebirthData,
      achievements: achievements,
      achievementStats: achievementStats,
      upgrades: upgrades,
    );

    return SaveValidationService.generateBackupCode(oldSaveData);
  }

  dynamic _createOldGameSaveData({
    required double fuba,
    required List<int> generators,
    required Map<String, int> inventory,
    required List<String> equipped,
    required RebirthData rebirthData,
    required Set<String> achievements,
    required Map<String, double> achievementStats,
    required Map<String, int> upgrades,
  }) {
    // Usar reflection ou criar um objeto compatível
    // Por enquanto, vou usar um Map para simular o objeto antigo
    return {
      'fuba': fuba,
      'generators': generators,
      'inventory': inventory,
      'equipped': equipped,
      'rebirthData': rebirthData,
      'achievements': achievements,
      'achievementStats': achievementStats,
      'upgrades': upgrades,
    };
  }

  GameSaveData? restoreFromBackupCode(String code) {
    final oldSaveData = SaveValidationService.restoreFromBackupCode(code);
    if (oldSaveData == null) return null;
    
    return GameSaveData(
      fuba: oldSaveData.fuba,
      generators: oldSaveData.generators,
      inventory: oldSaveData.inventory,
      equipped: oldSaveData.equipped,
      rebirthData: oldSaveData.rebirthData,
      achievements: oldSaveData.achievements,
      achievementStats: oldSaveData.achievementStats,
      upgrades: oldSaveData.upgrades,
    );
  }

  Future<String> exportToFile() async {
    final saveData = await loadGame();
    return jsonEncode(saveData.toJson());
  }

  Future<bool> importFromFile(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      final saveData = GameSaveData.fromJson(data);
      await _box!.put(_saveKey, saveData);
      return true;
    } catch (e) {
      return false;
    }
  }

  GameSaveData _getDefaultSaveData() {
    return GameSaveData(
      fuba: 0.0,
      generators: <int>[],
      inventory: <String, int>{},
      equipped: <String>[],
      rebirthData: const RebirthData(),
      achievements: <String>{},
      achievementStats: <String, double>{},
      upgrades: <String, int>{},
    );
  }

  String _decompress(String compressedData) {
    try {
      final deobfuscated = _deobfuscate(compressedData);
      final bytes = base64Decode(deobfuscated);
      final decompressed = gzip.decode(bytes);
      return utf8.decode(decompressed);
    } catch (e) {
      return compressedData;
    }
  }

  String _deobfuscate(String obfuscatedData) {
    const key = 'fuba_secret_key_2024';
    final keyBytes = utf8.encode(key);
    final dataBytes = base64Decode(obfuscatedData);
    final result = <int>[];

    for (int i = 0; i < dataBytes.length; i++) {
      result.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(result);
  }
}
