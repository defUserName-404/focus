import '../../../focus/data/mappers/focus_session_mappers.dart';
import '../../../focus/domain/entities/focus_session.dart';
import '../../domain/entities/task_stats.dart';
import '../../domain/repositories/i_task_stats_repository.dart';
import '../datasources/task_stats_local_datasource.dart';
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
}
