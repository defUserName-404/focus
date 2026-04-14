import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../domain/entities/sync_state.dart';
import '../providers/sync_provider.dart';

/// Screen shown when sync detects conflicts that require user resolution.
///
/// For each conflict the user chooses "Keep Local" or "Keep Remote".
/// Once all conflicts are resolved, tapping "Apply" sends them to the
/// sync engine which completes the merge.
class SyncConflictScreen extends ConsumerStatefulWidget {
  final List<SyncConflict> conflicts;

  const SyncConflictScreen({super.key, required this.conflicts});

  @override
  ConsumerState<SyncConflictScreen> createState() => _SyncConflictScreenState();
}

class _SyncConflictScreenState extends ConsumerState<SyncConflictScreen> {
  late List<SyncConflict> _resolvedConflicts;

  @override
  void initState() {
    super.initState();
    _resolvedConflicts = List.from(widget.conflicts);
  }

  bool get _allResolved => _resolvedConflicts.every((c) => c.resolution != null);

  void _setResolution(int index, ConflictResolution resolution) {
    setState(() {
      _resolvedConflicts[index] = _resolvedConflicts[index].copyWith(resolution: resolution);
    });
  }

  Future<void> _applyResolutions() async {
    if (!_allResolved) return;
    await ref.read(syncProvider.notifier).applyResolutions(_resolvedConflicts);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolve Sync Conflicts'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppConstants.spacing.large),
            child: Text(
              'Both your device and the cloud have changes for the items below. '
              'Choose which version to keep for each item.',
              style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.large),
              itemCount: _resolvedConflicts.length,
              separatorBuilder: (context2, index2) => SizedBox(height: AppConstants.spacing.regular),
              itemBuilder: (context, index) {
                final conflict = _resolvedConflicts[index];
                return _ConflictCard(
                  conflict: conflict,
                  onKeepLocal: () => _setResolution(index, ConflictResolution.keepLocal),
                  onKeepRemote: () => _setResolution(index, ConflictResolution.keepRemote),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppConstants.spacing.large),
            child: SizedBox(
              width: double.infinity,
              child: fu.FButton(
                onPress: _allResolved ? _applyResolutions : null,
                child: const Text('Apply Resolutions'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  final SyncConflict conflict;
  final VoidCallback onKeepLocal;
  final VoidCallback onKeepRemote;

  const _ConflictCard({required this.conflict, required this.onKeepLocal, required this.onKeepRemote});

  @override
  Widget build(BuildContext context) {
    final isLocal = conflict.resolution == ConflictResolution.keepLocal;
    final isRemote = conflict.resolution == ConflictResolution.keepRemote;

    return fu.FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                conflict.entityType == 'project' ? fu.FIcons.folderOpen : fu.FIcons.squareCheck,
                size: AppConstants.size.icon.regular,
                color: context.colors.primary,
              ),
              SizedBox(width: AppConstants.spacing.regular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conflict.entityTitle,
                      style: context.typography.sm.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppConstants.spacing.extraSmall),
                    Text(
                      conflict.entityType == 'project' ? 'Project' : 'Task',
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Local', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
                    Text(conflict.localUpdatedAt.toDateTimeString(), style: context.typography.xs),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Remote', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
                    Text(conflict.remoteUpdatedAt.toDateTimeString(), style: context.typography.xs),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Row(
            children: [
              Expanded(
                child: fu.FButton(
                  style: isLocal ? fu.FButtonStyle.primary() : fu.FButtonStyle.outline(),
                  onPress: onKeepLocal,
                  child: const Text('Keep Local'),
                ),
              ),
              SizedBox(width: AppConstants.spacing.regular),
              Expanded(
                child: fu.FButton(
                  style: isRemote ? fu.FButtonStyle.primary() : fu.FButtonStyle.outline(),
                  onPress: onKeepRemote,
                  child: const Text('Keep Remote'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
