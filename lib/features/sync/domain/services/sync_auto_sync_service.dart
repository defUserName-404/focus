import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../core/services/data_change_bus.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';
import '../entities/sync_state.dart';
import 'i_cloud_storage_service.dart';
import 'sync_engine.dart';

final _log = LogService.instance;

/// Drives automatic sync on app lifecycle events and debounced mutations.
class SyncAutoSyncService with WidgetsBindingObserver {
  SyncAutoSyncService({
    required SyncEngine syncEngine,
    required ICloudStorageService cloudService,
    required DataChangeBus dataChangeBus,
    this.mutationDebounce = const Duration(seconds: 8),
  }) : _syncEngine = syncEngine,
       _cloudService = cloudService,
       _dataChangeBus = dataChangeBus;

  final SyncEngine _syncEngine;
  final ICloudStorageService _cloudService;
  final DataChangeBus _dataChangeBus;
  final Duration mutationDebounce;

  Timer? _debounceTimer;
  bool _syncInFlight = false;
  bool _initialized = false;

  /// Optional callback so UI notifiers can mirror sync results.
  void Function(SyncState state)? onStateChanged;

  void init() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    _dataChangeBus.addListener(scheduleDebouncedSync);
    _log.info('Auto-sync service initialized', tag: 'SyncAutoSync');
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dataChangeBus.removeListener(scheduleDebouncedSync);
    _debounceTimer?.cancel();
    _initialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(triggerSync(reason: 'foreground'));
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        unawaited(triggerSync(reason: 'background'));
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Debounce a sync after a local mutation batch.
  void scheduleDebouncedSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(mutationDebounce, () {
      unawaited(triggerSync(reason: 'mutation'));
    });
  }

  /// Run an automatic sync when enabled + signed in.
  Future<void> triggerSync({required String reason}) async {
    if (_syncInFlight) return;
    try {
      if (!await _cloudService.isSignedIn()) return;
      if (!await _syncEngine.isSyncEnabled()) return;

      _syncInFlight = true;
      _log.info('Auto-sync triggered ($reason)', tag: 'SyncAutoSync');
      final result = await _syncEngine.performSync();
      switch (result) {
        case Success(:final value):
          onStateChanged?.call(value);
        case Failure(:final failure):
          _log.warning('Auto-sync failed: ${failure.message}', tag: 'SyncAutoSync');
          onStateChanged?.call(SyncState(status: SyncStatus.error, errorMessage: failure.message));
      }
    } catch (e, st) {
      _log.error('Auto-sync crashed', tag: 'SyncAutoSync', error: e, stackTrace: st);
    } finally {
      _syncInFlight = false;
    }
  }
}
