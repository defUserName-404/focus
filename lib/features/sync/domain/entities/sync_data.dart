import 'dart:convert';

import '../../../../core/utils/id_utils.dart';
import '../../../tasks/domain/entities/recurrence_rule.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/domain/entities/task_reminder_mode.dart';
import '../../../tasks/domain/entities/task_status.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/entities/project_status.dart';

/// Serializable data envelope for cloud sync.
///
/// Contains all projects and tasks along with metadata needed for
/// conflict detection and merge operations.
class SyncData {
  final DateTime syncTimestamp;
  final List<SyncProjectData> projects;
  final List<SyncTaskData> tasks;

  const SyncData({required this.syncTimestamp, required this.projects, required this.tasks});

  factory SyncData.fromJson(Map<String, dynamic> json) {
    return SyncData(
      syncTimestamp: DateTime.parse(json['syncTimestamp'] as String),
      projects: (json['projects'] as List<dynamic>)
          .map((e) => SyncProjectData.fromJson(e as Map<String, dynamic>))
          .toList(),
      tasks: (json['tasks'] as List<dynamic>).map((e) => SyncTaskData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'syncTimestamp': syncTimestamp.toIso8601String(),
    'projects': projects.map((p) => p.toJson()).toList(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory SyncData.fromJsonString(String jsonString) {
    return SyncData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  static SyncData empty() => SyncData(syncTimestamp: DateTime.now(), projects: const [], tasks: const []);
}

/// Serializable project data for sync.
class SyncProjectData {
  final int id;
  final String uuid;
  final String title;
  final String? description;
  final int statusIndex;
  final int? color;
  final DateTime? startDate;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SyncProjectData({
    required this.id,
    required this.uuid,
    required this.title,
    this.description,
    this.statusIndex = 0,
    this.color,
    this.startDate,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SyncProjectData.fromJson(Map<String, dynamic> json) {
    return SyncProjectData(
      id: json['id'] as int,
      uuid: (json['uuid'] as String?) ?? generateUuid(),
      title: json['title'] as String,
      description: json['description'] as String?,
      statusIndex: (json['statusIndex'] as int?) ?? ProjectStatus.active.index,
      color: json['color'] as int?,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'title': title,
    'description': description,
    'statusIndex': statusIndex,
    'color': color,
    'startDate': startDate?.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory SyncProjectData.fromProject(Project project) {
    return SyncProjectData(
      id: project.id!,
      uuid: project.uuid,
      title: project.title,
      description: project.description,
      statusIndex: project.status.index,
      color: project.color,
      startDate: project.startDate,
      deadline: project.deadline,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      deletedAt: project.deletedAt,
    );
  }

  Project toProject() => Project(
    id: id,
    uuid: uuid,
    title: title,
    description: description,
    status: statusIndex >= 0 && statusIndex < ProjectStatus.values.length
        ? ProjectStatus.values[statusIndex]
        : ProjectStatus.active,
    color: color,
    startDate: startDate,
    deadline: deadline,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

/// Serializable task data for sync.
class SyncTaskData {
  final int id;
  final String uuid;
  final int projectId;
  final int? parentTaskId;
  final String title;
  final String? description;
  final int priorityIndex;
  final int statusIndex;
  final int reminderModeIndex;
  final int? customReminderMinutesBefore;
  final DateTime? startDate;
  final DateTime? endDate;
  final int depth;
  final int? estimatedMinutes;
  final double sortOrder;
  final int? milestoneId;
  final String? recurrenceRuleJson;
  final DateTime? recurrenceAnchorDate;
  final bool isHabit;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SyncTaskData({
    required this.id,
    required this.uuid,
    required this.projectId,
    this.parentTaskId,
    required this.title,
    this.description,
    required this.priorityIndex,
    this.statusIndex = 0,
    this.reminderModeIndex = 0,
    this.customReminderMinutesBefore,
    this.startDate,
    this.endDate,
    required this.depth,
    this.estimatedMinutes,
    this.sortOrder = 0,
    this.milestoneId,
    this.recurrenceRuleJson,
    this.recurrenceAnchorDate,
    this.isHabit = false,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SyncTaskData.fromJson(Map<String, dynamic> json) {
    final statusIndex = json['statusIndex'] as int?;
    final isCompleted = json['isCompleted'] as bool? ?? false;
    return SyncTaskData(
      id: json['id'] as int,
      uuid: (json['uuid'] as String?) ?? generateUuid(),
      projectId: json['projectId'] as int,
      parentTaskId: json['parentTaskId'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      priorityIndex: json['priorityIndex'] as int,
      statusIndex: statusIndex ?? (isCompleted ? TaskStatus.done.index : TaskStatus.todo.index),
      reminderModeIndex: (json['reminderModeIndex'] as int?) ?? TaskReminderMode.smart.index,
      customReminderMinutesBefore: json['customReminderMinutesBefore'] as int?,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      depth: json['depth'] as int,
      estimatedMinutes: json['estimatedMinutes'] as int?,
      sortOrder: (json['sortOrder'] as num?)?.toDouble() ?? 0,
      milestoneId: json['milestoneId'] as int?,
      recurrenceRuleJson: json['recurrenceRuleJson'] as String?,
      recurrenceAnchorDate: json['recurrenceAnchorDate'] != null
          ? DateTime.parse(json['recurrenceAnchorDate'] as String)
          : null,
      isHabit: json['isHabit'] as bool? ?? false,
      isCompleted: isCompleted,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'projectId': projectId,
    'parentTaskId': parentTaskId,
    'title': title,
    'description': description,
    'priorityIndex': priorityIndex,
    'statusIndex': statusIndex,
    'reminderModeIndex': reminderModeIndex,
    'customReminderMinutesBefore': customReminderMinutesBefore,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'depth': depth,
    'estimatedMinutes': estimatedMinutes,
    'sortOrder': sortOrder,
    'milestoneId': milestoneId,
    'recurrenceRuleJson': recurrenceRuleJson,
    'recurrenceAnchorDate': recurrenceAnchorDate?.toIso8601String(),
    'isHabit': isHabit,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory SyncTaskData.fromTask(Task task) {
    return SyncTaskData(
      id: task.id!,
      uuid: task.uuid,
      projectId: task.projectId,
      parentTaskId: task.parentTaskId,
      title: task.title,
      description: task.description,
      priorityIndex: task.priority.index,
      statusIndex: task.status.index,
      reminderModeIndex: task.reminderMode.index,
      customReminderMinutesBefore: task.customReminderMinutesBefore,
      startDate: task.startDate,
      endDate: task.endDate,
      depth: task.depth,
      estimatedMinutes: task.estimatedMinutes,
      sortOrder: task.sortOrder,
      milestoneId: task.milestoneId,
      recurrenceRuleJson: task.recurrenceRule?.toJson(),
      recurrenceAnchorDate: task.recurrenceAnchorDate,
      isHabit: task.isHabit,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      deletedAt: task.deletedAt,
    );
  }

  Task toTask() {
    final resolvedStatus = statusIndex >= 0 && statusIndex < TaskStatus.values.length
        ? TaskStatus.values[statusIndex]
        : (isCompleted ? TaskStatus.done : TaskStatus.todo);
    return Task(
      id: id,
      uuid: uuid,
      projectId: projectId,
      parentTaskId: parentTaskId,
      title: title,
      description: description,
      priority: TaskPriority.values[priorityIndex],
      status: resolvedStatus,
      reminderMode: reminderModeIndex >= 0 && reminderModeIndex < TaskReminderMode.values.length
          ? TaskReminderMode.values[reminderModeIndex]
          : TaskReminderMode.smart,
      customReminderMinutesBefore: customReminderMinutesBefore,
      startDate: startDate,
      endDate: endDate,
      depth: depth,
      estimatedMinutes: estimatedMinutes,
      sortOrder: sortOrder,
      milestoneId: milestoneId,
      recurrenceRule: RecurrenceRule.tryParseJson(recurrenceRuleJson),
      recurrenceAnchorDate: recurrenceAnchorDate,
      isHabit: isHabit,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}
