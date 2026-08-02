import 'dart:convert';

import '../../../../core/utils/id_utils.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../tasks/domain/entities/recurrence_rule.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/domain/entities/task_reminder_mode.dart';
import '../../../tasks/domain/entities/task_status.dart';
import '../../../projects/domain/entities/project_status.dart';
import '../../../session/domain/entities/session_state.dart';

/// Current SyncData envelope schema. Bump when the payload shape changes.
///
/// Devices must refuse to merge payloads whose [schemaVersion] is *newer*
/// than this constant (older / equal versions are accepted).
const int kSyncSchemaVersion = 2;

/// Whitelisted settings keys included in cloud sync and local backup.
const Set<String> kSyncableSettingsKeys = SettingsKeys.syncableKeys;

/// Serializable data envelope for cloud sync and local backup/restore.
class SyncData {
  final int schemaVersion;
  final DateTime syncTimestamp;
  final List<SyncProjectData> projects;
  final List<SyncMilestoneData> milestones;
  final List<SyncTagData> tags;
  final List<SyncTaskData> tasks;
  final List<SyncTaskTagData> taskTags;
  final List<SyncTaskCompletionData> completions;
  final List<SyncFocusSessionData> sessions;
  final List<SyncSettingData> settings;

  const SyncData({
    this.schemaVersion = kSyncSchemaVersion,
    required this.syncTimestamp,
    this.projects = const [],
    this.milestones = const [],
    this.tags = const [],
    this.tasks = const [],
    this.taskTags = const [],
    this.completions = const [],
    this.sessions = const [],
    this.settings = const [],
  });

