import 'package:drift/drift.dart' show Value;
import 'package:focus/core/services/db_service.dart';

import '../../domain/entities/tag.dart';

extension DbTagToDomain on TagTableData {
  Tag toDomain() => Tag(
    id: id,
    uuid: uuid,
    name: name,
    color: color,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

extension DomainTagToCompanion on Tag {
  TagTableCompanion toCompanion() {
    if (id != null) {
      return TagTableCompanion(
        id: Value(id!),
        uuid: Value(uuid),
        name: Value(name),
        color: Value(color),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
      );
    }
    return TagTableCompanion.insert(
      uuid: uuid,
      name: name,
      color: Value(color),
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: Value(deletedAt),
    );
  }
}
