import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/confirmation_dialog.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routing/navigation_service.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../settings/domain/services/settings_service.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/session_state.dart';
import '../providers/focus_session_provider.dart';

class FocusCommands {
  //  Helpers
  /// Whether [session] is still in an active (non-terminal) state.
  static bool _isActive(FocusSession? session) {
    if (session == null) return false;
    return session.state != SessionState.completed &&
        session.state != SessionState.cancelled &&
        session.state != SessionState.incomplete;
  }

  /// End the existing session (marked as **incomplete**), then invoke
  /// [onReplaced] to create & navigate to the new one.
  static Future<void> _confirmReplace(BuildContext context, WidgetRef ref, {required VoidCallback onReplaced}) async {
    await ConfirmationDialog.show(
      context,
      title: 'Session already running',
      body: 'Ending the current session will mark it as incomplete. Start a new one?',
      confirmLabel: 'End & start new',
      cancelLabel: 'Keep current',
      confirmStyle: null,
      // uses default destructive style
      onConfirm: () {
        ref.read(focusTimerProvider.notifier).cancelSession();
        onReplaced();
      },
    );
  }

  /// Read persisted timer preferences.
  static Future<TimerPreferences> _timerPrefs() async {
    return getIt<SettingsService>().getTimerPreferences();
  }

  //  Public API

  /// Navigate to the focus session screen for a given task.
  static Future<void> start(BuildContext context, WidgetRef ref, {required BigInt taskId}) async {
    final existing = ref.read(focusTimerProvider);
    final nav = getIt<NavigationService>();

    if (_isActive(existing)) {
      if (existing!.taskId == taskId) {
        if (context.mounted) nav.goToFocusSession(context: context);
        return;
      }
      if (context.mounted) {
        await _confirmReplace(
          context,
          ref,
          onReplaced: () async {
            await _createAndNavigate(context, ref, taskId: taskId);
          },
        );
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
      },
    );
  }

  /// Start a **quick session** with no task attached.
  static Future<void> startQuickSession(BuildContext context, WidgetRef ref) async {
    final existing = ref.read(focusTimerProvider);

    if (_isActive(existing)) {
      if (context.mounted) {
        await _confirmReplace(
          context,
          ref,
          onReplaced: () async {
            await _createAndNavigate(context, ref);
          },
        );
      }
      return;
    }

    await _createAndNavigate(context, ref);
  }

  //  Internal creation helper

  static Future<void> _createAndNavigate(BuildContext context, WidgetRef ref, {BigInt? taskId}) async {
    final prefs = await _timerPrefs();

    await ref
        .read(focusTimerProvider.notifier)
        .createSession(
          taskId: taskId,
          focusMinutes: prefs.focusDurationMinutes,
          breakMinutes: prefs.breakDurationMinutes,
        );

    if (context.mounted) {
      getIt<NavigationService>().goToFocusSession(context: context);
    }
  }
}
