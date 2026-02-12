import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_graph_providers.g.dart';

@riverpod
class SelectedYearNotifier extends _$SelectedYearNotifier {
  @override
  int build() {
    return DateTime.now().year;
  }

  void setYear(int year) {
    state = year;
  }
}

@riverpod
class TappedDateNotifier extends _$TappedDateNotifier {
  @override
  String? build() {
    return null;
  }

  void setDate(String? date) {
    state = date;
  }
}
