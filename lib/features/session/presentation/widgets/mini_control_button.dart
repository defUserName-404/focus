import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';

class MiniControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const MiniControlButton({super.key, required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, size: 16, color: context.colors.primaryForeground),
      ),
    );
  }
}
