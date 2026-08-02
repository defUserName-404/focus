import 'package:drift/drift.dart';

import '../../../projects/data/models/project_model.dart';
import '../../../milestones/data/models/milestone_model.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_reminder_mode.dart';
import '../../domain/entities/task_status.dart';

@TableIndex(name: 'task_project_id_idx', columns: {#projectId})
@TableIndex(name: 'task_parent_id_idx', columns: {#parentTaskId})
@TableIndex(name: 'task_priority_idx', columns: {#priority})
@TableIndex(name: 'task_deadline_idx', columns: {#endDate})
@TableIndex(name: 'task_completed_idx', columns: {#isCompleted})
@TableIndex(name: 'task_status_idx', columns: {#status})
@TableIndex(name: 'task_sort_order_idx', columns: {#sortOrder})
@TableIndex(name: 'task_milestone_id_idx', columns: {#milestoneId})
@TableIndex(name: 'task_updated_at_idx', columns: {#updatedAt})
@TableIndex(name: 'task_uuid_idx', columns: {#uuid}, unique: true)
@TableIndex(name: 'task_deleted_at_idx', columns: {#deletedAt})
class TaskTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().unique()();

  IntColumn get projectId => integer().references(ProjectTable, #id, onDelete: KeyAction.cascade)();

  IntColumn get parentTaskId => integer().nullable().references(TaskTable, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  IntColumn get priority => intEnum<TaskPriority>()();

  IntColumn get status => intEnum<TaskStatus>().withDefault(const Constant(0))();

  IntColumn get reminderMode => intEnum<TaskReminderMode>().withDefault(const Constant(0))();

  IntColumn get customReminderMinutesBefore => integer().nullable()();

  DateTimeColumn get startDate => dateTime().nullable()();

  DateTimeColumn get endDate => dateTime().nullable()();

  IntColumn get depth => integer()();

  IntColumn get estimatedMinutes => integer().nullable()();

  RealColumn get sortOrder => real().withDefault(const Constant(0.0))();

  IntColumn get milestoneId => integer().nullable().references(MilestoneTable, #id, onDelete: KeyAction.setNull)();

  /// JSON-encoded [RecurrenceRule], or null for one-shot tasks.
  TextColumn get recurrenceRule => text().nullable()();

  /// Series start used by [RecurrenceExpander]; defaults to start/created when null.
  DateTimeColumn get recurrenceAnchorDate => dateTime().nullable()();

  /// When true, the recurring task is surfaced as a habit (streaks / agenda).
  BoolColumn get isHabit => boolean().withDefault(const Constant(false))();

  /// Kept in sync with [status] == done for one migration cycle (v7).
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();
}
