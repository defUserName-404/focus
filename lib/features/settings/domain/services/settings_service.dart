import '../../domain/entities/setting.dart';
import '../../domain/repositories/i_settings_repository.dart';

/// Domain service for user settings / preferences.
///
/// Provides typed convenience methods over the key-value store.
/// Used by providers instead of calling the repository directly.
class SettingsService {
  final ISettingsRepository _repository;

  SettingsService(this._repository);

  //  Audio preferences

  Future<AudioPreferences> getAudioPreferences() => _repository.getAudioPreferences();

  Stream<AudioPreferences> watchAudioPreferences() => _repository.watchAudioPreferences();

  Future<void> setAlarmSound(String soundId) => _repository.setValue(SettingsKeys.alarmSoundId, soundId);

  Future<void> setAmbienceSound(String soundId) => _repository.setValue(SettingsKeys.ambienceSoundId, soundId);

  Future<void> setAmbienceVolume(double volume) => _repository.setValue(SettingsKeys.ambienceVolume, volume.toString());

  Future<void> setAmbienceEnabled(bool enabled) =>
      _repository.setValue(SettingsKeys.ambienceEnabled, enabled.toString());

  //  Timer preferences

  Future<TimerPreferences> getTimerPreferences() => _repository.getTimerPreferences();

  Stream<TimerPreferences> watchTimerPreferences() => _repository.watchTimerPreferences();

  Future<void> setFocusDuration(int minutes) =>
      _repository.setValue(SettingsKeys.focusDurationMinutes, minutes.toString());

  Future<void> setBreakDuration(int minutes) =>
      _repository.setValue(SettingsKeys.breakDurationMinutes, minutes.toString());
}
