/// Raw aggregated stats from the database for a single task.
///
/// This is the data-layer representation returned by the datasource.
/// The mapper converts it to the domain [TaskStats] entity.
class TaskStatsModel {
  final int totalSeconds;
  final int totalSessions;
  final int completedSessions;

  /// ISO date string (`YYYY-MM-DD`) → number of completed sessions on that day.
  final Map<String, int> dailyCompletedSessions;

  const TaskStatsModel({
    required this.totalSeconds,
    required this.totalSessions,
    required this.completedSessions,
    required this.dailyCompletedSessions,
  });
}
