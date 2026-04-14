import 'package:drift/drift.dart' as drift;

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/entities/notification_inbox_item.dart';
import '../../domain/repositories/i_notification_inbox_repository.dart';
import '../datasources/notification_inbox_local_datasource.dart';
import '../mappers/notification_inbox_extensions.dart';

final _log = LogService.instance;

class NotificationInboxRepositoryImpl implements INotificationInboxRepository {
  NotificationInboxRepositoryImpl(this._local);

  final INotificationInboxLocalDataSource _local;

  @override
  Stream<List<NotificationInboxItem>> watchUpcomingTaskReminders({int limit = 12}) {
    return _local
        .watchUpcomingTaskReminders(from: DateTime.now(), limit: limit)
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  @override
  Stream<List<NotificationInboxItem>> watchRecentNotifications({int limit = 30}) {
    return _local
        .watchRecentNotifications(now: DateTime.now(), limit: limit)
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  @override
  Future<void> upsertScheduledTaskReminder({
    required int notificationId,
    required String title,
    String? body,
    String? payload,
    int? taskId,
    int? projectId,
    DateTime? scheduledFor,
    required DateTime occurredAt,
  }) async {
    try {
      final existing = await _local.getByNotificationId(notificationId);
      if (existing == null) {
        await _local.insert(
          NotificationInboxTableCompanion.insert(
            notificationId: notificationId,
            type: NotificationInboxType.taskReminder,
            state: NotificationInboxState.scheduled,
            title: title,
            body: drift.Value(body),
            payload: drift.Value(payload),
            taskId: drift.Value(taskId),
            projectId: drift.Value(projectId),
            scheduledFor: drift.Value(scheduledFor),
            createdAt: occurredAt,
            updatedAt: occurredAt,
          ),
        );
        return;
      }

      await _local.update(
        NotificationInboxTableCompanion(
          id: drift.Value(existing.id),
          state: drift.Value(NotificationInboxState.scheduled),
          title: drift.Value(title),
          body: drift.Value(body),
          payload: drift.Value(payload),
          taskId: drift.Value(taskId),
          projectId: drift.Value(projectId),
          scheduledFor: drift.Value(scheduledFor),
          updatedAt: drift.Value(occurredAt),
        ),
      );
    } catch (e, st) {
      _log.error('upsertScheduledTaskReminder failed', tag: 'NotificationInboxRepo', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> markTaskReminderOpened({required int notificationId, required DateTime openedAt}) async {
    try {
      final existing = await _local.getByNotificationId(notificationId);
      if (existing == null) return;

      await _local.update(
        NotificationInboxTableCompanion(
          id: drift.Value(existing.id),
          state: const drift.Value(NotificationInboxState.opened),
          updatedAt: drift.Value(openedAt),
        ),
      );
    } catch (e, st) {
      _log.error('markTaskReminderOpened failed', tag: 'NotificationInboxRepo', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> markTaskReminderCancelled({required int notificationId, required DateTime cancelledAt}) async {
    try {
      final existing = await _local.getByNotificationId(notificationId);
      if (existing == null) return;

      await _local.update(
        NotificationInboxTableCompanion(
          id: drift.Value(existing.id),
          state: const drift.Value(NotificationInboxState.cancelled),
          updatedAt: drift.Value(cancelledAt),
        ),
      );
    } catch (e, st) {
      _log.error('markTaskReminderCancelled failed', tag: 'NotificationInboxRepo', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> pruneOldNotifications({Duration retention = const Duration(days: 30)}) async {
    try {
      await _local.deleteOlderThan(DateTime.now().subtract(retention));
    } catch (e, st) {
      _log.error('pruneOldNotifications failed', tag: 'NotificationInboxRepo', error: e, stackTrace: st);
      rethrow;
    }
  }
}
