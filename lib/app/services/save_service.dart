import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/efficient_number_adapter.dart';
import '../core/utils/efficient_number.dart';
import '../models/rebirth_data.dart';
import '../models/game_save_data.dart';

class SaveService {
  static const String _boxName = 'fuba_save';
  static const String _saveKey = 'game_data';
  static const String _compressedSaveKey = 'compressed_game_data';
  static const String _metadataKey = 'save_metadata';

  static Box<GameSaveData>? _box;
  static Box<Map>? _settingsBox;
  static Box<String>? _compressedBox;

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(GameSaveDataAdapter());
    Hive.registerAdapter(RebirthDataAdapter());
    Hive.registerAdapter(EfficientNumberAdapter());

    final key = _deriveEncryptionKey('fuba_secret_key_2024');

    _box = await Hive.openBox<GameSaveData>(
      _boxName,
      encryptionCipher: HiveAesCipher(key),
    );

    _settingsBox = await Hive.openBox<Map>(
      'fuba_settings',
      encryptionCipher: HiveAesCipher(key),
    );

    _compressedBox = await Hive.openBox<String>(
      'fuba_compressed',
      encryptionCipher: HiveAesCipher(key),
    );

    await _checkAndCleanupOldData();
  }

  List<int> _deriveEncryptionKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.bytes;
  }

  Future<void> saveGame({
    required EfficientNumber fuba,
    required List<int> generators,
    required Map<String, int> inventory,
    required List<String> equipped,
    required RebirthData rebirthData,
    required List<String> achievements,
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

    try {
      await _box!.put(_saveKey, saveData);
    } catch (e) {
      await _saveCompressedData(saveData);
    }
  }

  Future<void> saveVisualSettings(Map<String, dynamic> settings) async {
    if (_settingsBox == null) return;
    await _settingsBox!.put('visual_settings', settings);
  }

  Future<Map<String, dynamic>?> loadVisualSettings() async {
    if (_settingsBox == null) return null;
    final settings = _settingsBox!.get('visual_settings');
    if (settings is Map<String, dynamic>) {
      return settings;
    }
    return null;
  }

  Future<GameSaveData> loadGame() async {
    if (_box == null) return _getDefaultSaveData();

    GameSaveData? compressedBackup;
    try {
      compressedBackup = await _loadCompressedData();
    } catch (e) {
    }

    try {
      final saveData = _box!.get(_saveKey);
      if (saveData != null) {
        return saveData;
      }
    } catch (e, stackTrace) {
      print('[SaveService] Erro ao ler dados do Hive: $e');
      print(stackTrace);
      if (compressedBackup != null) {
        print('[SaveService] Usando backup comprimido como fallback');
        return compressedBackup;
      }
      return _getDefaultSaveData();
    }

    if (compressedBackup != null) {
      return compressedBackup;
    }
    return await _loadCompressedData();
  }

  Future<bool> hasSaveData() async {
    if (_box == null) return false;
    return _box!.containsKey(_saveKey);
  }

  Future<void> clearSave() async {
    if (_box == null) return;
    await _box!.clear();
  }

  Future<String> exportToFile() async {
    final saveData = await loadGame();
    return jsonEncode(saveData.toJson());
  }

  Future<bool> importFromFile(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      final saveData = GameSaveData.fromJson(data);
      if (_box != null) {
        await _box!.put(_saveKey, saveData);
      }
      return true;
    } catch (e) {
      debugPrint('[SaveService]>> Erro ao importar save: $e');
      return false;
    }
  }

  GameSaveData _getDefaultSaveData() {
    return GameSaveData(
      fuba: const EfficientNumber.zero(),
      generators: <int>[],
      inventory: <String, int>{},
      equipped: <String>[],
      rebirthData: const RebirthData(),
      achievements: <String>[],
      achievementStats: <String, double>{},
      upgrades: <String, int>{},
    );
  }

  Future<void> _saveCompressedData(GameSaveData saveData) async {
    if (_compressedBox == null) return;

    final jsonData = jsonEncode(saveData.toJson());
    final compressed = _compressData(jsonData);
    final metadata = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'version': '1.0',
      'compressed': true,
    };

    await _compressedBox!.put(_compressedSaveKey, compressed);
    await _compressedBox!.put(_metadataKey, jsonEncode(metadata));
  }

  Future<GameSaveData> _loadCompressedData() async {
    if (_compressedBox == null) return _getDefaultSaveData();

    try {
      final compressed = _compressedBox!.get(_compressedSaveKey);
      if (compressed == null) return _getDefaultSaveData();

      final decompressed = _decompressData(compressed);
      final data = jsonDecode(decompressed);
      return GameSaveData.fromJson(data);
    } catch (e) {
      return _getDefaultSaveData();
    }
  }

  String _compressData(String data) {
    final bytes = utf8.encode(data);
    final compressed = gzip.encode(bytes);
    return base64Encode(compressed);
  }

  String _decompressData(String compressedData) {
    try {
      final bytes = base64Decode(compressedData);
      final decompressed = gzip.decode(bytes);
      return utf8.decode(decompressed);
    } catch (e) {
      return compressedData;
    }
  }

  Future<void> _checkAndCleanupOldData() async {
    if (_box == null) return;

    try {
      final boxSize = _box!.length;
      if (boxSize > 100) {
        await _cleanupOldEntries();
      }
    } catch (e) {
      await _clearCorruptedData();
    }
  }

  Future<void> _cleanupOldEntries() async {
    if (_box == null) return;

    final keys = _box!.keys.toList();
    if (keys.length > 50) {
      final keysToRemove = keys.take(keys.length - 50);
      for (final key in keysToRemove) {
        await _box!.delete(key);
      }
    }
  }

  Future<void> _clearCorruptedData() async {
    if (_box == null) return;

    try {
      await _box!.clear();
    } catch (e) {
      await _box!.close();
      final key = _deriveEncryptionKey('fuba_secret_key_2024');
      _box = await Hive.openBox<GameSaveData>(
        _boxName,
        encryptionCipher: HiveAesCipher(key),
      );
    }
  }

  Future<int> getBoxSize() async {
    if (_box == null) return 0;
    return _box!.length;
  }

  Future<void> optimizeStorage() async {
    if (_box == null) return;

    try {
      await _box!.compact();
    } catch (e) {
      await _clearCorruptedData();
    }
  }
}

String deobfuscate(String obfuscatedData) {
  const key = 'fuba_secret_key_2024';
  final keyBytes = utf8.encode(key);
  final dataBytes = base64Decode(obfuscatedData);
  final result = <int>[];

  for (int i = 0; i < dataBytes.length; i++) {
    result.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
  }

  return utf8.decode(result);
}

String obfuscate(String data) {
  const key = 'fuba_secret_key_2024';
  final keyBytes = utf8.encode(key);
  final dataBytes = utf8.encode(data);
  final result = <int>[];

  for (int i = 0; i < dataBytes.length; i++) {
    result.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
  }

  return base64Encode(result);
}
