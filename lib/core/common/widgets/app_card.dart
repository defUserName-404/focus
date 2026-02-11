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
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Row(
              crossAxisAlignment: .center,
              mainAxisSize: .max,
              spacing: AppConstants.spacing.small,
              children: [
                if (leading != null) ...[leading!],
                Expanded(
                  child: DefaultTextStyle(
                    style: context.typography.base.copyWith(
                      fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w600,
                      color: isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: .ellipsis,
                    child: title,
                  ),
                ),
                if (trailing != null) ...[trailing!],
              ],
            ),

            // Subtitle (e.g., Description)
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.only(left: leading != null ? 34 : 0),
                child: subtitle!,
              ),
            ],

            // Main Content (e.g., Date Row)
            if (content != null) ...[content!],
            // Footer Actions (e.g., Chips)
            if (footerActions != null && footerActions!.isNotEmpty) ...[
              Row(mainAxisAlignment: .end, children: [...footerActions!]),
            ],
            if (children != null) ...children!,
          ],
        ),
      ),
    );
  }
}
