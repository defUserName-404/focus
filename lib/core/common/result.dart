/// A discriminated union representing either a successful [value] or an
/// [AppFailure].
///
/// Prefer this over throwing exceptions in repositories and services.
/// The caller pattern-matches to handle both outcomes explicitly:
///
/// ```dart
/// final result = await repo.startSession(session);
/// switch (result) {
///   case Success(:final value): /* use value */
///   case Failure(:final failure): /* handle failure */
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Whether this result is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Returns the value if [Success], or calls [fallback] on failure.
  T getOrElse(T Function(AppFailure failure) fallback) => switch (this) {
    Success(:final value) => value,
    Failure(:final failure) => fallback(failure),
  };

  /// Returns the value if [Success], or `null` on failure.
  T? getOrNull() => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// Transforms the success value. Failures pass through unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Success(transform(value)),
    Failure(:final failure) => Failure(failure),
  };

  /// Flat-maps the success value into another [Result].
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Success(:final value) => transform(value),
    Failure(:final failure) => Failure(failure),
  };

  /// Execute [action] when this is a [Success]. Returns `this` for chaining.
  Result<T> onSuccess(void Function(T value) action) {
    if (this case Success(:final value)) action(value);
    return this;
  }

  /// Execute [action] when this is a [Failure]. Returns `this` for chaining.
  Result<T> onFailure(void Function(AppFailure failure) action) {
    if (this case Failure(:final failure)) action(failure);
    return this;
  }
}

/// Successful result wrapping [value].
final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failed result wrapping an [AppFailure].
final class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Failure<T> && failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failure($failure)';
}

// ---------------------------------------------------------------------------
// Failure hierarchy
// ---------------------------------------------------------------------------

/// Base class for all typed failures in the app.
///
/// Subclasses represent specific failure categories so callers can
/// pattern-match on the type to decide how to recover or what to show.
sealed class AppFailure {
  /// Human-readable description of what went wrong.
  final String message;

  /// The original exception / error, if any.
  final Object? error;

  /// Stack trace captured at the failure point.
  final StackTrace? stackTrace;

  const AppFailure(this.message, {this.error, this.stackTrace});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == runtimeType &&
          other is AppFailure &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => '$runtimeType($message)';
}

/// A database read / write / migration failure.
final class DatabaseFailure extends AppFailure {
  const DatabaseFailure(super.message, {super.error, super.stackTrace});
}

/// The requested entity was not found.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message, {super.error, super.stackTrace});
}

/// A focus session lifecycle error (e.g. invalid state transition).
final class SessionFailure extends AppFailure {
  const SessionFailure(super.message, {super.error, super.stackTrace});
}

/// An audio playback or audio-session activation failure.
final class AudioFailure extends AppFailure {
  const AudioFailure(super.message, {super.error, super.stackTrace});
}

/// A notification display / scheduling failure.
final class NotificationFailure extends AppFailure {
  const NotificationFailure(super.message, {super.error, super.stackTrace});
}

/// Catch-all for truly unexpected errors.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message, {super.error, super.stackTrace});
}
