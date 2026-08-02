import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Log entry for a single completed occurrence of a (recurring) task.
///
/// [occurrenceDate] is date-only (local midnight). Unique with [taskId]
/// among non-deleted rows.
@immutable
class TaskCompletion extends Equatable {
  final int? id;
  final String uuid;
  final int taskId;
  final DateTime occurrenceDate;
  final DateTime completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const TaskCompletion({
    this.id,
    required this.uuid,
    required this.taskId,
    required this.occurrenceDate,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [id, uuid, taskId, occurrenceDate, completedAt, createdAt, updatedAt, deletedAt];
}
