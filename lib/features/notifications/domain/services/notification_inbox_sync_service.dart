import 'dart:async';

import '../../../../core/constants/notification_constants.dart';
import '../../../../core/services/i_notification_service.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/services/notification_event.dart';
import '../repositories/i_notification_inbox_repository.dart';

final _log = LogService.instance;

class NotificationInboxSyncService {
  NotificationInboxSyncService(this._notificationService, this._repository);

  final INotificationService _notificationService;
  final INotificationInboxRepository _repository;

  StreamSubscription<NotificationEvent>? _subscription;
  bool _started = false;

  Future<void> init() async {
    if (_started) return;
    _started = true;

    await _repository.pruneOldNotifications();

    _subscription = _notificationService.eventStream.listen(
      (event) {
        unawaited(_handleEvent(event));
      },
      onError: (error, stackTrace) {
        _log.warning(
          'Notification inbox sync stream failed',
          tag: 'NotificationInboxSyncService',
          error: error,
          stackTrace: stackTrace is StackTrace ? stackTrace : null,
        );
      },
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
  }

  Future<void> _handleEvent(NotificationEvent event) async {
    try {
      switch (event.type) {
        case NotificationEventType.taskReminderScheduled:
          await _persistScheduledTaskReminder(event);
          return;
        case NotificationEventType.opened:
          await _markTaskReminderOpened(event);
          return;
        case NotificationEventType.cancelled:
          await _markTaskReminderCancelled(event);
          return;
        case NotificationEventType.focus:
        case NotificationEventType.alarm:
        case NotificationEventType.reminderScheduled:
        case NotificationEventType.action:
          return;
      }
    } catch (e, st) {
      _log.warning(
        'Failed to sync notification event to inbox',
        tag: 'NotificationInboxSyncService',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _persistScheduledTaskReminder(NotificationEvent event) async {
    final payload = event.payload;
    if (payload == null) return;

    final parsed = NotificationConstants.parseTaskPayload(payload);
    if (parsed == null) return;

    final notificationId = event.notificationId ?? NotificationConstants.taskReminderIdOffset + parsed.taskId;

    await _repository.upsertScheduledTaskReminder(
      notificationId: notificationId,
      title: event.title,
      body: event.body,
      payload: payload,
      taskId: parsed.taskId,
      projectId: parsed.projectId,
      scheduledFor: event.scheduledFor,
      occurredAt: event.occurredAt,
    );
  }

  Future<void> _markTaskReminderOpened(NotificationEvent event) async {
    final payload = event.payload;
    if (payload == null) return;

    final parsed = NotificationConstants.parseTaskPayload(payload);
    if (parsed == null) return;

    final notificationId = event.notificationId ?? NotificationConstants.taskReminderIdOffset + parsed.taskId;

    await _repository.markTaskReminderOpened(notificationId: notificationId, openedAt: event.occurredAt);
  }

  Future<void> _markTaskReminderCancelled(NotificationEvent event) async {
    final notificationId = event.notificationId;
    if (notificationId == null) return;
    if (notificationId < NotificationConstants.taskReminderIdOffset) return;

    await _repository.markTaskReminderCancelled(notificationId: notificationId, cancelledAt: event.occurredAt);
  }
}
