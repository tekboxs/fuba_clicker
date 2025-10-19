import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/rebirth_data.dart';
import 'save_validation_service.dart';

class SaveService {
  static const String _fubaKey = 'fuba_count';
  static const String _generatorsKey = 'generators';
  static const String _inventoryKey = 'inventory';
  static const String _equippedKey = 'equipped_accessories';
  static const String _rebirthDataKey = 'rebirth_data';
  static const String _achievementsKey = 'achievements';
  static const String _achievementStatsKey = 'achievement_stats';
  static const String _upgradesKey = 'upgrades';
  static const String _secretsKey = 'secrets';

  Future<void> saveGame({
    required double fuba,
    required List<int> generators,
    required Map<String, int> inventory,
    required List<String> equipped,
    required RebirthData rebirthData,
    required Set<String> achievements,
    required Map<String, double> achievementStats,
    required Map<String, int> upgrades,
    required Set<String> secrets,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_fubaKey, _compress(fuba.toString()));
    await prefs.setString(_generatorsKey, _compress(jsonEncode(generators)));
    await prefs.setString(_inventoryKey, _compress(jsonEncode(inventory)));
    await prefs.setString(_equippedKey, _compress(jsonEncode(equipped)));
    await prefs.setString(_rebirthDataKey, _compress(jsonEncode(rebirthData.toJson())));
    await prefs.setString(_achievementsKey, _compress(jsonEncode(achievements.toList())));
    await prefs.setString(_achievementStatsKey, _compress(jsonEncode(achievementStats)));
    await prefs.setString(_upgradesKey, _compress(jsonEncode(upgrades)));
    await prefs.setString(_secretsKey, _compress(jsonEncode(secrets.toList())));
  }

  Future<GameSaveData> loadGame() async {
    final prefs = await SharedPreferences.getInstance();

    double fuba = 0.0;
    
    final fubaString = prefs.getString(_fubaKey);
    if (fubaString != null) {
      fuba = double.tryParse(_decompress(fubaString)) ?? 0.0;
    } else {
      final fubaDouble = prefs.getDouble(_fubaKey);
      if (fubaDouble != null) {
        fuba = fubaDouble;
        await prefs.remove(_fubaKey);
        await prefs.setString(_fubaKey, _compress(fuba.toString()));
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
        ? Map<String, double>.from(jsonDecode(_decompress(achievementStatsJson)))
        : <String, double>{};

    final upgradesJson = prefs.getString(_upgradesKey);
    final upgrades = upgradesJson != null
        ? Map<String, int>.from(jsonDecode(_decompress(upgradesJson)))
        : <String, int>{};

    final secretsJson = prefs.getString(_secretsKey);
    final secrets = secretsJson != null
        ? Set<String>.from(jsonDecode(_decompress(secretsJson)))
        : <String>{};

    final saveData = GameSaveData(
      fuba: fuba,
      generators: generators,
      inventory: inventory,
      equipped: equipped,
      rebirthData: rebirthData,
      achievements: achievements,
      achievementStats: achievementStats,
      upgrades: upgrades,
      secrets: secrets,
    );

    // Validar consistência dos dados
    final validation = SaveValidationService.validateSaveData(saveData);
    if (!validation.isValid) {
      // Se dados são críticos inválidos, limpar save
      await clearSave();
      return _getDefaultSaveData();
    }

    return saveData;
  }

  Future<bool> hasSaveData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_fubaKey);
  }

