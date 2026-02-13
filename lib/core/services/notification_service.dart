import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/notification_constants.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Broadcast stream of notification action IDs (pause, resume, stop).
  static final StreamController<String> _actionController =
      StreamController<String>.broadcast();
  static Stream<String> get actionStream => _actionController.stream;

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request notification permission on Android 13+.
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  static void _onNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    if (actionId != null && actionId.isNotEmpty) {
      _actionController.add(actionId);
    }
  }

  /// Show the persistent focus session notification with media-style controls
  /// and an optional progress bar.
  Future<void> showFocusNotification({
    required String title,
    required String body,
    required bool isRunning,
    int progressMax = 0,
    int progressCurrent = 0,
  }) async {
    final actions = <AndroidNotificationAction>[
      if (isRunning)
        const AndroidNotificationAction(
          NotificationConstants.actionPause,
          'Pause',
          showsUserInterface: false,
        )
      else
        const AndroidNotificationAction(
          NotificationConstants.actionResume,
          'Resume',
          showsUserInterface: false,
        ),
      const AndroidNotificationAction(
        NotificationConstants.actionSkip,
        'Skip',
        showsUserInterface: false,
      ),
      const AndroidNotificationAction(
        NotificationConstants.actionStop,
        'Stop',
        showsUserInterface: false,
      ),
    ];

    final showProgress = progressMax > 0;

    final androidDetails = AndroidNotificationDetails(
      NotificationConstants.focusChannelId,
      NotificationConstants.focusChannelName,
      channelDescription: NotificationConstants.focusChannelDesc,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      usesChronometer: true,
      showProgress: showProgress,
      maxProgress: showProgress ? progressMax : 0,
      progress: showProgress ? progressCurrent : 0,
      category: AndroidNotificationCategory.progress,
      actions: actions,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      id: NotificationConstants.focusSessionId,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Show a one-shot alarm notification (non-persistent).
  Future<void> showAlarmNotification({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      NotificationConstants.alarmChannelId,
      NotificationConstants.alarmChannelName,
      channelDescription: NotificationConstants.alarmChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      id: NotificationConstants.alarmId,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Show a basic session notification (legacy).
  Future<void> showSessionNotification({
    required int id,
    required String title,
    required String body,
    bool isPersistent = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      NotificationConstants.focusChannelId,
      NotificationConstants.focusChannelName,
      channelDescription: NotificationConstants.focusChannelDesc,
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

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  Future<void> cancelFocusNotification() async {
    await _notifications.cancel(id: NotificationConstants.focusSessionId);
  }

  Future<void> cancelSessionNotification(int id) async {
    await _notifications.cancel(id: id);
  }
}
