import 'package:drift/drift.dart';

import '../../../../core/common/utils/date_formatter.dart';
import '../../../../core/services/db_service.dart';
import '../../../focus/domain/entities/session_state.dart';
import '../models/global_stats_model.dart';
import '../models/task_stats_model.dart';

abstract class ITaskStatsLocalDataSource {
  /// Watches aggregated stats for a task.
  ///
  /// Uses SQL-level aggregation; the stream re-emits whenever
  /// the focus_session_table changes for this task.
  Stream<TaskStatsModel> watchTaskStats(BigInt taskId);

  /// Watches the most recent sessions for a task, ordered by start_time desc.
  Stream<List<FocusSessionData>> watchRecentSessions(
    BigInt taskId, {
    int limit = 10,
  });

  /// Watches daily completed sessions across ALL tasks.
  /// Returns a map of date-only DateTime → completed session count.
  Stream<Map<DateTime, int>> watchGlobalDailyCompletedSessions();

  /// Watches aggregated global stats across all tasks and sessions.
  Stream<GlobalStatsModel> watchGlobalStats();

  /// Watches recently updated tasks (across all projects).
  Stream<List<TaskTableData>> watchRecentTasks({int limit = 5});
}

class TaskStatsLocalDataSourceImpl implements ITaskStatsLocalDataSource {
  TaskStatsLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  static final int _completedState = SessionState.completed.index;

  @override
  Stream<TaskStatsModel> watchTaskStats(BigInt taskId) {
    // The summary aggregate query doubles as the change-trigger.
    // Drift re-emits whenever focus_session_table is modified.
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

      // Fetch start-times of completed sessions for daily grouping.
      // Grouping is done in Dart to respect the local timezone.
      final dailyRows = await _db
          .customSelect(
            'SELECT start_time FROM focus_session_table '
            'WHERE task_id = ? AND state = $_completedState',
            variables: [Variable<BigInt>(taskId)],
          )
          .get();

      final Map<DateTime, int> daily = {};
      for (final row in dailyRows) {
        final epochSeconds = row.read<int>('start_time');
        final day = DateTimeFormatting.fromEpochSecondsToDateOnly(epochSeconds);
        daily[day] = (daily[day] ?? 0) + 1;
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

  @override
  Stream<Map<DateTime, int>> watchGlobalDailyCompletedSessions() {
    return _db
        .customSelect(
          'SELECT start_time FROM focus_session_table '
          'WHERE state = $_completedState',
          readsFrom: {_db.focusSessionTable},
        )
        .watch()
        .map((rows) {
      final Map<DateTime, int> daily = {};
      for (final row in rows) {
        final epochSeconds = row.read<int>('start_time');
        final day = DateTimeFormatting.fromEpochSecondsToDateOnly(epochSeconds);
        daily[day] = (daily[day] ?? 0) + 1;
      }
      return daily;
    });
  }

  @override
  Stream<GlobalStatsModel> watchGlobalStats() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEpoch = todayStart.millisecondsSinceEpoch ~/ 1000;

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
          '(SELECT SUM(elapsed_seconds) AS total_seconds, COUNT(*) AS total_sessions, '
          'SUM(CASE WHEN state = $_completedState THEN 1 ELSE 0 END) AS completed_sessions '
          'FROM focus_session_table) s, '
          '(SELECT COUNT(*) AS total_tasks, '
          'SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) AS completed_tasks '
          'FROM task_table WHERE depth = 0) t, '
          '(SELECT COUNT(*) AS today_sessions, COALESCE(SUM(elapsed_seconds), 0) AS today_seconds '
          'FROM focus_session_table WHERE state = $_completedState AND start_time >= ?) td',
          variables: [Variable<int>(todayEpoch)],
          readsFrom: {_db.focusSessionTable, _db.taskTable},
        )
        .watchSingle()
        .asyncMap((row) async {
      // Calculate current streak from daily completed sessions
      final dailyRows = await _db
          .customSelect(
            'SELECT DISTINCT start_time FROM focus_session_table '
            'WHERE state = $_completedState '
            'ORDER BY start_time DESC',
          )
          .get();

      final Set<DateTime> activeDays = {};
      for (final r in dailyRows) {
        final epochSeconds = r.read<int>('start_time');
        activeDays.add(DateTimeFormatting.fromEpochSecondsToDateOnly(epochSeconds));
      }

      int streak = 0;
      var checkDate = DateTime(now.year, now.month, now.day);
      while (activeDays.contains(checkDate)) {
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
}
