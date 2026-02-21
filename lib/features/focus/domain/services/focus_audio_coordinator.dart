import '../../../../core/constants/audio_assets.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/log_service.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../settings/domain/repositories/i_settings_repository.dart';

final _log = LogService.instance;

/// Coordinates all audio playback for focus sessions.
///
/// Handles ambience (start/stop/pause/resume) and alarm sounds,
/// reading user preferences from [ISettingsRepository].
class FocusAudioCoordinator {
  final AudioService _audioService;
  final ISettingsRepository _settingsRepo;

  FocusAudioCoordinator(this._audioService, this._settingsRepo);

  /// Start ambient sound based on user preferences.
  Future<void> startConfiguredAmbience([AudioPreferences? explicitPrefs]) async {
    try {
      final prefs = explicitPrefs ?? await _settingsRepo.getAudioPreferences();
      if (!prefs.ambienceEnabled) return;

      SoundPreset? preset;
      if (prefs.ambienceSoundId != null) {
        preset = AudioAssets.findById(prefs.ambienceSoundId!);
      }
      preset ??= AudioAssets.defaultAmbience;

      await _audioService.setNoiseVolume(prefs.ambienceVolume);
      await _audioService.startAmbience(preset);
      _log.debug('Ambience started: ${preset.label}', tag: 'FocusAudioCoordinator');
    } catch (e, st) {
      _log.error('Error starting configured ambience', tag: 'FocusAudioCoordinator', error: e, stackTrace: st);
    }
  }

  /// Play the configured alarm sound.
  Future<void> playConfiguredAlarm() async {
    try {
      final prefs = await _settingsRepo.getAudioPreferences();
      SoundPreset? preset;
      if (prefs.alarmSoundId != null) {
        preset = AudioAssets.findById(prefs.alarmSoundId!);
      }
      preset ??= AudioAssets.defaultAlarm;
      await _audioService.playAlarm(preset);
    } catch (e, st) {
      _log.error('Error playing configured alarm', tag: 'FocusAudioCoordinator', error: e, stackTrace: st);
      await _audioService.playAlarm();
    }
  }

  /// Pause the ambient sound (can be resumed later).
  Future<void> pauseAmbience() => _audioService.pauseAmbience();

  /// Resume a previously paused ambient sound.
  Future<void> resumeAmbience() => _audioService.resumeAmbience();

  /// Reload the ambient sound with the latest user preferences.
  ///
  /// Call this when the user changes the ambience sound/volume in settings
  /// while a session is actively playing. Stops the current sound and
  /// restarts with the updated preset.
  Future<void> reloadAmbience([AudioPreferences? newPrefs]) async {
    try {
      await _audioService.stopAmbience();
      await startConfiguredAmbience(newPrefs);
    } catch (e, st) {
      _log.error('Error reloading ambience', tag: 'FocusAudioCoordinator', error: e, stackTrace: st);
    }
  }

  /// Stop the ambient sound completely.
  Future<void> stopAmbience() async {
    try {
      await _audioService.stopAmbience();
    } catch (e, st) {
      _log.error('Error stopping ambience', tag: 'FocusAudioCoordinator', error: e, stackTrace: st);
    }
  }
}
