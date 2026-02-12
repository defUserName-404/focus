import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../focus/domain/entities/focus_session.dart';
import '../../domain/entities/daily_session_stats.dart';
import '../../domain/entities/global_stats.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_stats.dart';
import '../../domain/repositories/i_task_stats_repository.dart';

/// Provides the [ITaskStatsRepository] singleton from DI.
final taskStatsRepositoryProvider = Provider<ITaskStatsRepository>((ref) {
  return getIt<ITaskStatsRepository>();
});

/// Watches aggregated stats for a single task.
final taskStatsProvider = StreamProvider.family<TaskStats, String>((ref, taskIdString) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchTaskStats(BigInt.parse(taskIdString));
});

/// Watches the most recent focus sessions for a task (max 10).
final recentSessionsProvider = StreamProvider.family<List<FocusSession>, String>((ref, taskIdString) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchRecentSessions(BigInt.parse(taskIdString));
});

/// Watches daily completed sessions across ALL tasks for the activity heatmap.
/// Keys are ISO date strings (`YYYY-MM-DD`).
final globalDailyCompletedSessionsProvider = StreamProvider<Map<String, int>>((ref) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchGlobalDailyCompletedSessions();
});

/// Watches pre-aggregated daily stats for a date range.
/// The argument is `'startDate|endDate'` in ISO format.
final dailyStatsForRangeProvider =
    StreamProvider.family<List<DailySessionStats>, String>((ref, rangeKey) {
  final parts = rangeKey.split('|');
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchDailyStatsForRange(parts[0], parts[1]);
});

/// Watches aggregated global stats across all tasks and sessions.
final globalStatsProvider = StreamProvider<GlobalStats>((ref) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchGlobalStats();
});

/// Watches recently updated tasks (root level) across all projects.
final recentTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchRecentTasks();
});
