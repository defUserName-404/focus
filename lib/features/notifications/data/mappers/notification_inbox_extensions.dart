import 'package:drift/drift.dart' show Value;
import 'package:focus/core/services/db_service.dart';

import '../../domain/entities/notification_inbox_item.dart';

extension DbNotificationInboxToDomain on NotificationInboxTableData {
  NotificationInboxItem toDomain() => NotificationInboxItem(
    id: id,
    notificationId: notificationId,
    type: type,
    state: state,
    title: title,
    body: body,
    payload: payload,
    taskId: taskId,
    projectId: projectId,
    scheduledFor: scheduledFor,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension DomainNotificationInboxToCompanion on NotificationInboxItem {
  NotificationInboxTableCompanion toCompanion() {
    return NotificationInboxTableCompanion(
      id: Value(id),
      notificationId: Value(notificationId),
      type: Value(type),
      state: Value(state),
      title: Value(title),
      body: Value(body),
      payload: Value(payload),
      taskId: Value(taskId),
      projectId: Value(projectId),
      scheduledFor: Value(scheduledFor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
