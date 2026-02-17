import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/audio_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';
import '../../domain/entities/setting.dart';
import '../../domain/repositories/i_settings_repository.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
ISettingsRepository settingsRepository(Ref ref) => getIt<ISettingsRepository>();

/// Injected so the notifier never calls getIt directly.
@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) => getIt<AudioService>();

final audioPreferencesProvider = StreamProvider<AudioPreferences>((ref) {
  return ref.watch(settingsRepositoryProvider).watchAudioPreferences();
});

@riverpod
class PreviewingIdNotifier extends _$PreviewingIdNotifier {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

typedef AccordionState = ({bool ambience, bool alarm});

@riverpod
class AccordionExpandedNotifier extends _$AccordionExpandedNotifier {
  @override
  AccordionState build() => (ambience: false, alarm: false);

  void toggleAmbience() => state = (ambience: !state.ambience, alarm: state.alarm);

  void toggleAlarm() => state = (ambience: state.ambience, alarm: !state.alarm);
}

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  late final ISettingsRepository _repository;
  late final AudioService _audioService;

  bool _previewCancelled = false;

  @override
  FutureOr<AudioPreferences> build() async {
    _repository = ref.watch(settingsRepositoryProvider);
    _audioService = ref.watch(audioServiceProvider);
    return _repository.getAudioPreferences();
  }

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
  // AudioService owns a dedicated _previewPlayer that is completely separate
  // from _bgPlayer (session ambience). Because of this:
  //   - Session ambience keeps playing undisturbed during previews.
  //   - No pause/resume/reloadAmbience calls are needed here.
  //   - _previewCancelled only guards the delayed set(null) call so rapid
  //     successive taps don't leave a stale null after the new preview has
  //     already set its own ID.

  Future<void> previewAmbience(SoundPreset preset) async {
    _previewCancelled = true; // short-circuit any running delay
    await _audioService.stopPreview(); // stop previous audio immediately

    _previewCancelled = false;
    ref.read(previewingIdProvider.notifier).set(preset.id);

    await _audioService.startPreview(preset);

    await Future.delayed(const Duration(seconds: 3));
    if (_previewCancelled) return;

    await _audioService.stopPreview();
    ref.read(previewingIdProvider.notifier).set(null);
  }

  Future<void> previewAlarm(SoundPreset preset) async {
    _previewCancelled = true;
    await _audioService.stopPreview();

    _previewCancelled = false;
    ref.read(previewingIdProvider.notifier).set(preset.id);

    await _audioService.startPreview(preset);

    await Future.delayed(const Duration(seconds: 2));
    if (_previewCancelled) return;

    ref.read(previewingIdProvider.notifier).set(null);
  }
}

final timerSettingsProvider = StreamProvider<TimerPreferences>((ref) {
  return ref.watch(settingsRepositoryProvider).watchTimerPreferences();
});
