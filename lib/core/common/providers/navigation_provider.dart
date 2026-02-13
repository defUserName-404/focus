import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

/// Manages the bottom navigation bar state.
///
/// Keeps the selected tab index and exposes methods to switch tabs
/// programmatically from anywhere in the widget tree.
@Riverpod(keepAlive: true)
class BottomNavIndex extends _$BottomNavIndex {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }

  /// Navigate to the home tab (index 0).
  void goHome() => state = 0;
}
