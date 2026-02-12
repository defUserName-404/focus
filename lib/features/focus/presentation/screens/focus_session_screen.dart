import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/session_state.dart';
import '../providers/focus_session_provider.dart';

class FocusSessionScreen extends ConsumerWidget {
  const FocusSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(focusTimerProvider);

    if (session == null) {
      return const FScaffold(child: Center(child: Text('No active session')));
    }

    final taskAsync = ref.watch(taskByIdProvider(session.taskId.toString()));

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Focus'),
        prefixes: [FHeaderAction.back(onPress: () => Navigator.of(context).pop())],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing.large),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // ── Task + Project context ────────────────────────────
              taskAsync.when(
                data: (task) {
                  final projectAsync = ref.watch(projectByIdProvider(task.projectId.toString()));
                  return Column(
                    children: [
                      Text(
                        task.title,
                        style: context.typography.xl2.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      projectAsync.when(
                        data: (project) => Text(
                          project?.title ?? '',
                          style: context.typography.base.copyWith(color: context.colors.mutedForeground),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const Text('Error loading task'),
              ),

              const Spacer(flex: 2),

              // ── Circular timer ────────────────────────────────────
              _CircularTimerDisplay(session: session),

              const Spacer(flex: 1),

              // ── Controls ─────────────────────────────────────────
              _FocusControls(session: session),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Circular Timer ──────────────────────────────────────────────────────────

class _CircularTimerDisplay extends ConsumerWidget {
  final FocusSession session;

  const _CircularTimerDisplay({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFocus = session.state == SessionState.running || session.state == SessionState.paused;
    final totalSeconds = isFocus ? session.focusDurationMinutes * 60 : session.breakDurationMinutes * 60;

    final elapsedInPhase = isFocus
        ? session.elapsedSeconds
        : session.elapsedSeconds - (session.focusDurationMinutes * 60);

    final remainingSeconds = (totalSeconds - elapsedInPhase).clamp(0, totalSeconds);
    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;

    final progress = (elapsedInPhase / totalSeconds).clamp(0.0, 1.0);

    final ringSize = 240.0;
    final isPaused = session.state == SessionState.paused;

    return Column(
      children: [
        // Phase label
        Text(
          isFocus ? 'FOCUS' : 'BREAK',
          style: context.typography.sm.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 24),

        // Circular ring with timer inside
        GestureDetector(
          onDoubleTap: isPaused ? () => _showDurationEditor(context, ref) : null,
          child: SizedBox(
            width: ringSize,
            height: ringSize,
            child: CustomPaint(
              painter: _CircularProgressPainter(
                progress: progress,
                trackColor: context.colors.border,
                progressColor: isFocus ? context.colors.primary : context.colors.mutedForeground,
                strokeWidth: 4.0,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: context.typography.xl7.copyWith(fontWeight: FontWeight.w100, fontSize: 56),
                    ),
                    if (isPaused)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'double-tap to edit',
                          style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDurationEditor(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(focusTimerProvider.notifier);
    final focusController = TextEditingController(text: session.focusDurationMinutes.toString());
    final breakController = TextEditingController(text: session.breakDurationMinutes.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: focusController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Focus (minutes)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: breakController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Break (minutes)'),
            ),
          ],
        ),
        actions: [
          FButton(style: FButtonStyle.ghost(), onPress: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FButton(
            onPress: () {
              final focus = int.tryParse(focusController.text);
              final brk = int.tryParse(breakController.text);
              if (focus != null && focus > 0) {
                notifier.updateDuration(focusMinutes: focus, breakMinutes: (brk != null && brk > 0) ? brk : null);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Circular Progress Painter ───────────────────────────────────────────────

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track (background circle)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

// ── Controls ────────────────────────────────────────────────────────────────

class _FocusControls extends ConsumerWidget {
  final FocusSession session;

  const _FocusControls({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(focusTimerProvider.notifier);
    final isRunning = session.state == SessionState.running || session.state == SessionState.onBreak;
    final isPaused = session.state == SessionState.paused;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isPaused)
          FButton(onPress: () => notifier.resumeSession(), prefix: const Icon(FIcons.play), child: const Text('Resume'))
        else if (isRunning)
          FButton(onPress: () => notifier.pauseSession(), prefix: const Icon(FIcons.pause), child: const Text('Pause')),
        const SizedBox(width: 16),
        FButton(
          style: FButtonStyle.destructive(),
          onPress: () => _confirmEnd(context, notifier),
          prefix: const Icon(FIcons.square),
          child: const Text('End'),
        ),
      ],
    );
  }

  void _confirmEnd(BuildContext context, dynamic notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End session?'),
        content: const Text('This session will be saved as cancelled and won\'t count as completed.'),
        actions: [
          FButton(style: FButtonStyle.ghost(), onPress: () => Navigator.pop(ctx), child: const Text('Keep going')),
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () {
              notifier.cancelSession();
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // back to task list
            },
            child: const Text('End session'),
          ),
        ],
      ),
    );
  }
}
