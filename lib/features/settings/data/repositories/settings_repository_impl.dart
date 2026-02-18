import '../../domain/entities/setting.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  final ISettingsLocalDataSource _local;

  SettingsRepositoryImpl(this._local);

  @override
  Future<String?> getValue(String key) => _local.getValue(key);

  @override
  Future<void> setValue(String key, String value) => _local.setValue(key, value);

  @override
  Stream<String?> watchValue(String key) => _local.watchValue(key);

  @override
  Future<Map<String, String>> getAll() => _local.getAll();

  @override
  Stream<Map<String, String>> watchAll() => _local.watchAll();

  @override
  Future<AudioPreferences> getAudioPreferences() async {
    final all = await _local.getAll();
    return _decodePreferences(all);
  }

  @override
  Stream<AudioPreferences> watchAudioPreferences() {
    return _local.watchAll().map(_decodePreferences);
  }

  @override
  Future<TimerPreferences> getTimerPreferences() async {
    final all = await _local.getAll();
    return _decodeTimerPreferences(all);
  }

  @override
  Stream<TimerPreferences> watchTimerPreferences() {
    return _local.watchAll().map(_decodeTimerPreferences);
  }

  AudioPreferences _decodePreferences(Map<String, String> all) {
    return AudioPreferences(
      alarmSoundId: all[SettingsKeys.alarmSoundId],
      ambienceSoundId: all[SettingsKeys.ambienceSoundId],
      ambienceVolume: double.tryParse(all[SettingsKeys.ambienceVolume] ?? '') ?? 0.5,
      ambienceEnabled: (all[SettingsKeys.ambienceEnabled] ?? 'true') == 'true',
    );
  }

  TimerPreferences _decodeTimerPreferences(Map<String, String> all) {
    return TimerPreferences(
      focusDurationMinutes: int.tryParse(all[SettingsKeys.focusDurationMinutes] ?? '') ?? 25,
      breakDurationMinutes: int.tryParse(all[SettingsKeys.breakDurationMinutes] ?? '') ?? 5,
    );
  }
}
