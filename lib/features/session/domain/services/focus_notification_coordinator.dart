import 'dart:async';

import '../../../../core/services/notification_service.dart';

/// Coordinates all notification interactions for focus sessions.
///
/// Encapsulates notification content/messaging so the [FocusTimer]
/// doesn't need to know about notification titles, bodies, or action routing.
class FocusNotificationCoordinator {
  final NotificationService _notificationService;

  FocusNotificationCoordinator(this._notificationService);

  /// Show the "Break Time!" alarm notification.
  Future<void> showBreakNotification(int breakMinutes) {
    return _notificationService.showAlarmNotification(
      title: 'Break Time!',
      body: 'Focus complete. Take a ${breakMinutes}min break.',
    );
  }

  /// Show the "Break Over!" notification when auto-starting next cycle.
  Future<void> showNextCycleNotification() {
    return _notificationService.showAlarmNotification(
      title: 'Break Over!',
      body: 'Starting next focus session automatically.',
    );
  }

  /// Show notification when focus cycle is manually stopped.
  Future<void> showCycleStoppedNotification() {
    return _notificationService.showAlarmNotification(
      title: 'Focus Cycle Ended',
      body: 'Nice work! You stopped the Pomodoro cycle.',
    );
  }

  /// Show notification when session is completed early.
  Future<void> showEarlyCompleteNotification() {
    return _notificationService.showAlarmNotification(
      title: 'Session Complete!',
      body: 'Completed early — great focus!',
    );
  }

  /// Show notification when both task and session are completed.
  Future<void> showTaskCompleteNotification() {
    return _notificationService.showAlarmNotification(
      title: 'Task Complete!',
      body: 'Great work — session and task both done.',
    );
  }

  /// Cancel the persistent focus session notification.
  Future<void> cancelFocusNotification() {
    return _notificationService.cancelFocusNotification();
  }

  /// Listen for notification action taps (pause/resume/stop/skip).
  /// Returns a [StreamSubscription] that the caller must manage.
  StreamSubscription<String> listenForActions(void Function(String) handler) {
    return NotificationService.actionStream.listen(handler);
  }
}
