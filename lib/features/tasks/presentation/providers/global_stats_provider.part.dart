part of 'task_stats_provider.dart';

/// Watches aggregated global stats across all tasks and sessions.
final globalStatsProvider = StreamProvider<GlobalStats>((ref) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchGlobalStats();
});
