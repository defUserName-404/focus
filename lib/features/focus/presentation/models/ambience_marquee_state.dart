/// All the data the ambience marquee row needs to render.
///
/// Separated from the provider to keep the model testable and
/// the provider file focused on state management.
class AmbienceMarqueeState {
  /// `null` means the row should be hidden entirely.
  final String? soundLabel;
  final bool isMuted;
  final bool isPaused;
  final bool isBreak;

  const AmbienceMarqueeState({
    this.soundLabel,
    this.isMuted = false,
    this.isPaused = false,
    this.isBreak = false,
  });

  /// Whether the marquee text should scroll.
  bool get isScrolling =>
      soundLabel != null && !isMuted && !isPaused && !isBreak;

  /// Whether the visuals should appear dimmed.
  bool get isDimmed => isMuted || isPaused;

  /// Whether the entire row should be hidden.
  bool get isHidden => soundLabel == null || isBreak;
}
