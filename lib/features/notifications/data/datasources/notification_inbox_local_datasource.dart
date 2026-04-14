import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/entities/notification_inbox_item.dart';

abstract class INotificationInboxLocalDataSource {
  Future<NotificationInboxTableData?> getByNotificationId(int notificationId);

  Future<int> insert(NotificationInboxTableCompanion companion);

  Future<void> update(NotificationInboxTableCompanion companion);

  Stream<List<NotificationInboxTableData>> watchUpcomingTaskReminders({required DateTime from, required int limit});

  Stream<List<NotificationInboxTableData>> watchRecentNotifications({required DateTime now, required int limit});

  Future<void> deleteOlderThan(DateTime cutoff);
}

class NotificationInboxLocalDataSourceImpl implements INotificationInboxLocalDataSource {
  NotificationInboxLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  final _log = LogService.instance;

  @override
  Future<NotificationInboxTableData?> getByNotificationId(int notificationId) async {
    try {
      return await (_db.select(_db.notificationInboxTable)
            ..where((t) => t.notificationId.equals(notificationId))
            ..where((t) => t.type.equalsValue(NotificationInboxType.taskReminder)))
          .getSingleOrNull();
    } catch (e, st) {
      _log.error('getByNotificationId failed', tag: 'NotificationInboxLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<int> insert(NotificationInboxTableCompanion companion) async {
    try {
      return await _db.into(_db.notificationInboxTable).insert(companion);
    } catch (e, st) {
      _log.error('insert failed', tag: 'NotificationInboxLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> update(NotificationInboxTableCompanion companion) async {
    try {
      await (_db.update(_db.notificationInboxTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
    } catch (e, st) {
      _log.error('update failed', tag: 'NotificationInboxLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<NotificationInboxTableData>> watchUpcomingTaskReminders({required DateTime from, required int limit}) {
    return (_db.select(_db.notificationInboxTable)
          ..where((t) => t.type.equalsValue(NotificationInboxType.taskReminder))
          ..where((t) => t.state.equalsValue(NotificationInboxState.scheduled))
          ..where((t) => t.scheduledFor.isNotNull() & t.scheduledFor.isBiggerOrEqualValue(from))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledFor)])
          ..limit(limit))
        .watch();
  }

  @override
  Stream<List<NotificationInboxTableData>> watchRecentNotifications({required DateTime now, required int limit}) {
    return (_db.select(_db.notificationInboxTable)
          ..where((t) => t.type.equalsValue(NotificationInboxType.taskReminder))
          ..where(
            (t) =>
                t.state.equalsValue(NotificationInboxState.opened) |
                t.state.equalsValue(NotificationInboxState.cancelled) |
                (t.state.equalsValue(NotificationInboxState.scheduled) &
                    t.scheduledFor.isNotNull() &
                    t.scheduledFor.isSmallerOrEqualValue(now)),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
        .watch();
  }

  @override
  Future<void> deleteOlderThan(DateTime cutoff) async {
    try {
      await (_db.delete(_db.notificationInboxTable)..where((t) => t.updatedAt.isSmallerThanValue(cutoff))).go();
    } catch (e, st) {
      _log.error('deleteOlderThan failed', tag: 'NotificationInboxLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }
}
