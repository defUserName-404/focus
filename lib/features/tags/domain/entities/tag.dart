import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Immutable user-defined tag for labeling tasks.
@immutable
class Tag extends Equatable {
  final int? id;
  final String uuid;
  final String name;
  final int? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Tag({
    this.id,
    required this.uuid,
    required this.name,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [id, uuid, name, color, createdAt, updatedAt, deletedAt];
}
