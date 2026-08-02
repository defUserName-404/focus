import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../../../../core/config/google_oauth_config.dart';
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
///
/// Targets google_sign_in 7.x: singleton [GoogleSignIn.instance], explicit
/// [GoogleSignIn.initialize], and scope authorization via
/// [GoogleSignInAccount.authorizationClient].
class GoogleDriveService implements ICloudStorageService {
  static const _scopes = [drive.DriveApi.driveAppdataScope];
  static const _missingClientMessage =
      'Google Sign-In is not configured for this build. '
      'Set GOOGLE_CLIENT_ID (dart-define + Info.plist / GoogleSignIn.xcconfig). '
      'See .agents/docs/commands.md.';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? _account;
  drive.DriveApi? _driveApi;
  Future<void>? _initFuture;
  bool _listening = false;

  Future<void> _ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    await _googleSignIn.initialize(clientId: GoogleOAuthConfig.isConfigured ? GoogleOAuthConfig.clientId : null);
    if (_listening) return;
    _listening = true;
    _googleSignIn.authenticationEvents.listen((event) {
      switch (event) {
        case GoogleSignInAuthenticationEventSignIn(:final user):
          _account = user;
        case GoogleSignInAuthenticationEventSignOut():
          _account = null;
          _driveApi = null;
      }
    });
  }

  @override
  Future<Result<String>> signIn() async {
    if (!GoogleOAuthConfig.isConfigured) {
      _log.error(_missingClientMessage, tag: 'GoogleDriveService');
      return const Failure(SyncFailure(_missingClientMessage));
    }
    try {
      await _ensureInitialized();
      final account = await _googleSignIn.authenticate(scopeHint: _scopes);
      _account = account;
      // Reset cached API client so the new auth is used.
      _driveApi = null;
      _log.info('Google Drive sign-in successful: ${account.email}', tag: 'GoogleDriveService');
      return Success(account.email);
    } on GoogleSignInException catch (e, st) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Failure(SyncFailure('Sign-in was cancelled'));
      }
      _log.error('Google Drive sign-in failed', tag: 'GoogleDriveService', error: e, stackTrace: st);
      return Failure(SyncFailure('Failed to sign in to Google Drive', error: e, stackTrace: st));
    } catch (e, st) {
      _log.error('Google Drive sign-in failed', tag: 'GoogleDriveService', error: e, stackTrace: st);
      if (_isMissingGidClientError(e)) {
        return const Failure(SyncFailure(_missingClientMessage));
      }
      return Failure(SyncFailure('Failed to sign in to Google Drive', error: e, stackTrace: st));
    }
  }

  bool _isMissingGidClientError(Object error) {
    final text = error.toString();
    return text.contains('GIDClientID') || text.contains('No active configuration');
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    await _ensureInitialized();
    if (_driveApi != null) return _driveApi;

    var account = _account;
    if (account == null) {
      final lightweight = _googleSignIn.attemptLightweightAuthentication();
      if (lightweight != null) {
        account = await lightweight;
        _account = account;
      }
    }
    if (account == null) return null;

    final authz =
        await account.authorizationClient.authorizationForScopes(_scopes) ??
        await account.authorizationClient.authorizeScopes(_scopes);
    final client = authz.authClient(scopes: _scopes);
    _driveApi = drive.DriveApi(client);
    return _driveApi;
  }

  @override
  Future<bool> isSignedIn() async {
    if (!GoogleOAuthConfig.isConfigured) return false;
    await _ensureInitialized();
    if (_account != null) return true;
    final lightweight = _googleSignIn.attemptLightweightAuthentication();
    if (lightweight == null) return false;
    _account = await lightweight;
    return _account != null;
  }

  @override
  Future<String?> getAccountEmail() async {
    if (!GoogleOAuthConfig.isConfigured) return null;
    await _ensureInitialized();
    return _account?.email;
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
      _account = null;
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
