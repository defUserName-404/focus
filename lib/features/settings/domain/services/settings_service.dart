import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/setting.dart';
import '../../domain/repositories/i_settings_repository.dart';

final _log = LogService.instance;

/// Domain service for user settings / preferences.
///
/// Provides typed convenience methods over the key-value store.
/// Used by providers instead of calling the repository directly.
/// Read methods return their values directly; write methods return
/// [Result<void>] so callers can handle DB failures without exceptions.
class SettingsService {
  final ISettingsRepository _repository;

  SettingsService(this._repository);

  //  Generic key-value access

  Future<String?> getValue(String key) => _repository.getValue(key);

  Stream<String?> watchValue(String key) => _repository.watchValue(key);

  Future<Result<void>> setValue(String key, String value) => _writeValue(key, value, tag: 'setValue');

  //  Audio preferences

  Future<AudioPreferences> getAudioPreferences() => _repository.getAudioPreferences();

  Stream<AudioPreferences> watchAudioPreferences() => _repository.watchAudioPreferences();

  Future<Result<void>> setAlarmSound(String soundId) =>
      _writeValue(SettingsKeys.alarmSoundId, soundId, tag: 'setAlarmSound');

  Future<Result<void>> setAmbienceSound(String soundId) =>
      _writeValue(SettingsKeys.ambienceSoundId, soundId, tag: 'setAmbienceSound');

  Future<Result<void>> setAmbienceVolume(double volume) =>
      _writeValue(SettingsKeys.ambienceVolume, volume.toString(), tag: 'setAmbienceVolume');

  Future<Result<void>> setAmbienceEnabled(bool enabled) =>
      _writeValue(SettingsKeys.ambienceEnabled, enabled.toString(), tag: 'setAmbienceEnabled');

  //  Timer preferences

  Future<TimerPreferences> getTimerPreferences() => _repository.getTimerPreferences();

  Stream<TimerPreferences> watchTimerPreferences() => _repository.watchTimerPreferences();

  Future<Result<void>> setFocusDuration(int minutes) =>
      _writeValue(SettingsKeys.focusDurationMinutes, minutes.toString(), tag: 'setFocusDuration');

  Future<Result<void>> setBreakDuration(int minutes) =>
      _writeValue(SettingsKeys.breakDurationMinutes, minutes.toString(), tag: 'setBreakDuration');

  //  Desktop preferences

  Future<DesktopPreferences> getDesktopPreferences() => _repository.getDesktopPreferences();

  Stream<DesktopPreferences> watchDesktopPreferences() => _repository.watchDesktopPreferences();

  Future<Result<void>> setDesktopTrayEnabled(bool enabled) =>
      _writeValue(SettingsKeys.desktopTrayEnabled, enabled.toString(), tag: 'setDesktopTrayEnabled');

  Future<Result<void>> setDesktopLaunchAtStartupEnabled(bool enabled) => _writeValue(
    SettingsKeys.desktopLaunchAtStartupEnabled,
    enabled.toString(),
    tag: 'setDesktopLaunchAtStartupEnabled',
  );

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  Future<Result<void>> _writeValue(String key, String value, {required String tag}) async {
    try {
      await _repository.setValue(key, value);
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to write setting "$key" via $tag', tag: 'SettingsService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to save setting: $key', error: e, stackTrace: st));
    }
  }
}