  Future<void> clearSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fubaKey);
    await prefs.remove(_generatorsKey);
    await prefs.remove(_inventoryKey);
    await prefs.remove(_equippedKey);
    await prefs.remove(_rebirthDataKey);
    await prefs.remove(_achievementsKey);
    await prefs.remove(_achievementStatsKey);
    await prefs.remove(_upgradesKey);
    await prefs.remove(_secretsKey);
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
    required Set<String> secrets,
  }) {
    final saveData = GameSaveData(
      fuba: fuba,
      generators: generators,
      inventory: inventory,
      equipped: equipped,
      rebirthData: rebirthData,
      achievements: achievements,
      achievementStats: achievementStats,
      upgrades: upgrades,
      secrets: secrets,
    );
    
    return SaveValidationService.generateBackupCode(saveData);
  }

  GameSaveData? restoreFromBackupCode(String code) {
    return SaveValidationService.restoreFromBackupCode(code);
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
      secrets: <String>{},
    );
  }

  String _compress(String data) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final timestampBytes = utf8.encode(timestamp.toString().padLeft(8, '0'));
      
      final checksum = _generateChecksum(data);
      final checksumBytes = utf8.encode(checksum);
      
      final random = Random();
      final salt = List.generate(16, (_) => random.nextInt(256));
      
      final payload = [
        ...timestampBytes,
        ...utf8.encode(data),
        ...checksumBytes,
        ...salt,
      ];
      
      final compressed = gzip.encode(payload);
      final encoded1 = base64Encode(compressed);
      final obfuscated = _obfuscate(encoded1);
      final encoded2 = base64Encode(utf8.encode(obfuscated));
      final shuffled = _shuffleBytes(utf8.encode(encoded2));
      
      return base64Encode(shuffled);
    } catch (e) {
      return data;
    }
  }

  String _decompress(String compressedData) {
    try {
      final shuffled = base64Decode(compressedData);
      final unshuffled = _unshuffleBytes(shuffled);
      final encoded2 = utf8.decode(unshuffled);
      final obfuscated = utf8.decode(base64Decode(encoded2));
      final encoded1 = _deobfuscate(obfuscated);
      final bytes = base64Decode(encoded1);
      final decompressed = gzip.decode(bytes);
      
      final decompressedString = utf8.decode(decompressed);
      final timestampLength = 8;
      final checksumLength = 64;
      final saltLength = 16;
      
      if (decompressedString.length < timestampLength + checksumLength + saltLength) {
        return _decompressLegacy(compressedData);
      }
      
      decompressedString.substring(0, timestampLength);
      final data = decompressedString.substring(timestampLength, decompressedString.length - checksumLength - saltLength);
      final checksum = decompressedString.substring(decompressedString.length - checksumLength - saltLength, decompressedString.length - saltLength);
      
      final expectedChecksum = _generateChecksum(data);
      if (checksum != expectedChecksum) {
        return _decompressLegacy(compressedData);
      }
      
      return data;
    } catch (e) {
      return _decompressLegacy(compressedData);
    }
  }
  
  String _decompressLegacy(String compressedData) {
    try {
      final deobfuscated = _deobfuscate(compressedData);
      final bytes = base64Decode(deobfuscated);
      final decompressed = gzip.decode(bytes);
      return utf8.decode(decompressed);
    } catch (e) {
      return compressedData;
    }
  }

  String _obfuscate(String data) {
    const key = 'fuba_secret_key_2024';
    final keyBytes = utf8.encode(key);
    final dataBytes = utf8.encode(data);
    final result = <int>[];
    
    for (int i = 0; i < dataBytes.length; i++) {
      result.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64Encode(result);
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

  String _generateChecksum(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  List<int> _shuffleBytes(List<int> bytes) {
    final result = List<int>.from(bytes);
    const key = 'fuba_shuffle_2024';
    for (int i = 0; i < result.length; i++) {
      final j = (i + key.codeUnitAt(i % key.length)) % result.length;
      final temp = result[i];
      result[i] = result[j];
      result[j] = temp;
    }
    return result;
  }

  List<int> _unshuffleBytes(List<int> bytes) {
    final result = List<int>.from(bytes);
    const key = 'fuba_shuffle_2024';
    for (int i = result.length - 1; i >= 0; i--) {
      final j = (i + key.codeUnitAt(i % key.length)) % result.length;
      final temp = result[i];
      result[i] = result[j];
      result[j] = temp;
    }
    return result;
  }
}


