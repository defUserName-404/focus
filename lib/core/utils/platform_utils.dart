import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
  /// Whether the app is running on a desktop OS (Windows, Linux, macOS).
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  /// Whether the app is running on a mobile OS (Android, iOS).
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Whether the app is running on the web.
  static bool get isWeb => kIsWeb;

  /// Whether the platform supports native local notifications.
  ///
  /// Desktop platforms (except macOS via `flutter_local_notifications`)
  /// have limited or no support.
  static bool get supportsLocalNotifications {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  /// Whether the platform supports OS-level media session controls
  /// (lock-screen, notification shade, headphone buttons).
  static bool get supportsMediaSession {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Resolve the [FormFactor] from the current window width.
  ///
  /// Uses Material 3 breakpoints:
  ///  - compact: < 600 dp
  ///  - expanded: >= 600 dp
  static FormFactor formFactorOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 600 ? FormFactor.compact : FormFactor.expanded;
  }
}

/// Extension on [BuildContext] for quick form-factor checks.
extension FormFactorX on BuildContext {
  FormFactor get formFactor => PlatformUtils.formFactorOf(this);
  bool get isCompact => formFactor == FormFactor.compact;
  bool get isExpanded => formFactor == FormFactor.expanded;
}
