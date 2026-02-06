import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/projects/data/models/project_model.dart';

class IsarDatabase {
  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open([ProjectModelSchema], directory: dir.path, name: 'focus');

    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
