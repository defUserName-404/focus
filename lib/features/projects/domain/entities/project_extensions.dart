import 'project.dart';
import 'project_status.dart';

/// Sentinel object used in [ProjectCopyWith.copyWith] to distinguish
/// "parameter not provided" from "explicitly set to null".
///
/// See [TaskCopyWith] and [FocusSessionCopyWith] for the same pattern.
const _ProjectCopyWithUnset _projectCopyWithUnset = _ProjectCopyWithUnset();

class _ProjectCopyWithUnset {
  const _ProjectCopyWithUnset();
}

extension ProjectCopyWith on Project {
  Project copyWith({
    Object? id = _projectCopyWithUnset,
    String? uuid,
    String? title,
    Object? description = _projectCopyWithUnset,
    ProjectStatus? status,
    Object? color = _projectCopyWithUnset,
    Object? startDate = _projectCopyWithUnset,
    Object? deadline = _projectCopyWithUnset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _projectCopyWithUnset,
  }) {
    return Project(
      id: id == _projectCopyWithUnset ? this.id : id as int?,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description == _projectCopyWithUnset ? this.description : description as String?,
      status: status ?? this.status,
      color: color == _projectCopyWithUnset ? this.color : color as int?,
      startDate: startDate == _projectCopyWithUnset ? this.startDate : startDate as DateTime?,
      deadline: deadline == _projectCopyWithUnset ? this.deadline : deadline as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == _projectCopyWithUnset ? this.deletedAt : deletedAt as DateTime?,
    );
  }
}
