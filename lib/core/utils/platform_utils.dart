import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../constants/layout_breakpoints.dart';

/// Canonical platform categories for adaptive UI decisions.
///
/// The app uses two layout modes:
///  - **compact** (mobile): bottom navigation, stacked screens.
///  - **expanded** (desktop/tablet): side navigation rail or drawer,
///     master-detail panels.
enum FormFactor { compact, expanded }

/// Central point for platform detection.
///
/// All platform-specific branching goes through this class so the
/// decision is made once and consistently.
abstract final class PlatformUtils {
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  static bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// Whether the app is running on a desktop OS (Windows, Linux, macOS).
  static bool get isDesktop {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows || TargetPlatform.linux || TargetPlatform.macOS => true,
      _ => false,
    };
  }

  /// Whether the app is running on a mobile OS (Android, iOS).
  static bool get isMobile {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  /// Whether the app is running on the web.
  static bool get isWeb => kIsWeb;

  /// Whether the platform supports native local notifications.
  ///
  /// This app intentionally targets native platforms only.
  static bool get supportsLocalNotifications {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.linux ||
      TargetPlatform.windows => true,
      _ => false,
    };
  }

  /// Whether the platform supports OS-level media session controls
  /// (lock-screen, notification shade, headphone buttons).
  static bool get supportsMediaSession {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  /// Resolve the [FormFactor] from the current window width.
  ///
  /// Uses Material 3 breakpoints:
  ///  - compact: < 600 dp
  ///  - expanded: >= 600 dp
  static FormFactor formFactorOf(BuildContext context) {
    final sizeClass = LayoutBreakpoints.getWindowSizeClass(context);
    return sizeClass == WindowSizeClass.compact ? FormFactor.compact : FormFactor.expanded;
  }

  static WindowSizeClass windowSizeClassOf(BuildContext context) {
    return LayoutBreakpoints.getWindowSizeClass(context);
  }
}

/// Extension on [BuildContext] for quick form-factor checks.
extension FormFactorX on BuildContext {
  FormFactor get formFactor => PlatformUtils.formFactorOf(this);
  WindowSizeClass get windowSizeClass => PlatformUtils.windowSizeClassOf(this);
  bool get isCompact => formFactor == FormFactor.compact;
  bool get isExpanded => formFactor == FormFactor.expanded;
  bool get isMedium => windowSizeClass == WindowSizeClass.medium;
}
