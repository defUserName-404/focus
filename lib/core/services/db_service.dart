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
  int get schemaVersion => 1;

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
    onUpgrade: (m, from, to) async {},
  );
}
