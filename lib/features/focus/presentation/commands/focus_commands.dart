import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/confirmation_dialog.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/entities/session_state.dart';
import '../providers/focus_session_provider.dart';

class FocusCommands {
  /// Navigate to the focus session screen for a given task.
  ///
  /// If there is already an active (non-completed/cancelled) session,
  /// navigates to it instead of creating a new one.
  static Future<void> start(
    BuildContext context,
    WidgetRef ref, {
    required BigInt taskId,
    int focusMinutes = 25,
    int breakMinutes = 5,
  }) async {
    final existing = ref.read(focusTimerProvider);

    // If a session is already active, just show it.
    if (existing != null && existing.state != SessionState.completed && existing.state != SessionState.cancelled) {
      if (context.mounted) {
        Navigator.of(context).pushNamed(RouteConstants.focusSessionRoute);
      }
      return;
    }

    await ref
        .read(focusTimerProvider.notifier)
        .createSession(taskId: taskId, focusMinutes: focusMinutes, breakMinutes: breakMinutes);

    if (context.mounted) {
      Navigator.of(context).pushNamed(RouteConstants.focusSessionRoute);
    }
  }

  /// Show a confirmation dialog before ending the session.
  static Future<void> confirmEnd(BuildContext context, WidgetRef ref) async {
    await ConfirmationDialog.show(
      context,
      title: 'End session?',
      body: 'This session will be saved but won\'t count as completed.',
      confirmLabel: 'End session',
      cancelLabel: 'Keep going',
      onConfirm: () {
        ref.read(focusTimerProvider.notifier).cancelSession();
        Navigator.of(context).pop();
      },
    );
  }

  /// Show a dialog to edit focus/break duration (only while paused or idle).
  static Future<void> editDuration(
    BuildContext context,
    WidgetRef ref, {
    required int currentFocusMinutes,
    required int currentBreakMinutes,
  }) async {
    final focusController = TextEditingController(text: currentFocusMinutes.toString());
    final breakController = TextEditingController(text: currentBreakMinutes.toString());

    await showDialog(
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final focus = int.tryParse(focusController.text);
              final brk = int.tryParse(breakController.text);
              if (focus != null && focus > 0) {
                ref
                    .read(focusTimerProvider.notifier)
                    .updateDuration(focusMinutes: focus, breakMinutes: (brk != null && brk > 0) ? brk : null);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    focusController.dispose();
    breakController.dispose();
  }
}
