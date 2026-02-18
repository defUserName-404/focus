import 'package:flutter/material.dart';

import '../constants/route_constants.dart';

/// Global navigator key shared across the app.
///
/// Assigned to the root [MaterialApp] so that services (notification
/// taps, deep links) can navigate without a [BuildContext].
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Navigate to the focus session screen, preventing duplicate pushes.
///
/// Checks the current route before pushing — if we're already on the
/// focus session screen, this is a no-op.
void navigateToFocusSession({BuildContext? context}) {
  final nav = context != null ? Navigator.of(context, rootNavigator: true) : rootNavigatorKey.currentState;
  if (nav == null) return;

  // Check if the current route is already the focus session screen.
  bool alreadyOnFocusScreen = false;
  nav.popUntil((route) {
    if (route.settings.name == RouteConstants.focusSessionRoute) {
      alreadyOnFocusScreen = true;
    }
    return true; // don't actually pop — just inspect
  });

  if (!alreadyOnFocusScreen) {
    nav.pushNamed(RouteConstants.focusSessionRoute);
  }
}
