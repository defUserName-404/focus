import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../focus/domain/entities/session_state.dart';
import '../models/global_stats_model.dart';
import '../models/task_stats_model.dart';

abstract class ITaskStatsLocalDataSource {
  /// Watches aggregated stats for a single task.
  Stream<TaskStatsModel> watchTaskStats(BigInt taskId);

  /// Watches the most recent sessions for a task, ordered by start_time desc.
  Stream<List<FocusSessionData>> watchRecentSessions(
    BigInt taskId, {
    int limit = 10,
  });

  /// Watches daily completed-session counts across ALL tasks.
  ///
  /// Keys are ISO date strings (`YYYY-MM-DD`).
  Stream<Map<String, int>> watchGlobalDailyCompletedSessions();

  /// Watches aggregated global stats across all tasks and sessions.
  Stream<GlobalStatsModel> watchGlobalStats();

  /// Watches recently updated top-level tasks.
  Stream<List<TaskTableData>> watchRecentTasks({int limit = 5});

  /// Watches pre-aggregated daily stats for a date range (inclusive).
  ///
  /// [startDate] and [endDate] are ISO `YYYY-MM-DD` strings.
  /// Ideal for lazy-loading monthly pages in a horizontal scroll graph.
  Stream<List<DailySessionStatsData>> watchDailyStatsForRange(
    String startDate,
    String endDate,
  );
}

class TaskStatsLocalDataSourceImpl implements ITaskStatsLocalDataSource {
  TaskStatsLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  static final int _completedState = SessionState.completed.index;

  @override
  Stream<TaskStatsModel> watchTaskStats(BigInt taskId) {
    return _db
        .customSelect(
          'SELECT '
          'COALESCE(SUM(elapsed_seconds), 0) AS total_seconds, '
          'COUNT(*) AS total_sessions, '
          'SUM(CASE WHEN state = $_completedState THEN 1 ELSE 0 END) AS completed_sessions '
          'FROM focus_session_table WHERE task_id = ?',
          variables: [Variable<BigInt>(taskId)],
          readsFrom: {_db.focusSessionTable},
        )
        .watchSingle()
        .asyncMap((summaryRow) async {
      final totalSeconds = summaryRow.read<int>('total_seconds');
      final totalSessions = summaryRow.read<int>('total_sessions');
      final completedSessions = summaryRow.read<int>('completed_sessions');

      // Group completed sessions by local calendar date using SQLite's date().
      final dailyRows = await _db
          .customSelect(
            "SELECT date(start_time, 'unixepoch', 'localtime') AS d, COUNT(*) AS cnt "
            'FROM focus_session_table '
            'WHERE task_id = ? AND state = $_completedState '
            'GROUP BY d',
            variables: [Variable<BigInt>(taskId)],
          )
          .get();

      final Map<String, int> daily = {};
      for (final row in dailyRows) {
        daily[row.read<String>('d')] = row.read<int>('cnt');
      }

      return TaskStatsModel(
        totalSeconds: totalSeconds,
        totalSessions: totalSessions,
        completedSessions: completedSessions,
        dailyCompletedSessions: daily,
      );
    });
  }

  @override
  Stream<List<FocusSessionData>> watchRecentSessions(
    BigInt taskId, {
    int limit = 10,
  }) {
    return (_db.select(_db.focusSessionTable)
          ..where((t) => t.taskId.equals(taskId))
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(limit))
        .watch();
  }

  // ── Reads from daily_session_stats_table ─────────────────────────────────

  @override
  Stream<Map<String, int>> watchGlobalDailyCompletedSessions() {
    return (_db.select(_db.dailySessionStatsTable)
          ..where((t) => t.completedSessions.isBiggerThanValue(0)))
        .watch()
        .map((rows) {
      final Map<String, int> daily = {};
      for (final row in rows) {
        daily[row.date] = row.completedSessions;
      }
      return daily;
    });
  }

  @override
  Stream<GlobalStatsModel> watchGlobalStats() {
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return _db
        .customSelect(
          'SELECT '
          'COALESCE(s.total_seconds, 0) AS total_seconds, '
          'COALESCE(s.total_sessions, 0) AS total_sessions, '
          'COALESCE(s.completed_sessions, 0) AS completed_sessions, '
          'COALESCE(t.total_tasks, 0) AS total_tasks, '
          'COALESCE(t.completed_tasks, 0) AS completed_tasks, '
          'COALESCE(td.today_sessions, 0) AS today_sessions, '
          'COALESCE(td.today_seconds, 0) AS today_seconds '
          'FROM '
          '(SELECT COALESCE(SUM(elapsed_seconds), 0) AS total_seconds, COUNT(*) AS total_sessions, '
          'SUM(CASE WHEN state = $_completedState THEN 1 ELSE 0 END) AS completed_sessions '
          'FROM focus_session_table) s, '
          '(SELECT COUNT(*) AS total_tasks, '
          'SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) AS completed_tasks '
          'FROM task_table WHERE depth = 0) t, '
          '(SELECT COALESCE(completed_sessions, 0) AS today_sessions, '
          'COALESCE(focus_seconds, 0) AS today_seconds '
          'FROM daily_session_stats_table WHERE date = ?) td',
          variables: [Variable<String>(todayKey)],
          readsFrom: {
            _db.focusSessionTable,
            _db.taskTable,
            _db.dailySessionStatsTable,
          },
        )
        .watchSingle()
        .asyncMap((row) async {
      // Streak: count consecutive days with completed sessions,
      // walking backwards from today using the pre-aggregated table.
      final streakRows = await _db
          .customSelect(
            'SELECT date FROM daily_session_stats_table '
            'WHERE completed_sessions > 0 '
            'ORDER BY date DESC',
            readsFrom: {_db.dailySessionStatsTable},
          )
          .get();

      final activeDates = <String>{
        for (final r in streakRows) r.read<String>('date'),
      };

      int streak = 0;
      var checkDate = DateTime(now.year, now.month, now.day);
      while (true) {
        final key =
            '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
        if (!activeDates.contains(key)) break;
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      return GlobalStatsModel(
        totalSeconds: row.read<int>('total_seconds'),
        totalSessions: row.read<int>('total_sessions'),
        completedSessions: row.read<int>('completed_sessions'),
        totalTasks: row.read<int>('total_tasks'),
        completedTasks: row.read<int>('completed_tasks'),
        todaySessions: row.read<int>('today_sessions'),
        todaySeconds: row.read<int>('today_seconds'),
        currentStreak: streak,
      );
    });
  }

  @override
  Stream<List<TaskTableData>> watchRecentTasks({int limit = 5}) {
    return (_db.select(_db.taskTable)
          ..where((t) => t.depth.equals(0))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
        .watch();
  }

  @override
  Stream<List<DailySessionStatsData>> watchDailyStatsForRange(
    String startDate,
    String endDate,
  ) {
    return (_db.select(_db.dailySessionStatsTable)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }
}
