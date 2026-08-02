import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'project_status.dart';

/// Immutable representation of a user project.
@immutable
class Project extends Equatable {
  final int? id;
  final String uuid;
  final String title;
  final String? description;
  final ProjectStatus status;
  final int? color;
  final DateTime? startDate;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Project({
    this.id,
    required this.uuid,
    required this.title,
    this.description,
    this.status = ProjectStatus.active,
    this.color,
    this.startDate,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    uuid,
    title,
    description,
    status,
    color,
    startDate,
    deadline,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
