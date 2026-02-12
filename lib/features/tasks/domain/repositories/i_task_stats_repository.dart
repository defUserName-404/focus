import '../entities/task_stats.dart';
import '../../../focus/domain/entities/focus_session.dart';

abstract class ITaskStatsRepository {
  /// Watches aggregated stats for a task, computed at the ORM level.
  Stream<TaskStats> watchTaskStats(BigInt taskId);

  /// Watches the most recent focus sessions for a task.
  Stream<List<FocusSession>> watchRecentSessions(BigInt taskId, {int limit = 10});
}
