import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../../../focus/presentation/commands/focus_commands.dart';

class QuickSessionButton extends ConsumerWidget {
  const QuickSessionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardStyle = context.theme.cardStyle;
    return fu.FCard(
      style: (style) => fu.FCardStyle(
        decoration: cardStyle.decoration.copyWith(color: context.colors.primary),
        contentStyle: cardStyle.contentStyle,
      ),
      child: GestureDetector(
        onTap: () => FocusCommands.startQuickSession(context, ref),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.background.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
              ),
              child: Icon(fu.FIcons.play, color: context.colors.background, size: AppConstants.size.icon.regular),
            ),
            SizedBox(width: AppConstants.spacing.regular),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Session',
                    style: context.typography.base.copyWith(
                      color: context.colors.background,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacing.extraSmall),
                  Text(
                    'Start a quick focus session',
                    style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                  ),
                ],
              ),
            ),
            Icon(
              fu.FIcons.chevronRight,
              size: AppConstants.size.icon.extraSmall,
              color: context.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
