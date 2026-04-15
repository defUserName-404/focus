part of 'task_provider.dart';

@Riverpod(keepAlive: true)
class TaskListFilter extends _$TaskListFilter {
  @override
  TaskListFilterState build(String projectId) {
    return const TaskListFilterState();
  }

  void updateFilter({
    String? searchQuery,
    TaskSortCriteria? sortCriteria,
    TaskSortOrder? sortOrder,
    TaskPriority? priorityFilter,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      sortCriteria: sortCriteria,
      sortOrder: sortOrder,
      priorityFilter: priorityFilter,
    );
  }
}
