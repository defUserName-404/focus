import 'package:drift/drift.dart';

import '../../../../core/common/utils/date_formatter.dart';
import '../../../../core/services/db_service.dart';
import '../../../focus/domain/entities/session_state.dart';
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
}
