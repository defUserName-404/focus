import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/audio_assets.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/setting.dart';
import '../../domain/repositories/i_settings_repository.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
ISettingsRepository settingsRepository(Ref ref) {
  return getIt<ISettingsRepository>();
}

/// Watches audio preferences reactively.
final audioPreferencesProvider = StreamProvider<AudioPreferences>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchAudioPreferences();
});

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  late final ISettingsRepository _repository;

  @override
  FutureOr<AudioPreferences> build() async {
    _repository = ref.watch(settingsRepositoryProvider);
    return _repository.getAudioPreferences();
  }

  Future<void> setAlarmSound(String soundId) async {
    await _repository.setValue(SettingsKeys.alarmSoundId, soundId);
    final updated = state.value?.copyWith(alarmSoundId: soundId) ?? AudioPreferences(alarmSoundId: soundId);
    state = AsyncValue.data(updated);
  }

  Future<void> setAmbienceSound(String soundId) async {
    await _repository.setValue(SettingsKeys.ambienceSoundId, soundId);
    final updated = state.value?.copyWith(ambienceSoundId: soundId) ?? AudioPreferences(ambienceSoundId: soundId);
    state = AsyncValue.data(updated);
  }

  Future<void> setAmbienceVolume(double volume) async {
    await _repository.setValue(SettingsKeys.ambienceVolume, volume.toString());
    final updated = state.value?.copyWith(ambienceVolume: volume) ?? AudioPreferences(ambienceVolume: volume);
    state = AsyncValue.data(updated);
  }

  Future<void> setAmbienceEnabled(bool enabled) async {
    await _repository.setValue(SettingsKeys.ambienceEnabled, enabled.toString());
    final updated = state.value?.copyWith(ambienceEnabled: enabled) ?? AudioPreferences(ambienceEnabled: enabled);
    state = AsyncValue.data(updated);
  }

  /// Resolve the current alarm [SoundPreset] from preferences.
  SoundPreset getAlarmPreset(AudioPreferences prefs) {
    if (prefs.alarmSoundId != null) {
      final found = AudioAssets.findById(prefs.alarmSoundId!);
      if (found != null) return found;
    }
    return AudioAssets.defaultAlarm;
  }

  /// Resolve the current ambience [SoundPreset] from preferences.
  SoundPreset getAmbiencePreset(AudioPreferences prefs) {
    if (prefs.ambienceSoundId != null) {
      final found = AudioAssets.findById(prefs.ambienceSoundId!);
      if (found != null) return found;
    }
    return AudioAssets.defaultAmbience;
  }
}
