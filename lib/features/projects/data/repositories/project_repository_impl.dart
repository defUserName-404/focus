import '../../domain/entities/project.dart';
import '../../domain/repositories/i_project_repository.dart';
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
  Future<Project?> getProjectById(BigInt id) async {
    final row = await _localDataSource.getProjectById(id);
    return row?.toDomain();
  }

  @override
  Future<void> createProject(Project project) async {
    final companion = project.toCompanion();
    await _localDataSource.createProject(companion);
  }

  @override
  Future<void> updateProject(Project project) async {
    final companion = project.toCompanion();
    await _localDataSource.updateProject(companion);
  }

  @override
  Future<void> deleteProject(BigInt id) async {
    await _localDataSource.deleteProject(id);
  }

  @override
  Stream<List<Project>> watchAllProjects() {
    return _localDataSource.watchAllProjects().map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
