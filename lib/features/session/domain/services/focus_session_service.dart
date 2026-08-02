import '../../../../core/services/log_service.dart';
import '../../../../core/utils/id_utils.dart';
import '../../../../core/utils/result.dart';
import '../../../tasks/domain/entities/task_completion.dart';
import '../../../tasks/domain/entities/task_extensions.dart';
import '../../../tasks/domain/entities/task_status.dart';
import '../../../tasks/domain/repositories/i_task_repository.dart';
import '../entities/focus_session.dart';
import '../entities/focus_session_extensions.dart';
import '../entities/session_state.dart';
import '../repositories/i_focus_session_repository.dart';

final _log = LogService.instance;

/// Service layer between [FocusTimer] and the data layer.
///
/// Encapsulates all repository interactions so the presentation layer
/// never calls repositories directly. Handles:
/// - Session persistence (start / update)
/// - Abandoned session cleanup
/// - Cross-feature task completion
class FocusSessionService {
  final IFocusSessionRepository _sessionRepo;
  final ITaskRepository _taskRepo;

  FocusSessionService(this._sessionRepo, this._taskRepo);

  /// Persist a new session to the database.
  /// Returns the saved session (with generated ID).
  Future<Result<FocusSession>> startSession(FocusSession session) async {
    try {
      final saved = await _sessionRepo.startSession(session);

      // Auto-move linked task to In Progress if it's currently To Do.
      if (saved.taskId != null) {
        final task = await _taskRepo.getTaskById(saved.taskId!);
        if (task != null && task.status == TaskStatus.todo) {
          await _taskRepo.updateTask(task.copyWith(status: TaskStatus.inProgress, updatedAt: DateTime.now()));
        }
      }

      _log.info('Session started (id=${saved.id})', tag: 'FocusSessionService');
      return Success(saved);
    } catch (e, st) {
      _log.error('Failed to start session', tag: 'FocusSessionService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to start session', error: e, stackTrace: st));
    }
  }

  /// Update an existing session in the database.
  Future<Result<void>> updateSession(FocusSession session) async {
    try {
      await _sessionRepo.updateSession(session);
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to update session (id=${session.id})', tag: 'FocusSessionService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to update session', error: e, stackTrace: st));
    }
  }

  /// Finds any session that was left running / paused from a previous app run
  /// and marks it as **incomplete** (not "cancelled" — that's user-initiated).
  Future<void> cleanupAbandonedSessions({int? currentSessionId}) async {
    try {
      final active = await _sessionRepo.getActiveSession();
      if (active == null) return;

      // Don't touch the user's current in-memory session.
      if (currentSessionId != null && active.id == currentSessionId) return;

      if (active.state == SessionState.running ||
          active.state == SessionState.onBreak ||
          active.state == SessionState.paused) {
        final updated = active.copyWith(state: SessionState.incomplete, endTime: DateTime.now());
        await _sessionRepo.updateSession(updated);
        _log.info('Marked abandoned session ${active.id} as incomplete', tag: 'FocusSessionService');
      }
    } catch (e, st) {
      _log.error('Error cleaning up abandoned session', tag: 'FocusSessionService', error: e, stackTrace: st);
    }
  }

  /// Mark a task as completed. Used when the user finishes both
  /// the focus session and the associated task.
  Future<Result<void>> completeTask(int taskId) async {
    try {
      final task = await _taskRepo.getTaskById(taskId);
      if (task == null || task.isCompleted) return const Success(null);

      // For recurring tasks/habits, record a per-day completion instead of
      // flipping the task row status (which would complete all occurrences).
      if (task.isRecurring) {
        final now = DateTime.now();
        final dateOnly = DateTime(now.year, now.month, now.day);
        await _taskRepo.upsertCompletion(
          TaskCompletion(
            uuid: generateUuid(),
            taskId: taskId,
            occurrenceDate: dateOnly,
            completedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        final completedTask = task.copyWith(status: TaskStatus.done, updatedAt: DateTime.now());
        await _taskRepo.updateTask(completedTask);
      }

      _log.info('Task $taskId marked as completed', tag: 'FocusSessionService');
      return const Success(null);
    } catch (e, st) {
      _log.error('Error completing task $taskId', tag: 'FocusSessionService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to complete task', error: e, stackTrace: st));
    }
  }
}
