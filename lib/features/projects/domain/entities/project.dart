import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Immutable representation of a user project.
@immutable
class Project extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    this.id,
    required this.title,
    this.description,
    this.startDate,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, title, description, startDate, deadline, createdAt, updatedAt,
  ];
}
