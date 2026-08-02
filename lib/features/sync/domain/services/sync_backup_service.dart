import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';
import '../entities/sync_data.dart';
import 'sync_engine.dart';

final _log = LogService.instance;

/// Local JSON backup / restore using the SyncData envelope.
class SyncBackupService {
  SyncBackupService(this._syncEngine);

  final SyncEngine _syncEngine;

  /// Export full SyncData-shaped bundle to a user-chosen file.
  Future<Result<String>> exportToFile() async {
    try {
      final data = await _syncEngine.exportLocalBackup();
      final json = const JsonEncoder.withIndent('  ').convert(data.toJson());
      final path = await FilePicker.saveFile(
        dialogTitle: 'Export Focus backup',
        fileName: 'focus_backup_${_timestamp()}.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: utf8.encode(json),
      );
      if (path == null) {
        return const Failure(SyncFailure('Export cancelled'));
      }
      // Desktop saveFile may return a path without writing bytes on some platforms.
      final file = File(path);
      if (!await file.exists() || await file.length() == 0) {
        await file.writeAsString(json);
      }
      _log.info('Backup exported to $path', tag: 'SyncBackup');
      return Success(path);
    } catch (e, st) {
      _log.error('Backup export failed', tag: 'SyncBackup', error: e, stackTrace: st);
      return Failure(SyncFailure('Failed to export backup', error: e, stackTrace: st));
    }
  }

  /// Import a SyncData JSON file. Caller must confirm before invoking —
  /// this **replaces** local sync-covered data.
  Future<Result<void>> importFromFile() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Import Focus backup',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return const Failure(SyncFailure('Import cancelled'));
      }
      final file = result.files.single;
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
      if (bytes == null) {
        return const Failure(SyncFailure('Could not read backup file'));
      }
      final data = SyncData.fromJsonString(utf8.decode(bytes));
      return _syncEngine.restoreFromBackup(data);
    } catch (e, st) {
      _log.error('Backup import failed', tag: 'SyncBackup', error: e, stackTrace: st);
      return Failure(SyncFailure('Failed to import backup', error: e, stackTrace: st));
    }
  }

  String _timestamp() {
    final n = DateTime.now();
    return '${n.year}${n.month.toString().padLeft(2, '0')}${n.day.toString().padLeft(2, '0')}_'
        '${n.hour.toString().padLeft(2, '0')}${n.minute.toString().padLeft(2, '0')}';
  }
}
