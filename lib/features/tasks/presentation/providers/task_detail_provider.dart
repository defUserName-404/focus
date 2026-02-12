import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../focus/domain/entities/focus_session.dart';
import '../../../focus/domain/entities/session_state.dart';
import '../../../focus/domain/repositories/i_focus_session_repository.dart';

/// Computed statistics for a single task's focus sessions.
class TaskDetailStats {
  final int totalFocusMinutes;
  final int totalSessions;
  final int completedSessions;
  final double avgSessionMinutes;

  /// Date (day granularity) → total focus minutes on that day.
  final Map<DateTime, int> dailyFocusMinutes;

  /// Most recent sessions first, capped at 10.
  final List<FocusSession> recentSessions;

  const TaskDetailStats({
    required this.totalFocusMinutes,
    required this.totalSessions,
    required this.completedSessions,
    required this.avgSessionMinutes,
    required this.dailyFocusMinutes,
    required this.recentSessions,
  });

  static const empty = TaskDetailStats(
    totalFocusMinutes: 0,
    totalSessions: 0,
    completedSessions: 0,
    avgSessionMinutes: 0,
    dailyFocusMinutes: {},
    recentSessions: [],
  );

  String get formattedTotalTime {
    if (totalFocusMinutes < 60) return '${totalFocusMinutes}m';
    final hours = totalFocusMinutes ~/ 60;
    final mins = totalFocusMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  String get formattedAvgTime => '${avgSessionMinutes.round()}m';
}

/// Watches all focus sessions for a task and computes stats reactively.
final taskDetailStatsProvider =
    StreamProvider.family<TaskDetailStats, String>((ref, taskIdString) {
  final taskId = BigInt.parse(taskIdString);
  final repository = getIt<IFocusSessionRepository>();

  return repository.watchSessionsByTask(taskId).asyncMap((sessions) =>
      compute(_computeStats, sessions));
});

TaskDetailStats _computeStats(List<FocusSession> sessions) {
  if (sessions.isEmpty) return TaskDetailStats.empty;

  int totalMinutes = 0;
  int completed = 0;
  final Map<DateTime, int> daily = {};

  for (final s in sessions) {
    final minutes = s.elapsedSeconds ~/ 60;
    totalMinutes += minutes;
    if (s.state == SessionState.completed) completed++;

    final day =
        DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
    daily[day] = (daily[day] ?? 0) + minutes;
  }

  final avg = sessions.isNotEmpty ? totalMinutes / sessions.length : 0.0;

  // Most recent first
  final sorted = List<FocusSession>.from(sessions)
    ..sort((a, b) => b.startTime.compareTo(a.startTime));

  return TaskDetailStats(
    totalFocusMinutes: totalMinutes,
    totalSessions: sessions.length,
    completedSessions: completed,
    avgSessionMinutes: avg,
    dailyFocusMinutes: daily,
    recentSessions: sorted.take(10).toList(),
  );
}
