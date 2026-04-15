part of 'task_stats_provider.dart';

/// Watches aggregated stats for a single task.
final taskStatsProvider = StreamProvider.family<TaskStats, String>((ref, taskIdString) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchTaskStats(int.parse(taskIdString));
});
