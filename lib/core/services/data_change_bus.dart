/// Lightweight bus for local data mutations that should trigger auto-sync.
///
/// Domain/data layers emit [notify] after successful writes. Sync listens
/// and debounces a cloud sync without creating a feature→feature dependency.
class DataChangeBus {
  final List<void Function()> _listeners = [];

  void addListener(void Function() listener) => _listeners.add(listener);

  void removeListener(void Function() listener) => _listeners.remove(listener);

  void notify() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }
}
