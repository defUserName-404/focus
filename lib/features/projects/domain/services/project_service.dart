import '../../../../core/services/log_service.dart';
import '../../../../core/utils/id_utils.dart';
import '../../../../core/utils/result.dart';
import '../entities/project.dart';
import '../entities/project_extensions.dart';
import '../entities/project_list_filter_state.dart';
import '../entities/project_status.dart';
import '../repositories/i_project_repository.dart';

final _log = LogService.instance;

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

  Stream<Project?> watchProjectById(int id) => _repository.watchProjectById(id);

  Stream<List<Project>> watchFilteredProjects({
    String searchQuery = '',
    ProjectSortCriteria sortCriteria = ProjectSortCriteria.recentlyModified,
    ProjectSortOrder sortOrder = ProjectSortOrder.none,
    ProjectStatus? statusFilter,
  }) {
    return _repository.watchFilteredProjects(
      searchQuery: searchQuery,
      sortCriteria: sortCriteria,
      sortOrder: sortOrder,
      statusFilter: statusFilter,
    );
  }

  //  Write

  Future<Result<Project>> createProject({
    required String title,
    String? description,
    ProjectStatus status = ProjectStatus.active,
    int? color,
    DateTime? startDate,
    DateTime? deadline,
  }) async {
    try {
      final now = DateTime.now();
      final project = Project(
        uuid: generateUuid(),
        title: title,
        description: description,
        status: status,
        color: color,
        startDate: startDate,
        deadline: deadline,
        createdAt: now,
        updatedAt: now,
      );
      final created = await _repository.createProject(project);
      _log.info('Project created: "$title" (id=${created.id})', tag: 'ProjectService');
      return Success(created);
    } catch (e, st) {
      _log.error('Failed to create project "$title"', tag: 'ProjectService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to create project', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> updateProject(Project project) async {
    try {
      final updated = project.copyWith(updatedAt: DateTime.now());
      await _repository.updateProject(updated);
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to update project ${project.id}', tag: 'ProjectService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to update project', error: e, stackTrace: st));
    }
  }

  /// Soft-deletes the project and transactionally cascades to its tasks and
  /// focus sessions (hard FK cascade no longer applies with soft deletes).
  Future<Result<void>> deleteProject(int id) async {
    try {
      await _repository.deleteProject(id);
      _log.info('Project $id soft-deleted (cascaded to tasks/sessions)', tag: 'ProjectService');
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to delete project $id', tag: 'ProjectService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to delete project', error: e, stackTrace: st));
    }
  }
}
