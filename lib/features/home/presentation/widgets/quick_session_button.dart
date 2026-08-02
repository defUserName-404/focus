import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../../../session/presentation/commands/focus_commands.dart';

class QuickSessionButton extends ConsumerWidget {
  const QuickSessionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: context.colors.primary,
      borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      child: InkWell(
        onTap: () => FocusCommands.startQuickSession(context, ref),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.large, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.background.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
                ),
                child: Icon(fu.FLucideIcons.play, color: context.colors.background, size: AppConstants.size.icon.large),
              ),
              SizedBox(width: AppConstants.spacing.regular),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Start Focus Session',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.lg.copyWith(
                        color: context.colors.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacing.extraSmall),
                    Text(
                      'Tap to begin a quick session',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.sm.copyWith(color: context.colors.background.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Icon(
                fu.FLucideIcons.chevronRight,
                size: AppConstants.size.icon.regular,
                color: context.colors.background.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
