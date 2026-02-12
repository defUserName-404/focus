import '../entities/global_stats.dart';
import '../entities/task_stats.dart';
import '../entities/task.dart';
import '../../../focus/domain/entities/focus_session.dart';

abstract class ITaskStatsRepository {
  /// Watches aggregated stats for a task, computed at the ORM level.
  Stream<TaskStats> watchTaskStats(BigInt taskId);

  /// Watches the most recent focus sessions for a task.
  Stream<List<FocusSession>> watchRecentSessions(BigInt taskId, {int limit = 10});

  /// Watches daily completed sessions across all tasks.
  Stream<Map<DateTime, int>> watchGlobalDailyCompletedSessions();

  /// Watches aggregated global stats across all tasks and sessions.
  Stream<GlobalStats> watchGlobalStats();

  /// Watches recently updated tasks (across all projects), root level only.
  Stream<List<Task>> watchRecentTasks({int limit = 5});
}
