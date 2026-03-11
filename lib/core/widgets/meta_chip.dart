import 'package:flutter/material.dart';

import '../../config/theme/app_theme.dart';
import '../../constants/app_constants.dart';

/// A compact icon + label chip used for metadata display (e.g. project name,
/// dates). Reusable across task detail, project detail, and any summary UI.
class MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;

  const MetaChip({super.key, required this.icon, required this.label, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? context.colors.destructive : context.colors.mutedForeground;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppConstants.size.icon.extraSmall, color: color),
        SizedBox(width: AppConstants.spacing.small),
        Flexible(
          child: Text(
            label,
            style: context.typography.xs.copyWith(color: color),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
