import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:forui/forui.dart' as fu;

import '../providers/project_provider.dart';

class ProjectProgressBar extends ConsumerWidget {
  final String projectId;

  const ProjectProgressBar({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(projectProgressProvider(projectId));

    return progressAsync.maybeWhen(
      data: (progress) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(progress.label, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
              Text(
                '${progress.percent}%',
                style: context.typography.xs.copyWith(
                  fontWeight: FontWeight.w600,
                  color: progress.percent == 100 ? context.colors.primary : context.colors.foreground,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.spacing.extraSmall),
          fu.FDeterminateProgress(value: progress.progress),
        ],
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
