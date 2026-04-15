import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_graph_providers.g.dart';
part 'tapped_date_provider.part.dart';

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
