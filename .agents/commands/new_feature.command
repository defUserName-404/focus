#!/bin/bash

set -euo pipefail

FEATURE_NAME="${1:-}"

if [[ -z "$FEATURE_NAME" ]]; then
  echo "Error: feature name is required"
  echo "Usage: bash .agents/commands/new_feature.command <feature_name>"
  exit 1
fi

# Normalize to snake_case.
FEATURE_NAME="$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr '-' '_')"

# snake_case -> PascalCase helper.
pascal_case() {
  echo "$1" | awk -F '_' '{
    for (i = 1; i <= NF; i++) {
      $i = toupper(substr($i, 1, 1)) substr($i, 2)
    }
    gsub("_", "")
    print
  }'
}

FEATURE_CLASS="$(pascal_case "$FEATURE_NAME")"

ROOT="lib/features/$FEATURE_NAME"

echo "Creating feature module: $FEATURE_NAME"

mkdir -p "$ROOT/data/models"
mkdir -p "$ROOT/data/datasources"
mkdir -p "$ROOT/data/mappers"
mkdir -p "$ROOT/data/repositories"
mkdir -p "$ROOT/domain/entities"
mkdir -p "$ROOT/domain/repositories"
mkdir -p "$ROOT/domain/services"
mkdir -p "$ROOT/presentation/screens"
mkdir -p "$ROOT/presentation/widgets"
mkdir -p "$ROOT/presentation/providers"
mkdir -p "$ROOT/presentation/commands"

cat > "$ROOT/domain/entities/${FEATURE_NAME}.dart" << EOF
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class ${FEATURE_CLASS} extends Equatable {
  const ${FEATURE_CLASS}({
    this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}
EOF

cat > "$ROOT/domain/entities/${FEATURE_NAME}_extensions.dart" << EOF
import '${FEATURE_NAME}.dart';

extension ${FEATURE_CLASS}CopyWith on ${FEATURE_CLASS} {
  ${FEATURE_CLASS} copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ${FEATURE_CLASS}(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
EOF

cat > "$ROOT/domain/repositories/i_${FEATURE_NAME}_repository.dart" << EOF
import '../entities/${FEATURE_NAME}.dart';

abstract interface class I${FEATURE_CLASS}Repository {
  Future<List<${FEATURE_CLASS}>> getAll();
  Future<${FEATURE_CLASS}> create(${FEATURE_CLASS} entity);
  Future<void> update(${FEATURE_CLASS} entity);
  Future<void> delete(int id);
  Stream<List<${FEATURE_CLASS}>> watchAll();
}
EOF

cat > "$ROOT/domain/services/${FEATURE_NAME}_service.dart" << EOF
import 'package:focus/core/utils/result.dart';

import '../entities/${FEATURE_NAME}.dart';
import '../repositories/i_${FEATURE_NAME}_repository.dart';

class ${FEATURE_CLASS}Service {
  ${FEATURE_CLASS}Service(this._repository);

  final I${FEATURE_CLASS}Repository _repository;

  Future<Result<${FEATURE_CLASS}>> create() async {
    try {
      final now = DateTime.now();
      final entity = ${FEATURE_CLASS}(createdAt: now, updatedAt: now);
      final created = await _repository.create(entity);
      return Success(created);
    } catch (e, st) {
      return Failure(DatabaseFailure('Failed to create ${FEATURE_NAME}', error: e, stackTrace: st));
    }
  }
}
EOF

cat > "$ROOT/data/models/${FEATURE_NAME}_model.dart" << EOF
import 'package:drift/drift.dart';

class ${FEATURE_CLASS}Table extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
EOF

cat > "$ROOT/data/datasources/${FEATURE_NAME}_local_datasource.dart" << EOF
import 'package:focus/core/services/db_service.dart';

abstract interface class I${FEATURE_CLASS}LocalDataSource {
  Future<List<dynamic>> getAll();
}

class ${FEATURE_CLASS}LocalDataSourceImpl implements I${FEATURE_CLASS}LocalDataSource {
  ${FEATURE_CLASS}LocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<dynamic>> getAll() async {
    return <dynamic>[];
  }
}
EOF

cat > "$ROOT/data/mappers/${FEATURE_NAME}_extensions.dart" << EOF
// Add mapper extensions between drift rows and domain entities.
EOF

cat > "$ROOT/data/repositories/${FEATURE_NAME}_repository_impl.dart" << EOF
import '../../domain/entities/${FEATURE_NAME}.dart';
import '../../domain/repositories/i_${FEATURE_NAME}_repository.dart';
import '../datasources/${FEATURE_NAME}_local_datasource.dart';

class ${FEATURE_CLASS}RepositoryImpl implements I${FEATURE_CLASS}Repository {
  ${FEATURE_CLASS}RepositoryImpl(this._localDataSource);

  final I${FEATURE_CLASS}LocalDataSource _localDataSource;

  @override
  Future<List<${FEATURE_CLASS}>> getAll() async {
    return <${FEATURE_CLASS}>[];
  }

  @override
  Stream<List<${FEATURE_CLASS}>> watchAll() {
    return const Stream.empty();
  }

  @override
  Future<${FEATURE_CLASS}> create(${FEATURE_CLASS} entity) async {
    return entity;
  }

  @override
  Future<void> update(${FEATURE_CLASS} entity) async {}

  @override
  Future<void> delete(int id) async {}
}
EOF

cat > "$ROOT/presentation/providers/${FEATURE_NAME}_provider.dart" << EOF
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:focus/core/di/injection.dart';

import '../../domain/repositories/i_${FEATURE_NAME}_repository.dart';

part '${FEATURE_NAME}_provider.g.dart';

@Riverpod(keepAlive: true)
I${FEATURE_CLASS}Repository ${FEATURE_NAME}Repository(Ref ref) {
  return getIt<I${FEATURE_CLASS}Repository>();
}
EOF

cat > "$ROOT/presentation/commands/${FEATURE_NAME}_commands.dart" << EOF
import 'package:flutter/widgets.dart';

class ${FEATURE_CLASS}Commands {
  static void openList(BuildContext context) {
    // Add route navigation when routes are defined.
  }
}
EOF

cat > "$ROOT/presentation/screens/${FEATURE_NAME}_screen.dart" << EOF
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

class ${FEATURE_CLASS}Screen extends ConsumerWidget {
  const ${FEATURE_CLASS}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return fu.FScaffold(
      header: const fu.FHeader.nested(
        title: Text('${FEATURE_CLASS}'),
      ),
      child: const Center(
        child: Text('${FEATURE_CLASS} screen'),
      ),
    );
  }
}
EOF

cat > "$ROOT/presentation/widgets/${FEATURE_NAME}_card.dart" << EOF
import 'package:flutter/widgets.dart';

class ${FEATURE_CLASS}Card extends StatelessWidget {
  const ${FEATURE_CLASS}Card({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
EOF

echo "Created feature scaffolding under $ROOT"
echo "Next steps:"
echo "1) Register datasource/repository/service in lib/core/di/injection.dart"
echo "2) Add table to db_service.dart and migrations if needed"
echo "3) Run codegen: dart run build_runner build --delete-conflicting-outputs"
echo "4) Add route constants and router entries"
echo "5) Update docs: AGENTS.md and .agents/docs/* if architecture/workflow changed"
