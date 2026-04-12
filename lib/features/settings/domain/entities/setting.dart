import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

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

  /// Whether closing the desktop app should minimize to tray.
  static const String desktopTrayEnabled = 'desktop_tray_enabled';

  /// Whether the desktop app should auto-launch after login/startup.
  static const String desktopLaunchAtStartupEnabled = 'desktop_launch_at_startup_enabled';
}

/// Domain entity representing a user preference.
@immutable
class Setting extends Equatable {
  final String key;
  final String value;

  const Setting({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

/// Convenience wrapper holding all decoded audio preferences.
@immutable
class AudioPreferences extends Equatable {
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

  @override
  List<Object?> get props => [alarmSoundId, ambienceSoundId, ambienceVolume, ambienceEnabled];
}

/// Convenience wrapper for Pomodoro timer durations.
@immutable
class TimerPreferences extends Equatable {
  final int focusDurationMinutes;
  final int breakDurationMinutes;

  const TimerPreferences({this.focusDurationMinutes = 25, this.breakDurationMinutes = 5});

  TimerPreferences copyWith({int? focusDurationMinutes, int? breakDurationMinutes}) {
    return TimerPreferences(
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
    );
  }

  @override
  List<Object?> get props => [focusDurationMinutes, breakDurationMinutes];
}

/// Convenience wrapper for desktop-specific behavior preferences.
@immutable
class DesktopPreferences extends Equatable {
  final bool trayEnabled;
  final bool launchAtStartupEnabled;

  const DesktopPreferences({this.trayEnabled = true, this.launchAtStartupEnabled = true});

  DesktopPreferences copyWith({bool? trayEnabled, bool? launchAtStartupEnabled}) {
    return DesktopPreferences(
      trayEnabled: trayEnabled ?? this.trayEnabled,
      launchAtStartupEnabled: launchAtStartupEnabled ?? this.launchAtStartupEnabled,
    );
  }

  @override
  List<Object?> get props => [trayEnabled, launchAtStartupEnabled];
}
