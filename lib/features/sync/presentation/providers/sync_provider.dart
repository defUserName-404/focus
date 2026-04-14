import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sync_state.dart';
import '../../domain/services/i_cloud_storage_service.dart';
import '../../domain/services/sync_engine.dart';

part 'sync_provider.g.dart';

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
ICloudStorageService cloudStorageService(Ref ref) => getIt<ICloudStorageService>();

@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) => getIt<SyncEngine>();

// ---------------------------------------------------------------------------
// Sync state notifier
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class SyncNotifier extends _$SyncNotifier {
  late final SyncEngine _syncEngine;
  late final ICloudStorageService _cloudService;

  @override
  SyncState build() {
    _syncEngine = ref.watch(syncEngineProvider);
    _cloudService = ref.watch(cloudStorageServiceProvider);

    // Check initial sign-in state asynchronously.
    _initializeState();

    return const SyncState();
  }

  Future<void> _initializeState() async {
    final signedIn = await _cloudService.isSignedIn();
    if (signedIn) {
      final email = await _cloudService.getAccountEmail();
      final lastSyncedAt = await _syncEngine.getLastSyncedAt();
      state = state.copyWith(status: SyncStatus.idle, accountEmail: email, lastSyncedAt: lastSyncedAt);
    }
  }

  /// Sign in to Google Drive and update state.
  Future<void> signIn() async {
    final result = await _cloudService.signIn();
    switch (result) {
      case Success(:final value):
        final lastSyncedAt = await _syncEngine.getLastSyncedAt();
        state = state.copyWith(status: SyncStatus.idle, accountEmail: value, lastSyncedAt: lastSyncedAt);
      case Failure(:final failure):
        state = state.copyWith(status: SyncStatus.error, errorMessage: failure.message);
    }
  }

  /// Sign out from Google Drive.
  Future<void> signOut() async {
    final result = await _cloudService.signOut();
    switch (result) {
      case Success():
        state = const SyncState(status: SyncStatus.disconnected);
      case Failure(:final failure):
        state = state.copyWith(status: SyncStatus.error, errorMessage: failure.message);
    }
  }

  /// Trigger a sync operation.
  Future<void> sync() async {
    if (state.status == SyncStatus.syncing) return;

    state = state.copyWith(status: SyncStatus.syncing);

    final result = await _syncEngine.performSync();
    switch (result) {
      case Success(:final value):
        state = value;
      case Failure(:final failure):
        state = state.copyWith(status: SyncStatus.error, errorMessage: failure.message);
    }
  }

  /// Apply user's conflict resolutions and complete the sync.
  Future<void> applyResolutions(List<SyncConflict> resolvedConflicts) async {
    state = state.copyWith(status: SyncStatus.syncing);

    final result = await _syncEngine.applyResolutions(resolvedConflicts);
    switch (result) {
      case Success(:final value):
        state = value;
      case Failure(:final failure):
        state = state.copyWith(status: SyncStatus.error, errorMessage: failure.message);
    }
  }
}
