import '../../domain/entities/project.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../datasources/project_local_datasource.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements IProjectRepository {
  final IProjectLocalDataSource _localDataSource;

  ProjectRepositoryImpl(this._localDataSource);

  @override
  Future<List<Project>> getAllProjects() async {
    final models = await _localDataSource.getAllProjectModels();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final model = await _localDataSource.getProjectModelById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createProject(Project project) async {
    final model = ProjectModel.fromEntity(project);
    await _localDataSource.createProjectModel(model);
  }

  @override
  Future<void> updateProject(Project project) async {
    final model = ProjectModel.fromEntity(project);
    await _localDataSource.updateProjectModel(model);
  }

  @override
  Future<void> deleteProject(String id) async {
    await _localDataSource.deleteProjectModel(id);
  }

  @override
  Stream<List<Project>> watchAllProjects() {
    return _localDataSource.watchAllProjectModels().map((models) => models.map((m) => m.toEntity()).toList());
  }
}
