import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Represents the current status of the sync operation.
enum SyncStatus {
  /// Not connected to any cloud service.
  disconnected,

  /// Connected and idle.
  idle,

  /// Sync in progress.
  syncing,

  /// Sync completed successfully.
  success,

  /// Sync encountered an error.
  error,

  /// Conflicts detected that require user resolution.
  conflictsDetected,
}

/// Domain entity representing the current sync state.
@immutable
class SyncState extends Equatable {
  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;
  final String? accountEmail;
  final List<SyncConflict> conflicts;

  const SyncState({
    this.status = SyncStatus.disconnected,
    this.lastSyncedAt,
    this.errorMessage,
    this.accountEmail,
    this.conflicts = const [],
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncedAt,
    String? errorMessage,
    String? accountEmail,
    List<SyncConflict>? conflicts,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      accountEmail: accountEmail ?? this.accountEmail,
      conflicts: conflicts ?? this.conflicts,
    );
  }

  bool get isConnected => status != SyncStatus.disconnected;

  @override
  List<Object?> get props => [status, lastSyncedAt, errorMessage, accountEmail, conflicts];
}

/// Represents a sync conflict where both local and remote have changed.
@immutable
class SyncConflict extends Equatable {
  /// The unique identifier of the conflicting entity.
  final String entityType;
  final int entityId;
  final String entityTitle;

  /// When the local version was last updated.
  final DateTime localUpdatedAt;

  /// When the remote version was last updated.
  final DateTime remoteUpdatedAt;

  /// The user's resolution choice (null = unresolved).
  final ConflictResolution? resolution;

  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.entityTitle,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    this.resolution,
  });

  SyncConflict copyWith({ConflictResolution? resolution}) {
    return SyncConflict(
      entityType: entityType,
      entityId: entityId,
      entityTitle: entityTitle,
      localUpdatedAt: localUpdatedAt,
      remoteUpdatedAt: remoteUpdatedAt,
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  List<Object?> get props => [entityType, entityId, entityTitle, localUpdatedAt, remoteUpdatedAt, resolution];
}

/// How the user wants to resolve a conflict.
enum ConflictResolution {
  /// Keep the local version, overwrite remote.
  keepLocal,

  /// Keep the remote version, overwrite local.
  keepRemote,
}
