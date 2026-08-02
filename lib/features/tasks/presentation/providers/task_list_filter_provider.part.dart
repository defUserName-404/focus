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
    TaskStatus? statusFilter,
    TaskCompletionFilter? completionFilter,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      sortCriteria: sortCriteria,
      sortOrder: sortOrder,
      priorityFilter: priorityFilter,
      statusFilter: statusFilter,
      completionFilter: completionFilter,
    );
  }

  void clearStatusFilter() {
    state = state.copyWith(statusFilter: null);
  }

  void reset() {
    state = const TaskListFilterState();
  }
}
