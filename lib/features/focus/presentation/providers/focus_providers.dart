import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/common/utils/platform_utils.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/i_focus_session_repository.dart';
import '../../domain/services/focus_audio_coordinator.dart';
import '../../domain/services/focus_media_session_coordinator.dart';
import '../../domain/services/focus_notification_coordinator.dart';
import '../../domain/services/focus_session_service.dart';

part 'focus_providers.g.dart';

/// Riverpod wrappers for GetIt-registered focus singletons.
///
/// These providers bridge the GetIt DI container into Riverpod's
/// dependency graph. This allows:
/// - `ref.watch()` in the `FocusTimer` notifier (proper Riverpod pattern)
/// - `overrideWithValue()` in tests for easy mocking

@Riverpod(keepAlive: true)
FocusSessionService focusSessionService(Ref ref) => getIt<FocusSessionService>();

@Riverpod(keepAlive: true)
FocusAudioCoordinator focusAudioCoordinator(Ref ref) => getIt<FocusAudioCoordinator>();

@Riverpod(keepAlive: true)
FocusNotificationCoordinator? focusNotificationCoordinator(Ref ref) {
  if (!PlatformUtils.supportsLocalNotifications) return null;
  return getIt<FocusNotificationCoordinator>();
}

@Riverpod(keepAlive: true)
FocusMediaSessionCoordinator? focusMediaSessionCoordinator(Ref ref) {
  if (!PlatformUtils.supportsMediaSession) return null;
  return getIt<FocusMediaSessionCoordinator>();
}

@Riverpod(keepAlive: true)
IFocusSessionRepository focusSessionRepository(Ref ref) => getIt<IFocusSessionRepository>();
