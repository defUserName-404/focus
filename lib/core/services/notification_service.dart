import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/notification_constants.dart';
import '../routing/navigator_key.dart';

/// Top-level handler required by flutter_local_notifications for
/// notification actions received while the app is in the background.
/// Must be a top-level or static function.
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  final actionId = response.actionId;
  if (actionId != null && actionId.isNotEmpty) {
    NotificationService._actionController.add(actionId);
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  /// Broadcast stream of notification action IDs (pause, resume, stop).
  static final StreamController<String> _actionController = StreamController<String>.broadcast();
  static Stream<String> get actionStream => _actionController.stream;

  /// Broadcast stream of notification body taps (payload strings).
  static final StreamController<String> _tapController = StreamController<String>.broadcast();
  static Stream<String> get tapStream => _tapController.stream;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );

    // Request notification permission on Android 13+.
    // Wrapped in try-catch because audio_service's plugin registration
    // can cause the Android context to be null at this point.
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('requestNotificationsPermission failed: $e');
    }

    // Handle the case where the app was launched by tapping a notification.
    final launchDetails = await _notifications.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final payload = launchDetails.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        // Defer navigation until the widget tree is ready.
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTapNavigation(payload);
        });
      }
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    // Handle button actions.
    final actionId = response.actionId;
    if (actionId != null && actionId.isNotEmpty) {
      _actionController.add(actionId);
      return;
    }

    // Handle body tap — navigate to the appropriate screen.
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _handleNotificationTapNavigation(payload);
    }
  }

  /// Navigate to the correct screen based on the notification payload.
  static void _handleNotificationTapNavigation(String payload) {
    if (payload == NotificationConstants.focusSessionPayload) {
      final nav = rootNavigatorKey.currentState;
      if (nav != null) {
        navigateToFocusSession();
      } else {
        // Navigator not yet ready — enqueue for later.
        _tapController.add(payload);
      }
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
        const AndroidNotificationAction(NotificationConstants.actionPause, 'Pause', showsUserInterface: true)
      else
        const AndroidNotificationAction(NotificationConstants.actionResume, 'Resume', showsUserInterface: true),
      const AndroidNotificationAction(NotificationConstants.actionSkip, 'Skip', showsUserInterface: true),
      const AndroidNotificationAction(NotificationConstants.actionStop, 'Stop', showsUserInterface: true),
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

    const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: false);

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      id: NotificationConstants.focusSessionId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: NotificationConstants.focusSessionPayload,
    );
  }

  /// Show a one-shot alarm notification (non-persistent).
  Future<void> showAlarmNotification({required String title, required String body}) async {
    final androidDetails = AndroidNotificationDetails(
      NotificationConstants.alarmChannelId,
      NotificationConstants.alarmChannelName,
      channelDescription: NotificationConstants.alarmChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

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

    const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(id: id, title: title, body: body, notificationDetails: details);
  }

  Future<void> cancelFocusNotification() async {
    await _notifications.cancel(id: NotificationConstants.focusSessionId);
  }

  Future<void> cancelSessionNotification(int id) async {
    await _notifications.cancel(id: id);
  }
}
