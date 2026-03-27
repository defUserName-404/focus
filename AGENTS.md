# Focus - AI Agent Guidelines

> This document provides comprehensive instructions for AI coding agents working on the Focus codebase.
> For detailed documentation, see the `.agents/` directory.

## Quick Reference

| Category | Document |
|----------|----------|
| Code Style | [.agents/CODING_STYLE.md](.agents/CODING_STYLE.md) |
| Architecture | [.agents/ARCHITECTURE.md](.agents/ARCHITECTURE.md) |
| Commands | [.agents/COMMANDS.md](.agents/COMMANDS.md) |
| Patterns | [.agents/PATTERNS.md](.agents/PATTERNS.md) |
| **Audit Results** | [.agents/AUDIT_RESULTS.md](.agents/AUDIT_RESULTS.md) |
| **Feature Plans** | [.agents/FEATURE_PLANS.md](.agents/FEATURE_PLANS.md) |

---

## Project Overview

**Focus** is a cross-platform Flutter productivity app for managing deep work sessions, projects, and tasks. It is fully offline and privacy-first - all data stays on the user's device.

### Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter (Dart SDK >=3.10.0 <4.0.0) |
| State Management | Riverpod with code generation |
| Dependency Injection | GetIt |
| Database/ORM | Drift (SQLite) |
| UI Library | ForUI (forui) |
| Audio | audioplayers, audio_service, audio_session |
| Notifications | flutter_local_notifications |

---

## Essential Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (REQUIRED after changing providers, models, or DB schema)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch --delete-conflicting-outputs

# Run the app (debug mode)
flutter run

# Analyze code for issues
flutter analyze

# Format code (120 char line width)
dart format . --line-length=120

# Build release APK
flutter build apk --release --split-per-abi

# Build release iOS (unsigned)
flutter build ios --release --no-codesign
```

### Testing (No tests currently exist)

```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage
```

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/                        # Shared infrastructure
│   ├── app.dart                 # Root FocusApp widget
│   ├── config/theme/            # Theme configuration
│   ├── constants/               # App-wide constants
│   ├── di/injection.dart        # GetIt dependency injection setup
│   ├── providers/               # Core Riverpod providers
│   ├── routing/                 # go_router routes and configuration
│   ├── services/                # Core services (DB, audio, notifications, logging)
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Reusable UI widgets
└── features/                    # Feature modules (Clean Architecture)
    ├── home/                    # Home screen
    ├── projects/                # Project management
    ├── tasks/                   # Task management
    ├── session/                 # Focus session management
    └── settings/                # App settings
```

### Feature Module Structure

Each feature follows Clean Architecture:

```
features/<feature>/
├── data/
│   ├── datasources/             # Local/remote data sources
│   ├── mappers/                 # DB model <-> Domain entity mappers
│   ├── models/                  # Drift table definitions
│   └── repositories/            # Repository implementations
├── domain/
│   ├── entities/                # Immutable domain entities
│   ├── repositories/            # Repository interfaces (abstract)
│   └── services/                # Business logic services
└── presentation/
    ├── commands/                # UI action handlers
    ├── providers/               # Riverpod providers
    ├── screens/                 # Full-screen pages
    └── widgets/                 # Feature-specific widgets
```

---

## Critical Rules for Agents

### 1. Always Run Code Generation

After modifying any of these, run `dart run build_runner build --delete-conflicting-outputs`:
- Riverpod providers (`@Riverpod`, `@riverpod` annotations)
- Drift database tables or queries
- Files with `part '*.g.dart'` directives

### 2. Follow Clean Architecture

- **Domain layer** has NO dependencies on data or presentation
- **Data layer** depends only on domain
- **Presentation layer** depends on domain (via providers)

### 3. Use the Result Type for Error Handling

Services return `Result<T>` instead of throwing exceptions:

```dart
Future<Result<Project>> createProject(...) async {
  try {
    // ... operation
    return Success(project);
  } catch (e, st) {
    return Failure(DatabaseFailure('Failed to create project', error: e, stackTrace: st));
  }
}

// Caller uses pattern matching:
switch (result) {
  case Success(:final value): // handle success
  case Failure(:final failure): // handle failure
}
```

### 4. Use LogService for Logging

Never use `print()` or `debugPrint()`. Always use:

