import 'package:flutter_test/flutter_test.dart';

import 'package:focus/features/sync/domain/entities/sync_data.dart';
import 'package:focus/features/sync/domain/entities/sync_state.dart';
import 'package:focus/features/sync/domain/services/sync_merge_engine.dart';

void main() {
  const engine = SyncMergeEngine();
  final base = DateTime.utc(2026, 1, 1, 12);
  final lastSync = base;
  final earlier = base.subtract(const Duration(hours: 1));
  final later = base.add(const Duration(hours: 1));
  final muchLater = base.add(const Duration(hours: 2));

  SyncProjectData project({
    required String uuid,
    required String title,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) {
    return SyncProjectData(uuid: uuid, title: title, createdAt: earlier, updatedAt: updatedAt, deletedAt: deletedAt);
  }

  SyncTaskData task({
    required String uuid,
    required String title,
    required DateTime updatedAt,
    String projectUuid = 'proj-1',
    String? parentTaskUuid,
    int depth = 0,
    DateTime? deletedAt,
  }) {
    return SyncTaskData(
      uuid: uuid,
      projectUuid: projectUuid,
      parentTaskUuid: parentTaskUuid,
      title: title,
      priorityIndex: 1,
      depth: depth,
      isCompleted: false,
      createdAt: earlier,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  group('SyncMergeEngine', () {
    test('refuses remote schema newer than local', () {
      final local = SyncData(syncTimestamp: base, schemaVersion: kSyncSchemaVersion);
      final remote = SyncData(syncTimestamp: base, schemaVersion: kSyncSchemaVersion + 1);
      expect(() => engine.merge(local, remote, lastSync), throwsA(isA<SyncSchemaTooNewException>()));
    });

    test('concurrent create: union keeps both local-only and remote-only rows', () {
      final local = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'a', title: 'Local Only', updatedAt: later)],
      );
      final remote = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'b', title: 'Remote Only', updatedAt: later)],
      );

      final result = engine.merge(local, remote, lastSync);
      expect(result.conflicts, isEmpty);
      expect(result.merged.projects.map((p) => p.uuid).toSet(), {'a', 'b'});
    });

    test('concurrent edit of same uuid yields conflict', () {
      final local = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'shared', title: 'Local Edit', updatedAt: later)],
      );
      final remote = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'shared', title: 'Remote Edit', updatedAt: muchLater)],
      );

      final result = engine.merge(local, remote, lastSync);
      expect(result.conflicts, hasLength(1));
      expect(result.conflicts.single.entityId, 'shared');
      expect(result.conflicts.single.entityType, 'project');
      expect(result.merged.projects.where((p) => p.uuid == 'shared'), isEmpty);
    });

    test('delete-versus-edit: newer tombstone wins over older live edit', () {
      final local = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'p1', title: 'Gone', updatedAt: muchLater, deletedAt: muchLater)],
      );
      final remote = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'p1', title: 'Edited remotely', updatedAt: later)],
      );

      final result = engine.merge(local, remote, lastSync);
      expect(result.conflicts, isEmpty);
      expect(result.merged.projects.single.deletedAt, isNotNull);
      expect(result.merged.projects.single.title, 'Gone');
    });

    test('delete-versus-edit: both changed since last sync yields conflict when live is newer', () {
      final local = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'p1', title: 'Deleted locally', updatedAt: later, deletedAt: later)],
      );
      final remote = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'p1', title: 'Revived remotely', updatedAt: muchLater)],
      );

      final result = engine.merge(local, remote, lastSync);
      // Both changed since last sync → conflict (delete vs edit).
      expect(result.conflicts, hasLength(1));
      expect(result.conflicts.single.entityId, 'p1');
    });

    test('remote-only change updates local without conflict', () {
      final local = SyncData(
        syncTimestamp: earlier,
        projects: [project(uuid: 'p1', title: 'Old', updatedAt: earlier)],
      );
      final remote = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'p1', title: 'New', updatedAt: later)],
      );

      final result = engine.merge(local, remote, lastSync);
      expect(result.conflicts, isEmpty);
      expect(result.merged.projects.single.title, 'New');
    });

    test('local-only tombstone is retained for upload (union of uuids)', () {
      final local = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'dead', title: 'Tombstone', updatedAt: later, deletedAt: later)],
      );
      final remote = SyncData(syncTimestamp: earlier, projects: const []);

      final result = engine.merge(local, remote, lastSync);
      expect(result.merged.projects, hasLength(1));
      expect(result.merged.projects.single.deletedAt, isNotNull);
    });

    test('tasks are ordered parents-before-children by depth', () {
      final local = SyncData(
        syncTimestamp: later,
        tasks: [
          task(uuid: 'child', title: 'Child', updatedAt: later, parentTaskUuid: 'parent', depth: 1),
          task(uuid: 'parent', title: 'Parent', updatedAt: later, depth: 0),
        ],
      );
      final remote = SyncData(syncTimestamp: earlier);

      final result = engine.merge(local, remote, lastSync);
      expect(result.merged.tasks.map((t) => t.uuid).toList(), ['parent', 'child']);
    });

    test('three-device convergence: A create, B edit, C tombstone → newest tombstone', () {
      // Device A created, B edited, C deleted last — C's tombstone should win.
      final deviceA = SyncData(
        syncTimestamp: earlier,
        projects: [project(uuid: 'conv', title: 'Created A', updatedAt: earlier)],
      );
      final deviceB = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'conv', title: 'Edited B', updatedAt: later)],
      );
      final deviceC = SyncData(
        syncTimestamp: muchLater,
        projects: [project(uuid: 'conv', title: 'Edited B', updatedAt: muchLater, deletedAt: muchLater)],
      );

      final ab = engine.merge(deviceA, deviceB, null);
      expect(ab.conflicts, isEmpty);
      expect(ab.merged.projects.single.title, 'Edited B');
      final abc = engine.merge(ab.merged, deviceC, earlier);
      expect(abc.conflicts, isEmpty);
      expect(abc.merged.projects.single.deletedAt, isNotNull);
    });

    test('three-device convergence: concurrent edits on B and C after shared base conflict', () {
      final shared = SyncData(
        syncTimestamp: earlier,
        projects: [project(uuid: 'conv', title: 'Base', updatedAt: earlier)],
      );
      final deviceB = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'conv', title: 'B', updatedAt: later)],
      );
      final deviceC = SyncData(
        syncTimestamp: later,
        projects: [project(uuid: 'conv', title: 'C', updatedAt: later.add(const Duration(minutes: 1)))],
      );

      final fromB = engine.merge(shared, deviceB, earlier);
      expect(fromB.conflicts, isEmpty);
      final fromC = engine.merge(fromB.merged, deviceC, earlier);
      expect(fromC.conflicts, hasLength(1));
      expect(fromC.conflicts.single.entityId, 'conv');
    });

    test('settings merge by key and ignore non-whitelisted keys', () {
      final local = SyncData(
        syncTimestamp: later,
        settings: [
          SyncSettingData(key: 'focus_duration_minutes', value: '25', updatedAt: earlier),
          SyncSettingData(key: 'device_id', value: 'local-device', updatedAt: later),
        ],
      );
      final remote = SyncData(
        syncTimestamp: later,
        settings: [
          SyncSettingData(key: 'focus_duration_minutes', value: '30', updatedAt: later),
          SyncSettingData(key: 'device_id', value: 'remote-device', updatedAt: later),
        ],
      );

      final result = engine.merge(local, remote, lastSync);
      expect(result.conflicts, isEmpty);
      expect(result.merged.settings.single.key, 'focus_duration_minutes');
      expect(result.merged.settings.single.value, '30');
    });

    test('SyncConflict.entityId is a String uuid', () {
      final conflict = SyncConflict(
        entityType: 'task',
        entityId: 'uuid-abc',
        entityTitle: 'T',
        localUpdatedAt: later,
        remoteUpdatedAt: muchLater,
      );
      expect(conflict.entityId, isA<String>());
      expect(conflict.entityId, 'uuid-abc');
    });
  });
}
