import '../../../../core/utils/id_utils.dart';
import 'project_template.dart';
import 'project_template_payload.dart';

/// Stable seed UUIDs for built-in templates (idempotent migration inserts).
abstract final class BuiltInTemplateIds {
  static const productLaunch = 'tpl-builtin-product-launch-0001';
  static const contentSprint = 'tpl-builtin-content-sprint-0002';
  static const studyPlan = 'tpl-builtin-study-plan-0003';
}

/// Factory for the shipped built-in project templates.
abstract final class BuiltInTemplates {
  static List<ProjectTemplate> all({DateTime? now}) {
    final stamp = now ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return [_productLaunch(stamp), _contentSprint(stamp), _studyPlan(stamp)];
  }

  static ProjectTemplate _productLaunch(DateTime stamp) {
    return ProjectTemplate(
      uuid: BuiltInTemplateIds.productLaunch,
      name: 'Product Launch',
      description: 'Milestones and tasks for shipping a product release.',
      isBuiltin: true,
      payload: const ProjectTemplatePayload(
        defaultTitle: 'Product Launch',
        defaultDescription: 'Plan, build, and ship a release.',
        milestones: [
          TemplateMilestoneSpec(key: 'm0', title: 'Kickoff', targetOffsetDays: 0),
          TemplateMilestoneSpec(key: 'm1', title: 'Beta', targetOffsetDays: 21),
          TemplateMilestoneSpec(key: 'm2', title: 'Launch', targetOffsetDays: 35),
        ],
        tags: [
          TemplateTagSpec(key: 'g0', name: 'launch'),
          TemplateTagSpec(key: 'g1', name: 'marketing'),
        ],
        tasks: [
          TemplateTaskSpec(
            key: 't0',
            title: 'Define goals & success metrics',
            priorityIndex: 1,
            estimatedMinutes: 90,
            sortOrder: 0,
            endOffsetDays: 3,
            tagKeys: ['g0'],
            milestoneKey: 'm0',
          ),
          TemplateTaskSpec(
            key: 't1',
            title: 'Build MVP features',
            priorityIndex: 0,
            estimatedMinutes: 480,
            sortOrder: 1000,
            startOffsetDays: 3,
            endOffsetDays: 21,
            tagKeys: ['g0'],
            milestoneKey: 'm1',
          ),
          TemplateTaskSpec(
            key: 't2',
            title: 'Draft launch announcement',
            priorityIndex: 2,
            estimatedMinutes: 120,
            sortOrder: 2000,
            startOffsetDays: 14,
            endOffsetDays: 28,
            tagKeys: ['g1'],
            milestoneKey: 'm2',
          ),
          TemplateTaskSpec(
            key: 't3',
            title: 'QA & polish pass',
            priorityIndex: 1,
            estimatedMinutes: 240,
            sortOrder: 3000,
            startOffsetDays: 21,
            endOffsetDays: 32,
            tagKeys: ['g0'],
            milestoneKey: 'm2',
          ),
        ],
      ),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static ProjectTemplate _contentSprint(DateTime stamp) {
    return ProjectTemplate(
      uuid: BuiltInTemplateIds.contentSprint,
      name: 'Content Sprint',
      description: 'Two-week content production board with a weekly habit.',
      isBuiltin: true,
      payload: ProjectTemplatePayload(
        defaultTitle: 'Content Sprint',
        defaultDescription: 'Plan, produce, and publish content in two weeks.',
        milestones: const [
          TemplateMilestoneSpec(key: 'm0', title: 'Outline complete', targetOffsetDays: 3),
          TemplateMilestoneSpec(key: 'm1', title: 'Publish', targetOffsetDays: 14),
        ],
        tags: const [
          TemplateTagSpec(key: 'g0', name: 'content'),
          TemplateTagSpec(key: 'g1', name: 'writing'),
        ],
        tasks: [
          const TemplateTaskSpec(
            key: 't0',
            title: 'Topic research',
            priorityIndex: 1,
            estimatedMinutes: 120,
            sortOrder: 0,
            endOffsetDays: 2,
            tagKeys: ['g0'],
            milestoneKey: 'm0',
          ),
          const TemplateTaskSpec(
            key: 't1',
            title: 'Write first draft',
            priorityIndex: 1,
            estimatedMinutes: 180,
            sortOrder: 1000,
            startOffsetDays: 2,
            endOffsetDays: 7,
            tagKeys: ['g1'],
          ),
          const TemplateTaskSpec(
            key: 't2',
            title: 'Edit & design assets',
            priorityIndex: 2,
            estimatedMinutes: 150,
            sortOrder: 2000,
            startOffsetDays: 7,
            endOffsetDays: 12,
            tagKeys: ['g0'],
            milestoneKey: 'm1',
          ),
          TemplateTaskSpec(
            key: 't3',
            title: 'Daily writing habit',
            priorityIndex: 2,
            estimatedMinutes: 30,
            sortOrder: 3000,
            startOffsetDays: 0,
            endOffsetDays: 14,
            tagKeys: const ['g1'],
            isHabit: true,
            recurrenceRuleJson: const {'frequency': 'daily', 'interval': 1},
          ),
        ],
      ),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  static ProjectTemplate _studyPlan(DateTime stamp) {
    return ProjectTemplate(
      uuid: BuiltInTemplateIds.studyPlan,
      name: 'Study Plan',
      description: 'Exam prep with weekly review habits and milestones.',
      isBuiltin: true,
      payload: ProjectTemplatePayload(
        defaultTitle: 'Study Plan',
        defaultDescription: 'Structured study toward an exam or certification.',
        milestones: const [
          TemplateMilestoneSpec(key: 'm0', title: 'Syllabus mapped', targetOffsetDays: 7),
          TemplateMilestoneSpec(key: 'm1', title: 'Practice exam', targetOffsetDays: 28),
          TemplateMilestoneSpec(key: 'm2', title: 'Exam day', targetOffsetDays: 42),
        ],
        tags: const [
          TemplateTagSpec(key: 'g0', name: 'study'),
          TemplateTagSpec(key: 'g1', name: 'exam'),
        ],
        tasks: [
          const TemplateTaskSpec(
            key: 't0',
            title: 'Map syllabus & resources',
            priorityIndex: 1,
            estimatedMinutes: 90,
            sortOrder: 0,
            endOffsetDays: 5,
            tagKeys: ['g0'],
            milestoneKey: 'm0',
          ),
          TemplateTaskSpec(
            key: 't1',
            title: 'Weekly review session',
            priorityIndex: 1,
            estimatedMinutes: 60,
            sortOrder: 1000,
            startOffsetDays: 0,
            endOffsetDays: 42,
            tagKeys: const ['g0'],
            isHabit: true,
            recurrenceRuleJson: {
              'frequency': 'weekly',
              'interval': 1,
              'byWeekday': [6],
            },
          ),
          const TemplateTaskSpec(
            key: 't2',
            title: 'Complete practice exam',
            priorityIndex: 0,
            estimatedMinutes: 180,
            sortOrder: 2000,
            startOffsetDays: 21,
            endOffsetDays: 28,
            tagKeys: ['g1'],
            milestoneKey: 'm1',
          ),
          const TemplateTaskSpec(
            key: 't3',
            title: 'Final review & rest',
            priorityIndex: 2,
            estimatedMinutes: 120,
            sortOrder: 3000,
            startOffsetDays: 35,
            endOffsetDays: 41,
            tagKeys: ['g1'],
            milestoneKey: 'm2',
          ),
        ],
      ),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  /// Ensures built-in UUIDs are valid for storage (no generateUuid needed).
  static String ensureUuid(String id) => id.isEmpty ? generateUuid() : id;
}
