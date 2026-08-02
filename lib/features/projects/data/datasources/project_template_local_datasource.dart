import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';
import '../mappers/project_template_extensions.dart';
import '../../domain/entities/project_template.dart';

final _log = LogService.instance;

abstract class IProjectTemplateLocalDataSource {
  Future<List<ProjectTemplateTableData>> getAllTemplates();

  Future<ProjectTemplateTableData?> getTemplateById(int id);

  Future<ProjectTemplateTableData?> getTemplateByUuid(String uuid);

  Stream<List<ProjectTemplateTableData>> watchAllTemplates();

  Future<int> createTemplate(ProjectTemplateTableCompanion companion);

  Future<void> updateTemplate(ProjectTemplateTableCompanion companion);

  Future<void> deleteTemplate(int id);

  Future<void> ensureBuiltInTemplates(List<ProjectTemplate> builtIns);
}

class ProjectTemplateLocalDataSourceImpl implements IProjectTemplateLocalDataSource {
  ProjectTemplateLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<ProjectTemplateTableData>> getAllTemplates() {
    return (_db.select(_db.projectTemplateTable)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  @override
  Future<ProjectTemplateTableData?> getTemplateById(int id) {
    return (_db.select(_db.projectTemplateTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<ProjectTemplateTableData?> getTemplateByUuid(String uuid) {
    return (_db.select(_db.projectTemplateTable)..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  }

  @override
  Stream<List<ProjectTemplateTableData>> watchAllTemplates() {
    return (_db.select(_db.projectTemplateTable)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  @override
  Future<int> createTemplate(ProjectTemplateTableCompanion companion) async {
    try {
      return await _db.into(_db.projectTemplateTable).insert(companion);
    } catch (e, st) {
      _log.error('createTemplate failed', tag: 'ProjectTemplateLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateTemplate(ProjectTemplateTableCompanion companion) async {
    try {
      await (_db.update(_db.projectTemplateTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
    } catch (e, st) {
      _log.error('updateTemplate failed', tag: 'ProjectTemplateLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteTemplate(int id) async {
    try {
      await (_db.delete(_db.projectTemplateTable)..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      _log.error('deleteTemplate failed', tag: 'ProjectTemplateLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> ensureBuiltInTemplates(List<ProjectTemplate> builtIns) async {
    for (final template in builtIns) {
      final existing = await getTemplateByUuid(template.uuid);
      if (existing != null) continue;
      await createTemplate(template.toCompanion());
    }
  }
}
