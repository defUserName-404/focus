import 'package:isar_community/isar.dart';

import '../../domain/entities/project.dart';

part 'project_model.g.dart';

@collection
class ProjectModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String projectId;

  late String title;
  late String description;
  late DateTime startDate;
  late DateTime deadline;
  late DateTime createdAt;
  late DateTime updatedAt;

  // Conversion methods
  Project toEntity() => Project(
    id: projectId,
    title: title,
    description: description,
    startDate: startDate,
    deadline: deadline,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static ProjectModel fromEntity(Project project) => ProjectModel()
    ..projectId = project.id
    ..title = project.title
    ..description = project.description
    ..startDate = project.startDate
    ..deadline = project.deadline
    ..createdAt = project.createdAt
    ..updatedAt = project.updatedAt;
}
