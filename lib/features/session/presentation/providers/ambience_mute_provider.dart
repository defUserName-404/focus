import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/audio_assets.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../models/ambience_marquee_state.dart';
import 'focus_progress_provider.dart';
import 'focus_providers.dart';

part 'ambience_mute_provider.g.dart';
part 'ambience_marquee_provider.part.dart';

/// Whether the focus-session ambience audio is currently muted.
///
/// Toggling this pauses / resumes the ambient player via [AudioService]
/// without stopping the session or losing the current sound preset.
@Riverpod(keepAlive: true)
class AmbienceMute extends _$AmbienceMute {
  @override
  bool build() => false; // not muted by default

  void toggle() {
    final audioCoordinator = ref.read(focusAudioCoordinatorProvider);
    if (state) {
      audioCoordinator.resumeAmbience();
    } else {
      audioCoordinator.pauseAmbience();
    }
    state = !state;
  }

  /// Reset mute state (e.g. when a session ends).
  void reset() => state = false;
}
