import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:focus/features/focus/data/models/focus_session_model.dart';
import 'package:focus/features/settings/data/models/settings_model.dart';
import 'package:focus/features/tasks/data/models/daily_session_stats_model.dart';
import 'package:focus/features/tasks/data/models/task_model.dart';

import '../../features/focus/domain/entities/session_state.dart';
import '../../features/projects/data/models/project_model.dart';
import '../../features/tasks/domain/entities/task_priority.dart';

part 'db_service.g.dart';

@DriftDatabase(tables: [ProjectTable, TaskTable, FocusSessionTable, DailySessionStatsTable, SettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'focus.sqlite'));

  @override
  int get schemaVersion => 8;

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
      "COALESCE(SUM(elapsed_seconds), 0) "
      "FROM focus_session_table "
      "WHERE date(start_time, 'unixepoch', 'localtime') = ?",
      [dateKey, dateKey],
    );
  }

  /// Convenience: derives the local date key from a [DateTime] and recalculates.
  Future<void> recalculateDailyStatsForDate(DateTime dt) async {
    final local = dt.toLocal();
    final dateKey =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    await recalculateDailyStats(dateKey);
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Version 2: Added task table
      if (from < 2) {
        await m.createTable(taskTable);
      }
      // Version 3: Revamped task table (projectId, description)
      if (from < 3) {
        await m.deleteTable('task_table');
        await m.createTable(taskTable);
      }
      // Version 4: Revamped task table again (id, dates, parentId)
      if (from < 4) {
        await m.deleteTable('task_table');
        await m.createTable(taskTable);
      }
      // Version 5: Added indexes
      if (from < 5) {
        await m.createIndex(projectCreatedAtIdx);
        await m.createIndex(projectUpdatedAtIdx);
        await m.createIndex(taskProjectIdIdx);
        await m.createIndex(taskParentIdIdx);
        await m.createIndex(taskPriorityIdx);
        await m.createIndex(taskDeadlineIdx);
        await m.createIndex(taskCompletedIdx);
        await m.createIndex(taskUpdatedAtIdx);
      }
      // Version 6: Added focus session table
      if (from < 6) {
        await m.createTable(focusSessionTable);
      }
      // Version 7: Added daily_session_stats table with backfill
      if (from < 7) {
        await m.createTable(dailySessionStatsTable);
        // Backfill from existing focus sessions.
        // date(start_time, 'unixepoch', 'localtime') converts epoch-sec → local date string.
        await customStatement(
          "INSERT OR REPLACE INTO daily_session_stats_table (date, completed_sessions, total_sessions, focus_seconds) "
          "SELECT date(start_time, 'unixepoch', 'localtime'), "
          "SUM(CASE WHEN state = ${SessionState.completed.index} THEN 1 ELSE 0 END), "
          "COUNT(*), "
          "COALESCE(SUM(elapsed_seconds), 0) "
          "FROM focus_session_table "
          "GROUP BY date(start_time, 'unixepoch', 'localtime')",
        );
      }
      // Version 8: Added settings table
      if (from < 8) {
        await m.createTable(settingsTable);
      }
    },
  );
}
