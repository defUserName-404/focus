import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../config/theme/app_theme.dart';

/// Overflow menu with optional Edit / Save as template / Delete actions.
class ActionMenuButton extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSaveAsTemplate;
  final String editLabel;
  final String deleteLabel;
  final String saveAsTemplateLabel;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final PopupMenuPosition? position;

  const ActionMenuButton({
    super.key,
    this.onEdit,
    this.onDelete,
    this.onSaveAsTemplate,
    this.editLabel = 'Edit',
    this.deleteLabel = 'Delete',
    this.saveAsTemplateLabel = 'Save as template',
    this.icon = fu.FLucideIcons.ellipsisVertical,
    this.iconSize = 16,
    this.iconColor,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null && onSaveAsTemplate == null) {
      return const SizedBox.shrink();
    }
    return fu.FPopoverMenu(
      autofocus: true,
      menuAnchor: Alignment.topRight,
      childAnchor: Alignment.bottomRight,
      menu: [
        fu.FItemGroup(
          children: [
            if (onEdit != null)
              fu.FItem(
                prefix: const Icon(fu.FLucideIcons.pencil),
                title: Text(editLabel),
                onPress: () => onEdit?.call(),
              ),
            if (onSaveAsTemplate != null)
              fu.FItem(
                prefix: const Icon(fu.FLucideIcons.layoutTemplate),
                title: Text(saveAsTemplateLabel),
                onPress: () => onSaveAsTemplate?.call(),
              ),
            if (onDelete != null)
              fu.FItem(
                prefix: Icon(fu.FLucideIcons.trash, color: context.colors.destructive),
                title: Text(deleteLabel, style: context.typography.md.copyWith(color: context.colors.destructive)),
                onPress: () => onDelete?.call(),
              ),
          ],
        ),
      ],
      builder: (_, controller, _) => fu.FButton(
        onPress: controller.toggle,
        variant: .ghost,
        child: const Icon(fu.FLucideIcons.ellipsis, size: 20),
      ),
    );
  }
}
