import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class AddSubtaskChip extends StatelessWidget {
  final VoidCallback onPressed;

  const AddSubtaskChip({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return fu.FButton(
      style: fu.FButtonStyle.outline(),
      onPress: onPressed,
      prefix: Icon(fu.FIcons.plus, size: AppConstants.size.icon.small),
      child: Text('subtask', style: context.typography.xs),
    );
  }
}
