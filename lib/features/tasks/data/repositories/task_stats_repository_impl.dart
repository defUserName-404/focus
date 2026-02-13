import '../../../focus/data/mappers/focus_session_mappers.dart';
import '../../../focus/domain/entities/focus_session.dart';
import '../../domain/entities/daily_session_stats.dart';
import '../../domain/entities/global_stats.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_stats.dart';
import '../../domain/repositories/i_task_stats_repository.dart';
import '../datasources/task_stats_local_datasource.dart';
import '../mappers/global_stats_mappers.dart';
import '../mappers/task_extensions.dart';
import '../mappers/task_stats_mappers.dart';

class TaskStatsRepositoryImpl implements ITaskStatsRepository {
  final ITaskStatsLocalDataSource _local;

  TaskStatsRepositoryImpl(this._local);

  @override
  Stream<TaskStats> watchTaskStats(BigInt taskId) {
    return _local.watchTaskStats(taskId).map((model) => model.toDomain());
  }

  @override
  Stream<List<FocusSession>> watchRecentSessions(
    BigInt taskId, {
    int limit = 10,
  }) {
    return _local
        .watchRecentSessions(taskId, limit: limit)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<Map<String, int>> watchGlobalDailyCompletedSessions() {
    return _local.watchGlobalDailyCompletedSessions();
  }

  @override
  Stream<List<DailySessionStats>> watchDailyStatsForRange(
    String startDate,
    String endDate,
  ) {
    return _local.watchDailyStatsForRange(startDate, endDate).map(
      (rows) => rows
          .map(
            (r) => DailySessionStats(
              date: r.date,
              completedSessions: r.completedSessions,
              totalSessions: r.totalSessions,
              focusSeconds: r.focusSeconds,
            ),
          )
          .toList(),
    );
  }

  @override
  Stream<GlobalStats> watchGlobalStats() {
    return _local.watchGlobalStats().map((model) => model.toDomain());
  }

  @override
  Stream<List<Task>> watchRecentTasks({int limit = 5}) {
    return _local
        .watchRecentTasks(limit: limit)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
