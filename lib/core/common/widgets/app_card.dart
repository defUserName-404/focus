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
    const double leadingWidth = 32.0;

    return GestureDetector(
      onTap: onTap,
      child: fu.FCard(
        child: Column(
          mainAxisSize: .min,
          children: [
            Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Row(
                  crossAxisAlignment: .center,
                  children: [
                    if (leading != null) SizedBox(width: leadingWidth, child: leading!),
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
                    if (trailing != null) ...[SizedBox(width: AppConstants.spacing.regular), trailing!],
                  ],
                ),

                Padding(
                  padding: EdgeInsets.only(left: leading != null ? leadingWidth : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (subtitle != null) ...[SizedBox(height: AppConstants.spacing.extraSmall), subtitle!],
                      if (content != null) ...[SizedBox(height: AppConstants.spacing.regular), content!],
                      if (footerActions != null && footerActions!.isNotEmpty) ...[
                        SizedBox(height: AppConstants.spacing.regular),
                        Row(mainAxisAlignment: .end, children: footerActions!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (children != null) ...children!,
          ],
        ),
      ),
    );
  }
}
