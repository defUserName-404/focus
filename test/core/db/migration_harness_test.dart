import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus/core/services/db_service.dart';
import 'package:sqlite3/sqlite3.dart';

/// Phase 0 migration harness.
///
/// Captures the current (v5) schema via [AppDatabase.forTesting] and verifies
/// that upgrading from a hand-built v1 schema reaches v5 without nested
/// transaction statements and without losing rows.
void main() {
  test('onCreate produces schema version 5 with expected tables', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 5);

    final tables = await db.customSelect("SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name").get();
    final names = tables.map((row) => row.read<String>('name')).toSet();
    expect(
      names,
      containsAll({
        'project_table',
        'task_table',
        'focus_session_table',
        'daily_session_stats_table',
        'settings_table',
        'notification_inbox_table',
      }),
    );
  });

  test('migrates v1 schema to v5 and preserves task rows', () async {
    final raw = sqlite3.openInMemory();
    _createV1Schema(raw);
    raw.execute('INSERT INTO project_table (id, title, created_at, updated_at) VALUES (?, ?, ?, ?)', [
      1,
      'Legacy Project',
      1700000000,
      1700000000,
    ]);
    raw.execute(
      'INSERT INTO task_table (id, project_id, title, priority, depth, is_completed, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [1, 1, 'Legacy Task', 1, 0, 0, 1700000000, 1700000000],
    );
    raw.execute('PRAGMA user_version = 1');

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(() async {
      await db.close();
    });

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 5);

    final tasks = await db.select(db.taskTable).get();
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Legacy Task');
    expect(tasks.single.projectId, 1);

    // reminder columns added in v4
    expect(tasks.single.reminderMode.index, 0);

    // notification inbox created in v5
    final inbox = await db.select(db.notificationInboxTable).get();
    expect(inbox, isEmpty);
  });
}

void _createV1Schema(Database raw) {
  raw.execute('''
    CREATE TABLE project_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      start_date INTEGER,
      deadline INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  raw.execute('''
    CREATE TABLE task_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      project_id INTEGER NOT NULL,
      parent_task_id INTEGER,
      title TEXT NOT NULL,
      description TEXT,
      priority INTEGER NOT NULL,
      start_date INTEGER,
      end_date INTEGER,
      depth INTEGER NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY(project_id) REFERENCES project_table(id),
      FOREIGN KEY(parent_task_id) REFERENCES task_table(id)
    )
  ''');
  raw.execute('''
    CREATE TABLE focus_session_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      task_id INTEGER,
      focus_duration_minutes INTEGER NOT NULL,
      break_duration_minutes INTEGER NOT NULL,
      start_time INTEGER NOT NULL,
      end_time INTEGER,
      state INTEGER NOT NULL,
      elapsed_seconds INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY(task_id) REFERENCES task_table(id)
    )
  ''');
  raw.execute('''
    CREATE TABLE daily_session_stats_table (
      date TEXT NOT NULL PRIMARY KEY,
      completed_sessions INTEGER NOT NULL,
      total_sessions INTEGER NOT NULL,
      focus_seconds INTEGER NOT NULL
    )
  ''');
  raw.execute('''
    CREATE TABLE settings_table (
      key TEXT NOT NULL PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');
}
