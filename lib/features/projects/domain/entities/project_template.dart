import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'project_template_payload.dart';

/// Stored project template (built-in or user-saved).
@immutable
class ProjectTemplate extends Equatable {
  final int? id;
  final String uuid;
  final String name;
  final String? description;
  final bool isBuiltin;
  final ProjectTemplatePayload payload;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectTemplate({
    this.id,
    required this.uuid,
    required this.name,
    this.description,
    this.isBuiltin = false,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, uuid, name, description, isBuiltin, payload, createdAt, updatedAt];
}
