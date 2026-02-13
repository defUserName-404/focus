import '../../../../core/common/sort_criteria.dart';
import '../../../../core/common/sort_order.dart';

/// Sort criteria for the project list.
enum ProjectSortCriteria implements SortCriteria {
  recentlyModified('Recent'),
  deadline('Deadline'),
  startDate('Start'),
  title('Title'),
  createdDate('Created');

  @override
  final String label;

  const ProjectSortCriteria(this.label);
}

/// Sort order for the project list.
enum ProjectSortOrder implements SortOrder {
  none('None'),
  ascending('Ascending'),
  descending('Descending');

  @override
  final String label;

  const ProjectSortOrder(this.label);
}

/// Immutable state for project list filtering and sorting.
class ProjectListFilterState {
  final String searchQuery;
  final ProjectSortCriteria sortCriteria;
  final ProjectSortOrder sortOrder;

  const ProjectListFilterState({
    this.searchQuery = '',
    this.sortCriteria = ProjectSortCriteria.recentlyModified,
    this.sortOrder = ProjectSortOrder.none,
  });

  ProjectListFilterState copyWith({
    String? searchQuery,
    ProjectSortCriteria? sortCriteria,
    ProjectSortOrder? sortOrder,
  }) {
    return ProjectListFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
