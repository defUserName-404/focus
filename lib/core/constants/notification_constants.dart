/// Constants for notification channels, IDs, and action identifiers.
abstract final class NotificationConstants {
  // ── Channels ────────────────────────────────────────────────────────────

  static const String focusChannelId = 'focus_session_channel';
  static const String focusChannelName = 'Focus Session';
  static const String focusChannelDesc = 'Ongoing focus session notifications';

  static const String alarmChannelId = 'focus_alarm_channel';
  static const String alarmChannelName = 'Focus Alarms';
  static const String alarmChannelDesc =
      'Alarm notifications for session transitions';

  // ── Notification IDs ──────────────────────────────────────────────────────

  static const int focusSessionId = 1001;
  static const int alarmId = 1002;

  // ── Action IDs (notification buttons) ─────────────────────────────────────

  static const String actionPause = 'focus_pause';
  static const String actionResume = 'focus_resume';
  static const String actionStop = 'focus_stop';
  static const String actionSkip = 'focus_skip';
}
