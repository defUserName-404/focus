import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/audio_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';
import '../../domain/entities/setting.dart';
import '../../domain/repositories/i_settings_repository.dart';

part 'settings_provider.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
ISettingsRepository settingsRepository(Ref ref) => getIt<ISettingsRepository>();

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) => getIt<AudioService>();

// ---------------------------------------------------------------------------
// Audio preferences (reactive stream — used outside settings if needed)
// ---------------------------------------------------------------------------

final audioPreferencesProvider = StreamProvider<AudioPreferences>((ref) {
  return ref.watch(settingsRepositoryProvider).watchAudioPreferences();
});

// ---------------------------------------------------------------------------
// Preview state
// ---------------------------------------------------------------------------

@riverpod
class PreviewingIdNotifier extends _$PreviewingIdNotifier {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

// ---------------------------------------------------------------------------
// Settings notifier
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  late final ISettingsRepository _repository;
  late final AudioService _audioService;

  /// Incremented at the start of every preview call.
  /// Each async continuation captures its own generation value and bails out
  /// if a newer preview has since started — correctly handles any interleaving
  /// of previewAmbience / previewAlarm calls.
  int _previewGeneration = 0;

  @override
  FutureOr<AudioPreferences> build() async {
    _repository = ref.watch(settingsRepositoryProvider);
    _audioService = ref.watch(audioServiceProvider);
    return _repository.getAudioPreferences();
  }

  // ---- Persistence ---------------------------------------------------------

  Future<void> setAlarmSound(String soundId) async {
    await _repository.setValue(SettingsKeys.alarmSoundId, soundId);
    state = AsyncValue.data(state.value?.copyWith(alarmSoundId: soundId) ?? AudioPreferences(alarmSoundId: soundId));
  }

  Future<void> setAmbienceSound(String soundId) async {
    await _repository.setValue(SettingsKeys.ambienceSoundId, soundId);
    state = AsyncValue.data(
      state.value?.copyWith(ambienceSoundId: soundId) ?? AudioPreferences(ambienceSoundId: soundId),
    );
  }

  Future<void> setAmbienceVolume(double volume) async {
    await _repository.setValue(SettingsKeys.ambienceVolume, volume.toString());
    state = AsyncValue.data(state.value?.copyWith(ambienceVolume: volume) ?? AudioPreferences(ambienceVolume: volume));
  }

  Future<void> setAmbienceEnabled(bool enabled) async {
    await _repository.setValue(SettingsKeys.ambienceEnabled, enabled.toString());
    state = AsyncValue.data(
      state.value?.copyWith(ambienceEnabled: enabled) ?? AudioPreferences(ambienceEnabled: enabled),
    );
  }

  Future<void> setFocusDuration(int minutes) async =>
      _repository.setValue(SettingsKeys.focusDurationMinutes, minutes.toString());

  Future<void> setBreakDuration(int minutes) async =>
      _repository.setValue(SettingsKeys.breakDurationMinutes, minutes.toString());

  // ---- Preview logic -------------------------------------------------------
  //
  // AudioService._previewPlayer is separate from _bgPlayer, so session
  // ambience is never interrupted. No pause/resume/reloadAmbience needed.
  //
  // The generation counter handles all interleaving cases:
  //   - rapid same-type taps (ambience → ambience)
  //   - cross-type taps (ambience → alarm)
  // In every case the older delayed future sees a stale generation and exits
  // without touching previewingIdProvider.

  Future<void> previewAmbience(SoundPreset preset) async {
    final generation = ++_previewGeneration;
    await _audioService.stopPreview();

    ref.read(previewingIdProvider.notifier).set(preset.id);
    await _audioService.startPreview(preset);

    await Future.delayed(const Duration(seconds: 3));
    if (_previewGeneration != generation) return;

    await _audioService.stopPreview();
    ref.read(previewingIdProvider.notifier).set(null);
  }

  Future<void> previewAlarm(SoundPreset preset) async {
    final generation = ++_previewGeneration;
    await _audioService.stopPreview();

    ref.read(previewingIdProvider.notifier).set(preset.id);
    await _audioService.startPreview(preset);

    await Future.delayed(const Duration(seconds: 2));
    if (_previewGeneration != generation) return;

    ref.read(previewingIdProvider.notifier).set(null);
  }
}

// ---------------------------------------------------------------------------
// Timer preferences (reactive stream)
// ---------------------------------------------------------------------------

final timerSettingsProvider = StreamProvider<TimerPreferences>((ref) {
  return ref.watch(settingsRepositoryProvider).watchTimerPreferences();
});
