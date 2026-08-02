import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/project_template.dart';
import '../providers/project_template_provider.dart';

/// Compact picker for built-in and user templates on the create-project form.
class ProjectTemplatePicker extends ConsumerWidget {
  final ProjectTemplate? selected;
  final ValueChanged<ProjectTemplate?> onChanged;

  const ProjectTemplatePicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(projectTemplatesProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (templates) {
        if (templates.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Template', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: AppConstants.spacing.small),
            Wrap(
              spacing: AppConstants.spacing.small,
              runSpacing: AppConstants.spacing.small,
              children: [
                _Chip(label: 'Blank', selected: selected == null, onPress: () => onChanged(null)),
                for (final template in templates)
                  _Chip(
                    label: template.name,
                    selected: selected?.uuid == template.uuid,
                    builtin: template.isBuiltin,
                    onPress: () => onChanged(template),
                  ),
              ],
            ),
            if (selected?.description != null) ...[
              SizedBox(height: AppConstants.spacing.small),
              Text(
                selected!.description!,
                style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool builtin;
  final VoidCallback onPress;

  const _Chip({required this.label, required this.selected, required this.onPress, this.builtin = false});

  @override
  Widget build(BuildContext context) {
    return fu.FButton(
      size: .sm,
      mainAxisSize: .min,
      variant: selected ? .secondary : .outline,
      onPress: onPress,
      child: Text(builtin ? '$label · built-in' : label, style: context.typography.xs),
    );
  }
}
