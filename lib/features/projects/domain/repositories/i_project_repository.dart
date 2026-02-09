import '../entities/project.dart';

abstract class IProjectRepository {
  Future<List<Project>> getAllProjects();

  Future<Project?> getProjectById(BigInt id);

  Future<Project> createProject(Project project);

  Future<void> updateProject(Project project);

  Future<void> deleteProject(BigInt id);

  Stream<List<Project>> watchAllProjects();
}
