import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/common/widgets/confirmation_dialog.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../settings/domain/repositories/i_settings_repository.dart';
import '../../domain/entities/session_state.dart';
import '../providers/focus_session_provider.dart';

class FocusCommands {
  /// Navigate to the focus session screen for a given task.
  ///
  /// Reads focus/break duration from persisted settings.
  /// If there is already an active (non-completed/cancelled) session,
  /// navigates to it instead of creating a new one.
  static Future<void> start(
    BuildContext context,
    WidgetRef ref, {
    required BigInt taskId,
  }) async {
    final existing = ref.read(focusTimerProvider);

    // If a session is already active, just show it.
    if (existing != null &&
        existing.state != SessionState.completed &&
        existing.state != SessionState.cancelled &&
        existing.state != SessionState.incomplete) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushNamed(RouteConstants.focusSessionRoute);
      }
      return;
    }

    // Read timer settings from DB.
    final settingsRepo = getIt<ISettingsRepository>();
    final timerPrefs = await settingsRepo.getTimerPreferences();

    await ref.read(focusTimerProvider.notifier).createSession(
          taskId: taskId,
          focusMinutes: timerPrefs.focusDurationMinutes,
          breakMinutes: timerPrefs.breakDurationMinutes,
        );

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushNamed(RouteConstants.focusSessionRoute);
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
}
