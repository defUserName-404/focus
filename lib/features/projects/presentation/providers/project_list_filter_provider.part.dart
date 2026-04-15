part of 'project_provider.dart';

@Riverpod(keepAlive: true)
class ProjectListFilter extends _$ProjectListFilter {
  @override
  ProjectListFilterState build() {
    return const ProjectListFilterState();
  }

  void updateFilter({String? searchQuery, ProjectSortCriteria? sortCriteria, ProjectSortOrder? sortOrder}) {
    state = state.copyWith(searchQuery: searchQuery, sortCriteria: sortCriteria, sortOrder: sortOrder);
  }
}
