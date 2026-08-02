import 'package:drift/drift.dart';
import 'package:focus/features/tasks/data/models/task_model.dart';

import '../../domain/entities/session_state.dart';

@DataClassName('FocusSessionData')
@TableIndex(name: 'focus_session_task_id_idx', columns: {#taskId})
@TableIndex(name: 'focus_session_start_time_idx', columns: {#startTime})
@TableIndex(name: 'focus_session_uuid_idx', columns: {#uuid}, unique: true)
@TableIndex(name: 'focus_session_deleted_at_idx', columns: {#deletedAt})
class FocusSessionTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  IntColumn get taskId => integer().nullable().references(TaskTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get focusDurationMinutes => integer()();
  IntColumn get breakDurationMinutes => integer()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get state => intEnum<SessionState>()();
  IntColumn get elapsedSeconds => integer().withDefault(const Constant(0))();

  /// Elapsed seconds at which the focus phase ended.
  /// Stored to preserve accurate focus time across app restarts.
  /// Null while focus is still running; set when transitioning to break.
  IntColumn get focusPhaseEndedAt => integer().nullable()();

  DateTimeColumn get deletedAt => dateTime().nullable()();
}
