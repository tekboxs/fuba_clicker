import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Provider para gerenciar o player de áudio
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

/// Provider para controlar o estado do áudio
final audioStateProvider = StateNotifierProvider<AudioStateNotifier, bool>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return AudioStateNotifier(player);
});

class AudioStateNotifier extends StateNotifier<bool> {
  final AudioPlayer _player;
  bool _isInitialized = false;

  AudioStateNotifier(this._player) : super(false) {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    if (_isInitialized) return;
    
    try {
      await _player.setAsset('assets/song/tek-tema.ogg');
      await _player.setLoopMode(LoopMode.all);
      await _player.setVolume(0.1);
      _isInitialized = true;
      state = true;
      
      await _player.play();
    } catch (e) {
      debugPrint('Erro ao inicializar áudio: $e');
      state = false;
    }
  }

  Future<void> toggleAudio() async {
    if (!_isInitialized) {
      await _initializeAudio();
      return;
    }

    try {
      if (_player.playing) {
        await _player.pause();
        state = false;
      } else {
        await _player.play();
        state = true;
      }
    } catch (e) {
      debugPrint('Erro ao alternar áudio: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Erro ao ajustar volume: $e');
    }
  }
}
