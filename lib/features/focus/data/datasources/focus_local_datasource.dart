import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/entities/session_state.dart';

abstract class IFocusLocalDataSource {
  Future<List<FocusSessionData>> getAllSessions();

  Future<FocusSessionData?> getSessionById(int id);

  Future<FocusSessionData?> getActiveSession();

  Future<int> createSession(FocusSessionTableCompanion companion);

  Future<void> updateSession(FocusSessionTableCompanion companion);

  Future<void> deleteSession(int id);

  Stream<List<FocusSessionData>> watchSessionsByTask(int taskId);

  Stream<List<FocusSessionData>> watchAllSessions();
}

class FocusLocalDataSourceImpl implements IFocusLocalDataSource {
  FocusLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  final _log = LogService.instance;

  @override
  Future<List<FocusSessionData>> getAllSessions() async {
    return await _db.select(_db.focusSessionTable).get();
  }

  @override
  Future<FocusSessionData?> getSessionById(int id) async {
    try {
      return await (_db.select(_db.focusSessionTable)..where((t) => t.id.equals(id))).getSingleOrNull();
    } catch (e, st) {
      _log.error('getSessionById failed', tag: 'FocusLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<FocusSessionData?> getActiveSession() async {
    final query = _db.select(_db.focusSessionTable)
      ..where((t) => t.state.isIn([SessionState.running.index, SessionState.paused.index, SessionState.onBreak.index]))
      ..limit(1);
    try {
      return await query.getSingleOrNull();
    } catch (e, st) {
      _log.error('getActiveSession failed', tag: 'FocusLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<int> createSession(FocusSessionTableCompanion companion) async {
    // Transaction ensures the session insert and daily stats recalc
    // are committed atomically, preventing watchers from seeing a
    // half-updated state (root cause of the today / overall mismatch).
    try {
      return await _db.transaction(() async {
        final id = await _db.into(_db.focusSessionTable).insert(companion);
        await _recalcForCompanion(companion);
        return id;
      });
    } catch (e, st) {
      _log.error('createSession failed', tag: 'FocusLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateSession(FocusSessionTableCompanion companion) async {
    try {
      await _db.transaction(() async {
        await (_db.update(_db.focusSessionTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
        await _recalcForCompanion(companion);
      });
    } catch (e, st) {
      _log.error('updateSession failed', tag: 'FocusLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteSession(int id) async {
    // Fetch the session first so we know which date to recalculate.
    try {
      final session = await getSessionById(id);
      await (_db.delete(_db.focusSessionTable)..where((t) => t.id.equals(id))).go();
      if (session != null) {
        await _db.recalculateDailyStatsForDate(session.startTime);
      }
    } catch (e, st) {
      _log.error('deleteSession failed', tag: 'FocusLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<FocusSessionData>> watchSessionsByTask(int taskId) {
    return (_db.select(_db.focusSessionTable)..where((t) => t.taskId.equals(taskId))).watch();
  }

  @override
  Stream<List<FocusSessionData>> watchAllSessions() {
    return _db.select(_db.focusSessionTable).watch();
  }

  /// Derives the session's start time from the companion and recalculates
  /// the daily stats row for that date.
  Future<void> _recalcForCompanion(FocusSessionTableCompanion companion) async {
    if (companion.startTime case final start when start.present) {
      await _db.recalculateDailyStatsForDate(start.value);
    }
  }
}
