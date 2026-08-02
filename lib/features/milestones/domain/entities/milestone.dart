import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Immutable project milestone used to group tasks toward a target date.
@immutable
class Milestone extends Equatable {
  final int? id;
  final String uuid;
  final int projectId;
  final String title;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Milestone({
    this.id,
    required this.uuid,
    required this.projectId,
    required this.title,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [id, uuid, projectId, title, targetDate, createdAt, updatedAt, deletedAt];
}
