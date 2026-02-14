import 'dart:async';
import 'dart:ui' show Color;

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '../constants/notification_constants.dart';

/// Callback signature used by [FocusAudioHandler] to delegate
/// media-button and notification-action taps back to the app's
/// focus session logic (the Riverpod [FocusTimer] notifier).
typedef FocusActionCallback = void Function(String actionId);

/// A [BaseAudioHandler] that integrates the focus session with
/// Android's [MediaSession] / iOS's Now Playing system.
///
/// This gives us:
/// - A **MediaStyle notification** with play/pause/stop/skip buttons
///   that is controllable from the lock-screen & notification shade.
/// - Proper media-button handling (headset clicker, Bluetooth controls).
/// - Background execution kept alive by the audio_service isolate.
///
/// The handler itself does **not** own any timer or audio-player logic —
/// it only acts as a bridge between OS media controls and the app's
/// [FocusTimer] notifier. Call [updatePlaybackState] and [updateMediaItem]
/// from the timer whenever state changes.
class FocusAudioHandler extends BaseAudioHandler with SeekHandler {
  FocusActionCallback? onAction;

  // ── MediaSession actions ──────────────────────────────────────────────

  @override
  Future<void> play() async {
    onAction?.call(NotificationConstants.actionResume);
  }

  @override
  Future<void> pause() async {
    onAction?.call(NotificationConstants.actionPause);
  }

  @override
  Future<void> stop() async {
    onAction?.call(NotificationConstants.actionStop);
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    onAction?.call(NotificationConstants.actionSkip);
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    onAction?.call(name);
  }

  // ── Helpers for the FocusTimer to call ────────────────────────────────

  /// Update the media item shown in the notification.
  void updateSessionMediaItem({required String title, required String artist, required Duration duration}) {
    mediaItem.add(
      MediaItem(
        id: 'focus_session',
        album: 'Focus',
        title: title,
        artist: artist,
        duration: duration,
        artUri: null, // Could add an app icon URI here
      ),
    );
  }

  /// Update the playback state displayed on the notification and lock-screen.
  void updateSessionPlaybackState({
    required bool isPlaying,
    required Duration position,
    required Duration bufferedPosition,
    required Duration duration,
  }) {
    playbackState.add(
      PlaybackState(
        controls: [
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {MediaAction.play, MediaAction.pause, MediaAction.stop, MediaAction.skipToNext},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: bufferedPosition,
        speed: 1.0,
      ),
    );
  }

  /// Clear the media session when the focus session ends.
  Future<void> clearSession() async {
    playbackState.add(PlaybackState(controls: [], processingState: AudioProcessingState.idle, playing: false));
    mediaItem.add(null);
  }

  /// Initialise the handler from a static/top-level entry point.
  ///
  /// Call once from [setupDependencyInjection] before the app starts.
  static Future<FocusAudioHandler> init() async {
    try {
      final handler = await AudioService.init<FocusAudioHandler>(
        builder: () => FocusAudioHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId: NotificationConstants.focusChannelId,
          androidNotificationChannelName: NotificationConstants.focusChannelName,
          androidNotificationChannelDescription: NotificationConstants.focusChannelDesc,
          androidNotificationIcon: 'mipmap/launcher_icon',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidNotificationClickStartsActivity: true,
          // Show compact: play/pause, skip, stop
          notificationColor: const Color(0xFF09090b),
        ),
      );
      return handler;
    } catch (e) {
      debugPrint('FocusAudioHandler.init failed: $e');
      rethrow;
    }
  }
}
