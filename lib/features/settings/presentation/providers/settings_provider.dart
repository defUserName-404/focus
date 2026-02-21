import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/common/result.dart';
import '../../../../core/constants/audio_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';
import '../../domain/entities/setting.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/services/settings_service.dart';

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
  late final SettingsService _service;
  late final AudioService _audioService;

  /// Incremented at the start of every preview call.
  /// Each async continuation captures its own generation value and bails out
  /// if a newer preview has since started — correctly handles any interleaving
  /// of previewAmbience / previewAlarm calls.
  int _previewGeneration = 0;

  @override
  FutureOr<AudioPreferences> build() async {
    _service = getIt<SettingsService>();
    _audioService = ref.watch(audioServiceProvider);
    return _service.getAudioPreferences();
  }

  // ---- Persistence ---------------------------------------------------------

  Future<void> setAlarmSound(String soundId) async {
    final result = await _service.setAlarmSound(soundId);
    switch (result) {
      case Success():
        state = AsyncValue.data(state.value?.copyWith(alarmSoundId: soundId) ?? AudioPreferences(alarmSoundId: soundId));
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> setAmbienceSound(String soundId) async {
    final result = await _service.setAmbienceSound(soundId);
    switch (result) {
      case Success():
        state = AsyncValue.data(
          state.value?.copyWith(ambienceSoundId: soundId) ?? AudioPreferences(ambienceSoundId: soundId),
        );
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> setAmbienceVolume(double volume) async {
    final result = await _service.setAmbienceVolume(volume);
    switch (result) {
      case Success():
        state = AsyncValue.data(state.value?.copyWith(ambienceVolume: volume) ?? AudioPreferences(ambienceVolume: volume));
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> setAmbienceEnabled(bool enabled) async {
    final result = await _service.setAmbienceEnabled(enabled);
    switch (result) {
      case Success():
        state = AsyncValue.data(
          state.value?.copyWith(ambienceEnabled: enabled) ?? AudioPreferences(ambienceEnabled: enabled),
        );
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> setFocusDuration(int minutes) async {
    final result = await _service.setFocusDuration(minutes);
    if (result case Failure(:final failure)) {
      state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> setBreakDuration(int minutes) async {
    final result = await _service.setBreakDuration(minutes);
    if (result case Failure(:final failure)) {
      state = AsyncValue.error(failure, StackTrace.current);
    }
  }

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
