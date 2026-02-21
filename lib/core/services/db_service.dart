import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:focus/features/focus/data/models/focus_session_model.dart';
import 'package:focus/features/settings/data/models/settings_model.dart';
import 'package:focus/features/tasks/data/models/daily_session_stats_model.dart';
import 'package:focus/features/tasks/data/models/task_model.dart';

import '../../features/focus/domain/entities/session_state.dart';
import '../../features/projects/data/models/project_model.dart';
import '../../features/tasks/domain/entities/task_priority.dart';
import '../common/utils/datetime_formatter.dart';

part 'db_service.g.dart';

@DriftDatabase(tables: [ProjectTable, TaskTable, FocusSessionTable, DailySessionStatsTable, SettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'focus.sqlite'));

  @override
  int get schemaVersion => 2;

  /// Recalculates the [dailySessionStatsTable] row for the given
  /// local calendar [dateKey] (format `YYYY-MM-DD`).
  ///
  /// Call after every focus session INSERT / UPDATE / DELETE so
  /// the pre-aggregated stats stay in sync.
  Future<void> recalculateDailyStats(String dateKey) async {
    await customStatement(
      "INSERT OR REPLACE INTO daily_session_stats_table "
      "(date, completed_sessions, total_sessions, focus_seconds) "
      "SELECT ?, "
      "COALESCE(SUM(CASE WHEN state = ${SessionState.completed.index} THEN 1 ELSE 0 END), 0), "
      "COUNT(*), "
      "COALESCE(SUM(MIN(elapsed_seconds, focus_duration_minutes * 60)), 0) "
      "FROM focus_session_table "
      "WHERE date(start_time, 'unixepoch', 'localtime') = ?",
      [dateKey, dateKey],
    );
    // customStatement does not notify Drift stream watchers.
    // Explicitly mark the table as updated so that any .watch() query
    // on dailySessionStatsTable (e.g. the activity graph) re-emits.
    markTablesUpdated({dailySessionStatsTable});
  }

  /// Convenience: derives the local date key from a [DateTime] and recalculates.
  Future<void> recalculateDailyStatsForDate(DateTime dt) async {
    final dateKey = dt.toLocal().toShortDateKey();
    await recalculateDailyStats(dateKey);
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v1 → v2: Add ON DELETE CASCADE to TaskTable.project_id and
        // TaskTable.parent_task_id without losing data. SQLite does not
        // support altering FK constraints directly, so follow the safe
        // rename-create-copy-drop pattern documented by SQLite:
        // 1) Rename existing tables to _old
        // 2) Create new tables with the desired FK clauses
        // 3) Copy data from old -> new
        // 4) Drop old tables
        // 5) Recreate indexes
        // This preserves existing rows while updating the schema.

        await customStatement('BEGIN TRANSACTION');

        // Rename current tables to temporary names
        await customStatement('ALTER TABLE task_table RENAME TO task_table_old');
        await customStatement('ALTER TABLE focus_session_table RENAME TO focus_session_table_old');

        // Create new task_table with ON DELETE CASCADE FKs
        await customStatement('''
          CREATE TABLE task_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            project_id INTEGER NOT NULL,
            parent_task_id INTEGER,
            title TEXT NOT NULL,
            description TEXT,
            priority INTEGER NOT NULL,
            start_date INTEGER,
            end_date INTEGER,
            depth INTEGER NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY(project_id) REFERENCES project_table(id) ON DELETE CASCADE,
            FOREIGN KEY(parent_task_id) REFERENCES task_table(id) ON DELETE CASCADE
          )
        ''');

        // Copy data from old task table
        await customStatement('''
          INSERT INTO task_table (id, project_id, parent_task_id, title, description, priority, start_date, end_date, depth, is_completed, created_at, updated_at)
          SELECT id, project_id, parent_task_id, title, description, priority, start_date, end_date, depth, is_completed, created_at, updated_at
          FROM task_table_old
        ''');

        // Create new focus_session_table with cascade on task_id
        await customStatement('''
          CREATE TABLE focus_session_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER,
            focus_duration_minutes INTEGER NOT NULL,
            break_duration_minutes INTEGER NOT NULL,
            start_time INTEGER NOT NULL,
            end_time INTEGER,
            state INTEGER NOT NULL,
            elapsed_seconds INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(task_id) REFERENCES task_table(id) ON DELETE CASCADE
          )
        ''');

        // Copy data from old focus session table
        await customStatement('''
          INSERT INTO focus_session_table (id, task_id, focus_duration_minutes, break_duration_minutes, start_time, end_time, state, elapsed_seconds)
          SELECT id, task_id, focus_duration_minutes, break_duration_minutes, start_time, end_time, state, elapsed_seconds
          FROM focus_session_table_old
        ''');

        // Drop old tables
        await customStatement('DROP TABLE IF EXISTS focus_session_table_old');
        await customStatement('DROP TABLE IF EXISTS task_table_old');

        // Recreate indexes that the Dart tables expect
        await customStatement('CREATE INDEX IF NOT EXISTS task_project_id_idx ON task_table(project_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS task_parent_id_idx ON task_table(parent_task_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS task_priority_idx ON task_table(priority)');
        await customStatement('CREATE INDEX IF NOT EXISTS task_deadline_idx ON task_table(end_date)');
        await customStatement('CREATE INDEX IF NOT EXISTS task_completed_idx ON task_table(is_completed)');
        await customStatement('CREATE INDEX IF NOT EXISTS task_updated_at_idx ON task_table(updated_at)');

        await customStatement('CREATE INDEX IF NOT EXISTS focus_session_task_id_idx ON focus_session_table(task_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS focus_session_start_time_idx ON focus_session_table(start_time)');

        await customStatement('COMMIT');
      }
    },
    beforeOpen: (details) async {
      // SQLite requires this pragma to be enabled per connection.
      // Must run before any data-layer operation so FK constraints are enforced.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
