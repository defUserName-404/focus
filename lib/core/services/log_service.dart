import 'dart:developer' as developer;

/// Centralised logging service.
///
/// All app-level logging flows through this singleton so that:
/// - Log output can be toggled / filtered in one place.
/// - Production builds can redirect to Crashlytics / Sentry later.
/// - `debugPrint` calls scattered across the codebase are eliminated.
///
/// Usage:
/// ```dart
/// final _log = LogService.instance;
/// _log.info('Session started', tag: 'FocusTimer');
/// _log.error('DB write failed', tag: 'FocusRepo', error: e, stackTrace: st);
/// ```
class LogService {
  LogService._();

  static final LogService _instance = LogService._();
  static LogService get instance => _instance;

  /// Minimum level that will actually be emitted. Everything below is
  /// silently discarded. Defaults to [LogLevel.debug] in dev builds.
  LogLevel minLevel = LogLevel.debug;

  // ---- Public API ----------------------------------------------------------

  void debug(String message, {String? tag}) {
    _emit(LogLevel.debug, message, tag: tag);
  }

  void info(String message, {String? tag}) {
    _emit(LogLevel.info, message, tag: tag);
  }

  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _emit(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _emit(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // ---- Internal ------------------------------------------------------------

  void _emit(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minLevel.index) return;

    final prefix = tag != null ? '[$tag] ' : '';
    final errorSuffix = error != null ? ' | error: $error' : '';

    developer.log(
      '$prefix$message$errorSuffix',
      name: level.name.toUpperCase(),
      level: level.devToolsLevel,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Log severity levels, ordered from least to most severe.
enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000);

  /// Maps to `dart:developer` log levels for DevTools filtering.
  final int devToolsLevel;

  const LogLevel(this.devToolsLevel);
}
