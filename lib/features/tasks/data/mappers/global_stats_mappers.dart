import '../../domain/entities/global_stats.dart';
import '../models/global_stats_model.dart';

extension GlobalStatsModelToDomain on GlobalStatsModel {
  GlobalStats toDomain() {
    return GlobalStats(
      totalFocusMinutes: totalSeconds ~/ 60,
      totalSessions: totalSessions,
      completedSessions: completedSessions,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      todaySessions: todaySessions,
      todayFocusMinutes: todaySeconds ~/ 60,
      currentStreak: currentStreak,
    );
  }
}
