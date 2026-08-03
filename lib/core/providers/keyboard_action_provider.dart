import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple notifier that increments a counter on each call.
/// Keyboard shortcuts increment it; UI widgets listen and react.
class ToggleNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

/// Increments each time the user presses the filter keyboard shortcut.
/// The filter trigger widget watches this and toggles its popover/sheet.
final filterToggleProvider = NotifierProvider<ToggleNotifier, int>(ToggleNotifier.new);

/// Increments each time the user presses the search keyboard shortcut.
/// The search bar watches this and requests focus.
final searchFocusToggleProvider = NotifierProvider<ToggleNotifier, int>(ToggleNotifier.new);
