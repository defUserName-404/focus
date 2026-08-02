import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sync_state.dart';
import '../../domain/services/sync_backup_service.dart';
import '../providers/sync_provider.dart';

/// Card widget shown in Settings that displays sync status and controls.
class SyncSettingsCard extends ConsumerWidget {
  const SyncSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final syncEnabledAsync = ref.watch(syncEnabledProvider);

    return fu.FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(fu.FLucideIcons.cloud, size: AppConstants.size.icon.regular, color: context.colors.primary),
              SizedBox(width: AppConstants.spacing.regular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Google Drive Sync', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: AppConstants.spacing.extraSmall),
                    Text(
                      _statusText(syncState),
                      style: context.typography.xs.copyWith(color: _statusColor(context, syncState)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (syncState.accountEmail != null) ...[
            SizedBox(height: AppConstants.spacing.regular),
            Text(syncState.accountEmail!, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
          ],
          if (syncState.lastSyncedAt != null) ...[
            SizedBox(height: AppConstants.spacing.small),
            Text(
              'Last synced: ${syncState.lastSyncedAt!.toDateTimeString()}',
              style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
            ),
          ],
          if (syncState.errorMessage != null) ...[
            SizedBox(height: AppConstants.spacing.small),
            Text(
              syncState.errorMessage!,
              style: context.typography.xs.copyWith(color: context.colors.destructive),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (syncState.isConnected) ...[
            SizedBox(height: AppConstants.spacing.regular),
            Row(
              children: [
                Expanded(child: Text('Auto sync', style: context.typography.sm)),
                fu.FSwitch(
                  value: syncEnabledAsync.value ?? true,
                  onChange: (enabled) => ref.read(syncProvider.notifier).setSyncEnabled(enabled),
                ),
              ],
            ),
          ],
          SizedBox(height: AppConstants.spacing.regular),
          if (!syncState.isConnected)
            SizedBox(
              width: double.infinity,
              child: fu.FButton(
                onPress: () => ref.read(syncProvider.notifier).signIn(),
                child: const Text('Sign In with Google'),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: fu.FButton(
                    onPress: syncState.status == SyncStatus.syncing
                        ? null
                        : () async {
                            await ref.read(syncProvider.notifier).sync();
                            final updatedState = ref.read(syncProvider);
                            if (updatedState.status == SyncStatus.conflictsDetected && context.mounted) {
                              context.push(AppRoutes.syncConflicts.path, extra: updatedState.conflicts);
                            }
                          },
                    child: syncState.status == SyncStatus.syncing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Sync Now'),
                  ),
                ),
                SizedBox(width: AppConstants.spacing.regular),
                fu.FButton(
                  variant: .outline,
                  onPress: () => ref.read(syncProvider.notifier).signOut(),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          SizedBox(height: AppConstants.spacing.regular),
          Text('Local backup', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: AppConstants.spacing.small),
          Text(
            'Export or replace all projects, tasks, sessions, and syncable settings as JSON.',
            style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Row(
            children: [
              Expanded(
                child: fu.FButton(
                  variant: .outline,
                  onPress: () => _exportBackup(context),
                  child: const Text('Export backup'),
                ),
              ),
              SizedBox(width: AppConstants.spacing.regular),
              Expanded(
                child: fu.FButton(
                  variant: .outline,
                  onPress: () => _importBackup(context, ref),
                  child: const Text('Restore backup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final result = await getIt<SyncBackupService>().exportToFile();
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved: $value')));
      case Failure(:final failure):
        if (failure.message == 'Export cancelled') return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace local data?'),
        content: const Text(
          'Restoring a backup replaces projects, tasks, milestones, tags, '
          'sessions, completions, and syncable settings on this device. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Replace')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await getIt<SyncBackupService>().importFromFile();
    if (!context.mounted) return;
    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup restored')));
        ref.invalidate(syncProvider);
      case Failure(:final failure):
        if (failure.message == 'Import cancelled') return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  String _statusText(SyncState state) {
    return switch (state.status) {
      SyncStatus.disconnected => 'Not connected',
      SyncStatus.idle => 'Connected',
      SyncStatus.syncing => 'Syncing...',
      SyncStatus.success => 'Sync complete',
      SyncStatus.error => 'Sync error',
      SyncStatus.conflictsDetected => 'Conflicts detected',
    };
  }

  Color _statusColor(BuildContext context, SyncState state) {
    return switch (state.status) {
      SyncStatus.disconnected => context.colors.mutedForeground,
      SyncStatus.idle => context.colors.primary,
      SyncStatus.syncing => context.colors.primary,
      SyncStatus.success => context.colors.primary,
      SyncStatus.error => context.colors.destructive,
      SyncStatus.conflictsDetected => Colors.orange,
    };
  }
}
