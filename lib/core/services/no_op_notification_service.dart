import 'dart:async';

import 'i_notification_service.dart';

/// No-op implementation of notification operations for platforms
/// that don't support native local notifications (Windows, Linux, Web).
///
/// All methods are silent stubs — the app continues to work,
/// it just doesn't show system notifications.
class NoOpNotificationService implements INotificationService {
  // Empty broadcast streams that never emit
  final StreamController<String> _actionController = StreamController<String>.broadcast();
  final StreamController<String> _tapController = StreamController<String>.broadcast();

  @override
  Stream<String> get actionStream => _actionController.stream;

  @override
  Stream<String> get tapStream => _tapController.stream;

  @override
  Future<void> init() async {}

  @override
  Future<void> showFocusNotification({
    required String title,
    required String body,
    required bool isRunning,
    int progressMax = 0,
    int progressCurrent = 0,
  }) async {}

  @override
  Future<void> showAlarmNotification({required String title, required String body}) async {}

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> cancelFocusNotification() async {}

  void dispose() {
    _actionController.close();
    _tapController.close();
  }
}
