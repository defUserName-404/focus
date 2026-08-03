import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../domain/services/sync_backup_service.dart';
import '../providers/sync_provider.dart';

/// Local JSON backup export / restore controls for Settings.
class LocalBackupCard extends ConsumerWidget {
  const LocalBackupCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return fu.FCard(
      child: Padding(
        padding: context.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final result = await getIt<SyncBackupService>().exportToFile();
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        fu.showFToast(context: context, title: Text('Backup saved: $value'));
      case Failure(:final failure):
        if (failure.message == 'Export cancelled') return;
        fu.showFToast(context: context, title: Text(failure.message), variant: .destructive);
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final confirmed = await fu.showFDialog<bool>(
      context: context,
      builder: (ctx, _, _) => fu.FDialog(
        builder: (context, style) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              DefaultTextStyle(style: style.titleTextStyle, child: const Text('Replace local data?')),
              const SizedBox(height: 8),
              DefaultTextStyle(
                style: style.bodyTextStyle,
                child: const Text(
                  'Restoring a backup replaces projects, tasks, milestones, tags, '
                  'sessions, completions, and syncable settings on this device. '
                  'This cannot be undone.',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: .end,
                spacing: 8,
                children: [
                  fu.FButton(onPress: () => Navigator.of(ctx).pop(false), variant: .ghost, child: const Text('Cancel')),
                  fu.FButton(onPress: () => Navigator.of(ctx).pop(true), child: const Text('Replace')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await getIt<SyncBackupService>().importFromFile();
    if (!context.mounted) return;
    switch (result) {
      case Success():
        fu.showFToast(context: context, title: const Text('Backup restored'));
        ref.invalidate(syncProvider);
      case Failure(:final failure):
        if (failure.message == 'Import cancelled') return;
        fu.showFToast(context: context, title: Text(failure.message), variant: .destructive);
    }
  }
}
