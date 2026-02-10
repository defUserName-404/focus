import 'package:flutter/material.dart';

class ProjectProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const ProjectProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    final percent = (progress * 100).round();
    final isDone = percent == 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed of $total tasks',
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDone
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: const Color(0xFF1E1E1E),
            valueColor: AlwaysStoppedAnimation<Color>(
              isDone ? const Color(0xFF4CAF50) : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
