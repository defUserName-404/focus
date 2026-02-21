import 'package:drift/drift.dart';

import '../../domain/entities/task_priority.dart';

@TableIndex(name: 'task_project_id_idx', columns: {#projectId})
@TableIndex(name: 'task_parent_id_idx', columns: {#parentTaskId})
@TableIndex(name: 'task_priority_idx', columns: {#priority})
@TableIndex(name: 'task_deadline_idx', columns: {#endDate})
@TableIndex(name: 'task_completed_idx', columns: {#isCompleted})
@TableIndex(name: 'task_updated_at_idx', columns: {#updatedAt})
class TaskTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get projectId => integer()();

  IntColumn get parentTaskId => integer().nullable().references(TaskTable, #id)();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  IntColumn get priority => intEnum<TaskPriority>()();

  DateTimeColumn get startDate => dateTime().nullable()();

  DateTimeColumn get endDate => dateTime().nullable()();

  IntColumn get depth => integer()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
