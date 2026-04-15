part of 'task_provider.dart';

final filteredTasksProvider = StreamProvider.family<List<Task>, String>((ref, projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskListFilterProvider(projectId));

  return repository.watchFilteredTasks(
    projectId: int.parse(projectId),
    searchQuery: filter.searchQuery,
    sortCriteria: filter.sortCriteria,
    sortOrder: filter.sortOrder,
    priorityFilter: filter.priorityFilter,
  );
});
