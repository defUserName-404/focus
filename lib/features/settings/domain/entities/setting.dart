/// Known setting keys used throughout the app.
///
/// Centralises all preference keys to avoid magic strings.
abstract final class SettingsKeys {
  /// The ID of the selected alarm sound preset.
  static const String alarmSoundId = 'alarm_sound_id';

  /// The ID of the selected ambience/white-noise sound preset.
  static const String ambienceSoundId = 'ambience_sound_id';

  /// Ambience volume level (0.0 – 1.0), stored as a string.
  static const String ambienceVolume = 'ambience_volume';

  /// Whether ambience should auto-play when a focus session starts.
  static const String ambienceEnabled = 'ambience_enabled';

  /// Focus (Pomodoro) duration in minutes.
  static const String focusDurationMinutes = 'focus_duration_minutes';

  /// Break duration in minutes.
  static const String breakDurationMinutes = 'break_duration_minutes';
}

/// Domain entity representing a user preference.
class Setting {
  final String key;
  final String value;

  const Setting({required this.key, required this.value});
}

/// Convenience wrapper holding all decoded audio preferences.
class AudioPreferences {
  final String? alarmSoundId;
  final String? ambienceSoundId;
  final double ambienceVolume;
  final bool ambienceEnabled;

  const AudioPreferences({
    this.alarmSoundId,
    this.ambienceSoundId,
    this.ambienceVolume = 0.5,
    this.ambienceEnabled = true,
  });

  AudioPreferences copyWith({
    String? alarmSoundId,
    String? ambienceSoundId,
    double? ambienceVolume,
    bool? ambienceEnabled,
  }) {
    return AudioPreferences(
      alarmSoundId: alarmSoundId ?? this.alarmSoundId,
      ambienceSoundId: ambienceSoundId ?? this.ambienceSoundId,
      ambienceVolume: ambienceVolume ?? this.ambienceVolume,
      ambienceEnabled: ambienceEnabled ?? this.ambienceEnabled,
    );
  }
}

/// Convenience wrapper for Pomodoro timer durations.
class TimerPreferences {
  final int focusDurationMinutes;
  final int breakDurationMinutes;

  const TimerPreferences({this.focusDurationMinutes = 25, this.breakDurationMinutes = 5});

  TimerPreferences copyWith({int? focusDurationMinutes, int? breakDurationMinutes}) {
    return TimerPreferences(
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
    );
  }
}
