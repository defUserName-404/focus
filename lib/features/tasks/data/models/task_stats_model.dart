import 'package:dart_mappable/dart_mappable.dart';

part 'task_stats_model.mapper.dart';

/// Raw aggregated stats from the database for a single task.
///
/// This is the data-layer representation returned by the datasource.
/// The mapper converts it to the domain [TaskStats] entity.
@MappableClass()
class TaskStatsModel with TaskStatsModelMappable {
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
