import 'dart:convert';

import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../projects/domain/entities/project.dart';

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
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SyncProjectData({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SyncProjectData.fromJson(Map<String, dynamic> json) {
    return SyncProjectData(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startDate': startDate?.toIso8601String(),
    'deadline': deadline?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SyncProjectData.fromProject(Project project) {
    return SyncProjectData(
      id: project.id!,
      title: project.title,
      description: project.description,
      startDate: project.startDate,
      deadline: project.deadline,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
  }

  Project toProject() => Project(
    id: id,
    title: title,
    description: description,
    startDate: startDate,
    deadline: deadline,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

/// Serializable task data for sync.
class SyncTaskData {
  final int id;
  final int projectId;
  final int? parentTaskId;
  final String title;
  final String? description;
  final int priorityIndex;
  final DateTime? startDate;
  final DateTime? endDate;
  final int depth;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SyncTaskData({
    required this.id,
    required this.projectId,
    this.parentTaskId,
    required this.title,
    this.description,
    required this.priorityIndex,
    this.startDate,
    this.endDate,
    required this.depth,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SyncTaskData.fromJson(Map<String, dynamic> json) {
    return SyncTaskData(
      id: json['id'] as int,
      projectId: json['projectId'] as int,
      parentTaskId: json['parentTaskId'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      priorityIndex: json['priorityIndex'] as int,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      depth: json['depth'] as int,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'parentTaskId': parentTaskId,
    'title': title,
    'description': description,
    'priorityIndex': priorityIndex,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'depth': depth,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SyncTaskData.fromTask(Task task) {
    return SyncTaskData(
      id: task.id!,
      projectId: task.projectId,
      parentTaskId: task.parentTaskId,
      title: task.title,
      description: task.description,
      priorityIndex: task.priority.index,
      startDate: task.startDate,
      endDate: task.endDate,
      depth: task.depth,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  Task toTask() => Task(
    id: id,
    projectId: projectId,
    parentTaskId: parentTaskId,
    title: title,
    description: description,
    priority: TaskPriority.values[priorityIndex],
    startDate: startDate,
    endDate: endDate,
    depth: depth,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
