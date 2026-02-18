/// State for the focus session screen's UI chrome (controls visibility,
/// completion overlay, navigation guard).
class FocusScreenState {
  final bool isControlsVisible;
  final bool showCompletion;
  final bool hasPopped;

  const FocusScreenState({
    this.isControlsVisible = true,
    this.showCompletion = false,
    this.hasPopped = false,
  });

  FocusScreenState copyWith({
    bool? isControlsVisible,
    bool? showCompletion,
    bool? hasPopped,
  }) {
    return FocusScreenState(
      isControlsVisible: isControlsVisible ?? this.isControlsVisible,
      showCompletion: showCompletion ?? this.showCompletion,
      hasPopped: hasPopped ?? this.hasPopped,
    );
  }
}
