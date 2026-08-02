/// Compile-time Google OAuth client configuration for Apple platforms.
///
/// Pass at build/run time:
/// ```bash
/// fvm flutter run --dart-define=GOOGLE_CLIENT_ID=YOUR_ID.apps.googleusercontent.com
/// ```
///
/// Also set the same value (and reversed URL scheme) in
/// `ios/Flutter/GoogleSignIn.xcconfig` and `macos/Flutter/GoogleSignIn.xcconfig`
/// so `GIDClientID` is present in Info.plist. See `.agents/docs/commands.md`.
abstract final class GoogleOAuthConfig {
  const GoogleOAuthConfig._();

  static const clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

  static bool get isConfigured => clientId.isNotEmpty;

  /// Reversed iOS/macOS URL scheme for `CFBundleURLSchemes`
  /// (`123-abc.apps.googleusercontent.com` → `com.googleusercontent.apps.123-abc`).
  static String? get reversedClientId {
    if (!isConfigured) return null;
    const suffix = '.apps.googleusercontent.com';
    if (!clientId.endsWith(suffix)) return null;
    final prefix = clientId.substring(0, clientId.length - suffix.length);
    return 'com.googleusercontent.apps.$prefix';
  }
}
