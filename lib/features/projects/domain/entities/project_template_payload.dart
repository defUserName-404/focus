import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../milestones/domain/entities/milestone.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../tasks/domain/entities/recurrence_rule.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/domain/entities/task_status.dart';
import 'project.dart';

/// JSON schema version for [ProjectTemplatePayload].
const int kProjectTemplatePayloadVersion = 1;

/// Serializable blueprint of a project's structure (tasks, milestones, tags,
/// recurrence) with relative date offsets so it can be reapplied later.
@immutable
class ProjectTemplatePayload extends Equatable {
  final int version;
  final String? defaultTitle;
  final String? defaultDescription;
  final int? color;
  final List<TemplateMilestoneSpec> milestones;
  final List<TemplateTagSpec> tags;
  final List<TemplateTaskSpec> tasks;

  const ProjectTemplatePayload({
    this.version = kProjectTemplatePayloadVersion,
    this.defaultTitle,
    this.defaultDescription,
    this.color,
    this.milestones = const [],
    this.tags = const [],
    this.tasks = const [],
  });

  factory ProjectTemplatePayload.fromJson(Map<String, dynamic> json) {
    return ProjectTemplatePayload(
      version: (json['version'] as int?) ?? kProjectTemplatePayloadVersion,
      defaultTitle: json['defaultTitle'] as String?,
      defaultDescription: json['defaultDescription'] as String?,
      color: json['color'] as int?,
      milestones: (json['milestones'] as List<dynamic>? ?? const [])
          .map((e) => TemplateMilestoneSpec.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => TemplateTagSpec.fromJson(e as Map<String, dynamic>))
          .toList(),
      tasks: (json['tasks'] as List<dynamic>? ?? const [])
          .map((e) => TemplateTaskSpec.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory ProjectTemplatePayload.fromJsonString(String raw) {
    return ProjectTemplatePayload.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'defaultTitle': defaultTitle,
    'defaultDescription': defaultDescription,
    'color': color,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'tags': tags.map((t) => t.toJson()).toList(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };

  String toJsonString() => jsonEncode(toJson());

  /// Captures a live project into a reusable template payload.
  ///
  /// Dates become offsets from [anchor] (project start, else earliest dated
  /// task/milestone, else [fallbackNow]).
  static ProjectTemplatePayload capture({
    required Project project,
    required List<Task> tasks,
    required List<Milestone> milestones,
    required Map<int, List<Tag>> tagsByTaskId,
    DateTime? fallbackNow,
  }) {
    final now = fallbackNow ?? DateTime.now();
    final liveTasks = tasks.where((t) => t.deletedAt == null).toList();
    final liveMilestones = milestones.where((m) => m.deletedAt == null).toList();
    final anchor = _resolveAnchor(
      projectStart: project.startDate,
      tasks: liveTasks,
      milestones: liveMilestones,
      fallback: now,
    );
    final milestoneKeyById = <int, String>{
      for (var i = 0; i < liveMilestones.length; i++)
        if (liveMilestones[i].id != null) liveMilestones[i].id!: 'm$i',
    };
    final taskKeyById = <int, String>{
      for (var i = 0; i < liveTasks.length; i++)
        if (liveTasks[i].id != null) liveTasks[i].id!: 't$i',
    };
    final tagByUuid = <String, Tag>{};
    for (final list in tagsByTaskId.values) {
      for (final tag in list) {
        if (tag.deletedAt == null) tagByUuid[tag.uuid] = tag;
      }
    }
    final tags = tagByUuid.values.toList();
    final tagKeyByUuid = <String, String>{for (var i = 0; i < tags.length; i++) tags[i].uuid: 'g$i'};
    return ProjectTemplatePayload(
      defaultTitle: project.title,
      defaultDescription: project.description,
      color: project.color,
      milestones: [
        for (final m in liveMilestones)
          if (m.id != null)
            TemplateMilestoneSpec(
              key: milestoneKeyById[m.id]!,
              title: m.title,
              targetOffsetDays: m.targetDate == null ? null : _offsetDays(anchor, m.targetDate!),
            ),
      ],
      tags: [for (final tag in tags) TemplateTagSpec(key: tagKeyByUuid[tag.uuid]!, name: tag.name, color: tag.color)],
      tasks: [
        for (final task in liveTasks)
          if (task.id != null)
            TemplateTaskSpec(
              key: taskKeyById[task.id]!,
              title: task.title,
              description: task.description,
              priorityIndex: task.priority.index,
              statusIndex: TaskStatus.todo.index,
              estimatedMinutes: task.estimatedMinutes,
              sortOrder: task.sortOrder,
              depth: task.depth,
              parentKey: task.parentTaskId == null ? null : taskKeyById[task.parentTaskId],
              milestoneKey: task.milestoneId == null ? null : milestoneKeyById[task.milestoneId],
              tagKeys: [
                for (final tag in tagsByTaskId[task.id] ?? const <Tag>[])
                  if (tag.deletedAt == null) tagKeyByUuid[tag.uuid]!,
              ],
              startOffsetDays: task.startDate == null ? null : _offsetDays(anchor, task.startDate!),
              endOffsetDays: task.endDate == null ? null : _offsetDays(anchor, task.endDate!),
              recurrenceRuleJson: task.recurrenceRule?.toMap(),
              isHabit: task.isHabit,
            ),
      ],
    );
  }

  static DateTime _resolveAnchor({
    required DateTime? projectStart,
    required List<Task> tasks,
    required List<Milestone> milestones,
    required DateTime fallback,
  }) {
    if (projectStart != null) return DateTime(projectStart.year, projectStart.month, projectStart.day);
    final dates = <DateTime>[
      for (final t in tasks) ...[if (t.startDate != null) t.startDate!, if (t.endDate != null) t.endDate!],
      for (final m in milestones)
        if (m.targetDate != null) m.targetDate!,
    ];
    if (dates.isEmpty) return DateTime(fallback.year, fallback.month, fallback.day);
    dates.sort();
    final first = dates.first;
    return DateTime(first.year, first.month, first.day);
  }

  static int _offsetDays(DateTime anchor, DateTime date) {
    final a = DateTime(anchor.year, anchor.month, anchor.day);
    final d = DateTime(date.year, date.month, date.day);
    return d.difference(a).inDays;
  }

  @override
  List<Object?> get props => [version, defaultTitle, defaultDescription, color, milestones, tags, tasks];
}

@immutable
class TemplateMilestoneSpec extends Equatable {
  final String key;
  final String title;
  final int? targetOffsetDays;

  const TemplateMilestoneSpec({required this.key, required this.title, this.targetOffsetDays});

  factory TemplateMilestoneSpec.fromJson(Map<String, dynamic> json) => TemplateMilestoneSpec(
    key: json['key'] as String,
    title: json['title'] as String,
    targetOffsetDays: json['targetOffsetDays'] as int?,
  );

  Map<String, dynamic> toJson() => {'key': key, 'title': title, 'targetOffsetDays': targetOffsetDays};

  DateTime? resolveDate(DateTime anchor) {
    if (targetOffsetDays == null) return null;
    return DateTime(anchor.year, anchor.month, anchor.day).add(Duration(days: targetOffsetDays!));
  }

  @override
  List<Object?> get props => [key, title, targetOffsetDays];
}

@immutable
class TemplateTagSpec extends Equatable {
  final String key;
  final String name;
  final int? color;

  const TemplateTagSpec({required this.key, required this.name, this.color});

  factory TemplateTagSpec.fromJson(Map<String, dynamic> json) =>
      TemplateTagSpec(key: json['key'] as String, name: json['name'] as String, color: json['color'] as int?);

  Map<String, dynamic> toJson() => {'key': key, 'name': name, 'color': color};

  @override
  List<Object?> get props => [key, name, color];
}

@immutable
class TemplateTaskSpec extends Equatable {
  final String key;
  final String title;
  final String? description;
  final int priorityIndex;
  final int statusIndex;
  final int? estimatedMinutes;
  final double sortOrder;
  final int depth;
  final String? parentKey;
  final String? milestoneKey;
  final List<String> tagKeys;
  final int? startOffsetDays;
  final int? endOffsetDays;
  final Map<String, dynamic>? recurrenceRuleJson;
  final bool isHabit;

  const TemplateTaskSpec({
    required this.key,
    required this.title,
    this.description,
    this.priorityIndex = 2,
    this.statusIndex = 0,
    this.estimatedMinutes,
    this.sortOrder = 0,
    this.depth = 0,
    this.parentKey,
    this.milestoneKey,
    this.tagKeys = const [],
    this.startOffsetDays,
    this.endOffsetDays,
    this.recurrenceRuleJson,
    this.isHabit = false,
  });

  factory TemplateTaskSpec.fromJson(Map<String, dynamic> json) => TemplateTaskSpec(
    key: json['key'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    priorityIndex: (json['priorityIndex'] as int?) ?? TaskPriority.medium.index,
    statusIndex: (json['statusIndex'] as int?) ?? TaskStatus.todo.index,
    estimatedMinutes: json['estimatedMinutes'] as int?,
    sortOrder: (json['sortOrder'] as num?)?.toDouble() ?? 0,
    depth: (json['depth'] as int?) ?? 0,
    parentKey: json['parentKey'] as String?,
    milestoneKey: json['milestoneKey'] as String?,
    tagKeys: (json['tagKeys'] as List<dynamic>? ?? const []).cast<String>(),
    startOffsetDays: json['startOffsetDays'] as int?,
    endOffsetDays: json['endOffsetDays'] as int?,
    recurrenceRuleJson: json['recurrenceRule'] as Map<String, dynamic>?,
    isHabit: (json['isHabit'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'title': title,
    'description': description,
    'priorityIndex': priorityIndex,
    'statusIndex': statusIndex,
    'estimatedMinutes': estimatedMinutes,
    'sortOrder': sortOrder,
    'depth': depth,
    'parentKey': parentKey,
    'milestoneKey': milestoneKey,
    'tagKeys': tagKeys,
    'startOffsetDays': startOffsetDays,
    'endOffsetDays': endOffsetDays,
    'recurrenceRule': recurrenceRuleJson,
    'isHabit': isHabit,
  };

  TaskPriority get priority {
    final values = TaskPriority.values;
    if (priorityIndex < 0 || priorityIndex >= values.length) return TaskPriority.medium;
    return values[priorityIndex];
  }

  TaskStatus get status {
    final values = TaskStatus.values;
    if (statusIndex < 0 || statusIndex >= values.length) return TaskStatus.todo;
    return values[statusIndex];
  }

  RecurrenceRule? get recurrenceRule => RecurrenceRule.tryParse(recurrenceRuleJson);

  DateTime? resolveStart(DateTime anchor) => _offsetToDate(anchor, startOffsetDays);

  DateTime? resolveEnd(DateTime anchor) => _offsetToDate(anchor, endOffsetDays);

  static DateTime? _offsetToDate(DateTime anchor, int? offsetDays) {
    if (offsetDays == null) return null;
    return DateTime(anchor.year, anchor.month, anchor.day).add(Duration(days: offsetDays));
  }

  @override
  List<Object?> get props => [
    key,
    title,
    description,
    priorityIndex,
    statusIndex,
    estimatedMinutes,
    sortOrder,
    depth,
    parentKey,
    milestoneKey,
    tagKeys,
    startOffsetDays,
    endOffsetDays,
    recurrenceRuleJson,
    isHabit,
  ];
}
