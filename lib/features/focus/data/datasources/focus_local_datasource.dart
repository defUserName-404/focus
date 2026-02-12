import '../../../../core/services/db_service.dart';
import '../../domain/entities/session_state.dart';

abstract class IFocusLocalDataSource {
  Future<List<FocusSessionData>> getAllSessions();

  Future<FocusSessionData?> getSessionById(BigInt id);

  Future<FocusSessionData?> getActiveSession();

  Future<int> createSession(FocusSessionTableCompanion companion);

  Future<void> updateSession(FocusSessionTableCompanion companion);

  Future<void> deleteSession(BigInt id);

  Stream<List<FocusSessionData>> watchSessionsByTask(BigInt taskId);

  Stream<List<FocusSessionData>> watchAllSessions();
}

class FocusLocalDataSourceImpl implements IFocusLocalDataSource {
  FocusLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<FocusSessionData>> getAllSessions() async {
    return await _db.select(_db.focusSessionTable).get();
  }

  @override
  Future<FocusSessionData?> getSessionById(BigInt id) async {
    return await (_db.select(_db.focusSessionTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<FocusSessionData?> getActiveSession() async {
    final query = _db.select(_db.focusSessionTable)
      ..where((t) => t.state.isIn([SessionState.running.index, SessionState.paused.index, SessionState.onBreak.index]))
      ..limit(1);

    return await query.getSingleOrNull();
  }

  @override
  Future<int> createSession(FocusSessionTableCompanion companion) async {
    return await _db.into(_db.focusSessionTable).insert(companion);
  }

  @override
  Future<void> updateSession(FocusSessionTableCompanion companion) async {
    await (_db.update(_db.focusSessionTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
  }

  @override
  Future<void> deleteSession(BigInt id) async {
    await (_db.delete(_db.focusSessionTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Stream<List<FocusSessionData>> watchSessionsByTask(BigInt taskId) {
    return (_db.select(_db.focusSessionTable)..where((t) => t.taskId.equals(taskId))).watch();
  }

  @override
  Stream<List<FocusSessionData>> watchAllSessions() {
    return _db.select(_db.focusSessionTable).watch();
  }
}
