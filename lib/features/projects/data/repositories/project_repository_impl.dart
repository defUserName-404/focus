import '../../domain/entities/project.dart';
import '../../domain/entities/project_extensions.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../../domain/entities/project_list_filter_state.dart';
import '../datasources/project_local_datasource.dart';
import '../mappers/project_extensions.dart';

class ProjectRepositoryImpl implements IProjectRepository {
  final IProjectLocalDataSource _localDataSource;

  ProjectRepositoryImpl(this._localDataSource);

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
    final companion = project.toCompanion();
    final id = await _localDataSource.createProject(companion);
    return project.copyWith(id: id);
  }

  @override
  Future<void> updateProject(Project project) async {
    final companion = project.toCompanion();
    await _localDataSource.updateProject(companion);
  }

  @override
  Future<void> deleteProject(int id) async {
    await _localDataSource.deleteProject(id);
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
  }) {
    return _localDataSource
        .watchFilteredProjects(searchQuery: searchQuery, sortCriteria: sortCriteria, sortOrder: sortOrder)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
