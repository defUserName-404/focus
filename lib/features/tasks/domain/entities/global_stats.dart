/// Aggregated global statistics across all tasks and sessions.
class GlobalStats {
  final int totalFocusMinutes;
  final int totalSessions;
  final int completedSessions;
  final int totalTasks;
  final int completedTasks;
  final int todaySessions;
  final int todayFocusMinutes;
  final int currentStreak;

  const GlobalStats({
    required this.totalFocusMinutes,
    required this.totalSessions,
    required this.completedSessions,
    required this.totalTasks,
    required this.completedTasks,
    required this.todaySessions,
    required this.todayFocusMinutes,
    required this.currentStreak,
  });

  static const empty = GlobalStats(
    totalFocusMinutes: 0,
    totalSessions: 0,
    completedSessions: 0,
    totalTasks: 0,
    completedTasks: 0,
    todaySessions: 0,
    todayFocusMinutes: 0,
    currentStreak: 0,
  );

  String get formattedTotalTime {
    if (totalFocusMinutes < 60) return '${totalFocusMinutes}m';
    final hours = totalFocusMinutes ~/ 60;
    final mins = totalFocusMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  String get formattedTodayTime {
    if (todayFocusMinutes < 60) return '${todayFocusMinutes}m';
    final hours = todayFocusMinutes ~/ 60;
    final mins = todayFocusMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  double get taskCompletionRate =>
      totalTasks > 0 ? completedTasks / totalTasks : 0.0;
}
