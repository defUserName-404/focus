import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Aggregated statistics for a single task's focus sessions.
///
/// All computation is performed at the ORM/SQL level for performance.
/// [dailyCompletedSessions] maps ISO date strings (`YYYY-MM-DD`) to the
/// number of completed sessions on that day, powering the activity heatmap.
///
/// Formatting lives in presentation-layer extensions.
@immutable
class TaskStats extends Equatable {
  final int totalFocusMinutes;
  /// Total focus time in seconds (preserved from DB for precision).
  final int totalFocusSeconds;
  final int totalSessions;
  final int completedSessions;
  final double avgSessionMinutes;

  /// ISO date string (`YYYY-MM-DD`) → completed session count.
  final Map<String, int> dailyCompletedSessions;

  const TaskStats({
    required this.totalFocusMinutes,
    required this.totalFocusSeconds,
    required this.totalSessions,
    required this.completedSessions,
    required this.avgSessionMinutes,
    required this.dailyCompletedSessions,
  });

  static const empty = TaskStats(
    totalFocusMinutes: 0,
    totalFocusSeconds: 0,
    totalSessions: 0,
    completedSessions: 0,
    avgSessionMinutes: 0,
    dailyCompletedSessions: {},
  );

  @override
  List<Object?> get props => [
    totalFocusMinutes, totalFocusSeconds, totalSessions, completedSessions,
    avgSessionMinutes, dailyCompletedSessions,
  ];
}
