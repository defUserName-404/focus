/// Aggregated statistics for a single task's focus sessions.
///
/// All computation is performed at the ORM/SQL level for performance.
/// [dailyCompletedSessions] maps ISO date strings (`YYYY-MM-DD`) to the
/// number of completed sessions on that day, powering the activity heatmap.
class TaskStats {
  final int totalFocusMinutes;
  final int totalSessions;
  final int completedSessions;
  final double avgSessionMinutes;

  /// ISO date string (`YYYY-MM-DD`) → completed session count.
  final Map<String, int> dailyCompletedSessions;

  const TaskStats({
    required this.totalFocusMinutes,
    required this.totalSessions,
    required this.completedSessions,
    required this.avgSessionMinutes,
    required this.dailyCompletedSessions,
  });

  static const empty = TaskStats(
    totalFocusMinutes: 0,
    totalSessions: 0,
    completedSessions: 0,
    avgSessionMinutes: 0,
    dailyCompletedSessions: {},
  );

  String get formattedTotalTime {
    if (totalFocusMinutes < 60) return '${totalFocusMinutes}m';
    final hours = totalFocusMinutes ~/ 60;
    final mins = totalFocusMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  String get formattedAvgTime => '${avgSessionMinutes.round()}m';
}
