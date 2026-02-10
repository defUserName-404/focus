import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;

class ProjectProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const ProjectProgressBar({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    final percent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed of $total tasks',
              style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
            ),
            Text(
              '$percent%',
              style: context.typography.xs.copyWith(
                fontWeight: FontWeight.w600,
                color: percent == 100 ? context.colors.primary : context.colors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        fu.FProgress(),
      ],
    );
  }
}
