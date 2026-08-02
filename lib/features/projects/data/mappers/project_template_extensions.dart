import 'package:drift/drift.dart' show Value;
import 'package:focus/core/services/db_service.dart';

import '../../domain/entities/project_template.dart';
import '../../domain/entities/project_template_payload.dart';

extension DbProjectTemplateToDomain on ProjectTemplateTableData {
  ProjectTemplate toDomain() => ProjectTemplate(
    id: id,
    uuid: uuid,
    name: name,
    description: description,
    isBuiltin: isBuiltin,
    payload: ProjectTemplatePayload.fromJsonString(payloadJson),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension DomainProjectTemplateToCompanion on ProjectTemplate {
  ProjectTemplateTableCompanion toCompanion() {
    if (id != null) {
      return ProjectTemplateTableCompanion(
        id: Value(id!),
        uuid: Value(uuid),
        name: Value(name),
        description: Value(description),
        isBuiltin: Value(isBuiltin),
        payloadJson: Value(payload.toJsonString()),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      );
    }
    return ProjectTemplateTableCompanion.insert(
      uuid: uuid,
      name: name,
      description: Value<String?>(description),
      isBuiltin: Value(isBuiltin),
      payloadJson: payload.toJsonString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
