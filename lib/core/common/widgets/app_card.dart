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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(AppConstants.spacing.regular),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Header Row: Checkbox + Title + Trailing ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (leading != null)
                        SizedBox(width: leadingWidth, child: leading!),
                      Expanded(
                        child: DefaultTextStyle(
                          style: context.typography.base.copyWith(
                            fontWeight: isCompleted
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: isCompleted
                                ? context.colors.mutedForeground
                                : context.colors.foreground,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          child: title,
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 8),
                        trailing!,
                      ],
                    ],
                  ),

                  // --- Body Content Indented below Title ---
                  Padding(
                    padding: EdgeInsets.only(
                      left: leading != null ? leadingWidth : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Subtitle / Description
                        if (subtitle != null) ...[
                          const SizedBox(height: 2), // Reduced gap
                          subtitle!,
                        ],

                        // Content (e.g., Date Row)
                        if (content != null) ...[
                          const SizedBox(height: 6), // Reduced gap
                          content!,
                        ],

                        // Footer Actions row
                        if (footerActions != null &&
                            footerActions!.isNotEmpty) ...[
                          const SizedBox(height: 10), // Reduced gap
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: footerActions!,
                          ),
                        ],
                      ],
                    ),
                  ),
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
