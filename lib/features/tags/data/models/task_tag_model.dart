import 'package:drift/drift.dart';

import '../../../tasks/data/models/task_model.dart';
import 'tag_model.dart';

/// Many-to-many association between tasks and tags.
///
/// Soft-deleted via [deletedAt] so tombstones can sync across devices.
/// Primary key remains `(taskId, tagId)`; re-linking revives the same row.
@DataClassName('TaskTagData')
@TableIndex(name: 'task_tag_uuid_idx', columns: {#uuid}, unique: true)
@TableIndex(name: 'task_tag_deleted_at_idx', columns: {#deletedAt})
class TaskTagTable extends Table {
  IntColumn get taskId => integer().references(TaskTable, #id, onDelete: KeyAction.cascade)();

  IntColumn get tagId => integer().references(TagTable, #id, onDelete: KeyAction.cascade)();

  TextColumn get uuid => text().unique()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {taskId, tagId};
}
