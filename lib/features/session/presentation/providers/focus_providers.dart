import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../domain/repositories/i_focus_session_repository.dart';
import '../../domain/services/focus_audio_coordinator.dart';
import '../../domain/services/focus_media_session_coordinator.dart';
import '../../domain/services/focus_notification_coordinator.dart';
import '../../domain/services/focus_session_service.dart';

part 'focus_providers.g.dart';
part 'focus_audio_coordinator_provider.part.dart';
part 'focus_media_session_coordinator_provider.part.dart';
part 'focus_notification_coordinator_provider.part.dart';
part 'focus_session_repository_provider.part.dart';

/// Riverpod wrappers for GetIt-registered focus singletons.
///
/// These providers bridge the GetIt DI container into Riverpod's
/// dependency graph. This allows:
/// - `ref.watch()` in the `FocusTimer` notifier (proper Riverpod pattern)
/// - `overrideWithValue()` in tests for easy mocking

@Riverpod(keepAlive: true)
FocusSessionService focusSessionService(Ref ref) => getIt<FocusSessionService>();
