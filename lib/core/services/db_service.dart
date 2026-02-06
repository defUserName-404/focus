import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/projects/data/models/project_model.dart';

part 'db_service.g.dart';

@DriftDatabase(tables: [ProjectTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'focus.sqlite'));

  @override
  int get schemaVersion => 1;
}
