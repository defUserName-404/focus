part of 'project_provider.dart';

final filteredProjectListProvider = StreamProvider<List<Project>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  final filter = ref.watch(projectListFilterProvider);

  return repository.watchFilteredProjects(
    searchQuery: filter.searchQuery,
    sortCriteria: filter.sortCriteria,
    sortOrder: filter.sortOrder,
  );
});
