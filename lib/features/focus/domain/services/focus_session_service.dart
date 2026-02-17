import 'package:flutter/foundation.dart';

import '../../../tasks/domain/entities/task_extensions.dart';
import '../../../tasks/domain/repositories/i_task_repository.dart';
import '../entities/focus_session.dart';
import '../entities/focus_session_extensions.dart';
import '../entities/session_state.dart';
import '../repositories/i_focus_session_repository.dart';

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
  Future<FocusSession> startSession(FocusSession session) {
    return _sessionRepo.startSession(session);
  }

  /// Update an existing session in the database.
  Future<void> updateSession(FocusSession session) {
    return _sessionRepo.updateSession(session);
  }

  /// Finds any session that was left running / paused from a previous app run
  /// and marks it as **incomplete** (not "cancelled" — that's user-initiated).
  Future<void> cleanupAbandonedSessions({BigInt? currentSessionId}) async {
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
      }
    } catch (e) {
      debugPrint('Error cleaning up abandoned session: $e');
    }
  }

  /// Mark a task as completed. Used when the user finishes both
  /// the focus session and the associated task.
  Future<void> completeTask(BigInt taskId) async {
    try {
      final task = await _taskRepo.getTaskById(taskId);
      if (task != null && !task.isCompleted) {
        final completedTask = task.copyWith(isCompleted: true, updatedAt: DateTime.now());
        await _taskRepo.updateTask(completedTask);
      }
    } catch (e) {
      debugPrint('Error completing task: $e');
    }
  }
}
