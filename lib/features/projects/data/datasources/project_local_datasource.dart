import 'package:isar_community/isar.dart';

// No longer need to import db_service.dart here as Isar instance is injected
// import '../../../../core/services/db_service.dart';
import '../models/project_model.dart';

abstract class IProjectLocalDataSource {
  Future<List<ProjectModel>> getAllProjectModels();

  Future<ProjectModel?> getProjectModelById(String id);

  Future<void> createProjectModel(ProjectModel project);

  Future<void> updateProjectModel(ProjectModel project);

  Future<void> deleteProjectModel(String id);

  Stream<List<ProjectModel>> watchAllProjectModels();
}

class ProjectLocalDataSourceImpl implements IProjectLocalDataSource {
  final Isar _isar; // Now final and initialized via constructor

  ProjectLocalDataSourceImpl(this._isar); // Constructor to inject Isar

  @override
  Future<List<ProjectModel>> getAllProjectModels() async {
    return await _isar.projectModels.where().findAll();
  }

  @override
  Future<ProjectModel?> getProjectModelById(String id) async {
    return await _isar.projectModels.filter().projectIdEqualTo(id).findFirst();
  }

  @override
  Future<void> createProjectModel(ProjectModel project) async {
    await _isar.writeTxn(() async {
      await _isar.projectModels.put(project);
    });
  }

  @override
  Future<void> updateProjectModel(ProjectModel project) async {
    await _isar.writeTxn(() async {
      await _isar.projectModels.put(project); // Upsert behavior
    });
  }

  @override
  Future<void> deleteProjectModel(String id) async {
    await _isar.writeTxn(() async {
      await _isar.projectModels.filter().projectIdEqualTo(id).deleteFirst();
    });
  }

  @override
  Stream<List<ProjectModel>> watchAllProjectModels() {
    return _isar.projectModels.where().watch(fireImmediately: true);
  }
}
