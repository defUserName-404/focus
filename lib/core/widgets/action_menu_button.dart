import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../config/theme/app_theme.dart';

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

    return fu.FPopoverMenu(
      autofocus: true,
      menuAnchor: Alignment.topRight,
      childAnchor: Alignment.bottomRight,
      menu: [
        fu.FItemGroup(
          children: [
            fu.FItem(prefix: const Icon(fu.FIcons.pencil), title: const Text('Edit'), onPress: () => onEdit?.call()),
            fu.FItem(
              prefix: Icon(fu.FIcons.trash, color: context.colors.destructive),
              title: Text('Delete', style: context.typography.base.copyWith(color: context.colors.destructive)),
              onPress: () => onDelete?.call(),
            ),
          ],
        ),
      ],
      builder: (_, controller, _) => fu.FButton(
        onPress: controller.toggle,
        style: fu.FButtonStyle.ghost(),
        child: const Icon(fu.FIcons.ellipsis, size: 20),
      ),
    );
  }
}
