import 'package:drift/drift.dart' show Value;
import 'package:focus/core/services/db_service.dart';

import '../../domain/entities/project.dart';

extension DbProjectToDomain on ProjectTableData {
  Project toDomain() => Project(
    id: id,
    uuid: uuid,
    title: title,
    description: description,
    status: status,
    color: color,
    startDate: startDate,
    deadline: deadline,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

extension DomainProjectToCompanion on Project {
  ProjectTableCompanion toCompanion() {
    if (id != null) {
      return ProjectTableCompanion(
        id: Value(id!),
        uuid: Value(uuid),
        title: Value(title),
        description: Value(description),
        status: Value(status),
        color: Value(color),
        startDate: Value(startDate),
        deadline: Value(deadline),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
      );
    }
    return ProjectTableCompanion.insert(
      uuid: uuid,
      title: title,
      description: Value<String?>(description),
      status: Value(status),
      color: Value<int?>(color),
      startDate: Value<DateTime?>(startDate),
      deadline: Value<DateTime?>(deadline),
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: Value<DateTime?>(deletedAt),
    );
  }
}
