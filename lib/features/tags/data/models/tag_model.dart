import 'package:drift/drift.dart';

@TableIndex(name: 'tag_uuid_idx', columns: {#uuid}, unique: true)
@TableIndex(name: 'tag_deleted_at_idx', columns: {#deletedAt})
@TableIndex(name: 'tag_name_idx', columns: {#name})
class TagTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().unique()();

  TextColumn get name => text()();

  /// ARGB color value, or null for the theme default.
  IntColumn get color => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();
}
