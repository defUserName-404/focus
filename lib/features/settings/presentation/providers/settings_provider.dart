import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/audio_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';
import '../../../focus/domain/entities/session_state.dart';
import '../../../focus/presentation/providers/focus_providers.dart';
import '../../../focus/presentation/providers/focus_session_provider.dart';
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

@riverpod
class PreviewingIdNotifier extends _$PreviewingIdNotifier {
  @override
  String? build() {
    return null;
  }

  void set(String? id) {
    state = id;
  }
}

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

  Future<void> setFocusDuration(int minutes) async {
    await _repository.setValue(SettingsKeys.focusDurationMinutes, minutes.toString());
  }

  Future<void> setBreakDuration(int minutes) async {
    await _repository.setValue(SettingsKeys.breakDurationMinutes, minutes.toString());
  }

  Future<void> previewAmbience(SoundPreset preset) async {
    ref.read(previewingIdProvider.notifier).set(preset.id);

    // Pause session if running
    final session = ref.read(focusTimerProvider);
    final wasRunning = session?.state == SessionState.running || session?.state == SessionState.onBreak;
    if (wasRunning) {
      ref.read(focusTimerProvider.notifier).pauseSession();
    }

    getIt<AudioService>().startAmbience(preset);

    await Future.delayed(const Duration(seconds: 3));

    await getIt<AudioService>().stopAmbience();
    ref.read(previewingIdProvider.notifier).set(null);

    if (wasRunning) {
      // Resume session. Since we overwrote the bgPlayer track with the preview,
      // we must force a reload of the correct session ambience.
      ref.read(focusTimerProvider.notifier).resumeSession();
      // resumeSession() calls resumeAmbience() which resumes the *preview* track
      // if we don't fix it. So we reload the correct ambience immediately.
      ref.read(focusAudioCoordinatorProvider).reloadAmbience();
    }
  }

  Future<void> previewAlarm(SoundPreset preset) async {
    ref.read(previewingIdProvider.notifier).set(preset.id);

    // Pause session if running (to avoid noise overlap)
    final session = ref.read(focusTimerProvider);
    final wasRunning = session?.state == SessionState.running || session?.state == SessionState.onBreak;
    if (wasRunning) {
      ref.read(focusTimerProvider.notifier).pauseSession();
    }

    getIt<AudioService>().playAlarm(preset);

    await Future.delayed(const Duration(seconds: 2));
    ref.read(previewingIdProvider.notifier).set(null);

    if (wasRunning) {
      ref.read(focusTimerProvider.notifier).resumeSession();
    }
  }
}

/// Watches timer preferences (focus/break duration) reactively.
final timerSettingsProvider = StreamProvider<TimerPreferences>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchTimerPreferences();
});
