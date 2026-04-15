part of 'all_tasks_provider.dart';

final filteredAllTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(allTasksFilterProvider);

  return repository.watchAllFilteredTasks(
    searchQuery: filter.searchQuery,
    sortCriteria: filter.sortCriteria,
    sortOrder: filter.sortOrder,
    priorityFilter: filter.priorityFilter,
    completionFilter: filter.completionFilter,
  );
});
