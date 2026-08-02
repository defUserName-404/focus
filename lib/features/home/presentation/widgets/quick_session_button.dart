import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../session/presentation/commands/focus_commands.dart';

class QuickSessionButton extends ConsumerWidget {
  const QuickSessionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final button = fu.FButton(
      onPress: () => FocusCommands.startQuickSession(context, ref),
      prefix: Icon(fu.FLucideIcons.play, size: AppConstants.size.icon.regular),
      child: const Text('Start Focus Session'),
    );

    if (context.isCompact) {
      return button;
    }

    return Align(
      alignment: .centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          crossAxisAlignment: .stretch,
          spacing: AppConstants.spacing.extraSmall,
          children: [
            button,
            SizedBox(height: AppConstants.spacing.regular),
            Text(
              'Begin a quick session without picking a task',
              style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
