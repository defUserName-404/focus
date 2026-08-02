import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';
import '../../../session/domain/entities/session_state.dart';
import '../../domain/entities/task_status.dart';
import '../models/global_stats_model.dart';
import '../models/report_stats_models.dart';
import '../models/task_stats_model.dart';

abstract class ITaskStatsLocalDataSource {
  /// Watches aggregated stats for a single task.
  Stream<TaskStatsModel> watchTaskStats(int taskId);

  /// Watches the most recent sessions for a task, ordered by start_time desc.
  Stream<List<FocusSessionData>> watchRecentSessions(int taskId, {int limit = 10});

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
  Stream<List<DailySessionStatsData>> watchDailyStatsForRange(String startDate, String endDate);

  /// Watches habit metadata plus completion dates in `[startDate, endDate]`.
  Stream<List<HabitConsistencySourceRow>> watchHabitConsistencySources(String startDate, String endDate);

  /// Watches habit completion counts by day for a heatmap range.
  Stream<Map<String, int>> watchHabitCompletionHeatmap(String startDate, String endDate);

  /// Watches estimated vs actual focus minutes per task in the window.
  Stream<List<EstimateAccuracyRow>> watchEstimateAccuracy(String startDate, String endDate);

  /// Watches focus seconds grouped by project for sessions in the window.
  Stream<List<TimeBreakdownRow>> watchTimeByProject(String startDate, String endDate);

  /// Watches focus seconds grouped by tag for sessions in the window.
  Stream<List<TimeBreakdownRow>> watchTimeByTag(String startDate, String endDate);

  /// Watches task + habit completion counts keyed by ISO date.
  Stream<Map<String, int>> watchTaskCompletionsByDate(String startDate, String endDate);

  /// Watches average cycle seconds (work-start proxy → done) for the window.
  Stream<CycleTimeAggregateRow> watchAverageCycleTime(String startDate, String endDate);
}

class TaskStatsLocalDataSourceImpl implements ITaskStatsLocalDataSource {
  TaskStatsLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  final _log = LogService.instance;

  static final int _completedState = SessionState.completed.index;

