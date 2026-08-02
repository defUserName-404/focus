import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/project_template.dart';
import '../../domain/services/project_template_service.dart';

part 'project_template_provider.g.dart';

@Riverpod(keepAlive: true)
ProjectTemplateService projectTemplateService(Ref ref) {
  return getIt<ProjectTemplateService>();
}

@Riverpod(keepAlive: true)
Stream<List<ProjectTemplate>> projectTemplates(Ref ref) {
  return ref.watch(projectTemplateServiceProvider).watchAllTemplates();
}
