import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/save_service.dart';
import '../models/fuba_generator.dart';
import 'game_providers.dart';
import 'accessory_provider.dart';

class SaveNotifier extends StateNotifier<bool> {
  SaveNotifier(this.ref) : super(false) {
    _startPeriodicSave();
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

  Future<void> saveGame() async {
    try {
      state = true;
      final fuba = ref.read(fubaProvider);
      final generators = ref.read(generatorsProvider);
      final inventory = ref.read(inventoryProvider);
      final equipped = ref.read(equippedAccessoriesProvider);

      await _saveService.saveGame(
        fuba: fuba,
        generators: generators,
        inventory: inventory,
        equipped: equipped,
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

