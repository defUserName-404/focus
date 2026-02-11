import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:forui/forui.dart' as fu;

class AppCard extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;
  final Widget? content;
  final List<Widget>? footerActions;
  final List<Widget>? children;
  final VoidCallback? onTap;
  final bool isCompleted;

  const AppCard({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.subtitle,
    this.content,
    this.footerActions,
    this.children,
    this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: fu.FCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppConstants.spacing.regular),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row: [Leading] + Title + [Trailing]
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: DefaultTextStyle(
                          style: context.typography.base.copyWith(
                            fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w600,
                            color: isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          child: title,
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 4),
                        trailing!,
                      ],
                    ],
                  ),

                  // Subtitle (e.g., Description)
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.only(left: leading != null ? 30 : 0),
                      child: subtitle!,
                    ),
                  ],

                  // Main Content (e.g., Date Row)
                  if (content != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(left: leading != null ? 30 : 0),
                      child: content!,
                    ),
                  ],

                  // Footer Actions (e.g., Chips)
                  if (footerActions != null && footerActions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.only(left: leading != null ? 30 : 0),
                      child: Wrap(
                        spacing: AppConstants.spacing.small,
                        runSpacing: AppConstants.spacing.small,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: footerActions!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (children != null) ...children!,
          ],
        ),
      ),
    );
  }
}
