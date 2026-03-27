import 'project.dart';

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
    String? title,
    Object? description = _projectCopyWithUnset,
    Object? startDate = _projectCopyWithUnset,
    Object? deadline = _projectCopyWithUnset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id == _projectCopyWithUnset ? this.id : id as int?,
      title: title ?? this.title,
      description: description == _projectCopyWithUnset ? this.description : description as String?,
      startDate: startDate == _projectCopyWithUnset ? this.startDate : startDate as DateTime?,
      deadline: deadline == _projectCopyWithUnset ? this.deadline : deadline as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
