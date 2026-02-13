import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const SectionHeader({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: context.typography.sm.copyWith(fontWeight: FontWeight.w600, color: context.colors.foreground),
        ),
        const Spacer(),
        if (onViewAll != null)
          fu.FButton(
            style: fu.FButtonStyle.ghost(),
            onPress: onViewAll,
            child: Text('View All', style: context.typography.xs),
          ),
      ],
    );
  }
}
