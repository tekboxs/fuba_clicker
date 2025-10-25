import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

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

final audioVolumeProvider = StateNotifierProvider<AudioVolumeNotifier, double>((
  ref,
) {
  return AudioVolumeNotifier();
});

class AudioVolumeNotifier extends StateNotifier<double> {
  AudioVolumeNotifier() : super(0.1);

  void setVolume(double volume) {
    state = volume.clamp(0.01, 1.0);
  }
}

class AudioStateNotifier extends StateNotifier<bool> {
  final AudioPlayer _player;
  bool _isInitialized = false;
  bool _isMuted = false;

  AudioStateNotifier(this._player) : super(true) {
    _initializeAudio();
  }

  Future<bool> _requestAudioPermission() async {
    if (kIsWeb) return true;
    
    final status = await Permission.audio.status;
    if (status.isGranted) return true;
    
    if (status.isDenied) {
      final result = await Permission.audio.request();
      return result.isGranted;
    }
    
    return false;
  }

  Future<void> _initializeAudio() async {
    if (kDebugMode) return;
    if (_isInitialized) return;

    try {
      final hasPermission = await _requestAudioPermission();
      if (!hasPermission) {
        debugPrint('Permissão de áudio negada');
        state = false;
        return;
      }

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
      final hasPermission = await _requestAudioPermission();
      if (!hasPermission) {
        debugPrint('Permissão de áudio necessária para reproduzir música');
        state = false;
        return;
      }
      await _initializeAudio();
      return;
    }

    try {
      if (_player.state == PlayerState.playing) {
        await _player.pause();
        state = false;
        _isMuted = true;
      } else {
        await _player.resume();
        state = true;
        _isMuted = false;
      }
    } catch (e) {
      debugPrint('Erro ao alternar áudio: $e');
    }
  }

  bool get isMuted => _isMuted;

  Future<bool> canReactivateAudio(double celestialTokens) async {
    return celestialTokens >= 5.0;
  }

  Future<void> reactivateAudioWithPayment() async {
    if (!_isMuted) return;
    
    try {
      await _player.resume();
      state = true;
      _isMuted = false;
    } catch (e) {
      debugPrint('Erro ao reativar áudio: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.01, 1.0);
      await _player.setVolume(clampedVolume);
    } catch (e) {
      debugPrint('Erro ao ajustar volume: $e');
    }
  }
}

class ClickSoundNotifier {
  final AudioPlayer _clickPlayer;

  ClickSoundNotifier(this._clickPlayer);

  Future<bool> _requestAudioPermission() async {
    if (kIsWeb) return true;
    
    final status = await Permission.audio.status;
    if (status.isGranted) return true;
    
    if (status.isDenied) {
      final result = await Permission.audio.request();
      return result.isGranted;
    }
    
    return false;
  }

  Future<void> playClickSound() async {
    try {
      final hasPermission = await _requestAudioPermission();
      if (!hasPermission) {
        debugPrint('Permissão de áudio necessária para tocar som');
        return;
      }

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
