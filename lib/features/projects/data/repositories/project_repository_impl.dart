import 'package:isar_community/isar.dart';

import '../../../../core/services/db_service.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements IProjectRepository {
  late final Isar _isar;

  ProjectRepositoryImpl() {
    _init();
  }

  Future<void> _init() async {
    _isar = await IsarDatabase.getInstance();
  }

  @override
  Future<List<Project>> getAllProjects() async {
    final models = await _isar.projectModels.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final model = await _isar.projectModels.filter().projectIdEqualTo(id).findFirst();
    return model?.toEntity();
  }

  @override
  Future<void> createProject(Project project) async {
    final model = ProjectModel.fromEntity(project);
    await _isar.writeTxn(() async {
      await _isar.projectModels.put(model);
    });
  }

  @override
  Future<void> updateProject(Project project) async {
    await createProject(project); // Upsert behavior
  }

  @override
  Future<void> deleteProject(String id) async {
    await _isar.writeTxn(() async {
      await _isar.projectModels.filter().projectIdEqualTo(id).deleteFirst();
    });
  }

  @override
  Stream<List<Project>> watchAllProjects() {
    return _isar.projectModels
        .where()
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}
