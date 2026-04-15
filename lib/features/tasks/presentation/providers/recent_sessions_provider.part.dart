part of 'task_stats_provider.dart';

/// Watches the most recent focus sessions for a task (max 10).
final recentSessionsProvider = StreamProvider.family<List<FocusSession>, String>((ref, taskIdString) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchRecentSessions(int.parse(taskIdString));
});
