import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';

part 'ambience_mute_provider.g.dart';

/// Whether the focus-session ambience audio is currently muted.
///
/// Toggling this pauses / resumes the ambient player via [AudioService]
/// without stopping the session or losing the current sound preset.
@Riverpod(keepAlive: true)
class AmbienceMute extends _$AmbienceMute {
  @override
  bool build() => false; // not muted by default

  void toggle() {
    final audioService = getIt<AudioService>();
    if (state) {
      audioService.resumeAmbience();
    } else {
      audioService.pauseAmbience();
    }
    state = !state;
  }

  /// Reset mute state (e.g. when a session ends).
  void reset() => state = false;
}