  factory SyncData.fromJson(Map<String, dynamic> json) {
    final schemaVersion = (json['schemaVersion'] as int?) ?? 1;
    final projects = (json['projects'] as List<dynamic>? ?? const [])
        .map((e) => SyncProjectData.fromJson(e as Map<String, dynamic>))
        .toList();

    // Legacy v1 payloads referenced peers by local int ids. Resolve to UUIDs
    // when possible so merge can key by UUID.
    final projectIdToUuid = <int, String>{
      for (final p in projects)
        if (p.legacyId != null) p.legacyId!: p.uuid,
    };

    final milestones = (json['milestones'] as List<dynamic>? ?? const [])
        .map((e) => SyncMilestoneData.fromJson(e as Map<String, dynamic>, projectIdToUuid: projectIdToUuid))
        .toList();
    final milestoneIdToUuid = <int, String>{
      for (final m in milestones)
        if (m.legacyId != null) m.legacyId!: m.uuid,
    };

    final tags = (json['tags'] as List<dynamic>? ?? const [])
        .map((e) => SyncTagData.fromJson(e as Map<String, dynamic>))
        .toList();
    final tagIdToUuid = <int, String>{
      for (final t in tags)
        if (t.legacyId != null) t.legacyId!: t.uuid,
    };

    final tasks = (json['tasks'] as List<dynamic>? ?? const [])
        .map(
          (e) => SyncTaskData.fromJson(
            e as Map<String, dynamic>,
            projectIdToUuid: projectIdToUuid,
            milestoneIdToUuid: milestoneIdToUuid,
          ),
        )
        .toList();
    final taskIdToUuid = <int, String>{
      for (final t in tasks)
        if (t.legacyId != null) t.legacyId!: t.uuid,
    };

    // Second pass: resolve parentTaskUuid from legacy parentTaskId.
    final resolvedTasks = [
      for (final t in tasks)
        t.parentTaskUuid == null && t.legacyParentTaskId != null && taskIdToUuid.containsKey(t.legacyParentTaskId)
            ? t.copyWith(parentTaskUuid: taskIdToUuid[t.legacyParentTaskId])
            : t,
    ];

    return SyncData(
      schemaVersion: schemaVersion,
      syncTimestamp: DateTime.parse(json['syncTimestamp'] as String),
      projects: projects,
      milestones: milestones,
      tags: tags,
      tasks: resolvedTasks,
      taskTags: (json['taskTags'] as List<dynamic>? ?? const [])
          .map(
            (e) => SyncTaskTagData.fromJson(
              e as Map<String, dynamic>,
              taskIdToUuid: taskIdToUuid,
              tagIdToUuid: tagIdToUuid,
            ),
          )
          .toList(),
      completions: (json['completions'] as List<dynamic>? ?? const [])
          .map((e) => SyncTaskCompletionData.fromJson(e as Map<String, dynamic>, taskIdToUuid: taskIdToUuid))
          .toList(),
      sessions: (json['sessions'] as List<dynamic>? ?? const [])
          .map((e) => SyncFocusSessionData.fromJson(e as Map<String, dynamic>, taskIdToUuid: taskIdToUuid))
          .toList(),
      settings: (json['settings'] as List<dynamic>? ?? const [])
          .map((e) => SyncSettingData.fromJson(e as Map<String, dynamic>))
          .where((s) => kSyncableSettingsKeys.contains(s.key))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'syncTimestamp': syncTimestamp.toIso8601String(),
    'projects': projects.map((p) => p.toJson()).toList(),
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'tags': tags.map((t) => t.toJson()).toList(),
    'tasks': tasks.map((t) => t.toJson()).toList(),
    'taskTags': taskTags.map((t) => t.toJson()).toList(),
    'completions': completions.map((c) => c.toJson()).toList(),
    'sessions': sessions.map((s) => s.toJson()).toList(),
    'settings': settings.map((s) => s.toJson()).toList(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory SyncData.fromJsonString(String jsonString) {
    return SyncData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  static SyncData empty() => SyncData(syncTimestamp: DateTime.now());

  SyncData copyWith({
    int? schemaVersion,
    DateTime? syncTimestamp,
    List<SyncProjectData>? projects,
    List<SyncMilestoneData>? milestones,
    List<SyncTagData>? tags,
    List<SyncTaskData>? tasks,
    List<SyncTaskTagData>? taskTags,
    List<SyncTaskCompletionData>? completions,
    List<SyncFocusSessionData>? sessions,
    List<SyncSettingData>? settings,
  }) {
    return SyncData(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      syncTimestamp: syncTimestamp ?? this.syncTimestamp,
      projects: projects ?? this.projects,
      milestones: milestones ?? this.milestones,
      tags: tags ?? this.tags,
      tasks: tasks ?? this.tasks,
      taskTags: taskTags ?? this.taskTags,
      completions: completions ?? this.completions,
      sessions: sessions ?? this.sessions,
      settings: settings ?? this.settings,
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

DateTime? _parseDate(dynamic value) => value != null ? DateTime.parse(value as String) : null;

String _requireUuid(Map<String, dynamic> json, [String key = 'uuid']) {
  final value = json[key] as String?;
  return (value != null && value.isNotEmpty) ? value : generateUuid();
}

// ---------------------------------------------------------------------------
// Entity payloads
// ---------------------------------------------------------------------------

class SyncProjectData {
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

  /// Legacy v1 int id — used only while migrating old payloads.
  final int? legacyId;

  const SyncProjectData({
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
    this.legacyId,
  });

  factory SyncProjectData.fromJson(Map<String, dynamic> json) {
    return SyncProjectData(
      uuid: _requireUuid(json),
      title: json['title'] as String,
      description: json['description'] as String?,
      statusIndex: (json['statusIndex'] as int?) ?? ProjectStatus.active.index,
      color: json['color'] as int?,
      startDate: _parseDate(json['startDate']),
      deadline: _parseDate(json['deadline']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: _parseDate(json['deletedAt']),
      legacyId: json['id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
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
}

class SyncMilestoneData {
  final String uuid;
  final String projectUuid;
  final String title;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? legacyId;

  const SyncMilestoneData({
    required this.uuid,
    required this.projectUuid,
    required this.title,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.legacyId,
  });

  factory SyncMilestoneData.fromJson(Map<String, dynamic> json, {Map<int, String> projectIdToUuid = const {}}) {
    final projectUuid = json['projectUuid'] as String? ?? projectIdToUuid[json['projectId'] as int?] ?? '';
    return SyncMilestoneData(
      uuid: _requireUuid(json),
      projectUuid: projectUuid,
      title: json['title'] as String,
      targetDate: _parseDate(json['targetDate']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: _parseDate(json['deletedAt']),
      legacyId: json['id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'projectUuid': projectUuid,
    'title': title,
    'targetDate': targetDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };
}

class SyncTagData {
  final String uuid;
  final String name;
  final int? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? legacyId;

  const SyncTagData({
    required this.uuid,
    required this.name,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.legacyId,
  });

  factory SyncTagData.fromJson(Map<String, dynamic> json) {
    return SyncTagData(
      uuid: _requireUuid(json),
      name: json['name'] as String,
      color: json['color'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: _parseDate(json['deletedAt']),
      legacyId: json['id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'color': color,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };
}

class SyncTaskData {
  final String uuid;
  final String projectUuid;
  final String? parentTaskUuid;
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
  final String? milestoneUuid;
  final String? recurrenceRuleJson;
  final DateTime? recurrenceAnchorDate;
  final bool isHabit;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? legacyId;
  final int? legacyParentTaskId;

  const SyncTaskData({
    required this.uuid,
    required this.projectUuid,
    this.parentTaskUuid,
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
    this.milestoneUuid,
    this.recurrenceRuleJson,
    this.recurrenceAnchorDate,
    this.isHabit = false,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.legacyId,
    this.legacyParentTaskId,
  });

  factory SyncTaskData.fromJson(
    Map<String, dynamic> json, {
    Map<int, String> projectIdToUuid = const {},
    Map<int, String> milestoneIdToUuid = const {},
  }) {
    final statusIndex = json['statusIndex'] as int?;
    final isCompleted = json['isCompleted'] as bool? ?? false;
    final projectUuid = json['projectUuid'] as String? ?? projectIdToUuid[json['projectId'] as int?] ?? '';
    final milestoneUuid = json['milestoneUuid'] as String? ?? milestoneIdToUuid[json['milestoneId'] as int?];

    return SyncTaskData(
      uuid: _requireUuid(json),
      projectUuid: projectUuid,
      parentTaskUuid: json['parentTaskUuid'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      priorityIndex: json['priorityIndex'] as int? ?? TaskPriority.medium.index,
      statusIndex: statusIndex ?? (isCompleted ? TaskStatus.done.index : TaskStatus.todo.index),
      reminderModeIndex: (json['reminderModeIndex'] as int?) ?? TaskReminderMode.smart.index,
      customReminderMinutesBefore: json['customReminderMinutesBefore'] as int?,
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      depth: json['depth'] as int? ?? 0,
      estimatedMinutes: json['estimatedMinutes'] as int?,
      sortOrder: (json['sortOrder'] as num?)?.toDouble() ?? 0,
      milestoneUuid: milestoneUuid,
      recurrenceRuleJson: json['recurrenceRuleJson'] as String?,
      recurrenceAnchorDate: _parseDate(json['recurrenceAnchorDate']),
      isHabit: json['isHabit'] as bool? ?? false,
      isCompleted: isCompleted,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: _parseDate(json['deletedAt']),
      legacyId: json['id'] as int?,
      legacyParentTaskId: json['parentTaskId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'projectUuid': projectUuid,
    'parentTaskUuid': parentTaskUuid,
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
    'milestoneUuid': milestoneUuid,
    'recurrenceRuleJson': recurrenceRuleJson,
    'recurrenceAnchorDate': recurrenceAnchorDate?.toIso8601String(),
    'isHabit': isHabit,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  SyncTaskData copyWith({String? parentTaskUuid}) {
    return SyncTaskData(
      uuid: uuid,
      projectUuid: projectUuid,
      parentTaskUuid: parentTaskUuid ?? this.parentTaskUuid,
      title: title,
      description: description,
      priorityIndex: priorityIndex,
      statusIndex: statusIndex,
      reminderModeIndex: reminderModeIndex,
      customReminderMinutesBefore: customReminderMinutesBefore,
      startDate: startDate,
      endDate: endDate,
      depth: depth,
      estimatedMinutes: estimatedMinutes,
      sortOrder: sortOrder,
      milestoneUuid: milestoneUuid,
      recurrenceRuleJson: recurrenceRuleJson,
      recurrenceAnchorDate: recurrenceAnchorDate,
      isHabit: isHabit,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      legacyId: legacyId,
      legacyParentTaskId: legacyParentTaskId,
    );
  }

  bool get isDone =>
      (statusIndex >= 0 && statusIndex < TaskStatus.values.length ? TaskStatus.values[statusIndex] : null) ==
          TaskStatus.done ||
      isCompleted;

  RecurrenceRule? get recurrenceRule => RecurrenceRule.tryParseJson(recurrenceRuleJson);
}

class SyncTaskTagData {
  final String uuid;
  final String taskUuid;
  final String tagUuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SyncTaskTagData({
    required this.uuid,
    required this.taskUuid,
    required this.tagUuid,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SyncTaskTagData.fromJson(
    Map<String, dynamic> json, {
    Map<int, String> taskIdToUuid = const {},
    Map<int, String> tagIdToUuid = const {},
  }) {
    final taskUuid = json['taskUuid'] as String? ?? taskIdToUuid[json['taskId'] as int?] ?? '';
    final tagUuid = json['tagUuid'] as String? ?? tagIdToUuid[json['tagId'] as int?] ?? '';
    final createdAt = _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final updatedAt = _parseDate(json['updatedAt']) ?? createdAt;
    return SyncTaskTagData(
      uuid: _requireUuid(json),
      taskUuid: taskUuid,
      tagUuid: tagUuid,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: _parseDate(json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'taskUuid': taskUuid,
    'tagUuid': tagUuid,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };
}

class SyncTaskCompletionData {
  final String uuid;
  final String taskUuid;
  final DateTime occurrenceDate;
  final DateTime completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SyncTaskCompletionData({
    required this.uuid,
    required this.taskUuid,
    required this.occurrenceDate,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SyncTaskCompletionData.fromJson(Map<String, dynamic> json, {Map<int, String> taskIdToUuid = const {}}) {
    return SyncTaskCompletionData(
      uuid: _requireUuid(json),
      taskUuid: json['taskUuid'] as String? ?? taskIdToUuid[json['taskId'] as int?] ?? '',
      occurrenceDate: DateTime.parse(json['occurrenceDate'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: _parseDate(json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'taskUuid': taskUuid,
    'occurrenceDate': occurrenceDate.toIso8601String(),
    'completedAt': completedAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };
}

class SyncFocusSessionData {
  final String uuid;
  final String? taskUuid;
  final int focusDurationMinutes;
  final int breakDurationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final int stateIndex;
  final int elapsedSeconds;
  final int? focusPhaseEndedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const SyncFocusSessionData({
    required this.uuid,
    this.taskUuid,
    required this.focusDurationMinutes,
    required this.breakDurationMinutes,
    required this.startTime,
    this.endTime,
    required this.stateIndex,
    this.elapsedSeconds = 0,
    this.focusPhaseEndedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SyncFocusSessionData.fromJson(Map<String, dynamic> json, {Map<int, String> taskIdToUuid = const {}}) {
    final startTime = DateTime.parse(json['startTime'] as String);
    final endTime = _parseDate(json['endTime']);
    final deletedAt = _parseDate(json['deletedAt']);
    // Sessions historically lacked updatedAt; derive a stable clock for merge.
    final updatedAt = _parseDate(json['updatedAt']) ?? deletedAt ?? endTime ?? startTime;
    final createdAt = _parseDate(json['createdAt']) ?? startTime;

    return SyncFocusSessionData(
      uuid: _requireUuid(json),
      taskUuid: json['taskUuid'] as String? ?? taskIdToUuid[json['taskId'] as int?],
      focusDurationMinutes: json['focusDurationMinutes'] as int,
      breakDurationMinutes: json['breakDurationMinutes'] as int,
      startTime: startTime,
      endTime: endTime,
      stateIndex: json['stateIndex'] as int? ?? SessionState.completed.index,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      focusPhaseEndedAt: json['focusPhaseEndedAt'] as int?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'taskUuid': taskUuid,
    'focusDurationMinutes': focusDurationMinutes,
    'breakDurationMinutes': breakDurationMinutes,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'stateIndex': stateIndex,
    'elapsedSeconds': elapsedSeconds,
    'focusPhaseEndedAt': focusPhaseEndedAt,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
  };
}

class SyncSettingData {
  final String key;
  final String value;
  final DateTime updatedAt;

  const SyncSettingData({required this.key, required this.value, required this.updatedAt});

  factory SyncSettingData.fromJson(Map<String, dynamic> json) {
    return SyncSettingData(
      key: json['key'] as String,
      value: json['value'] as String,
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value, 'updatedAt': updatedAt.toIso8601String()};
}
