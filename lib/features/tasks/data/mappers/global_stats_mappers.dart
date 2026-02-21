import '../../domain/entities/global_stats.dart';
import '../models/global_stats_model.dart';

/// Manual mapping from `GlobalStatsModel` (DB) to domain `GlobalStats`.
///
/// We preserve raw seconds fields (`totalSeconds`, `todaySeconds`) into the
/// domain so presentation code can format precisely. The minutes fields are
/// derived for convenience.
extension GlobalStatsModelToDomain on GlobalStatsModel {
  GlobalStats toDomain() {
    return GlobalStats(
      totalFocusMinutes: totalSeconds ~/ 60,
      totalFocusSeconds: totalSeconds,
      totalSessions: totalSessions,
      completedSessions: completedSessions,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      todaySessions: todaySessions,
      todayFocusMinutes: todaySeconds ~/ 60,
      todayFocusSeconds: todaySeconds,
      currentStreak: currentStreak,
    );
  }
}
