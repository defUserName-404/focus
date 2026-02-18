import 'dart:async';

/// No-op implementation of notification operations for platforms
/// that don't support native local notifications (Windows, Linux).
///
/// All methods are silent stubs — the app continues to work,
/// it just doesn't show system notifications.
class NoOpNotificationService {
  Future<void> init() async {}

  Future<void> showFocusNotification({
    required String title,
    required String body,
    required bool isRunning,
    int progressMax = 0,
    int progressCurrent = 0,
  }) async {}

  Future<void> showAlarmNotification({required String title, required String body}) async {}

  Future<void> cancelFocusNotification() async {}
}
