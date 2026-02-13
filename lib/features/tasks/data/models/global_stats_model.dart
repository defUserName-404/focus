/// Raw aggregated global stats from the database.
class GlobalStatsModel {
  final int totalSeconds;
  final int totalSessions;
  final int completedSessions;
  final int totalTasks;
  final int completedTasks;
  final int todaySessions;
  final int todaySeconds;
  final int currentStreak;

  const GlobalStatsModel({
    required this.totalSeconds,
    required this.totalSessions,
    required this.completedSessions,
    required this.totalTasks,
    required this.completedTasks,
    required this.todaySessions,
    required this.todaySeconds,
    required this.currentStreak,
  });
}
