import 'tag.dart';

const _TagCopyWithUnset _tagCopyWithUnset = _TagCopyWithUnset();

class _TagCopyWithUnset {
  const _TagCopyWithUnset();
}

extension TagCopyWith on Tag {
  Tag copyWith({
    Object? id = _tagCopyWithUnset,
    String? uuid,
    String? name,
    Object? color = _tagCopyWithUnset,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _tagCopyWithUnset,
  }) {
    return Tag(
      id: id == _tagCopyWithUnset ? this.id : id as int?,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      color: color == _tagCopyWithUnset ? this.color : color as int?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == _tagCopyWithUnset ? this.deletedAt : deletedAt as DateTime?,
    );
  }
}
