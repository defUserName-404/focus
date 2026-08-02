import '../../../../core/services/data_change_bus.dart';
import '../../domain/entities/project_template.dart';
import '../../domain/repositories/i_project_template_repository.dart';
import '../datasources/project_template_local_datasource.dart';
import '../mappers/project_template_extensions.dart';

class ProjectTemplateRepositoryImpl implements IProjectTemplateRepository {
  ProjectTemplateRepositoryImpl(this._local, this._bus);

  final IProjectTemplateLocalDataSource _local;
  final DataChangeBus _bus;

  @override
  Future<List<ProjectTemplate>> getAllTemplates() async {
    final rows = await _local.getAllTemplates();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<ProjectTemplate?> getTemplateById(int id) async {
    final row = await _local.getTemplateById(id);
    return row?.toDomain();
  }

  @override
  Future<ProjectTemplate?> getTemplateByUuid(String uuid) async {
    final row = await _local.getTemplateByUuid(uuid);
    return row?.toDomain();
  }

  @override
  Stream<List<ProjectTemplate>> watchAllTemplates() {
    return _local.watchAllTemplates().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<ProjectTemplate> createTemplate(ProjectTemplate template) async {
    final id = await _local.createTemplate(template.toCompanion());
    _bus.notify();
    final created = await _local.getTemplateById(id);
    return created!.toDomain();
  }

  @override
  Future<void> updateTemplate(ProjectTemplate template) async {
    await _local.updateTemplate(template.toCompanion());
    _bus.notify();
  }

  @override
  Future<void> deleteTemplate(int id) async {
    await _local.deleteTemplate(id);
    _bus.notify();
  }

  @override
  Future<void> ensureBuiltInTemplates(List<ProjectTemplate> builtIns) {
    return _local.ensureBuiltInTemplates(builtIns);
  }
}
