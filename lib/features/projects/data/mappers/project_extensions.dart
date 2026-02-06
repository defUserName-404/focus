import 'package:focus/core/services/db_service.dart' as db;

import '../../domain/entities/project.dart';

extension DbProjectToDomain on db.Project {
  Project toDomain() {
    return Project(
      id: id,
      title: title,
      description: description,
      startDate: startDate,
      deadline: deadline,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension DomainProjectToCompanion on Project {
  db.ProjectsCompanion toCompanion() {
    return db.ProjectsCompanion.insert(
      id: id,
      title: title,
      description: description,
      startDate: startDate,
      deadline: deadline,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
