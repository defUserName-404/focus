import 'package:drift/drift.dart' show Value;
import 'package:focus/core/services/db_service.dart';

import '../../domain/entities/milestone.dart';

extension DbMilestoneToDomain on MilestoneTableData {
  Milestone toDomain() => Milestone(
    id: id,
    uuid: uuid,
    projectId: projectId,
    title: title,
    targetDate: targetDate,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

extension DomainMilestoneToCompanion on Milestone {
  MilestoneTableCompanion toCompanion() {
    if (id != null) {
      return MilestoneTableCompanion(
        id: Value(id!),
        uuid: Value(uuid),
        projectId: Value(projectId),
        title: Value(title),
        targetDate: Value(targetDate),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
      );
    }
    return MilestoneTableCompanion.insert(
      uuid: uuid,
      projectId: projectId,
      title: title,
      targetDate: Value(targetDate),
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: Value(deletedAt),
    );
  }
}
