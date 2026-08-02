import 'package:drift/drift.dart';

import '../../../tasks/data/models/task_model.dart';
import 'tag_model.dart';

/// Many-to-many association between tasks and tags.
class TaskTagTable extends Table {
  IntColumn get taskId => integer().references(TaskTable, #id, onDelete: KeyAction.cascade)();

  IntColumn get tagId => integer().references(TagTable, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {taskId, tagId};
}
