import 'project_template.dart';
import 'project_template_payload.dart';

extension ProjectTemplateCopyWith on ProjectTemplate {
  ProjectTemplate copyWith({
    int? id,
    String? uuid,
    String? name,
    String? description,
    bool? isBuiltin,
    ProjectTemplatePayload? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectTemplate(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
