import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class FocusCircleIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const FocusCircleIconButton({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animation.medium,
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
        child: Center(
          child: AnimatedSwitcher(
            duration: AppConstants.animation.short,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(icon, key: ValueKey(icon), color: color, size: size * 0.4),
          ),
        ),
      ),
    );
  }
}
