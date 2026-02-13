import '../entities/setting.dart';

abstract class ISettingsRepository {
  /// Get a single setting value by key.
  Future<String?> getValue(String key);

  /// Set a setting value by key.
  Future<void> setValue(String key, String value);

  /// Watch a single setting value reactively.
  Stream<String?> watchValue(String key);

  /// Get all settings as a map.
  Future<Map<String, String>> getAll();

  /// Watch all settings as a map.
  Stream<Map<String, String>> watchAll();

  /// Convenience: get decoded audio preferences.
  Future<AudioPreferences> getAudioPreferences();

  /// Convenience: watch decoded audio preferences reactively.
  Stream<AudioPreferences> watchAudioPreferences();

  /// Convenience: get decoded timer (Pomodoro) preferences.
  Future<TimerPreferences> getTimerPreferences();

  /// Convenience: watch decoded timer preferences reactively.
  Stream<TimerPreferences> watchTimerPreferences();
}
