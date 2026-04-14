import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/notification_constants.dart';
import '../routing/app_router.dart';
import '../routing/routes.dart';
import '../utils/platform_utils.dart';
import 'i_notification_service.dart';
import 'log_service.dart';
import 'notification_event.dart';

/// Top-level handler required by flutter_local_notifications for
/// notification actions received while the app is in the background.
/// Must be a top-level or static function.
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  final actionId = response.actionId;
  if (actionId != null && actionId.isNotEmpty) {
    NotificationService._actionController.add(actionId);
    NotificationService._eventController.add(
      NotificationEvent(
        type: NotificationEventType.action,
        occurredAt: DateTime.now(),
        notificationId: response.id,
        title: 'Notification action',
        actionId: actionId,
      ),
    );
  }
}

/// Platform notification service for Android, iOS, macOS, Linux, and Windows.
///
/// Uses flutter_local_notifications to display system notifications
/// with action buttons and progress indicators.
class NotificationService implements INotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Map<int, Timer> _inProcessScheduledTimers = <int, Timer>{};

  /// Broadcast stream of notification action IDs (pause, resume, stop).
  static final StreamController<String> _actionController = StreamController<String>.broadcast();

  @override
  Stream<String> get actionStream => _actionController.stream;

  /// Broadcast stream of notification body taps (payload strings).
  static final StreamController<String> _tapController = StreamController<String>.broadcast();

  @override
  Stream<String> get tapStream => _tapController.stream;

  /// Broadcast stream for recent notification events shown in-app.
  static final StreamController<NotificationEvent> _eventController = StreamController<NotificationEvent>.broadcast();

  @override
  Stream<NotificationEvent> get eventStream => _eventController.stream;

  @override
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open notification');
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Focus',
      appUserModelId: 'com.defusername.focus',
      guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

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
    } catch (e, stackTrace) {
      LogService.instance.warning(
        'requestNotificationsPermission failed',
        tag: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }

    // Request user permission on Apple platforms if needed.
    try {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

      final macPlugin = _notifications.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      await macPlugin?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e, stackTrace) {
      LogService.instance.warning(
        'requestPermissions failed on Apple platforms',
        tag: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }

    // Handle the case where the app was launched by tapping a notification.
    NotificationAppLaunchDetails? launchDetails;
    try {
      launchDetails = await _notifications.getNotificationAppLaunchDetails();
    } catch (e, stackTrace) {
      LogService.instance.warning(
        'getNotificationAppLaunchDetails failed',
        tag: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }

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
      _eventController.add(
        NotificationEvent(
          type: NotificationEventType.action,
          occurredAt: DateTime.now(),
          notificationId: response.id,
          title: 'Notification action',
          actionId: actionId,
        ),
      );
      return;
    }

    // Handle body tap — navigate to the appropriate screen.
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      final parsedTaskPayload = NotificationConstants.parseTaskPayload(payload);
      _eventController.add(
        NotificationEvent(
          type: NotificationEventType.opened,
          occurredAt: DateTime.now(),
          notificationId:
              response.id ??
              (parsedTaskPayload == null
                  ? null
                  : NotificationConstants.taskReminderIdOffset + parsedTaskPayload.taskId),
          title: 'Notification opened',
          payload: payload,
        ),
      );
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
        _tapController.add(payload);
      }
      return;
    }

    final taskPayload = NotificationConstants.parseTaskPayload(payload);
    if (taskPayload != null) {
      final nav = rootNavigatorKey.currentState;
      if (nav != null) {
        final path = AppRoutes.taskDetailPath(taskPayload.taskId);
        final query = taskPayload.projectId == null ? null : {'projectId': taskPayload.projectId.toString()};
        appRouter.push(Uri(path: path, queryParameters: query).toString());
      } else {
        _tapController.add(payload);
      }
    }
  }

  @override
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

    final linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.low,
      defaultActionName: 'Open session',
      actions: <LinuxNotificationAction>[
        LinuxNotificationAction(
          key: isRunning ? NotificationConstants.actionPause : NotificationConstants.actionResume,
          label: isRunning ? 'Pause' : 'Resume',
        ),
        const LinuxNotificationAction(key: NotificationConstants.actionSkip, label: 'Skip'),
        const LinuxNotificationAction(key: NotificationConstants.actionStop, label: 'Stop'),
      ],
    );

    const darwinDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: false);
    const windowsDetails = WindowsNotificationDetails(scenario: WindowsNotificationScenario.reminder);

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    await _notifications.show(
      id: NotificationConstants.focusSessionId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: NotificationConstants.focusSessionPayload,
    );
  }

  @override
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

    const darwinDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    const linuxDetails = LinuxNotificationDetails(urgency: LinuxNotificationUrgency.normal);
    const windowsDetails = WindowsNotificationDetails(scenario: WindowsNotificationScenario.alarm);

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    await _notifications.show(
      id: NotificationConstants.alarmId,
      title: title,
      body: body,
      notificationDetails: details,
    );

    _eventController.add(
      NotificationEvent(type: NotificationEventType.alarm, occurredAt: DateTime.now(), title: title, body: body),
    );
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
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

    const darwinDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    const linuxDetails = LinuxNotificationDetails(urgency: LinuxNotificationUrgency.normal);
    const windowsDetails = WindowsNotificationDetails(scenario: WindowsNotificationScenario.reminder);

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    _eventController.add(
      NotificationEvent(
        type: payload != null && payload.startsWith(NotificationConstants.taskPayloadPrefix)
            ? NotificationEventType.taskReminderScheduled
            : NotificationEventType.reminderScheduled,
        occurredAt: DateTime.now(),
        notificationId: id,
        title: title,
        body: body,
        payload: payload,
        scheduledFor: scheduledTime,
      ),
    );

    // The Linux notification server doesn't provide scheduling APIs, so we
    // emulate scheduling while the app process is alive.
    if (PlatformUtils.isLinux) {
      _scheduleInProcessNotification(
        id: id,
        title: title,
        body: body,
        details: details,
        scheduledTime: scheduledTime,
        payload: payload,
      );
      return;
    }

    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    if (PlatformUtils.isAndroid) {
      final canUseExactAlarms = await _canUseExactAlarms();
      final primaryMode = canUseExactAlarms
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      try {
        await _scheduleZonedNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          details: details,
          androidScheduleMode: primaryMode,
          payload: payload,
        );
        return;
      } catch (e, stackTrace) {
        if (primaryMode == AndroidScheduleMode.exactAllowWhileIdle) {
          try {
            await _scheduleZonedNotification(
              id: id,
              title: title,
              body: body,
              scheduledDate: scheduledDate,
              details: details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              payload: payload,
            );
            LogService.instance.warning(
              'Exact alarm scheduling failed, used inexact Android scheduling',
              tag: 'NotificationService',
              error: e,
              stackTrace: stackTrace,
            );
            return;
          } catch (_) {
            // Fall through to in-process fallback below.
          }
        }

        LogService.instance.warning(
          'zonedSchedule failed, using in-process fallback',
          tag: 'NotificationService',
          error: e,
          stackTrace: stackTrace,
        );

        _scheduleInProcessNotification(
          id: id,
          title: title,
          body: body,
          details: details,
          scheduledTime: scheduledTime,
          payload: payload,
        );
        return;
      }
    }

    try {
      await _scheduleZonedNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        details: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e, stackTrace) {
      LogService.instance.warning(
        'zonedSchedule failed, using in-process fallback',
        tag: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );

      _scheduleInProcessNotification(
        id: id,
        title: title,
        body: body,
        details: details,
        scheduledTime: scheduledTime,
        payload: payload,
      );
    }
  }

  Future<bool> _canUseExactAlarms() async {
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final canScheduleExact = await androidPlugin?.canScheduleExactNotifications();
      return canScheduleExact ?? true;
    } catch (e, stackTrace) {
      LogService.instance.warning(
        'canScheduleExactNotifications failed; using inexact Android scheduling',
        tag: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> _scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
  }) {
    return _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: androidScheduleMode,
      payload: payload,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    _inProcessScheduledTimers.remove(id)?.cancel();
    await _notifications.cancel(id: id);
    _eventController.add(
      NotificationEvent(
        type: NotificationEventType.cancelled,
        occurredAt: DateTime.now(),
        notificationId: id,
        title: 'Notification cancelled',
        body: 'Notification ID $id',
      ),
    );
  }

  @override
  Future<void> cancelFocusNotification() async {
    await cancelNotification(NotificationConstants.focusSessionId);
  }

  void _scheduleInProcessNotification({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    required DateTime scheduledTime,
    String? payload,
  }) {
    _inProcessScheduledTimers.remove(id)?.cancel();

    final delay = scheduledTime.difference(DateTime.now());
    if (delay <= Duration.zero) return;

    _inProcessScheduledTimers[id] = Timer(delay, () {
      _inProcessScheduledTimers.remove(id);
      unawaited(_notifications.show(id: id, title: title, body: body, notificationDetails: details, payload: payload));
    });
  }
}
