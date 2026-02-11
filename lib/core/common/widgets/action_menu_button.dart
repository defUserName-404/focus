import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;

class ActionMenuButton extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String editLabel;
  final String deleteLabel;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final PopupMenuPosition? position;

  const ActionMenuButton({
    super.key,
    this.onEdit,
    this.onDelete,
    this.editLabel = 'Edit',
    this.deleteLabel = 'Delete',
    this.icon = fu.FIcons.ellipsisVertical,
    this.iconSize = 16,
    this.iconColor,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: Icon(icon, size: iconSize, color: iconColor ?? context.colors.mutedForeground),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      position: position ?? PopupMenuPosition.over,
      itemBuilder: (_) => [
        if (onEdit != null) PopupMenuItem(value: 'edit', child: Text(editLabel)),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Text(deleteLabel, style: const TextStyle(color: Colors.red)),
          ),
      ],
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
    );
  }
}
