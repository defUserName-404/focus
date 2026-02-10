import 'package:flutter/material.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
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
    final hasAnyMeta =
        project.startDate != null || project.deadline != null;

    if (!hasAnyMeta) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_right_rounded,
                size: 16,
                color: const Color(0xFF666666),
              ),
              const SizedBox(width: 4),
              const Text(
                'Project details',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 8,
              children: [
                if (project.startDate != null)
                  _MetaChip(label: 'Start', value: _fmt(project.startDate!)),
                if (project.deadline != null)
                  _MetaChip(
                    label: 'Deadline',
                    value: _fmt(project.deadline!),
                    valueColor: const Color(0xFFE8A87C),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetaChip({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFFCCCCCC),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border.all(color: const Color(0xFF222222)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
