import '../entities/project_template.dart';

abstract class IProjectTemplateRepository {
  Future<List<ProjectTemplate>> getAllTemplates();

  Future<ProjectTemplate?> getTemplateById(int id);

  Future<ProjectTemplate?> getTemplateByUuid(String uuid);

  Stream<List<ProjectTemplate>> watchAllTemplates();

  Future<ProjectTemplate> createTemplate(ProjectTemplate template);

  Future<void> updateTemplate(ProjectTemplate template);

  Future<void> deleteTemplate(int id);

  /// Inserts built-in templates that are missing by UUID (idempotent).
  Future<void> ensureBuiltInTemplates(List<ProjectTemplate> builtIns);
}
