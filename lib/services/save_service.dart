import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  static const String _fubaKey = 'fuba_count';
  static const String _generatorsKey = 'generators';
  static const String _inventoryKey = 'inventory';
  static const String _equippedKey = 'equipped_accessories';

  Future<void> saveGame({
    required double fuba,
    required List<int> generators,
    required Map<String, int> inventory,
    required List<String> equipped,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble(_fubaKey, fuba);
    await prefs.setString(_generatorsKey, jsonEncode(generators));
    await prefs.setString(_inventoryKey, jsonEncode(inventory));
    await prefs.setString(_equippedKey, jsonEncode(equipped));
  }

  Future<GameSaveData> loadGame() async {
    final prefs = await SharedPreferences.getInstance();

    final fuba = prefs.getDouble(_fubaKey) ?? 0.0;
    
    final generatorsJson = prefs.getString(_generatorsKey);
    final generators = generatorsJson != null
        ? List<int>.from(jsonDecode(generatorsJson))
        : <int>[];

    final inventoryJson = prefs.getString(_inventoryKey);
    final inventory = inventoryJson != null
        ? Map<String, int>.from(jsonDecode(inventoryJson))
        : <String, int>{};

    final equippedJson = prefs.getString(_equippedKey);
    final equipped = equippedJson != null
        ? List<String>.from(jsonDecode(equippedJson))
        : <String>[];

    return GameSaveData(
      fuba: 100000000000000000,
      // fuba: fuba,
      generators: generators,
      inventory: inventory,
      equipped: equipped,
    );
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
  }
}

class GameSaveData {
  final double fuba;
  final List<int> generators;
  final Map<String, int> inventory;
  final List<String> equipped;

  GameSaveData({
    required this.fuba,
    required this.generators,
    required this.inventory,
    required this.equipped,
  });
}

