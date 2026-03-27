import 'dart:async';

/// Abstract interface for notification services.
///
/// Implemented by [NotificationService] for platforms with native notifications,
/// and [NoOpNotificationService] for platforms without notification support.
abstract class INotificationService {
  /// Initialize the notification service.
  Future<void> init();

  /// Show the persistent focus session notification with media-style controls.
  Future<void> showFocusNotification({
    required String title,
    required String body,
    required bool isRunning,
    int progressMax = 0,
    int progressCurrent = 0,
  });

  /// Show a one-shot alarm notification (non-persistent).
  Future<void> showAlarmNotification({required String title, required String body});

  /// Schedule a one-shot notification for a future date/time.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  });

  /// Cancel a scheduled notification by id.
  Future<void> cancelNotification(int id);

  /// Cancel the persistent focus session notification.
  Future<void> cancelFocusNotification();

  /// Stream of notification action IDs (pause, resume, stop, skip).
  Stream<String> get actionStream;

  /// Stream of notification body taps (payload strings).
  Stream<String> get tapStream;
}
