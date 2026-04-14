import 'package:drift/drift.dart';

import '../../domain/entities/notification_inbox_item.dart';

@TableIndex(name: 'notification_inbox_notification_id_idx', columns: {#notificationId})
@TableIndex(name: 'notification_inbox_updated_at_idx', columns: {#updatedAt})
@TableIndex(name: 'notification_inbox_scheduled_for_idx', columns: {#scheduledFor})
class NotificationInboxTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get notificationId => integer()();

  IntColumn get type => intEnum<NotificationInboxType>()();

  IntColumn get state => intEnum<NotificationInboxState>()();

  TextColumn get title => text()();

  TextColumn get body => text().nullable()();

  TextColumn get payload => text().nullable()();

  IntColumn get taskId => integer().nullable()();

  IntColumn get projectId => integer().nullable()();

  DateTimeColumn get scheduledFor => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {notificationId, type},
  ];
}
