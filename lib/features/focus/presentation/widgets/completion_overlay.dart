import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// A full-screen animated overlay shown when a task is completed.
///
/// Includes:
/// - An expanding circle ripple from the center
/// - An animated checkmark that draws itself
/// - Confetti-like particles bursting outward
/// - A fade-in "Task Complete!" message
/// - Auto-dismisses after ~2.5 seconds
class CompletionOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const CompletionOverlay({super.key, required this.onDismiss});

  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay> with TickerProviderStateMixin {
  late final AnimationController _rippleController;
  late final AnimationController _checkController;
  late final AnimationController _confettiController;
  late final AnimationController _textController;

  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;
  late final Animation<double> _checkProgress;
  late final Animation<double> _textOpacity;
  late final Animation<double> _confettiProgress;

  final List<_Particle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Ripple: scale up + fade
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rippleScale = Tween(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleOpacity = Tween(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Checkmark draws in
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkProgress = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    // Confetti burst outward
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _confettiProgress = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.easeOut),
    );

    // Text fades in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Generate particles
    for (int i = 0; i < 24; i++) {
      _particles.add(_Particle(
        angle: (i / 24) * 2 * math.pi + _random.nextDouble() * 0.3,
        distance: 80 + _random.nextDouble() * 100,
        size: 4 + _random.nextDouble() * 6,
        colorIndex: i % 4,
      ));
    }

    _startSequence();
  }

  Future<void> _startSequence() async {
    _rippleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();
    _confettiController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _checkController.dispose();
    _confettiController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.colors.primary;
    final confettiColors = [
      primaryColor,
      Colors.amber,
      Colors.tealAccent,
      Colors.pinkAccent,
    ];

    return AnimatedBuilder(
      animation: Listenable.merge([
        _rippleController,
        _checkController,
        _confettiController,
        _textController,
      ]),
      builder: (context, _) {
        return Stack(
          children: [
            // Semi-transparent backdrop
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),

            // Ripple circle
            Center(
              child: Transform.scale(
                scale: _rippleScale.value,
                child: Opacity(
                  opacity: _rippleOpacity.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),

            // Confetti particles
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiProgress.value,
                    colors: confettiColors,
                  ),
                ),
              ),
            ),

            // Check circle
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
                child: CustomPaint(
                  painter: _CheckmarkPainter(
                    progress: _checkProgress.value,
                    color: Colors.white,
                    strokeWidth: 4,
                  ),
                ),
              ),
            ),

            // Text
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).size.height * 0.3,
              child: Opacity(
                opacity: _textOpacity.value,
                child: Column(
                  children: [
                    Text(
                      'Task Complete!',
                      textAlign: TextAlign.center,
                      style: context.typography.xl2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacing.small),
                    Text(
                      'Great work — keep the momentum going.',
                      textAlign: TextAlign.center,
                      style: context.typography.sm.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Particle data ────────────────────────────────────────────────────────────

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final int colorIndex;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.colorIndex,
  });
}

// ── Confetti painter ─────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final List<Color> colors;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      final dist = p.distance * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final dx = center.dx + math.cos(p.angle) * dist;
      final dy = center.dy + math.sin(p.angle) * dist;

      final paint = Paint()
        ..color = colors[p.colorIndex].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), p.size * (1.0 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}

// ── Checkmark painter ────────────────────────────────────────────────────────

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Checkmark points relative to the center of the circle
    final cx = size.width / 2;
    final cy = size.height / 2;

    final p1 = Offset(cx - 14, cy + 2);   // start (left)
    final p2 = Offset(cx - 4, cy + 12);   // bottom
    final p3 = Offset(cx + 16, cy - 10);  // end (right)

    final path = Path();

    // First leg: p1 → p2
    final firstLegEnd = progress < 0.5 ? progress * 2 : 1.0;
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(
      p1.dx + (p2.dx - p1.dx) * firstLegEnd,
      p1.dy + (p2.dy - p1.dy) * firstLegEnd,
    );

    // Second leg: p2 → p3
    if (progress > 0.5) {
      final secondLegEnd = (progress - 0.5) * 2;
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * secondLegEnd,
        p2.dy + (p3.dy - p2.dy) * secondLegEnd,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter old) => old.progress != progress;
}
