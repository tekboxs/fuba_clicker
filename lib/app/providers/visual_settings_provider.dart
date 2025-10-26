import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/save_service.dart';

class VisualSettings {
  final bool disableAnimations;
  final bool disableParticles;
  final bool disableParallax;
  final bool disableEffects;
  final bool lowQualityMode;
  final bool hideAccessories;

  const VisualSettings({
    this.disableAnimations = false,
    this.disableParticles = false,
    this.disableParallax = false,
    this.disableEffects = false,
    this.lowQualityMode = false,
    this.hideAccessories = false,
  });

  VisualSettings copyWith({
    bool? disableAnimations,
    bool? disableParticles,
    bool? disableParallax,
    bool? disableEffects,
    bool? lowQualityMode,
    bool? hideAccessories,
  }) {
    return VisualSettings(
      disableAnimations: disableAnimations ?? this.disableAnimations,
      disableParticles: disableParticles ?? this.disableParticles,
      disableParallax: disableParallax ?? this.disableParallax,
      disableEffects: disableEffects ?? this.disableEffects,
      lowQualityMode: lowQualityMode ?? this.lowQualityMode,
      hideAccessories: hideAccessories ?? this.hideAccessories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disableAnimations': disableAnimations,
      'disableParticles': disableParticles,
      'disableParallax': disableParallax,
      'disableEffects': disableEffects,
      'lowQualityMode': lowQualityMode,
      'hideAccessories': hideAccessories,
    };
  }

  factory VisualSettings.fromJson(Map<String, dynamic> json) {
    return VisualSettings(
      disableAnimations: json['disableAnimations'] ?? false,
      disableParticles: json['disableParticles'] ?? false,
      disableParallax: json['disableParallax'] ?? false,
      disableEffects: json['disableEffects'] ?? false,
      lowQualityMode: json['lowQualityMode'] ?? false,
      hideAccessories: json['hideAccessories'] ?? false,
    );
  }

  bool get isPerformanceMode => 
      disableAnimations || disableParticles || disableParallax || 
      disableEffects || lowQualityMode || hideAccessories;
}

class VisualSettingsNotifier extends StateNotifier<VisualSettings> {
  VisualSettingsNotifier() : super(const VisualSettings());

  void updateSettings(VisualSettings newSettings) {
    state = newSettings;
    _saveSettings();
  }

  void toggleAnimation() {
    state = state.copyWith(disableAnimations: !state.disableAnimations);
    _saveSettings();
  }

  void toggleParticles() {
    state = state.copyWith(disableParticles: !state.disableParticles);
    _saveSettings();
  }

  void toggleParallax() {
    state = state.copyWith(disableParallax: !state.disableParallax);
    _saveSettings();
  }

  void toggleEffects() {
    state = state.copyWith(disableEffects: !state.disableEffects);
    _saveSettings();
  }

  void toggleLowQuality() {
    state = state.copyWith(lowQualityMode: !state.lowQualityMode);
    _saveSettings();
  }

  void toggleAccessories() {
    state = state.copyWith(hideAccessories: !state.hideAccessories);
    _saveSettings();
  }

  void enablePerformanceMode() {
    state = const VisualSettings(
      disableAnimations: true,
      disableParticles: true,
      disableParallax: true,
      disableEffects: true,
      lowQualityMode: true,
      hideAccessories: true,
    );
    _saveSettings();
  }

  void disablePerformanceMode() {
    state = const VisualSettings();
    _saveSettings();
  }

  void loadSettings(Map<String, dynamic>? settings) {
    if (settings != null) {
      state = VisualSettings.fromJson(settings);
    }
  }

  void _saveSettings() {
    SaveService().saveVisualSettings(state.toJson());
  }
}

final visualSettingsProvider = StateNotifierProvider<VisualSettingsNotifier, VisualSettings>((ref) {
  return VisualSettingsNotifier();
});

final disableAnimationsProvider = Provider<bool>((ref) {
  return ref.watch(visualSettingsProvider).disableAnimations;
});

final disableParticlesProvider = Provider<bool>((ref) {
  return ref.watch(visualSettingsProvider).disableParticles;
});

final disableParallaxProvider = Provider<bool>((ref) {
  return ref.watch(visualSettingsProvider).disableParallax;
});

final disableEffectsProvider = Provider<bool>((ref) {
  return ref.watch(visualSettingsProvider).disableEffects;
});

final lowQualityModeProvider = Provider<bool>((ref) {
  return ref.watch(visualSettingsProvider).lowQualityMode;
});

final hideAccessoriesProvider = Provider<bool>((ref) {
  return ref.watch(visualSettingsProvider).hideAccessories;
});

final isPerformanceModeProvider = Provider<bool>((ref) {
  return ref.watch(visualSettingsProvider).isPerformanceMode;
});
