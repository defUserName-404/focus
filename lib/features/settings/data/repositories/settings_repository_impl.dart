import '../../../../core/services/log_service.dart';
import '../../domain/entities/setting.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

final _log = LogService.instance;

class SettingsRepositoryImpl implements ISettingsRepository {
  final ISettingsLocalDataSource _local;

  SettingsRepositoryImpl(this._local);

  @override
  Future<String?> getValue(String key) => _local.getValue(key);

  @override
  Future<void> setValue(String key, String value) async {
    try {
      await _local.setValue(key, value);
    } catch (e, st) {
      _log.error('Failed to write setting "$key"', tag: 'SettingsRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<String?> watchValue(String key) => _local.watchValue(key);

  @override
  Future<Map<String, String>> getAll() => _local.getAll();

  @override
  Stream<Map<String, String>> watchAll() => _local.watchAll();

  @override
  Future<AudioPreferences> getAudioPreferences() async {
    final all = await _local.getAll();
    return _decodeAudioPreferences(all);
  }

  @override
  Stream<AudioPreferences> watchAudioPreferences() {
    return _local.watchAll().map(_decodeAudioPreferences);
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

  /// Decodes an [AudioPreferences] object from a raw settings map.
  ///
  /// Lives here (rather than in a dedicated mapper file) because the
  /// settings store is a generic key-value table — there is no generated
  /// Drift data class to extend. Defaults are applied using `??` so parsing
  /// failures are silent and non-crashing; the stored values are all
  /// user-controlled primitives.
  AudioPreferences _decodeAudioPreferences(Map<String, String> all) {
    return AudioPreferences(
      alarmSoundId: all[SettingsKeys.alarmSoundId],
      ambienceSoundId: all[SettingsKeys.ambienceSoundId],
      ambienceVolume: double.tryParse(all[SettingsKeys.ambienceVolume] ?? '') ?? 0.5,
      ambienceEnabled: (all[SettingsKeys.ambienceEnabled] ?? 'true') == 'true',
    );
  }

  /// Decodes a [TimerPreferences] object from a raw settings map.
  ///
  /// Same rationale as [_decodeAudioPreferences] — no external mapper needed.
  TimerPreferences _decodeTimerPreferences(Map<String, String> all) {
    return TimerPreferences(
      focusDurationMinutes: int.tryParse(all[SettingsKeys.focusDurationMinutes] ?? '') ?? 25,
      breakDurationMinutes: int.tryParse(all[SettingsKeys.breakDurationMinutes] ?? '') ?? 5,
    );
  }
}
