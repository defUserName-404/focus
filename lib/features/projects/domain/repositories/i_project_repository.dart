import '../entities/project.dart';
import '../../presentation/providers/project_list_filter_state.dart';

abstract class IProjectRepository {
  Future<List<Project>> getAllProjects();
  Future<Project?> getProjectById(BigInt id);
  Future<Project> createProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(BigInt id);
  Stream<List<Project>> watchAllProjects();
  Stream<List<Project>> watchFilteredProjects({
    String searchQuery,
    ProjectSortCriteria sortCriteria,
    ProjectSortOrder sortOrder,
  });
}
