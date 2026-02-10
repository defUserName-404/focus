import '../../../tasks/domain/entities/task_priority.dart';

/// Sort criteria for the task list on the project detail screen.
enum TaskSortCriteria {
  recentlyModified('Recent'),
  deadline('Deadline'),
  priority('Priority'),
  title('Title'),
  createdDate('Created');

  final String label;
  const TaskSortCriteria(this.label);
}

/// Immutable state for task list filtering and sorting.
class TaskListFilterState {
  final String searchQuery;
  final TaskSortCriteria sortCriteria;
  final TaskPriority? priorityFilter;

  const TaskListFilterState({
    this.searchQuery = '',
    this.sortCriteria = TaskSortCriteria.recentlyModified,
    this.priorityFilter,
  });

  TaskListFilterState copyWith({
    String? searchQuery,
    TaskSortCriteria? sortCriteria,
    Object? priorityFilter = _unset,
  }) {
    return TaskListFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      priorityFilter:
          priorityFilter == _unset ? this.priorityFilter : priorityFilter as TaskPriority?,
    );
  }
}

const _unset = Object();
