import '../../../../core/sort_criteria.dart';
import '../../../../core/sort_order.dart';
import 'project_status.dart';

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
  final ProjectStatus? statusFilter;

  const ProjectListFilterState({
    this.searchQuery = '',
    this.sortCriteria = ProjectSortCriteria.recentlyModified,
    this.sortOrder = ProjectSortOrder.none,
    this.statusFilter,
  });

  ProjectListFilterState copyWith({
    String? searchQuery,
    ProjectSortCriteria? sortCriteria,
    ProjectSortOrder? sortOrder,
    Object? statusFilter = _unset,
  }) {
    return ProjectListFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortCriteria: sortCriteria ?? this.sortCriteria,
      sortOrder: sortOrder ?? this.sortOrder,
      statusFilter: statusFilter == _unset ? this.statusFilter : statusFilter as ProjectStatus?,
    );
  }
}

const _unset = Object();
