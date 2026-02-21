import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';

abstract class ISettingsLocalDataSource {
  Future<String?> getValue(String key);

  Future<void> setValue(String key, String value);

  Stream<String?> watchValue(String key);

  Future<Map<String, String>> getAll();

  Stream<Map<String, String>> watchAll();
}

class SettingsLocalDataSourceImpl implements ISettingsLocalDataSource {
  SettingsLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  final _log = LogService.instance;

  @override
  Future<String?> getValue(String key) async {
    try {
      final row = await (_db.select(_db.settingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
      return row?.value;
    } catch (e, st) {
      _log.error('getValue failed', tag: 'SettingsLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> setValue(String key, String value) async {
    try {
      await _db.into(_db.settingsTable).insertOnConflictUpdate(SettingsTableCompanion.insert(key: key, value: value));
    } catch (e, st) {
      _log.error('setValue failed', tag: 'SettingsLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<String?> watchValue(String key) {
    return (_db.select(
      _db.settingsTable,
    )..where((t) => t.key.equals(key))).watchSingleOrNull().map((row) => row?.value);
  }

  @override
  Future<Map<String, String>> getAll() async {
    try {
      final rows = await _db.select(_db.settingsTable).get();
      return {for (final row in rows) row.key: row.value};
    } catch (e, st) {
      _log.error('getAll failed', tag: 'SettingsLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<Map<String, String>> watchAll() {
    return _db.select(_db.settingsTable).watch().map((rows) => {for (final row in rows) row.key: row.value});
  }
}
