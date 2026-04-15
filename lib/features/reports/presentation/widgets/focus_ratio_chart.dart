import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class FocusRatioChart extends StatelessWidget {
  final double focusRatio;
  final double breakRatio;
  final String ratioLabel;

  const FocusRatioChart({
    super.key,
    required this.focusRatio,
    required this.breakRatio,
    required this.ratioLabel,
  });

  @override
  Widget build(BuildContext context) {
    final focusPercent = (focusRatio * 100).round().clamp(0, 100);
    final breakPercent = 100 - focusPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Focus Ratio', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppConstants.spacing.regular),
        Center(
          child: SizedBox(
            width: 96,
            height: 96,
            child: CustomPaint(
              painter: _RatioRingPainter(
                focusRatio: focusRatio,
                focusColor: context.colors.primary,
                breakColor: context.colors.mutedForeground.withValues(alpha: 0.25),
              ),
              child: Center(
                child: Text(ratioLabel, style: context.typography.sm.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
        SizedBox(height: AppConstants.spacing.regular),
        Text(
          '$focusPercent% Focus',
          style: context.typography.sm.copyWith(color: context.colors.primary, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: AppConstants.spacing.extraSmall),
        Text('$breakPercent% Break', style: context.typography.sm.copyWith(color: context.colors.mutedForeground)),
      ],
    );
  }
}

class _RatioRingPainter extends CustomPainter {
  final double focusRatio;
  final Color focusColor;
  final Color breakColor;

  const _RatioRingPainter({required this.focusRatio, required this.focusColor, required this.breakColor});

  @override
  void paint(Canvas canvas, Size size) {
    final clampedRatio = focusRatio.clamp(0.0, 1.0);
    const strokeWidth = 10.0;
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..color = breakColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final focusPaint = Paint()
      ..color = focusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);

    if (clampedRatio > 0) {
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * clampedRatio, false, focusPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RatioRingPainter oldDelegate) {
    return oldDelegate.focusRatio != focusRatio ||
        oldDelegate.focusColor != focusColor ||
        oldDelegate.breakColor != breakColor;
  }
}
