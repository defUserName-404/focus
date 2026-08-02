import '../../../../core/services/data_change_bus.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/focus_session_extensions.dart';
import '../../domain/repositories/i_focus_session_repository.dart';
import '../datasources/focus_local_datasource.dart';
import '../mappers/focus_session_mappers.dart';

final _log = LogService.instance;

class FocusSessionRepositoryImpl implements IFocusSessionRepository {
  final IFocusLocalDataSource _local;
  final DataChangeBus? _dataChangeBus;

  FocusSessionRepositoryImpl(this._local, [this._dataChangeBus]);

  void _emitChange() => _dataChangeBus?.notify();

  @override
  Future<FocusSession> startSession(FocusSession session) async {
    try {
      final companion = session.toCompanion();
      final id = await _local.createSession(companion);
      final saved = session.copyWith(id: id);
      _log.debug('Session persisted (id=$id)', tag: 'FocusSessionRepository');
      _emitChange();
      return saved;
    } catch (e, st) {
      _log.error('Failed to persist session', tag: 'FocusSessionRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateSession(FocusSession session) async {
    if (session.id == null) return;
    try {
      final companion = session.toCompanion();
      await _local.updateSession(companion);
      _emitChange();
    } catch (e, st) {
      _log.error(
        'Failed to update session (id=${session.id})',
        tag: 'FocusSessionRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<FocusSession?> getActiveSession() async {
    try {
      final data = await _local.getActiveSession();
      return data?.toDomain();
    } catch (e, st) {
      _log.error('Failed to query active session', tag: 'FocusSessionRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<FocusSession>> watchSessionsByTask(int taskId) {
    return _local.watchSessionsByTask(taskId).map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<FocusSession>> watchAllSessions() {
    return _local.watchAllSessions().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<void> deleteSession(int id) async {
    try {
      await _local.deleteSession(id);
      _emitChange();
    } catch (e, st) {
      _log.error('Failed to delete session (id=$id)', tag: 'FocusSessionRepository', error: e, stackTrace: st);
      rethrow;
    }
  }
}
