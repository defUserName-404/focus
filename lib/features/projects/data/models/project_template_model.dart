import 'package:drift/drift.dart';

@TableIndex(name: 'project_template_uuid_idx', columns: {#uuid}, unique: true)
@TableIndex(name: 'project_template_builtin_idx', columns: {#isBuiltin})
class ProjectTemplateTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().unique()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();

  /// JSON [ProjectTemplatePayload] blob.
  TextColumn get payloadJson => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
