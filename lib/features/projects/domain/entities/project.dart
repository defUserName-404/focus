import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Immutable representation of a user project.
@immutable
class Project extends Equatable {
  final int? id;
  final String uuid;
  final String title;
  final String? description;
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
    this.startDate,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [id, uuid, title, description, startDate, deadline, createdAt, updatedAt, deletedAt];
}
