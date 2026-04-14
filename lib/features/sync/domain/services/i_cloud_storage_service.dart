import '../../../../core/utils/result.dart';
import '../entities/sync_data.dart';

/// Abstract interface for cloud storage providers (Google Drive, Dropbox, etc.).
///
/// Each implementation handles authentication and file operations
/// for its specific cloud service.
abstract class ICloudStorageService {
  /// Whether the user is currently signed in.
  Future<bool> isSignedIn();

  /// Get the signed-in user's email address.
  Future<String?> getAccountEmail();

  /// Sign in to the cloud service. Returns the account email on success.
  Future<Result<String>> signIn();

  /// Sign out from the cloud service.
  Future<Result<void>> signOut();

  /// Upload sync data to the cloud.
  Future<Result<void>> uploadSyncData(SyncData data);

  /// Download sync data from the cloud. Returns null if no data exists.
  Future<Result<SyncData?>> downloadSyncData();
}
