import '../../../session/domain/entities/focus_session.dart';
import '../entities/daily_session_stats.dart';
import '../entities/estimate_accuracy_stat.dart';
import '../entities/global_stats.dart';
import '../entities/habit_consistency_stat.dart';
import '../entities/task.dart';
import '../entities/task_stats.dart';
import '../entities/task_throughput_stats.dart';
import '../entities/time_breakdown_item.dart';

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

  /// Watches per-habit consistency for the inclusive ISO date window.
  Stream<List<HabitConsistencyStat>> watchHabitConsistency(String startDate, String endDate);

  /// Watches habit completion counts by day (`YYYY-MM-DD` → count).
  Stream<Map<String, int>> watchHabitCompletionHeatmap(String startDate, String endDate);

  /// Watches estimate accuracy summary for sessions in the window.
  Stream<EstimateAccuracySummary> watchEstimateAccuracy(String startDate, String endDate);

  /// Watches focus time by project for sessions in the window.
  Stream<List<TimeBreakdownItem>> watchTimeByProject(String startDate, String endDate);

  /// Watches focus time by tag for sessions in the window.
  Stream<List<TimeBreakdownItem>> watchTimeByTag(String startDate, String endDate);

  /// Watches throughput buckets and average cycle time for the window.
  ///
  /// [weeklyWindow] controls day vs week bucket labels.
  Stream<TaskThroughputStats> watchTaskThroughput({
    required String startDate,
    required String endDate,
    required bool weeklyWindow,
  });
}
