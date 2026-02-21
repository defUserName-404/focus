import '../entities/project_list_filter_state.dart';
import '../entities/project.dart';

abstract interface class IProjectRepository {
  Future<List<Project>> getAllProjects();

  Future<Project?> getProjectById(int id);

  Future<Project> createProject(Project project);

  Future<void> updateProject(Project project);

  Future<void> deleteProject(int id);

  Stream<Project?> watchProjectById(int id);

  Stream<List<Project>> watchAllProjects();

  Stream<List<Project>> watchFilteredProjects({
    String searchQuery,
    ProjectSortCriteria sortCriteria,
    ProjectSortOrder sortOrder,
  });
}
