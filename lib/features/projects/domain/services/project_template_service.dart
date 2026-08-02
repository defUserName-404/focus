import '../../../../core/services/log_service.dart';
import '../../../../core/utils/id_utils.dart';
import '../../../../core/utils/result.dart';
import '../../../milestones/domain/services/milestone_service.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../tags/domain/services/tag_service.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/services/task_service.dart';
import '../entities/built_in_templates.dart';
import '../entities/project.dart';
import '../entities/project_template.dart';
import '../entities/project_template_payload.dart';
import '../repositories/i_project_repository.dart';
import '../repositories/i_project_template_repository.dart';
import 'project_service.dart';

final _log = LogService.instance;

/// Orchestrates saving projects as templates and applying templates to new projects.
class ProjectTemplateService {
  ProjectTemplateService(
    this._templates,
    this._projects,
    this._projectService,
    this._tasks,
    this._milestones,
    this._tags,
  );

  final IProjectTemplateRepository _templates;
  final IProjectRepository _projects;
  final ProjectService _projectService;
  final TaskService _tasks;
  final MilestoneService _milestones;
  final TagService _tags;

  Future<List<ProjectTemplate>> getAllTemplates() => _templates.getAllTemplates();

  Stream<List<ProjectTemplate>> watchAllTemplates() => _templates.watchAllTemplates();

  Future<ProjectTemplate?> getTemplateById(int id) => _templates.getTemplateById(id);

  /// Seeds built-in templates if missing (safe to call on startup).
  Future<void> ensureBuiltIns() => _templates.ensureBuiltInTemplates(BuiltInTemplates.all());

  Future<Result<ProjectTemplate>> saveProjectAsTemplate({
    required int projectId,
    required String name,
    String? description,
  }) async {
    try {
      final project = await _projects.getProjectById(projectId);
      if (project == null) {
        return const Failure(NotFoundFailure('Project not found'));
      }
      final tasks = await _tasks.getTasksByProjectId(projectId);
      final milestones = await _milestones.getMilestonesByProjectId(projectId);
      final tagsByTaskId = <int, List<Tag>>{};
      for (final task in tasks) {
        if (task.id == null) continue;
        tagsByTaskId[task.id!] = await _tags.getTagsForTask(task.id!);
      }
      final payload = ProjectTemplatePayload.capture(
        project: project,
        tasks: tasks,
        milestones: milestones,
        tagsByTaskId: tagsByTaskId,
      );
      final now = DateTime.now();
      final template = ProjectTemplate(
        uuid: generateUuid(),
        name: name.trim().isEmpty ? project.title : name.trim(),
        description: description?.trim().isEmpty == true ? null : description?.trim(),
        isBuiltin: false,
        payload: payload,
        createdAt: now,
        updatedAt: now,
      );
      final created = await _templates.createTemplate(template);
      _log.info('Saved project $projectId as template "${created.name}"', tag: 'ProjectTemplateService');
      return Success(created);
    } catch (e, st) {
      _log.error(
        'Failed to save project $projectId as template',
        tag: 'ProjectTemplateService',
        error: e,
        stackTrace: st,
      );
      return Failure(DatabaseFailure('Failed to save template', error: e, stackTrace: st));
    }
  }

