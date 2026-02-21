import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Aggregated global statistics across all tasks and sessions.
///
/// Pure data container — formatting lives in presentation-layer extensions.
@immutable
class GlobalStats extends Equatable {
  final int totalFocusMinutes;
  /// Total focus time in seconds (preserved from DB for precision).
  final int totalFocusSeconds;
  final int totalSessions;
  final int completedSessions;
  final int totalTasks;
  final int completedTasks;
  final int todaySessions;
  final int todayFocusMinutes;
  /// Today's focus seconds (preserved from DB for precision).
  final int todayFocusSeconds;
  final int currentStreak;

  const GlobalStats({
    required this.totalFocusMinutes,
    required this.totalFocusSeconds,
    required this.totalSessions,
    required this.completedSessions,
    required this.totalTasks,
    required this.completedTasks,
    required this.todaySessions,
    required this.todayFocusMinutes,
    required this.todayFocusSeconds,
    required this.currentStreak,
  });

  static const empty = GlobalStats(
    totalFocusMinutes: 0,
    totalFocusSeconds: 0,
    totalSessions: 0,
    completedSessions: 0,
    totalTasks: 0,
    completedTasks: 0,
    todaySessions: 0,
    todayFocusMinutes: 0,
    todayFocusSeconds: 0,
    currentStreak: 0,
  );

  double get taskCompletionRate => totalTasks > 0 ? completedTasks / totalTasks : 0.0;

  @override
  List<Object?> get props => [
    totalFocusMinutes, totalFocusSeconds, totalSessions, completedSessions,
    totalTasks, completedTasks, todaySessions, todayFocusMinutes, todayFocusSeconds,
    currentStreak,
  ];
}
