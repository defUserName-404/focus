import 'package:drift/drift.dart';

import 'task_model.dart';

@TableIndex(name: 'task_completion_uuid_idx', columns: {#uuid}, unique: true)
@TableIndex(name: 'task_completion_task_id_idx', columns: {#taskId})
@TableIndex(name: 'task_completion_occurrence_date_idx', columns: {#occurrenceDate})
@TableIndex(name: 'task_completion_deleted_at_idx', columns: {#deletedAt})
class TaskCompletionTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().unique()();

  IntColumn get taskId => integer().references(TaskTable, #id, onDelete: KeyAction.cascade)();

  /// Local calendar date as `YYYY-MM-DD` (date-only, no time component).
  TextColumn get occurrenceDate => text()();

  DateTimeColumn get completedAt => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();
}