  /// Creates a project from [template], materializing milestones, tags, and tasks.
  Future<Result<Project>> applyTemplate({
    required ProjectTemplate template,
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? deadline,
  }) async {
    try {
      final payload = template.payload;
      final projectResult = await _projectService.createProject(
        title: title,
        description: description ?? payload.defaultDescription,
        color: payload.color,
        startDate: startDate,
        deadline: deadline,
      );
      late final Project project;
      switch (projectResult) {
        case Success(:final value):
          project = value;
        case Failure(:final failure):
          return Failure(failure);
      }
      final projectId = project.id;
      if (projectId == null) {
        return const Failure(DatabaseFailure('Created project missing id'));
      }
      final anchor = startDate != null
          ? DateTime(startDate.year, startDate.month, startDate.day)
          : DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final milestoneIdByKey = <String, int>{};
      for (final spec in payload.milestones) {
        final result = await _milestones.createMilestone(
          projectId: projectId,
          title: spec.title,
          targetDate: spec.resolveDate(anchor),
        );
        switch (result) {
          case Success(:final value):
            if (value.id != null) milestoneIdByKey[spec.key] = value.id!;
          case Failure(:final failure):
            return Failure(failure);
        }
      }
      final tagIdByKey = <String, int>{};
      final existingTags = await _tags.getAllTags();
      final existingByName = <String, Tag>{for (final t in existingTags) t.name.toLowerCase(): t};
      for (final spec in payload.tags) {
        final existing = existingByName[spec.name.toLowerCase()];
        if (existing?.id != null) {
          tagIdByKey[spec.key] = existing!.id!;
          continue;
        }
        final result = await _tags.createTag(name: spec.name, color: spec.color);
        switch (result) {
          case Success(:final value):
            if (value.id != null) {
              tagIdByKey[spec.key] = value.id!;
              existingByName[spec.name.toLowerCase()] = value;
            }
          case Failure(:final failure):
            return Failure(failure);
        }
      }
      final sortedTasks = [...payload.tasks]
        ..sort((a, b) {
          final depthCmp = a.depth.compareTo(b.depth);
          if (depthCmp != 0) return depthCmp;
          return a.sortOrder.compareTo(b.sortOrder);
        });
      final taskIdByKey = <String, int>{};
      for (final spec in sortedTasks) {
        final parentId = spec.parentKey == null ? null : taskIdByKey[spec.parentKey];
        final milestoneId = spec.milestoneKey == null ? null : milestoneIdByKey[spec.milestoneKey];
        final start = spec.resolveStart(anchor);
        final end = spec.resolveEnd(anchor);
        final result = await _tasks.createTask(
          projectId: projectId,
          parentTaskId: parentId,
          title: spec.title,
          description: spec.description,
          priority: spec.priority,
          status: spec.status,
          startDate: start,
          endDate: end,
          estimatedMinutes: spec.estimatedMinutes,
          sortOrder: spec.sortOrder,
          milestoneId: milestoneId,
          recurrenceRule: spec.recurrenceRule,
          recurrenceAnchorDate: spec.recurrenceRule == null ? null : (start ?? anchor),
          isHabit: spec.isHabit,
          depth: spec.depth,
        );
        late final Task created;
        switch (result) {
          case Success(:final value):
            created = value;
          case Failure(:final failure):
            return Failure(failure);
        }
        if (created.id != null) {
          taskIdByKey[spec.key] = created.id!;
          final tagIds = [
            for (final key in spec.tagKeys)
              if (tagIdByKey.containsKey(key)) tagIdByKey[key]!,
          ];
          if (tagIds.isNotEmpty) {
            final tagResult = await _tags.setTaskTags(created.id!, tagIds);
            if (tagResult case Failure(:final failure)) return Failure(failure);
          }
        }
      }
      _log.info(
        'Applied template "${template.name}" → project $projectId '
        '(${payload.tasks.length} tasks, ${payload.milestones.length} milestones)',
        tag: 'ProjectTemplateService',
      );
      return Success(project);
    } catch (e, st) {
      _log.error('Failed to apply template ${template.uuid}', tag: 'ProjectTemplateService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to apply template', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> deleteTemplate(int id) async {
    try {
      final existing = await _templates.getTemplateById(id);
      if (existing == null) return const Failure(NotFoundFailure('Template not found'));
      if (existing.isBuiltin) {
        return const Failure(UnexpectedFailure('Built-in templates cannot be deleted'));
      }
      await _templates.deleteTemplate(id);
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to delete template $id', tag: 'ProjectTemplateService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to delete template', error: e, stackTrace: st));
    }
  }
}
