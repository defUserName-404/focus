import 'package:drift/drift.dart' show BuildGeneralColumn, Column, DateTimeColumn, Table, TextColumn;

class Projects extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get description => text()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get deadline => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
