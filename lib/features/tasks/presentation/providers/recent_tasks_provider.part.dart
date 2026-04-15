part of 'task_stats_provider.dart';

/// Watches recently updated tasks (root level) across all projects.
final recentTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchRecentTasks();
});
