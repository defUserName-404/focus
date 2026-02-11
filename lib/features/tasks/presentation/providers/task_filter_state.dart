import '../../../../core/common/sort_criteria.dart';
import '../../../../core/common/sort_order.dart';
import '../../../tasks/domain/entities/task_priority.dart';

/// Sort criteria for the task list on the project detail screen.
enum TaskSortCriteria implements SortCriteria {
  recentlyModified('Recent'),
  deadline('Deadline'),
  priority('Priority'),
  title('Title'),
  createdDate('Created');

  @override
  final String label;

  const TaskSortCriteria(this.label);
}

/// Sort order for the task list.
enum TaskSortOrder implements SortOrder {
  none('None'),
  ascending('Ascending'),
  descending('Descending');

  @override
  final String label;

  const TaskSortOrder(this.label);
}

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
