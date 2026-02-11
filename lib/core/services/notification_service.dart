import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> showSessionNotification({
    required int id,
    required String title,
    required String body,
    bool isPersistent = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'focus_session_channel',
      'Focus Session',
      channelDescription: 'Ongoing focus session notifications',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: isPersistent,
      autoCancel: !isPersistent,
      onlyAlertOnce: true,
      showWhen: true,
      usesChronometer: isPersistent,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  Future<void> cancelSessionNotification(int id) async {
    await _notifications.cancel(id);
  }
}
