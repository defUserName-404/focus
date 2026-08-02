import '../../../../core/services/data_change_bus.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_extensions.dart';
import '../../domain/entities/project_list_filter_state.dart';
import '../../domain/entities/project_status.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../datasources/project_local_datasource.dart';
import '../mappers/project_extensions.dart';

final _log = LogService.instance;

class ProjectRepositoryImpl implements IProjectRepository {
  final IProjectLocalDataSource _localDataSource;
  final DataChangeBus? _dataChangeBus;

  ProjectRepositoryImpl(this._localDataSource, [this._dataChangeBus]);

  void _emitChange() => _dataChangeBus?.notify();

  @override
  Future<List<Project>> getAllProjects() async {
    final rows = await _localDataSource.getAllProjects();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Project?> getProjectById(int id) async {
    final row = await _localDataSource.getProjectById(id);
    return row?.toDomain();
  }

  @override
  Future<Project> createProject(Project project) async {
    try {
      final companion = project.toCompanion();
      final id = await _localDataSource.createProject(companion);
      _log.debug('Project row inserted (id=$id)', tag: 'ProjectRepository');
      _emitChange();
      return project.copyWith(id: id);
    } catch (e, st) {
      _log.error('Failed to insert project', tag: 'ProjectRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateProject(Project project) async {
    try {
      final companion = project.toCompanion();
      await _localDataSource.updateProject(companion);
      _emitChange();
    } catch (e, st) {
      _log.error('Failed to update project (id=${project.id})', tag: 'ProjectRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      await _localDataSource.deleteProject(id);
      _emitChange();
    } catch (e, st) {
      _log.error('Failed to delete project (id=$id)', tag: 'ProjectRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<Project?> watchProjectById(int id) {
    return _localDataSource.watchProjectById(id).map((row) => row?.toDomain());
  }

  @override
  Stream<List<Project>> watchAllProjects() {
    return _localDataSource.watchAllProjects().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<Project>> watchFilteredProjects({
    String searchQuery = '',
    ProjectSortCriteria sortCriteria = ProjectSortCriteria.recentlyModified,
    ProjectSortOrder sortOrder = ProjectSortOrder.none,
    ProjectStatus? statusFilter,
  }) {
    return _localDataSource
        .watchFilteredProjects(
          searchQuery: searchQuery,
          sortCriteria: sortCriteria,
          sortOrder: sortOrder,
          statusFilter: statusFilter,
        )
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
