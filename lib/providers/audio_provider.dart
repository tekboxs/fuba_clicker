import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

final clickSoundPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

final audioStateProvider = StateNotifierProvider<AudioStateNotifier, bool>((
  ref,
) {
  final player = ref.watch(audioPlayerProvider);
  return AudioStateNotifier(player);
});

class AudioStateNotifier extends StateNotifier<bool> {
  final AudioPlayer _player;
  bool _isInitialized = false;

  AudioStateNotifier(this._player) : super(true) {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    if (kDebugMode) return;
    if (_isInitialized) return;

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.1);
      await _player.play(AssetSource('song/tek-tema.mp3'));
      _isInitialized = true;
      state = true;
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
      if (_player.state == PlayerState.playing) {
        await _player.pause();
        state = false;
      } else {
        await _player.resume();
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

class ClickSoundNotifier {
  final AudioPlayer _clickPlayer;

  ClickSoundNotifier(this._clickPlayer);

  Future<void> playClickSound() async {
    try {
      await _clickPlayer.stop();
      await _clickPlayer.setVolume(0.3);
      await _clickPlayer.play(AssetSource('song/click.mp3'));
    } catch (e) {
      debugPrint('Erro ao tocar som de click: $e');
    }
  }
}

final clickSoundNotifierProvider = Provider<ClickSoundNotifier>((ref) {
  final player = ref.watch(clickSoundPlayerProvider);
  return ClickSoundNotifier(player);
});
