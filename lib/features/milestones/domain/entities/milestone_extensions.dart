import 'milestone.dart';

const _MilestoneCopyWithUnset _milestoneCopyWithUnset = _MilestoneCopyWithUnset();

class _MilestoneCopyWithUnset {
  const _MilestoneCopyWithUnset();
}

extension MilestoneCopyWith on Milestone {
  Milestone copyWith({
    Object? id = _milestoneCopyWithUnset,
    String? uuid,
    int? projectId,
    String? title,
    Object? targetDate = _milestoneCopyWithUnset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _milestoneCopyWithUnset,
  }) {
    return Milestone(
      id: id == _milestoneCopyWithUnset ? this.id : id as int?,
      uuid: uuid ?? this.uuid,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      targetDate: targetDate == _milestoneCopyWithUnset ? this.targetDate : targetDate as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == _milestoneCopyWithUnset ? this.deletedAt : deletedAt as DateTime?,
    );
  }
}