```dart
final _log = LogService.instance;

_log.debug('Debug message', tag: 'ClassName');
_log.info('Info message', tag: 'ClassName');
_log.warning('Warning', tag: 'ClassName', error: e, stackTrace: st);
_log.error('Error', tag: 'ClassName', error: e, stackTrace: st);
```

### 5. Use GetIt for Dependency Injection

All services are registered in `lib/core/di/injection.dart`. Access via:

```dart
import 'package:focus/core/di/injection.dart';

final service = getIt<ServiceType>();
```

### 6. Immutable Domain Entities

Domain entities must be:
- Marked with `@immutable`
- Extend `Equatable`
- Have `const` constructors
- Use `copyWith` for modifications (defined in `*_extensions.dart`)

### 7. Database Migrations

When changing the database schema:
1. Increment `schemaVersion` in `db_service.dart`
2. Add migration logic in the `onUpgrade` callback
3. Test migration with existing data

---

## Important Files to Know

| File | Purpose |
|------|---------|
| `lib/core/di/injection.dart` | All dependency registration |
| `lib/core/services/db_service.dart` | Database definition and migrations |
| `lib/core/utils/result.dart` | Result type for error handling |
| `lib/core/services/log_service.dart` | Centralized logging |
| `lib/core/routing/app_router.dart` | GoRouter configuration |
| `lib/core/routing/routes.dart` | Route paths and helper builders |
| `lib/core/constants/app_constants.dart` | UI constants (spacing, sizes) |
| `lib/core/config/theme/app_theme.dart` | Theme configuration |
| `pubspec.yaml` | Dependencies and assets |
| `analysis_options.yaml` | Linter rules |

---

## Agent Self-Update Protocol

**IMPORTANT**: When making significant changes to the codebase, update the agent documentation:

1. **New feature added**: Update `.agents/ARCHITECTURE.md` and `.agents/PATTERNS.md` with new patterns
2. **New dependency added**: Update tech stack in this file
3. **Build/test process changed**: Update `.agents/COMMANDS.md`
4. **Code style changed**: Update `.agents/CODING_STYLE.md`
5. **New patterns established**: Add examples to `.agents/PATTERNS.md`

Changes that warrant documentation updates:
- New architectural patterns or layers
- New utility classes or services
- Changes to the DI setup
- Database schema changes
- New code generation requirements
- Breaking changes to existing patterns

---

## Platform Support

| Platform | Notes |
|----------|-------|
| Android | Full support, media session controls |
| iOS | Full support, media session controls |
| macOS | Partial support, local notifications only |
| Linux | Basic support, no notifications |
| Windows | Basic support, no notifications |
| Web | Basic support, no notifications/audio session |

Use `PlatformUtils` for platform-specific branching:

```dart
if (PlatformUtils.supportsLocalNotifications) { ... }
if (PlatformUtils.supportsMediaSession) { ... }
if (PlatformUtils.isDesktop) { ... }
if (PlatformUtils.isMobile) { ... }
```

---

## Common Tasks

### Adding a New Feature

1. Create feature directory: `lib/features/<name>/`
2. Create subdirectories: `data/`, `domain/`, `presentation/`
3. Define domain entities in `domain/entities/`
4. Define repository interface in `domain/repositories/i_<name>_repository.dart`
5. Implement repository in `data/repositories/<name>_repository_impl.dart`
6. Create service in `domain/services/<name>_service.dart`
7. Register in `lib/core/di/injection.dart`
8. Create Riverpod providers in `presentation/providers/`
9. Create screens and widgets

### Adding a New Drift Table

1. Create model in `data/models/<name>_model.dart`
2. Add table to `@DriftDatabase` annotation in `db_service.dart`
3. Run code generation
4. Create mapper extensions in `data/mappers/`
5. Create datasource interface and implementation

### Adding a New Screen

1. Create screen in `presentation/screens/<name>_screen.dart`
2. Use `ConsumerWidget` or `ConsumerStatefulWidget` for Riverpod
3. Add route constant/helper in `lib/core/routing/routes.dart`
4. Add route handling in `lib/core/routing/app_router.dart`
5. Use `context.go` / `context.push` from UI/commands

---

## License

CC BY-NC 4.0 - Creative Commons Attribution-NonCommercial 4.0 International
