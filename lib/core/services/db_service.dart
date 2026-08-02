import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:focus/features/settings/data/models/settings_model.dart';
import 'package:focus/features/notifications/data/models/notification_inbox_model.dart';
import 'package:focus/features/tasks/data/models/daily_session_stats_model.dart';
import 'package:focus/features/tasks/data/models/task_completion_model.dart';
import 'package:focus/features/tasks/data/models/task_model.dart';
import 'package:focus/features/tags/data/models/tag_model.dart';
import 'package:focus/features/tags/data/models/task_tag_model.dart';
import 'package:focus/features/milestones/data/models/milestone_model.dart';

import '../../features/projects/data/models/project_model.dart';
import '../../features/session/data/models/focus_session_model.dart';
import '../../features/session/domain/entities/session_state.dart';
import '../../features/notifications/domain/entities/notification_inbox_item.dart';
import '../../features/tasks/domain/entities/task_priority.dart';
import '../../features/tasks/domain/entities/task_reminder_mode.dart';
import '../../features/tasks/domain/entities/task_status.dart';
import '../../features/projects/domain/entities/project_status.dart';
import '../utils/datetime_formatter.dart';
import '../utils/id_utils.dart';

part 'db_service.g.dart';

@DriftDatabase(
  tables: [
    ProjectTable,
    TaskTable,
    FocusSessionTable,
    DailySessionStatsTable,
    SettingsTable,
    NotificationInboxTable,
    TagTable,
    TaskTagTable,
    MilestoneTable,
    TaskCompletionTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'focus.sqlite'));

  /// In-memory / injected executor for tests and migration harnesses.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 9;

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
      "WHERE deleted_at IS NULL AND date(start_time, 'unixepoch', 'localtime') = ?",
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
      // Partial unique index is not expressible via Drift annotations.
      await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS task_completion_task_occurrence_live_idx '
        'ON task_completion_table(task_id, occurrence_date) WHERE deleted_at IS NULL',
      );
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

        // Drift already wraps onUpgrade in a transaction. Do not issue
        // nested BEGIN/COMMIT here — that can fail on some sqlite builds.
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
        await customStatement(
          'CREATE INDEX IF NOT EXISTS focus_session_start_time_idx ON focus_session_table(start_time)',
        );
      }

      // v2 → v3: Add focus_phase_ended_at column to focus_session_table
      // This column stores the elapsed seconds when focus phase ended,
      // preserving accurate focus time data across app restarts.
      if (from < 3) {
        await customStatement('ALTER TABLE focus_session_table ADD COLUMN focus_phase_ended_at INTEGER');
      }

      // v3 → v4: Add reminder strategy fields to task_table.
      if (from < 4) {
        await customStatement('ALTER TABLE task_table ADD COLUMN reminder_mode INTEGER NOT NULL DEFAULT 0');
        await customStatement('ALTER TABLE task_table ADD COLUMN custom_reminder_minutes_before INTEGER');
      }

      // v4 → v5: Add persisted notification inbox table.
      if (from < 5) {
        await m.createTable(notificationInboxTable);
      }

      // v5 → v6: Sync-ready identity (uuid) + soft-delete tombstones.
      if (from < 6) {
        await customStatement('ALTER TABLE project_table ADD COLUMN uuid TEXT');
        await customStatement('ALTER TABLE project_table ADD COLUMN deleted_at INTEGER');
        await customStatement('ALTER TABLE task_table ADD COLUMN uuid TEXT');
        await customStatement('ALTER TABLE task_table ADD COLUMN deleted_at INTEGER');
        await customStatement('ALTER TABLE focus_session_table ADD COLUMN uuid TEXT');
        await customStatement('ALTER TABLE focus_session_table ADD COLUMN deleted_at INTEGER');

        await _backfillUuids('project_table');
        await _backfillUuids('task_table');
        await _backfillUuids('focus_session_table');

        await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS project_uuid_idx ON project_table(uuid)');
        await customStatement('CREATE INDEX IF NOT EXISTS project_deleted_at_idx ON project_table(deleted_at)');
        await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS task_uuid_idx ON task_table(uuid)');
        await customStatement('CREATE INDEX IF NOT EXISTS task_deleted_at_idx ON task_table(deleted_at)');
        await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS focus_session_uuid_idx ON focus_session_table(uuid)');
        await customStatement(
          'CREATE INDEX IF NOT EXISTS focus_session_deleted_at_idx ON focus_session_table(deleted_at)',
        );
      }

      // v6 → v7: PM model — task/project status, estimates, sort order,
      // milestones, tags, and task↔tag associations.
      if (from < 7) {
        await m.createTable(tagTable);
        await m.createTable(milestoneTable);
        await m.createTable(taskTagTable);

        await customStatement(
          'ALTER TABLE task_table ADD COLUMN status INTEGER NOT NULL DEFAULT ${TaskStatus.todo.index}',
        );
        await customStatement('ALTER TABLE task_table ADD COLUMN estimated_minutes INTEGER');
        await customStatement('ALTER TABLE task_table ADD COLUMN sort_order REAL NOT NULL DEFAULT 0.0');
        await customStatement(
          'ALTER TABLE task_table ADD COLUMN milestone_id INTEGER '
          'REFERENCES milestone_table(id) ON DELETE SET NULL',
        );

        await customStatement(
          'ALTER TABLE project_table ADD COLUMN status INTEGER NOT NULL DEFAULT ${ProjectStatus.active.index}',
        );
        await customStatement('ALTER TABLE project_table ADD COLUMN color INTEGER');

        // Backfill task status from legacy is_completed bool.
        await customStatement(
          'UPDATE task_table SET status = CASE WHEN is_completed = 1 '
          'THEN ${TaskStatus.done.index} ELSE ${TaskStatus.todo.index} END',
        );

        await customStatement('CREATE INDEX IF NOT EXISTS task_status_idx ON task_table(status)');
        await customStatement('CREATE INDEX IF NOT EXISTS task_sort_order_idx ON task_table(sort_order)');
        await customStatement('CREATE INDEX IF NOT EXISTS task_milestone_id_idx ON task_table(milestone_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS project_status_idx ON project_table(status)');
        await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS tag_uuid_idx ON tag_table(uuid)');
        await customStatement('CREATE INDEX IF NOT EXISTS tag_deleted_at_idx ON tag_table(deleted_at)');
        await customStatement('CREATE INDEX IF NOT EXISTS tag_name_idx ON tag_table(name)');
        await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS milestone_uuid_idx ON milestone_table(uuid)');
        await customStatement('CREATE INDEX IF NOT EXISTS milestone_project_id_idx ON milestone_table(project_id)');
        await customStatement('CREATE INDEX IF NOT EXISTS milestone_deleted_at_idx ON milestone_table(deleted_at)');
      }

      // v7 → v8: Recurrence / habits — rule JSON, anchor, isHabit, and
      // per-occurrence completion log with soft-delete-aware uniqueness.
      if (from < 8) {
        await customStatement('ALTER TABLE task_table ADD COLUMN recurrence_rule TEXT');
        await customStatement('ALTER TABLE task_table ADD COLUMN recurrence_anchor_date INTEGER');
        await customStatement('ALTER TABLE task_table ADD COLUMN is_habit INTEGER NOT NULL DEFAULT 0');

        await m.createTable(taskCompletionTable);

        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS task_completion_uuid_idx ON task_completion_table(uuid)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS task_completion_task_id_idx ON task_completion_table(task_id)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS task_completion_occurrence_date_idx '
          'ON task_completion_table(occurrence_date)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS task_completion_deleted_at_idx ON task_completion_table(deleted_at)',
        );
        // Unique (taskId, occurrenceDate) among live rows only.
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS task_completion_task_occurrence_live_idx '
          'ON task_completion_table(task_id, occurrence_date) WHERE deleted_at IS NULL',
        );
      }

      // v8 → v9: Task↔tag link tombstones for multi-device sync.
      // Idempotent: v7 `createTable` on current code already emits these columns.
      if (from < 9) {
        final info = await customSelect("PRAGMA table_info('task_tag_table')").get();
        final columns = {for (final row in info) row.read<String>('name')};
        if (!columns.contains('uuid')) {
          await customStatement('ALTER TABLE task_tag_table ADD COLUMN uuid TEXT');
          await customStatement('ALTER TABLE task_tag_table ADD COLUMN created_at INTEGER');
          await customStatement('ALTER TABLE task_tag_table ADD COLUMN updated_at INTEGER');
          await customStatement('ALTER TABLE task_tag_table ADD COLUMN deleted_at INTEGER');

          final nowMs = DateTime.now().millisecondsSinceEpoch;
          final rows = await customSelect('SELECT task_id, tag_id FROM task_tag_table WHERE uuid IS NULL').get();
          for (final row in rows) {
            await customStatement(
              'UPDATE task_tag_table SET uuid = ?, created_at = ?, updated_at = ? '
              'WHERE task_id = ? AND tag_id = ?',
              [generateUuid(), nowMs, nowMs, row.read<int>('task_id'), row.read<int>('tag_id')],
            );
          }
        } else {
          // Columns exist but legacy rows may still lack uuid values.
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          final rows = await customSelect(
            'SELECT task_id, tag_id FROM task_tag_table WHERE uuid IS NULL OR uuid = \'\'',
          ).get();
          for (final row in rows) {
            await customStatement(
              'UPDATE task_tag_table SET uuid = ?, '
              'created_at = COALESCE(created_at, ?), updated_at = COALESCE(updated_at, ?) '
              'WHERE task_id = ? AND tag_id = ?',
              [generateUuid(), nowMs, nowMs, row.read<int>('task_id'), row.read<int>('tag_id')],
            );
          }
        }

        await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS task_tag_uuid_idx ON task_tag_table(uuid)');
        await customStatement('CREATE INDEX IF NOT EXISTS task_tag_deleted_at_idx ON task_tag_table(deleted_at)');
      }
    },
    beforeOpen: (details) async {
      // SQLite requires this pragma to be enabled per connection.
      // Must run before any data-layer operation so FK constraints are enforced.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Assigns a UUID to every row in [tableName] that still has a null uuid.
  Future<void> _backfillUuids(String tableName) async {
    final rows = await customSelect('SELECT id FROM $tableName WHERE uuid IS NULL').get();
    for (final row in rows) {
      final id = row.read<int>('id');
      await customStatement('UPDATE $tableName SET uuid = ? WHERE id = ?', [generateUuid(), id]);
    }
  }
}
