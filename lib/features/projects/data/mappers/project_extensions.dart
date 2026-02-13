import 'package:drift/drift.dart' show Value;
import 'package:focus/core/services/db_service.dart';

import '../../domain/entities/project.dart';

extension DbProjectToDomain on ProjectTableData {
  Project toDomain() => Project(
    id: id,
    title: title,
    description: description,
    startDate: startDate,
    deadline: deadline,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension DomainProjectToCompanion on Project {
  ProjectTableCompanion toCompanion() {
    if (id != null) {
      return ProjectTableCompanion(
        id: Value(id!),
        title: Value(title),
        description: Value(description),
        startDate: Value(startDate),
        deadline: Value(deadline),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      );
    }
    return ProjectTableCompanion.insert(
      title: title,
      description: Value<String?>(description),
      startDate: Value<DateTime?>(startDate),
      deadline: Value<DateTime?>(deadline),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
