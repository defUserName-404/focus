import '../../domain/entities/task_stats.dart';
import '../models/task_stats_model.dart';

extension TaskStatsModelToDomain on TaskStatsModel {
  TaskStats toDomain() {
    final totalMinutes = totalSeconds ~/ 60;
    final avg = totalSessions > 0 ? totalMinutes / totalSessions : 0.0;

    return TaskStats(
      totalFocusMinutes: totalMinutes,
      totalSessions: totalSessions,
      completedSessions: completedSessions,
      avgSessionMinutes: avg,
      dailyCompletedSessions: dailyCompletedSessions,
    );
  }
}
