import '../../domain/entities/focus_session.dart';
import '../../domain/entities/focus_session_extensions.dart';
import '../../domain/repositories/i_focus_session_repository.dart';
import '../datasources/focus_local_datasource.dart';
import '../mappers/focus_session_mappers.dart';

class FocusSessionRepositoryImpl implements IFocusSessionRepository {
  final IFocusLocalDataSource _local;

  FocusSessionRepositoryImpl(this._local);

  @override
  Future<FocusSession> startSession(FocusSession session) async {
    final companion = session.toCompanion();
    final id = await _local.createSession(companion);
    return session.copyWith(id: BigInt.from(id));
  }

  @override
  Future<void> updateSession(FocusSession session) async {
    if (session.id == null) return;
    final companion = session.toCompanion();
    await _local.updateSession(companion);
  }

  @override
  Future<FocusSession?> getActiveSession() async {
    final data = await _local.getActiveSession();
    return data?.toDomain();
  }

  @override
  Stream<List<FocusSession>> watchSessionsByTask(BigInt taskId) {
    return _local.watchSessionsByTask(taskId).map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Stream<List<FocusSession>> watchAllSessions() {
    return _local.watchAllSessions().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<void> deleteSession(BigInt id) async {
    await _local.deleteSession(id);
  }
}
