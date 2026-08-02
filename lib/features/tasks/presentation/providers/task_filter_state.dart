import '../../../tasks/domain/entities/all_tasks_filter_state.dart';
import '../../../tasks/domain/entities/task_filter_state.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/domain/entities/task_status.dart';

// Re-export so existing presentation imports keep working.
export '../../../tasks/domain/entities/task_filter_state.dart' show TaskSortCriteria, TaskSortOrder;
export '../../../tasks/domain/entities/all_tasks_filter_state.dart' show TaskCompletionFilter;

/// Immutable state for task list filtering and sorting.
class TaskListFilterState {
  final String searchQuery;
  final TaskSortCriteria sortCriteria;
  final TaskSortOrder sortOrder;
  final TaskPriority? priorityFilter;
  final TaskStatus? statusFilter;
  final TaskCompletionFilter completionFilter;

  const TaskListFilterState({
    this.searchQuery = '',
    this.sortCriteria = TaskSortCriteria.recentlyModified,
    this.sortOrder = TaskSortOrder.none,
    this.priorityFilter,
    this.statusFilter,
    this.completionFilter = TaskCompletionFilter.all,
  });

  TaskListFilterState copyWith({
    String? searchQuery,
    TaskSortCriteria? sortCriteria,
    TaskSortOrder? sortOrder,
    Object? priorityFilter = _unset,
    Object? statusFilter = _unset,
    TaskCompletionFilter? completionFilter,
  }) {
    return TaskListFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      sortOrder: sortOrder ?? this.sortOrder,
      priorityFilter: priorityFilter == _unset ? this.priorityFilter : priorityFilter as TaskPriority?,
      statusFilter: statusFilter == _unset ? this.statusFilter : statusFilter as TaskStatus?,
      completionFilter: completionFilter ?? this.completionFilter,
    );
  }
}

const _unset = Object();
