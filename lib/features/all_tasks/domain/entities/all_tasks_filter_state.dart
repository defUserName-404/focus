import '../../../../core/common/sort_criteria.dart';
import '../../../../core/common/sort_order.dart';
import '../../../tasks/domain/entities/task_priority.dart';

/// Sort criteria for the global (all-projects) task list.
enum AllTasksSortCriteria implements SortCriteria {
  recentlyModified('Recent'),
  deadline('Deadline'),
  priority('Priority'),
  title('Title'),
  createdDate('Created');

  @override
  final String label;

  const AllTasksSortCriteria(this.label);
}

/// Sort order for the global task list.
enum AllTasksSortOrder implements SortOrder {
  none('None'),
  ascending('Ascending'),
  descending('Descending');

  @override
  final String label;

  const AllTasksSortOrder(this.label);
}

/// Filter: show all, completed only, or incomplete only.
enum TaskCompletionFilter {
  all('All'),
  completed('Done'),
  incomplete('To Do');

  final String label;

  const TaskCompletionFilter(this.label);
}

/// Immutable state for the global task list filtering and sorting.
class AllTasksFilterState {
  final String searchQuery;
  final AllTasksSortCriteria sortCriteria;
  final AllTasksSortOrder sortOrder;
  final TaskPriority? priorityFilter;
  final TaskCompletionFilter completionFilter;

  const AllTasksFilterState({
    this.searchQuery = '',
    this.sortCriteria = AllTasksSortCriteria.recentlyModified,
    this.sortOrder = AllTasksSortOrder.none,
    this.priorityFilter,
    this.completionFilter = TaskCompletionFilter.all,
  });

  AllTasksFilterState copyWith({
    String? searchQuery,
    AllTasksSortCriteria? sortCriteria,
    AllTasksSortOrder? sortOrder,
    Object? priorityFilter = _unset,
    TaskCompletionFilter? completionFilter,
  }) {
    return AllTasksFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      sortOrder: sortOrder ?? this.sortOrder,
      priorityFilter: priorityFilter == _unset ? this.priorityFilter : priorityFilter as TaskPriority?,
      completionFilter: completionFilter ?? this.completionFilter,
    );
  }
}

const _unset = Object();
