import '../../domain/entities/task_stats.dart';
import '../models/task_stats_model.dart';

/// Manual mapping from the DB model to the domain `TaskStats`.
///
/// This mapping must compute aggregate values (minutes, averages) from the
/// pre-aggregated `totalSeconds` column produced by the custom SQL queries.
/// We preserve the raw seconds in the domain model (`totalFocusSeconds`) so
/// presentation code can decide how to round/format without losing precision.
extension TaskStatsModelToDomain on TaskStatsModel {
  TaskStats toDomain() {
    final totalMinutes = totalSeconds ~/ 60;
    final avg = totalSessions > 0 ? (totalSeconds / totalSessions) / 60.0 : 0.0;

    return TaskStats(
      totalFocusMinutes: totalMinutes,
      totalFocusSeconds: totalSeconds,
      totalSessions: totalSessions,
      completedSessions: completedSessions,
      avgSessionMinutes: avg,
      dailyCompletedSessions: dailyCompletedSessions,
    );
  }
}