  @override
  Stream<TaskStatsModel> watchTaskStats(int taskId) {
    return _db
        .customSelect(
          'SELECT '
          'COALESCE(SUM(MIN(elapsed_seconds, focus_duration_minutes * 60)), 0) AS total_seconds, '
          'COUNT(*) AS total_sessions, '
          'COALESCE(SUM(CASE WHEN state = $_completedState THEN 1 ELSE 0 END), 0) AS completed_sessions '
          'FROM focus_session_table WHERE task_id = ? AND deleted_at IS NULL',
          variables: [Variable<int>(taskId)],
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
                'WHERE task_id = ? AND state = $_completedState AND deleted_at IS NULL '
                'GROUP BY d',
                variables: [Variable<int>(taskId)],
              )
              .get();

          try {
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
          } catch (e, st) {
            _log.error(
              'Error mapping TaskStatsModel for task $taskId',
              tag: 'TaskStatsLocalDataSource',
              error: e,
              stackTrace: st,
            );
            rethrow;
          }
        });
  }

  @override
  Stream<List<FocusSessionData>> watchRecentSessions(int taskId, {int limit = 10}) {
    return (_db.select(_db.focusSessionTable)
          ..where((t) => t.taskId.equals(taskId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startTime)])
          ..limit(limit))
        .watch();
  }

  //  Reads from daily_session_stats_table

  @override
  Stream<Map<String, int>> watchGlobalDailyCompletedSessions() {
    return (_db.select(_db.dailySessionStatsTable)..where((t) => t.completedSessions.isBiggerThanValue(0))).watch().map(
      (rows) {
        final Map<String, int> daily = {};
        for (final row in rows) {
          daily[row.date] = row.completedSessions;
        }
        return daily;
      },
    );
  }

  @override
  Stream<GlobalStatsModel> watchGlobalStats() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Today’s stats are derived from focus_session_table (same source as
    // the overall counters) so the two can never disagree.  The previous
    // implementation read today from daily_session_stats_table, which
    // could lag behind the session table after a write, causing the
    // today / overall mismatch the user reported.
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
          '(SELECT COALESCE(SUM(MIN(elapsed_seconds, focus_duration_minutes * 60)), 0) AS total_seconds, COUNT(*) AS total_sessions, '
          'SUM(CASE WHEN state = $_completedState THEN 1 ELSE 0 END) AS completed_sessions '
          'FROM focus_session_table WHERE deleted_at IS NULL) s, '
          '(SELECT COUNT(*) AS total_tasks, '
          'SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) AS completed_tasks '
          'FROM task_table WHERE depth = 0 AND deleted_at IS NULL) t, '
          '(SELECT '
          'COALESCE(SUM(CASE WHEN state = $_completedState THEN 1 ELSE 0 END), 0) AS today_sessions, '
          'COALESCE(SUM(MIN(elapsed_seconds, focus_duration_minutes * 60)), 0) AS today_seconds '
          'FROM focus_session_table '
          "WHERE deleted_at IS NULL AND date(start_time, 'unixepoch', 'localtime') = ?) td",
          variables: [Variable<String>(todayKey)],
          readsFrom: {_db.focusSessionTable, _db.taskTable, _db.dailySessionStatsTable},
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

          final activeDates = <String>{for (final r in streakRows) r.read<String>('date')};

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
          ..where((t) => t.depth.equals(0) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
        .watch();
  }

  @override
  Stream<List<DailySessionStatsData>> watchDailyStatsForRange(String startDate, String endDate) {
    return (_db.select(_db.dailySessionStatsTable)
          ..where((t) => t.date.isBiggerOrEqualValue(startDate) & t.date.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  @override
  Stream<List<HabitConsistencySourceRow>> watchHabitConsistencySources(String startDate, String endDate) {
    return _db
        .customSelect(
          'SELECT id, title, recurrence_rule, recurrence_anchor_date, start_date, created_at '
          'FROM task_table '
          'WHERE is_habit = 1 AND deleted_at IS NULL AND recurrence_rule IS NOT NULL',
          readsFrom: {_db.taskTable, _db.taskCompletionTable},
        )
        .watch()
        .asyncMap((rows) async {
          final completionRows = await _db
              .customSelect(
                'SELECT task_id, occurrence_date '
                'FROM task_completion_table '
                'WHERE deleted_at IS NULL '
                'AND occurrence_date >= ? AND occurrence_date <= ?',
                variables: [Variable<String>(startDate), Variable<String>(endDate)],
                readsFrom: {_db.taskCompletionTable},
              )
              .get();
          final byTask = <int, List<String>>{};
          for (final row in completionRows) {
            final taskId = row.read<int>('task_id');
            byTask.putIfAbsent(taskId, () => []).add(row.read<String>('occurrence_date'));
          }
          return [
            for (final row in rows)
              HabitConsistencySourceRow(
                taskId: row.read<int>('id'),
                title: row.read<String>('title'),
                recurrenceRuleJson: row.read<String>('recurrence_rule'),
                recurrenceAnchorDate: row.readNullable<DateTime>('recurrence_anchor_date'),
                startDate: row.readNullable<DateTime>('start_date'),
                createdAt: row.read<DateTime>('created_at'),
                completionDateKeys: byTask[row.read<int>('id')] ?? const [],
              ),
          ];
        });
  }

  @override
  Stream<Map<String, int>> watchHabitCompletionHeatmap(String startDate, String endDate) {
    return _db
        .customSelect(
          'SELECT tc.occurrence_date AS d, COUNT(*) AS cnt '
          'FROM task_completion_table tc '
          'INNER JOIN task_table t ON t.id = tc.task_id '
          'WHERE tc.deleted_at IS NULL AND t.deleted_at IS NULL AND t.is_habit = 1 '
          'AND tc.occurrence_date >= ? AND tc.occurrence_date <= ? '
          'GROUP BY tc.occurrence_date',
          variables: [Variable<String>(startDate), Variable<String>(endDate)],
          readsFrom: {_db.taskCompletionTable, _db.taskTable},
        )
        .watch()
        .map((rows) {
          final map = <String, int>{};
          for (final row in rows) {
            map[row.read<String>('d')] = row.read<int>('cnt');
          }
          return map;
        });
  }

  @override
  Stream<List<EstimateAccuracyRow>> watchEstimateAccuracy(String startDate, String endDate) {
    return _db
        .customSelect(
          'SELECT t.id AS task_id, t.title AS title, t.estimated_minutes AS estimated_minutes, '
          'CAST(COALESCE(SUM(MIN(s.elapsed_seconds, s.focus_duration_minutes * 60)), 0) / 60 AS INTEGER) '
          'AS actual_minutes '
          'FROM task_table t '
          'INNER JOIN focus_session_table s ON s.task_id = t.id AND s.deleted_at IS NULL '
          "AND date(s.start_time, 'unixepoch', 'localtime') >= ? "
          "AND date(s.start_time, 'unixepoch', 'localtime') <= ? "
          'WHERE t.deleted_at IS NULL '
          'AND t.estimated_minutes IS NOT NULL AND t.estimated_minutes > 0 '
          'GROUP BY t.id, t.title, t.estimated_minutes '
          'HAVING actual_minutes > 0 '
          'ORDER BY actual_minutes DESC',
          variables: [Variable<String>(startDate), Variable<String>(endDate)],
          readsFrom: {_db.taskTable, _db.focusSessionTable},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              EstimateAccuracyRow(
                taskId: row.read<int>('task_id'),
                title: row.read<String>('title'),
                estimatedMinutes: row.read<int>('estimated_minutes'),
                actualMinutes: row.read<int>('actual_minutes'),
              ),
          ],
        );
  }

  @override
  Stream<List<TimeBreakdownRow>> watchTimeByProject(String startDate, String endDate) {
    return _db
        .customSelect(
          'SELECT p.id AS id, p.title AS name, '
          'COALESCE(SUM(MIN(s.elapsed_seconds, s.focus_duration_minutes * 60)), 0) AS focus_seconds, '
          'p.color AS color '
          'FROM project_table p '
          'INNER JOIN task_table t ON t.project_id = p.id AND t.deleted_at IS NULL '
          'INNER JOIN focus_session_table s ON s.task_id = t.id AND s.deleted_at IS NULL '
          "AND date(s.start_time, 'unixepoch', 'localtime') >= ? "
          "AND date(s.start_time, 'unixepoch', 'localtime') <= ? "
          'WHERE p.deleted_at IS NULL '
          'GROUP BY p.id, p.title, p.color '
          'HAVING focus_seconds > 0 '
          'ORDER BY focus_seconds DESC',
          variables: [Variable<String>(startDate), Variable<String>(endDate)],
          readsFrom: {_db.projectTable, _db.taskTable, _db.focusSessionTable},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              TimeBreakdownRow(
                id: row.read<int>('id'),
                name: row.read<String>('name'),
                focusSeconds: row.read<int>('focus_seconds'),
                color: row.readNullable<int>('color'),
              ),
          ],
        );
  }

  @override
  Stream<List<TimeBreakdownRow>> watchTimeByTag(String startDate, String endDate) {
    return _db
        .customSelect(
          'SELECT tag.id AS id, tag.name AS name, '
          'COALESCE(SUM(MIN(s.elapsed_seconds, s.focus_duration_minutes * 60)), 0) AS focus_seconds, '
          'tag.color AS color '
          'FROM tag_table tag '
          'INNER JOIN task_tag_table tt ON tt.tag_id = tag.id '
          'INNER JOIN focus_session_table s ON s.task_id = tt.task_id AND s.deleted_at IS NULL '
          "AND date(s.start_time, 'unixepoch', 'localtime') >= ? "
          "AND date(s.start_time, 'unixepoch', 'localtime') <= ? "
          'WHERE tag.deleted_at IS NULL '
          'GROUP BY tag.id, tag.name, tag.color '
          'HAVING focus_seconds > 0 '
          'ORDER BY focus_seconds DESC',
          variables: [Variable<String>(startDate), Variable<String>(endDate)],
          readsFrom: {_db.tagTable, _db.taskTagTable, _db.focusSessionTable},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              TimeBreakdownRow(
                id: row.read<int>('id'),
                name: row.read<String>('name'),
                focusSeconds: row.read<int>('focus_seconds'),
                color: row.readNullable<int>('color'),
              ),
          ],
        );
  }

  @override
  Stream<Map<String, int>> watchTaskCompletionsByDate(String startDate, String endDate) {
    final doneStatus = TaskStatus.done.index;
    return _db
        .customSelect(
          'SELECT d, SUM(cnt) AS cnt FROM ('
          "SELECT date(updated_at, 'unixepoch', 'localtime') AS d, COUNT(*) AS cnt "
          'FROM task_table '
          'WHERE status = $doneStatus AND deleted_at IS NULL AND is_habit = 0 '
          "AND date(updated_at, 'unixepoch', 'localtime') >= ? "
          "AND date(updated_at, 'unixepoch', 'localtime') <= ? "
          'GROUP BY d '
          'UNION ALL '
          'SELECT occurrence_date AS d, COUNT(*) AS cnt '
          'FROM task_completion_table '
          'WHERE deleted_at IS NULL '
          'AND occurrence_date >= ? AND occurrence_date <= ? '
          'GROUP BY occurrence_date'
          ') GROUP BY d',
          variables: [
            Variable<String>(startDate),
            Variable<String>(endDate),
            Variable<String>(startDate),
            Variable<String>(endDate),
          ],
          readsFrom: {_db.taskTable, _db.taskCompletionTable},
        )
        .watch()
        .map((rows) {
          final map = <String, int>{};
          for (final row in rows) {
            map[row.read<String>('d')] = row.read<int>('cnt');
          }
          return map;
        });
  }

  @override
  Stream<CycleTimeAggregateRow> watchAverageCycleTime(String startDate, String endDate) {
    final doneStatus = TaskStatus.done.index;
    return _db
        .customSelect(
          'SELECT '
          'AVG('
          't.updated_at - COALESCE('
          '(SELECT MIN(fs.start_time) FROM focus_session_table fs '
          'WHERE fs.task_id = t.id AND fs.deleted_at IS NULL), '
          't.start_date, t.created_at'
          ')'
          ') AS avg_cycle_seconds, '
          'COUNT(*) AS sample_count '
          'FROM task_table t '
          'WHERE t.status = $doneStatus AND t.deleted_at IS NULL AND t.is_habit = 0 '
          "AND date(t.updated_at, 'unixepoch', 'localtime') >= ? "
          "AND date(t.updated_at, 'unixepoch', 'localtime') <= ? "
          'AND t.updated_at > COALESCE('
          '(SELECT MIN(fs.start_time) FROM focus_session_table fs '
          'WHERE fs.task_id = t.id AND fs.deleted_at IS NULL), '
          't.start_date, t.created_at'
          ')',
          variables: [Variable<String>(startDate), Variable<String>(endDate)],
          readsFrom: {_db.taskTable, _db.focusSessionTable},
        )
        .watchSingle()
        .map((row) {
          final sampleCount = row.read<int>('sample_count');
          if (sampleCount <= 0) return CycleTimeAggregateRow.empty;
          final avg = row.readNullable<double>('avg_cycle_seconds');
          return CycleTimeAggregateRow(averageCycleSeconds: avg, sampleCount: sampleCount);
        });
  }
}
