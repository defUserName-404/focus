import 'package:dart_mappable/dart_mappable.dart';

part 'global_stats_model.mapper.dart';

/// Raw aggregated global stats from the database.
@MappableClass()
class GlobalStatsModel with GlobalStatsModelMappable {
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
