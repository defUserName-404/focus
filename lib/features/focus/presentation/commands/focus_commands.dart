import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/confirmation_dialog.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/navigator_key.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../settings/domain/repositories/i_settings_repository.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/session_state.dart';
import '../providers/focus_session_provider.dart';

class FocusCommands {
  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Whether [session] is still in an active (non-terminal) state.
  static bool _isActive(FocusSession? session) {
    if (session == null) return false;
    return session.state != SessionState.completed &&
        session.state != SessionState.cancelled &&
        session.state != SessionState.incomplete;
  }

  /// End the existing session (marked as **incomplete**), then invoke
  /// [onReplaced] to create & navigate to the new one.
  static Future<void> _confirmReplace(
    BuildContext context,
    WidgetRef ref, {
    required VoidCallback onReplaced,
  }) async {
    await ConfirmationDialog.show(
      context,
      title: 'Session already running',
      body: 'Ending the current session will mark it as incomplete. Start a new one?',
      confirmLabel: 'End & start new',
      cancelLabel: 'Keep current',
      confirmStyle: null, // uses default destructive style
      onConfirm: () {
        ref.read(focusTimerProvider.notifier).cancelSession();
        onReplaced();
      },
    );
  }

  /// Read persisted timer preferences.
  static Future<TimerPreferences> _timerPrefs() async {
    final repo = getIt<ISettingsRepository>();
    return repo.getTimerPreferences();
  }

  // ── Public API ──────────────────────────────────────────────────────────

  /// Navigate to the focus session screen for a given task.
  ///
  /// Reads focus/break duration from persisted settings.
  /// If there is already an active session, asks the user whether
  /// to end it and start a new one.
  static Future<void> start(
    BuildContext context,
    WidgetRef ref, {
    required BigInt taskId,
  }) async {
    final existing = ref.read(focusTimerProvider);

    if (_isActive(existing)) {
      // Same task → just navigate to it.
      if (existing!.taskId == taskId) {
        if (context.mounted) navigateToFocusSession(context: context);
        return;
      }
      // Different task → ask to replace.
      if (context.mounted) {
        await _confirmReplace(context, ref, onReplaced: () async {
          await _createAndNavigate(context, ref, taskId: taskId);
        });
      }
      return;
    }

    await _createAndNavigate(context, ref, taskId: taskId);
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

  /// Start a **quick session** with no task attached.
  ///
  /// Quick sessions count toward daily statistics but are not linked
  /// to a task or project. They appear as "Quick Session" in the UI.
  static Future<void> startQuickSession(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final existing = ref.read(focusTimerProvider);

    if (_isActive(existing)) {
      if (context.mounted) {
        await _confirmReplace(context, ref, onReplaced: () async {
          await _createAndNavigate(context, ref);
        });
      }
      return;
    }

    await _createAndNavigate(context, ref);
  }

  // ── Internal creation helper ────────────────────────────────────────────

  /// Create a new session and navigate to the focus screen.
  ///
  /// If [taskId] is `null`, creates a quick session.
  static Future<void> _createAndNavigate(
    BuildContext context,
    WidgetRef ref, {
    BigInt? taskId,
  }) async {
    final prefs = await _timerPrefs();

    await ref.read(focusTimerProvider.notifier).createSession(
          taskId: taskId,
          focusMinutes: prefs.focusDurationMinutes,
          breakMinutes: prefs.breakDurationMinutes,
        );

    if (context.mounted) {
      navigateToFocusSession(context: context);
    }
  }
}
