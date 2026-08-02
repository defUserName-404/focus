import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus/core/services/db_service.dart';
import 'package:sqlite3/sqlite3.dart';

/// Phase 1 migration harness.
///
/// Captures the current (v6) schema via [AppDatabase.forTesting] and verifies
/// that upgrading from a hand-built v1 schema reaches v6 without nested
/// transaction statements, without losing rows, and with uuid/deletedAt columns.
void main() {
  test('onCreate produces schema version 6 with expected tables', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 6);

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

    final projectCols = await db.customSelect('PRAGMA table_info(project_table)').get();
    final projectColNames = projectCols.map((r) => r.read<String>('name')).toSet();
    expect(projectColNames, containsAll({'uuid', 'deleted_at'}));

    final taskCols = await db.customSelect('PRAGMA table_info(task_table)').get();
    final taskColNames = taskCols.map((r) => r.read<String>('name')).toSet();
    expect(taskColNames, containsAll({'uuid', 'deleted_at'}));

    final sessionCols = await db.customSelect('PRAGMA table_info(focus_session_table)').get();
    final sessionColNames = sessionCols.map((r) => r.read<String>('name')).toSet();
    expect(sessionColNames, containsAll({'uuid', 'deleted_at'}));
  });

  test('migrates v1 schema to v6, preserves rows, and backfills uuids', () async {
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
    raw.execute(
      'INSERT INTO focus_session_table '
      '(id, task_id, focus_duration_minutes, break_duration_minutes, start_time, state, elapsed_seconds) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      [1, 1, 25, 5, 1700000000, 0, 0],
    );
    raw.execute('PRAGMA user_version = 1');

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(() async {
      await db.close();
    });

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 6);

    final tasks = await db.select(db.taskTable).get();
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Legacy Task');
    expect(tasks.single.projectId, 1);
    expect(tasks.single.uuid, isNotEmpty);
    expect(tasks.single.deletedAt, isNull);

    // reminder columns added in v4
    expect(tasks.single.reminderMode.index, 0);

    // notification inbox created in v5
    final inbox = await db.select(db.notificationInboxTable).get();
    expect(inbox, isEmpty);

    final projects = await db.select(db.projectTable).get();
    expect(projects.single.uuid, isNotEmpty);
    expect(projects.single.deletedAt, isNull);

    final sessions = await db.select(db.focusSessionTable).get();
    expect(sessions.single.uuid, isNotEmpty);
    expect(sessions.single.deletedAt, isNull);

    final indexes = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE '%uuid%'")
        .get();
    final indexNames = indexes.map((r) => r.read<String>('name')).toSet();
    expect(indexNames, containsAll({'project_uuid_idx', 'task_uuid_idx', 'focus_session_uuid_idx'}));
  });

  test('migrates v5 schema to v6 adding soft-delete columns', () async {
    final raw = sqlite3.openInMemory();
    _createV5Schema(raw);
    raw.execute('INSERT INTO project_table (id, title, created_at, updated_at) VALUES (?, ?, ?, ?)', [
      1,
      'V5 Project',
      1700000000,
      1700000000,
    ]);
    raw.execute(
      'INSERT INTO task_table '
      '(id, project_id, title, priority, depth, is_completed, reminder_mode, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [1, 1, 'V5 Task', 1, 0, 0, 0, 1700000000, 1700000000],
    );
    raw.execute('PRAGMA user_version = 5');

    final db = AppDatabase.forTesting(NativeDatabase.opened(raw));
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 6);

    final project = (await db.select(db.projectTable).get()).single;
    expect(project.uuid, isNotEmpty);
    expect(project.deletedAt, isNull);

    final task = (await db.select(db.taskTable).get()).single;
    expect(task.uuid, isNotEmpty);
    expect(task.deletedAt, isNull);
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

void _createV5Schema(Database raw) {
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
      reminder_mode INTEGER NOT NULL DEFAULT 0,
      custom_reminder_minutes_before INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY(project_id) REFERENCES project_table(id) ON DELETE CASCADE,
      FOREIGN KEY(parent_task_id) REFERENCES task_table(id) ON DELETE CASCADE
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
      focus_phase_ended_at INTEGER,
      FOREIGN KEY(task_id) REFERENCES task_table(id) ON DELETE CASCADE
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
  raw.execute('''
    CREATE TABLE notification_inbox_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      notification_id INTEGER NOT NULL,
      type INTEGER NOT NULL,
      state INTEGER NOT NULL,
      title TEXT NOT NULL,
      body TEXT,
      payload TEXT,
      task_id INTEGER,
      project_id INTEGER,
      scheduled_for INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      UNIQUE(notification_id, type)
    )
  ''');
}
