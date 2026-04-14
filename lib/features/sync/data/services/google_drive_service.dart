import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sync_data.dart';
import '../../domain/services/i_cloud_storage_service.dart';

final _log = LogService.instance;

/// The filename used for sync data in Google Drive's appDataFolder.
const _syncFileName = 'focus_sync_data.json';

/// Google Drive implementation of [ICloudStorageService].
///
/// Uses the appDataFolder space so the sync file is hidden from the user's
/// normal Drive view. Requires the `drive.appdata` scope.
class GoogleDriveService implements ICloudStorageService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]);

  drive.DriveApi? _driveApi;

  Future<drive.DriveApi?> _getDriveApi() async {
    if (_driveApi != null) return _driveApi;

    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) return null;

    _driveApi = drive.DriveApi(httpClient);
    return _driveApi;
  }

  @override
  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  @override
  Future<String?> getAccountEmail() async {
    final account = _googleSignIn.currentUser;
    return account?.email;
  }

  @override
  Future<Result<String>> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return const Failure(SyncFailure('Sign-in was cancelled'));
      }
      // Reset cached API client so the new auth is used.
      _driveApi = null;
      _log.info('Google Drive sign-in successful: ${account.email}', tag: 'GoogleDriveService');
      return Success(account.email);
    } catch (e, st) {
      _log.error('Google Drive sign-in failed', tag: 'GoogleDriveService', error: e, stackTrace: st);
      return Failure(SyncFailure('Failed to sign in to Google Drive', error: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      _driveApi = null;
      _log.info('Google Drive sign-out successful', tag: 'GoogleDriveService');
      return const Success(null);
    } catch (e, st) {
      _log.error('Google Drive sign-out failed', tag: 'GoogleDriveService', error: e, stackTrace: st);
      return Failure(SyncFailure('Failed to sign out', error: e, stackTrace: st));
    }
  }

  @override
  Future<Result<void>> uploadSyncData(SyncData data) async {
    try {
      final api = await _getDriveApi();
      if (api == null) {
        return const Failure(SyncFailure('Not signed in to Google Drive'));
      }

      final content = data.toJsonString();
      final mediaStream = http.ByteStream.fromBytes(utf8.encode(content));
      final mediaLength = utf8.encode(content).length;

      final media = drive.Media(mediaStream, mediaLength);

      // Check if the file already exists.
      final existingFileId = await _findSyncFileId(api);

      if (existingFileId != null) {
        // Update existing file.
        await api.files.update(drive.File(), existingFileId, uploadMedia: media);
        _log.info('Sync data updated on Google Drive', tag: 'GoogleDriveService');
      } else {
        // Create new file in appDataFolder.
        final driveFile = drive.File()
          ..name = _syncFileName
          ..parents = ['appDataFolder'];
        await api.files.create(driveFile, uploadMedia: media);
        _log.info('Sync data created on Google Drive', tag: 'GoogleDriveService');
      }

      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to upload sync data', tag: 'GoogleDriveService', error: e, stackTrace: st);
      return Failure(SyncFailure('Failed to upload sync data', error: e, stackTrace: st));
    }
  }

  @override
  Future<Result<SyncData?>> downloadSyncData() async {
    try {
      final api = await _getDriveApi();
      if (api == null) {
        return const Failure(SyncFailure('Not signed in to Google Drive'));
      }

      final fileId = await _findSyncFileId(api);
      if (fileId == null) {
        _log.info('No sync data found on Google Drive', tag: 'GoogleDriveService');
        return const Success(null);
      }

      final response = await api.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      final bytes = <int>[];
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
      }

      final jsonString = utf8.decode(bytes);
      final syncData = SyncData.fromJsonString(jsonString);

      _log.info(
        'Sync data downloaded: ${syncData.projects.length} projects, ${syncData.tasks.length} tasks',
        tag: 'GoogleDriveService',
      );
      return Success(syncData);
    } catch (e, st) {
      _log.error('Failed to download sync data', tag: 'GoogleDriveService', error: e, stackTrace: st);
      return Failure(SyncFailure('Failed to download sync data', error: e, stackTrace: st));
    }
  }

  /// Find the file ID of the sync data file in appDataFolder.
  Future<String?> _findSyncFileId(drive.DriveApi api) async {
    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_syncFileName'",
        $fields: 'files(id, name)',
      );
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }
      return null;
    } catch (e, st) {
      _log.warning('Failed to search for sync file', tag: 'GoogleDriveService', error: e, stackTrace: st);
      return null;
    }
  }
}
