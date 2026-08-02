import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:forui/forui.dart' as fu;

class AppCard extends StatefulWidget {
  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;
  final Widget? content;
  final List<Widget>? footerActions;
  final List<Widget>? children;
  final VoidCallback? onTap;
  final bool isCompleted;
  final MouseCursor mouseCursor;

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
    this.mouseCursor = SystemMouseCursors.click,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const double leadingWidth = 32.0;
    final tappable = widget.onTap != null;

    return MouseRegion(
      cursor: tappable ? widget.mouseCursor : MouseCursor.defer,
      onEnter: tappable ? (_) => setState(() => _hovered = true) : null,
      onExit: tappable ? (_) => setState(() => _hovered = false) : null,
      child: AnimatedContainer(
        duration: AppConstants.animation.short,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
          color: _hovered ? context.colors.muted.withValues(alpha: 0.45) : Colors.transparent,
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: fu.FCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.leading != null) SizedBox(width: leadingWidth, child: widget.leading!),
                        Expanded(
                          child: DefaultTextStyle(
                            style: context.typography.md.copyWith(
                              fontWeight: widget.isCompleted ? FontWeight.w400 : FontWeight.w600,
                              color: widget.isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                              decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            child: widget.title,
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          SizedBox(width: AppConstants.spacing.regular),
                          widget.trailing!,
                        ],
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: widget.leading != null ? leadingWidth : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.subtitle != null) ...[
                            SizedBox(height: AppConstants.spacing.extraSmall),
                            widget.subtitle!,
                          ],
                          if (widget.content != null) ...[
                            SizedBox(height: AppConstants.spacing.regular),
                            widget.content!,
                          ],
                          if (widget.footerActions != null && widget.footerActions!.isNotEmpty) ...[
                            SizedBox(height: AppConstants.spacing.regular),
                            Row(mainAxisAlignment: MainAxisAlignment.end, children: widget.footerActions!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                ...?widget.children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
