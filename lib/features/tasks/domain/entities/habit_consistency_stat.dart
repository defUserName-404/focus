import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Per-habit consistency metrics for a report insights window.
@immutable
class HabitConsistencyStat extends Equatable {
  final int taskId;
  final String title;
  final double completionRate;
  final int currentStreak;
  final int longestStreak;
  final int scheduledCount;
  final int completedCount;

  const HabitConsistencyStat({
    required this.taskId,
    required this.title,
    required this.completionRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.scheduledCount,
    required this.completedCount,
  });

  @override
  List<Object?> get props => [
    taskId,
    title,
    completionRate,
    currentStreak,
    longestStreak,
    scheduledCount,
    completedCount,
  ];
}
