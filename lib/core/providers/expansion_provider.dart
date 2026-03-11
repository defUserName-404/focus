import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expansion_provider.g.dart';

@Riverpod(keepAlive: true)
class Expansion extends _$Expansion {
  @override
  Map<String, bool> build() {
    return {};
  }

  bool isExpanded(String id, {bool defaultValue = false}) {
    return state[id] ?? defaultValue;
  }

  void toggle(String id, {bool defaultValue = false}) {
    final current = state[id] ?? defaultValue;
    state = {...state, id: !current};
  }

  void setExpanded(String id, bool expanded) {
    state = {...state, id: expanded};
  }
}
