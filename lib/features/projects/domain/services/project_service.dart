import '../entities/project.dart';
import '../entities/project_extensions.dart';
import '../repositories/i_project_repository.dart';

/// Domain service for project operations.
///
/// Sits between the presentation layer (providers/commands) and the
/// repository. Encapsulates any business logic beyond simple CRUD,
/// such as timestamping and validation.
class ProjectService {
  final IProjectRepository _repository;

  ProjectService(this._repository);

  //  Read

  Future<List<Project>> getAllProjects() => _repository.getAllProjects();

  Stream<List<Project>> watchAllProjects() => _repository.watchAllProjects();

  Stream<Project?> watchProjectById(BigInt id) => _repository.watchProjectById(id);

  Stream<List<Project>> watchFilteredProjects({String searchQuery = '', dynamic sortCriteria, dynamic sortOrder}) {
    return _repository.watchFilteredProjects(
      searchQuery: searchQuery,
      sortCriteria: sortCriteria,
      sortOrder: sortOrder,
    );
  }

  //  Write

  Future<Project> createProject({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? deadline,
  }) async {
    final now = DateTime.now();
    final project = Project(
      title: title,
      description: description,
      startDate: startDate,
      deadline: deadline,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.createProject(project);
  }

  Future<void> updateProject(Project project) async {
    final updated = project.copyWith(updatedAt: DateTime.now());
    return _repository.updateProject(updated);
  }

  Future<void> deleteProject(BigInt id) => _repository.deleteProject(id);
}
