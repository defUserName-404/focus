import '../entities/daily_session_stats.dart';
import '../entities/global_stats.dart';
import '../entities/task_stats.dart';
import '../entities/task.dart';
import '../../../focus/domain/entities/focus_session.dart';

abstract class ITaskStatsRepository {
  /// Watches aggregated stats for a task, computed at the ORM level.
  Stream<TaskStats> watchTaskStats(int taskId);

  /// Watches the most recent focus sessions for a task.
  Stream<List<FocusSession>> watchRecentSessions(int taskId, {int limit = 10});

  /// Watches daily completed sessions across all tasks.
  /// Keys are ISO date strings (`YYYY-MM-DD`).
  Stream<Map<String, int>> watchGlobalDailyCompletedSessions();

  /// Watches pre-aggregated daily stats for a date range (inclusive).
  /// [startDate] and [endDate] are ISO `YYYY-MM-DD` strings.
  Stream<List<DailySessionStats>> watchDailyStatsForRange(String startDate, String endDate);

  /// Watches aggregated global stats across all tasks and sessions.
  Stream<GlobalStats> watchGlobalStats();

  /// Watches recently updated tasks (across all projects), root level only.
  Stream<List<Task>> watchRecentTasks({int limit = 5});
}
