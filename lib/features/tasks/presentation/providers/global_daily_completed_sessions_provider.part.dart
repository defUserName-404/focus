part of 'task_stats_provider.dart';

/// Watches daily completed sessions across ALL tasks for the activity heatmap.
/// Keys are ISO date strings (`YYYY-MM-DD`).
final globalDailyCompletedSessionsProvider = StreamProvider<Map<String, int>>((ref) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchGlobalDailyCompletedSessions();
});
