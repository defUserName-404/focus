import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:forui/forui.dart' as fu;

class StreakBadge extends StatefulWidget {
  final int streak;

  const StreakBadge({super.key, required this.streak});

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppConstants.animation.extraLong)..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacity = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colors.primary;
    final amberColor = context.colors.primary.withOpacity(0.8);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacing.regular,
        vertical: AppConstants.spacing.small,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        border: Border.all(color: primaryColor.withValues(alpha: 0.25), width: AppConstants.border.width.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scale.value,
                child: Opacity(opacity: _opacity.value, child: child),
              );
            },
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [primaryColor, amberColor],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Icon(fu.FIcons.flame, size: AppConstants.size.icon.small, color: Colors.white),
            ),
          ),
          SizedBox(width: AppConstants.spacing.small),
          Text(
            '${widget.streak}d streak',
            style: context.typography.xs.copyWith(fontWeight: FontWeight.w600, color: primaryColor),
          ),
        ],
      ),
    );
  }
}
