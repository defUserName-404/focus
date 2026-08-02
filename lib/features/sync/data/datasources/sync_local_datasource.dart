import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';
import '../../../projects/domain/entities/project_status.dart';
import '../../../session/domain/entities/session_state.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/domain/entities/task_reminder_mode.dart';
import '../../../tasks/domain/entities/task_status.dart';
import '../../domain/entities/sync_data.dart';

final _log = LogService.instance;

/// Bulk local read/write surface used exclusively by [SyncEngine].
///
/// Gather includes soft-deleted rows so tombstones can propagate. Apply
/// upserts by UUID and resolves peer references via UUID → local id maps.
abstract interface class ISyncLocalDataSource {
  Future<SyncData> gatherLocalData();

  /// Replace local sync-covered rows with [merged] (UUID upsert).
  ///
  /// Used after a successful merge and for local backup restore.
  Future<void> applyMergedData(SyncData merged);

  /// Wipe sync-covered tables then apply [merged]. Used by restore.
  Future<void> replaceAllWith(SyncData merged);
}

class SyncLocalDataSourceImpl implements ISyncLocalDataSource {
  SyncLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<SyncData> gatherLocalData() async {
    final projects = await _db.select(_db.projectTable).get();
    final milestones = await _db.select(_db.milestoneTable).get();
    final tags = await _db.select(_db.tagTable).get();
    final tasks = await _db.select(_db.taskTable).get();
    final taskTags = await _db.select(_db.taskTagTable).get();
    final completions = await _db.select(_db.taskCompletionTable).get();
    final sessions = await _db.select(_db.focusSessionTable).get();
    final settingsRows = await _db.select(_db.settingsTable).get();

    final projectIdToUuid = {for (final p in projects) p.id: p.uuid};
    final milestoneIdToUuid = {for (final m in milestones) m.id: m.uuid};
    final tagIdToUuid = {for (final t in tags) t.id: t.uuid};
    final taskIdToUuid = {for (final t in tasks) t.id: t.uuid};

    final settingsMap = {for (final s in settingsRows) s.key: s.value};

    return SyncData(
      schemaVersion: kSyncSchemaVersion,
      syncTimestamp: DateTime.now(),
      projects: [
        for (final p in projects)
          SyncProjectData(
            uuid: p.uuid,
            title: p.title,
            description: p.description,
            statusIndex: p.status.index,
            color: p.color,
            startDate: p.startDate,
            deadline: p.deadline,
            createdAt: p.createdAt,
            updatedAt: p.updatedAt,
            deletedAt: p.deletedAt,
          ),
      ],
      milestones: [
        for (final m in milestones)
          if (projectIdToUuid.containsKey(m.projectId))
            SyncMilestoneData(
              uuid: m.uuid,
              projectUuid: projectIdToUuid[m.projectId]!,
              title: m.title,
              targetDate: m.targetDate,
              createdAt: m.createdAt,
              updatedAt: m.updatedAt,
              deletedAt: m.deletedAt,
            ),
      ],
      tags: [
        for (final t in tags)
          SyncTagData(
            uuid: t.uuid,
            name: t.name,
            color: t.color,
            createdAt: t.createdAt,
            updatedAt: t.updatedAt,
            deletedAt: t.deletedAt,
          ),
      ],
      tasks: [
        for (final t in tasks)
          if (projectIdToUuid.containsKey(t.projectId))
            SyncTaskData(
              uuid: t.uuid,
              projectUuid: projectIdToUuid[t.projectId]!,
              parentTaskUuid: t.parentTaskId != null ? taskIdToUuid[t.parentTaskId!] : null,
              title: t.title,
              description: t.description,
              priorityIndex: t.priority.index,
              statusIndex: t.status.index,
              reminderModeIndex: t.reminderMode.index,
              customReminderMinutesBefore: t.customReminderMinutesBefore,
              startDate: t.startDate,
              endDate: t.endDate,
              depth: t.depth,
              estimatedMinutes: t.estimatedMinutes,
              sortOrder: t.sortOrder,
              milestoneUuid: t.milestoneId != null ? milestoneIdToUuid[t.milestoneId!] : null,
              recurrenceRuleJson: t.recurrenceRule,
              recurrenceAnchorDate: t.recurrenceAnchorDate,
              isHabit: t.isHabit,
              isCompleted: t.status == TaskStatus.done,
              createdAt: t.createdAt,
              updatedAt: t.updatedAt,
              deletedAt: t.deletedAt,
            ),
      ]..sort((a, b) => a.depth.compareTo(b.depth)),
      taskTags: [
        for (final link in taskTags)
          if (taskIdToUuid.containsKey(link.taskId) && tagIdToUuid.containsKey(link.tagId))
            SyncTaskTagData(
              uuid: link.uuid,
              taskUuid: taskIdToUuid[link.taskId]!,
              tagUuid: tagIdToUuid[link.tagId]!,
              createdAt: link.createdAt,
              updatedAt: link.updatedAt,
              deletedAt: link.deletedAt,
            ),
      ],
      completions: [
        for (final c in completions)
          if (taskIdToUuid.containsKey(c.taskId))
            SyncTaskCompletionData(
              uuid: c.uuid,
              taskUuid: taskIdToUuid[c.taskId]!,
              occurrenceDate: DateTime.parse(c.occurrenceDate),
              completedAt: c.completedAt,
              createdAt: c.createdAt,
              updatedAt: c.updatedAt,
              deletedAt: c.deletedAt,
            ),
      ],
      sessions: [
        for (final s in sessions)
          SyncFocusSessionData(
            uuid: s.uuid,
            taskUuid: s.taskId != null ? taskIdToUuid[s.taskId!] : null,
            focusDurationMinutes: s.focusDurationMinutes,
            breakDurationMinutes: s.breakDurationMinutes,
            startTime: s.startTime,
            endTime: s.endTime,
            stateIndex: s.state.index,
            elapsedSeconds: s.elapsedSeconds,
            focusPhaseEndedAt: s.focusPhaseEndedAt,
            createdAt: s.startTime,
            updatedAt: s.deletedAt ?? s.endTime ?? s.startTime,
            deletedAt: s.deletedAt,
          ),
      ],
      settings: [
        for (final key in kSyncableSettingsKeys)
          if (settingsMap.containsKey(key))
            SyncSettingData(
              key: key,
              value: settingsMap[key]!,
              updatedAt:
                  DateTime.tryParse(settingsMap[SettingsKeys.updatedAtKey(key)] ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
            ),
      ],
    );
  }

  @override
  Future<void> applyMergedData(SyncData merged) async {
    await _db.transaction(() async {
      await _upsertAll(merged);
    });
  }

  @override
  Future<void> replaceAllWith(SyncData merged) async {
    await _db.transaction(() async {
      await _db.delete(_db.taskTagTable).go();
      await _db.delete(_db.taskCompletionTable).go();
      await _db.delete(_db.focusSessionTable).go();
      await _db.delete(_db.taskTable).go();
      await _db.delete(_db.milestoneTable).go();
      await _db.delete(_db.tagTable).go();
      await _db.delete(_db.projectTable).go();
      // Clear only syncable settings (+ their clocks); leave device/desktop prefs.
      for (final key in kSyncableSettingsKeys) {
        await (_db.delete(_db.settingsTable)..where((t) => t.key.equals(key))).go();
        await (_db.delete(_db.settingsTable)..where((t) => t.key.equals(SettingsKeys.updatedAtKey(key)))).go();
      }
      await _upsertAll(merged);
    });
  }

  Future<void> _upsertAll(SyncData merged) async {
    final projectUuidToId = await _upsertProjects(merged.projects);
    final milestoneUuidToId = await _upsertMilestones(merged.milestones, projectUuidToId);
    final tagUuidToId = await _upsertTags(merged.tags);
    final taskUuidToId = await _upsertTasks(merged.tasks, projectUuidToId, milestoneUuidToId);
    await _upsertTaskTags(merged.taskTags, taskUuidToId, tagUuidToId);
    await _upsertCompletions(merged.completions, taskUuidToId);
    await _upsertSessions(merged.sessions, taskUuidToId);
    await _upsertSettings(merged.settings);
  }

  Future<Map<String, int>> _upsertProjects(List<SyncProjectData> projects) async {
    final existing = await _db.select(_db.projectTable).get();
    final byUuid = {for (final p in existing) p.uuid: p};
    final map = <String, int>{};

    for (final p in projects) {
      final status = _safeEnum(ProjectStatus.values, p.statusIndex, ProjectStatus.active);
      final current = byUuid[p.uuid];
      if (current == null) {
        final id = await _db
            .into(_db.projectTable)
            .insert(
              ProjectTableCompanion.insert(
                uuid: p.uuid,
                title: p.title,
                description: Value(p.description),
                status: Value(status),
                color: Value(p.color),
                startDate: Value(p.startDate),
                deadline: Value(p.deadline),
                createdAt: p.createdAt,
                updatedAt: p.updatedAt,
                deletedAt: Value(p.deletedAt),
              ),
            );
        map[p.uuid] = id;
      } else {
        await (_db.update(_db.projectTable)..where((t) => t.id.equals(current.id))).write(
          ProjectTableCompanion(
            title: Value(p.title),
            description: Value(p.description),
            status: Value(status),
            color: Value(p.color),
            startDate: Value(p.startDate),
            deadline: Value(p.deadline),
            createdAt: Value(p.createdAt),
            updatedAt: Value(p.updatedAt),
            deletedAt: Value(p.deletedAt),
          ),
        );
        map[p.uuid] = current.id;
      }
    }

    // Retain local-only projects in the id map for FK resolution of local-only children.
    for (final p in existing) {
      map.putIfAbsent(p.uuid, () => p.id);
    }
    return map;
  }

  Future<Map<String, int>> _upsertMilestones(
    List<SyncMilestoneData> milestones,
    Map<String, int> projectUuidToId,
  ) async {
    final existing = await _db.select(_db.milestoneTable).get();
    final byUuid = {for (final m in existing) m.uuid: m};
    final map = <String, int>{};

    for (final m in milestones) {
      final projectId = projectUuidToId[m.projectUuid];
      if (projectId == null) {
        _log.warning('Skipping milestone ${m.uuid}: missing project ${m.projectUuid}', tag: 'SyncLocalDS');
        continue;
      }
      final current = byUuid[m.uuid];
      if (current == null) {
        final id = await _db
            .into(_db.milestoneTable)
            .insert(
              MilestoneTableCompanion.insert(
                uuid: m.uuid,
                projectId: projectId,
                title: m.title,
                targetDate: Value(m.targetDate),
                createdAt: m.createdAt,
                updatedAt: m.updatedAt,
                deletedAt: Value(m.deletedAt),
              ),
            );
        map[m.uuid] = id;
      } else {
        await (_db.update(_db.milestoneTable)..where((t) => t.id.equals(current.id))).write(
          MilestoneTableCompanion(
            projectId: Value(projectId),
            title: Value(m.title),
            targetDate: Value(m.targetDate),
            createdAt: Value(m.createdAt),
            updatedAt: Value(m.updatedAt),
            deletedAt: Value(m.deletedAt),
          ),
        );
        map[m.uuid] = current.id;
      }
    }

    for (final m in existing) {
      map.putIfAbsent(m.uuid, () => m.id);
    }
    return map;
  }

  Future<Map<String, int>> _upsertTags(List<SyncTagData> tags) async {
    final existing = await _db.select(_db.tagTable).get();
    final byUuid = {for (final t in existing) t.uuid: t};
    final map = <String, int>{};

    for (final t in tags) {
      final current = byUuid[t.uuid];
      if (current == null) {
        final id = await _db
            .into(_db.tagTable)
            .insert(
              TagTableCompanion.insert(
                uuid: t.uuid,
                name: t.name,
                color: Value(t.color),
                createdAt: t.createdAt,
                updatedAt: t.updatedAt,
                deletedAt: Value(t.deletedAt),
              ),
            );
        map[t.uuid] = id;
      } else {
        await (_db.update(_db.tagTable)..where((t2) => t2.id.equals(current.id))).write(
          TagTableCompanion(
            name: Value(t.name),
            color: Value(t.color),
            createdAt: Value(t.createdAt),
            updatedAt: Value(t.updatedAt),
            deletedAt: Value(t.deletedAt),
          ),
        );
        map[t.uuid] = current.id;
      }
    }

    for (final t in existing) {
      map.putIfAbsent(t.uuid, () => t.id);
    }
    return map;
  }

  Future<Map<String, int>> _upsertTasks(
    List<SyncTaskData> tasks,
    Map<String, int> projectUuidToId,
    Map<String, int> milestoneUuidToId,
  ) async {
    final existing = await _db.select(_db.taskTable).get();
    final byUuid = {for (final t in existing) t.uuid: t};
    final map = {for (final t in existing) t.uuid: t.id};

    // Already sorted by depth in merge; still sort defensively.
    final ordered = [...tasks]..sort((a, b) => a.depth.compareTo(b.depth));

    for (final t in ordered) {
      final projectId = projectUuidToId[t.projectUuid];
      if (projectId == null) {
        _log.warning('Skipping task ${t.uuid}: missing project ${t.projectUuid}', tag: 'SyncLocalDS');
        continue;
      }
      final parentId = t.parentTaskUuid != null ? map[t.parentTaskUuid!] : null;
      final milestoneId = t.milestoneUuid != null ? milestoneUuidToId[t.milestoneUuid!] : null;
      final status = _safeEnum(TaskStatus.values, t.statusIndex, t.isCompleted ? TaskStatus.done : TaskStatus.todo);
      final priority = _safeEnum(TaskPriority.values, t.priorityIndex, TaskPriority.medium);
      final reminder = _safeEnum(TaskReminderMode.values, t.reminderModeIndex, TaskReminderMode.smart);
      final current = byUuid[t.uuid];

      if (current == null) {
        final id = await _db
            .into(_db.taskTable)
            .insert(
              TaskTableCompanion.insert(
                uuid: t.uuid,
                projectId: projectId,
                parentTaskId: Value(parentId),
                title: t.title,
                description: Value(t.description),
                priority: priority,
                status: Value(status),
                isCompleted: Value(status == TaskStatus.done),
                reminderMode: Value(reminder),
                customReminderMinutesBefore: Value(t.customReminderMinutesBefore),
                startDate: Value(t.startDate),
                endDate: Value(t.endDate),
                depth: t.depth,
                estimatedMinutes: Value(t.estimatedMinutes),
                sortOrder: Value(t.sortOrder),
                milestoneId: Value(milestoneId),
                recurrenceRule: Value(t.recurrenceRuleJson),
                recurrenceAnchorDate: Value(t.recurrenceAnchorDate),
                isHabit: Value(t.isHabit),
                createdAt: t.createdAt,
                updatedAt: t.updatedAt,
                deletedAt: Value(t.deletedAt),
              ),
            );
        map[t.uuid] = id;
      } else {
        await (_db.update(_db.taskTable)..where((row) => row.id.equals(current.id))).write(
          TaskTableCompanion(
            projectId: Value(projectId),
            parentTaskId: Value(parentId),
            title: Value(t.title),
            description: Value(t.description),
            priority: Value(priority),
            status: Value(status),
            isCompleted: Value(status == TaskStatus.done),
            reminderMode: Value(reminder),
            customReminderMinutesBefore: Value(t.customReminderMinutesBefore),
            startDate: Value(t.startDate),
            endDate: Value(t.endDate),
            depth: Value(t.depth),
            estimatedMinutes: Value(t.estimatedMinutes),
            sortOrder: Value(t.sortOrder),
            milestoneId: Value(milestoneId),
            recurrenceRule: Value(t.recurrenceRuleJson),
            recurrenceAnchorDate: Value(t.recurrenceAnchorDate),
            isHabit: Value(t.isHabit),
            createdAt: Value(t.createdAt),
            updatedAt: Value(t.updatedAt),
            deletedAt: Value(t.deletedAt),
          ),
        );
        map[t.uuid] = current.id;
      }
    }

    return map;
  }

  Future<void> _upsertTaskTags(
    List<SyncTaskTagData> links,
    Map<String, int> taskUuidToId,
    Map<String, int> tagUuidToId,
  ) async {
    final existing = await _db.select(_db.taskTagTable).get();
    final byUuid = {for (final l in existing) l.uuid: l};

    for (final link in links) {
      final taskId = taskUuidToId[link.taskUuid];
      final tagId = tagUuidToId[link.tagUuid];
      if (taskId == null || tagId == null) {
        _log.warning('Skipping task-tag ${link.uuid}: missing task/tag', tag: 'SyncLocalDS');
        continue;
      }

      final current = byUuid[link.uuid];
      if (current == null) {
        // May collide on (taskId, tagId) if uuid differs — revive/update that row.
        final byPair = existing.where((e) => e.taskId == taskId && e.tagId == tagId).firstOrNull;
        if (byPair != null) {
          await (_db.update(_db.taskTagTable)..where((t) => t.taskId.equals(taskId) & t.tagId.equals(tagId))).write(
            TaskTagTableCompanion(
              uuid: Value(link.uuid),
              createdAt: Value(link.createdAt),
              updatedAt: Value(link.updatedAt),
              deletedAt: Value(link.deletedAt),
            ),
          );
        } else {
          await _db
              .into(_db.taskTagTable)
              .insert(
                TaskTagTableCompanion.insert(
                  taskId: taskId,
                  tagId: tagId,
                  uuid: link.uuid,
                  createdAt: link.createdAt,
                  updatedAt: link.updatedAt,
                  deletedAt: Value(link.deletedAt),
                ),
              );
        }
      } else {
        await (_db.update(_db.taskTagTable)
              ..where((t) => t.taskId.equals(current.taskId) & t.tagId.equals(current.tagId)))
            .write(TaskTagTableCompanion(updatedAt: Value(link.updatedAt), deletedAt: Value(link.deletedAt)));
      }
    }
  }

  Future<void> _upsertCompletions(List<SyncTaskCompletionData> completions, Map<String, int> taskUuidToId) async {
    final existing = await _db.select(_db.taskCompletionTable).get();
    final byUuid = {for (final c in existing) c.uuid: c};

    for (final c in completions) {
      final taskId = taskUuidToId[c.taskUuid];
      if (taskId == null) continue;
      final occurrenceKey =
          '${c.occurrenceDate.year.toString().padLeft(4, '0')}-'
          '${c.occurrenceDate.month.toString().padLeft(2, '0')}-'
          '${c.occurrenceDate.day.toString().padLeft(2, '0')}';
      final current = byUuid[c.uuid];

      if (current == null) {
        await _db
            .into(_db.taskCompletionTable)
            .insert(
              TaskCompletionTableCompanion.insert(
                uuid: c.uuid,
                taskId: taskId,
                occurrenceDate: occurrenceKey,
                completedAt: c.completedAt,
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
                deletedAt: Value(c.deletedAt),
              ),
            );
      } else {
        await (_db.update(_db.taskCompletionTable)..where((t) => t.id.equals(current.id))).write(
          TaskCompletionTableCompanion(
            taskId: Value(taskId),
            occurrenceDate: Value(occurrenceKey),
            completedAt: Value(c.completedAt),
            createdAt: Value(c.createdAt),
            updatedAt: Value(c.updatedAt),
            deletedAt: Value(c.deletedAt),
          ),
        );
      }
    }
  }

  Future<void> _upsertSessions(List<SyncFocusSessionData> sessions, Map<String, int> taskUuidToId) async {
    final existing = await _db.select(_db.focusSessionTable).get();
    final byUuid = {for (final s in existing) s.uuid: s};

    for (final s in sessions) {
      final taskId = s.taskUuid != null ? taskUuidToId[s.taskUuid!] : null;
      final state = _safeEnum(SessionState.values, s.stateIndex, SessionState.completed);
      final current = byUuid[s.uuid];

      if (current == null) {
        await _db
            .into(_db.focusSessionTable)
            .insert(
              FocusSessionTableCompanion.insert(
                uuid: s.uuid,
                taskId: Value(taskId),
                focusDurationMinutes: s.focusDurationMinutes,
                breakDurationMinutes: s.breakDurationMinutes,
                startTime: s.startTime,
                endTime: Value(s.endTime),
                state: state,
                elapsedSeconds: Value(s.elapsedSeconds),
                focusPhaseEndedAt: Value(s.focusPhaseEndedAt),
                deletedAt: Value(s.deletedAt),
              ),
            );
      } else {
        await (_db.update(_db.focusSessionTable)..where((t) => t.id.equals(current.id))).write(
          FocusSessionTableCompanion(
            taskId: Value(taskId),
            focusDurationMinutes: Value(s.focusDurationMinutes),
            breakDurationMinutes: Value(s.breakDurationMinutes),
            startTime: Value(s.startTime),
            endTime: Value(s.endTime),
            state: Value(state),
            elapsedSeconds: Value(s.elapsedSeconds),
            focusPhaseEndedAt: Value(s.focusPhaseEndedAt),
            deletedAt: Value(s.deletedAt),
          ),
        );
      }
    }
  }

  Future<void> _upsertSettings(List<SyncSettingData> settings) async {
    for (final s in settings) {
      if (!kSyncableSettingsKeys.contains(s.key)) continue;
      await _db
          .into(_db.settingsTable)
          .insertOnConflictUpdate(SettingsTableCompanion.insert(key: s.key, value: s.value));
      await _db
          .into(_db.settingsTable)
          .insertOnConflictUpdate(
            SettingsTableCompanion.insert(key: SettingsKeys.updatedAtKey(s.key), value: s.updatedAt.toIso8601String()),
          );
    }
  }
}

T _safeEnum<T>(List<T> values, int index, T fallback) {
  if (index >= 0 && index < values.length) return values[index];
  return fallback;
}
