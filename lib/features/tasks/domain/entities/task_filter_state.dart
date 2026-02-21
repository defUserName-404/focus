import '../../../../core/common/sort_criteria.dart';
import '../../../../core/common/sort_order.dart';

/// Sort criteria for the per-project task list.
///
/// Lives in the **domain** layer so that [ITaskRepository] and the data-layer
/// implementations depend on it without importing from presentation.
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

/// Sort order for the per-project task list.
enum TaskSortOrder implements SortOrder {
  none('None'),
  ascending('Ascending'),
  descending('Descending');

  @override
  final String label;

  const TaskSortOrder(this.label);
}
