/// Pure utility for computing the dashboard greeting.
///
/// Returns a time-of-day greeting, optionally personalised with [name].
library;

/// Returns the time-of-day greeting for [now], optionally suffixed with
/// ", [name]".
///
/// Buckets (local time):
///   05:00–11:59  → "Good morning"
///   12:00–16:59  → "Good afternoon"
///   17:00–20:59  → "Good evening"
///   21:00–04:59  → "Working late"
///
/// [name] is trimmed; if empty or null it is omitted entirely.
String greetingFor({String? name, DateTime? now}) {
  final t = (now ?? DateTime.now()).hour;
  final base = t < 5
      ? 'Working late'
      : t < 12
      ? 'Good morning'
      : t < 17
      ? 'Good afternoon'
      : t < 21
      ? 'Good evening'
      : 'Working late';

  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty) return base;
  return '$base, $trimmed';
}
