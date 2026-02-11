import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:forui/forui.dart' as fu;
import 'package:intl/intl.dart';

class ProjectMetaSection extends StatefulWidget {
  final Project project;

  const ProjectMetaSection({super.key, required this.project});

  @override
  State<ProjectMetaSection> createState() => _ProjectMetaSectionState();
}

class _ProjectMetaSectionState extends State<ProjectMetaSection> {
  bool _expanded = false;

  String _fmt(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final hasAnyMeta = project.startDate != null || project.deadline != null;

    if (!hasAnyMeta) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Icon(
                _expanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                size: 16,
                color: context.colors.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text('Project details', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
            ],
          ),
        ),
        if (_expanded) ...[
          SizedBox(height: AppConstants.spacing.regular),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: AppConstants.spacing.regular,
              children: [
                if (project.startDate != null) fu.FBadge(child: Text('Start: ${_fmt(project.startDate!)}')),
                if (project.deadline != null)
                  fu.FBadge(style: fu.FBadgeStyle.destructive(), child: Text('Deadline: ${_fmt(project.deadline!)}')),
              ],
            ),
          ),
          SizedBox(height: AppConstants.spacing.regular),
        ],
      ],
    );
  }
}
