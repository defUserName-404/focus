import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/i_focus_session_repository.dart';

class FocusSessionRepositoryImpl implements IFocusSessionRepository {
  final AppDatabase _db;

  FocusSessionRepositoryImpl(this._db);

  @override
  Future<FocusSession> startSession(FocusSession session) async {
    final companion = _toCompanion(session);
    final id = await _db.into(_db.focusSessionTable).insert(companion);
    return session.copyWith(id: BigInt.from(id));
  }

  @override
  Future<void> updateSession(FocusSession session) async {
    if (session.id == null) return;
    final companion = _toCompanion(session);
    await (_db.update(
      _db.focusSessionTable,
    )..where((t) => t.id.equals(session.id!))).write(companion);
  }

  @override
  Future<FocusSession?> getActiveSession() async {
    final query = _db.select(_db.focusSessionTable)
      ..where(
        (t) => t.state.isIn([
          SessionState.running.index,
          SessionState.paused.index,
          SessionState.onBreak.index,
        ]),
      )
      ..limit(1);

    final data = await query.getSingleOrNull();
    return data != null ? _toEntity(data) : null;
  }

  @override
  Stream<List<FocusSession>> watchSessionsByTask(BigInt taskId) {
    return (_db.select(_db.focusSessionTable)
          ..where((t) => t.taskId.equals(taskId)))
        .watch()
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Stream<List<FocusSession>> watchAllSessions() {
    return _db
        .select(_db.focusSessionTable)
        .watch()
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Future<void> deleteSession(BigInt id) async {
    await (_db.delete(
      _db.focusSessionTable,
    )..where((t) => t.id.equals(id))).go();
  }

  FocusSession _toEntity(FocusSessionData data) {
    return FocusSession(
      id: data.id,
      taskId: data.taskId,
      focusDurationMinutes: data.focusDurationMinutes,
      breakDurationMinutes: data.breakDurationMinutes,
      startTime: data.startTime,
      endTime: data.endTime,
      state: data.state,
      elapsedSeconds: data.elapsedSeconds,
    );
  }

  FocusSessionTableCompanion _toCompanion(FocusSession session) {
    return FocusSessionTableCompanion(
      taskId: Value(session.taskId),
      focusDurationMinutes: Value(session.focusDurationMinutes),
      breakDurationMinutes: Value(session.breakDurationMinutes),
      startTime: Value(session.startTime),
      endTime: Value(session.endTime),
      state: Value(session.state),
      elapsedSeconds: Value(session.elapsedSeconds),
    );
  }
}
