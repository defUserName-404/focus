import '../../../tasks/domain/entities/task_filter_state.dart';
import '../../../tasks/domain/entities/task_priority.dart';

// Re-export so existing presentation imports keep working.
export '../../../tasks/domain/entities/task_filter_state.dart' show TaskSortCriteria, TaskSortOrder;

/// Immutable state for task list filtering and sorting.
class TaskListFilterState {
  final String searchQuery;
  final TaskSortCriteria sortCriteria;
  final TaskSortOrder sortOrder;
  final TaskPriority? priorityFilter;

  const TaskListFilterState({
    this.searchQuery = '',
    this.sortCriteria = TaskSortCriteria.recentlyModified,
    this.sortOrder = TaskSortOrder.none,
    this.priorityFilter,
  });

  TaskListFilterState copyWith({
    String? searchQuery,
    TaskSortCriteria? sortCriteria,
    TaskSortOrder? sortOrder,
    Object? priorityFilter = _unset,
  }) {
    return TaskListFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      sortOrder: sortOrder ?? this.sortOrder,
      priorityFilter: priorityFilter == _unset ? this.priorityFilter : priorityFilter as TaskPriority?,
    );
  }
}

const _unset = Object();
