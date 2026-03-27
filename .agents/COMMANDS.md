# Commands Reference

This document provides a complete reference of all build, test, lint, and development commands for the Focus project.

---

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [Development Commands](#development-commands)
3. [Code Generation](#code-generation)
4. [Testing](#testing)
5. [Building](#building)
6. [Linting and Formatting](#linting-and-formatting)
7. [Debugging](#debugging)
8. [CI/CD](#cicd)
9. [Troubleshooting](#troubleshooting)

---

## Quick Reference

| Task | Command |
|------|---------|
| Install dependencies | `flutter pub get` |
| Run code generation | `dart run build_runner build --delete-conflicting-outputs` |
| Run app (debug) | `flutter run` |
| Analyze code | `flutter analyze` |
| Format code | `dart format . --line-length=120` |
| Run all tests | `flutter test` |
| Run single test | `flutter test test/path/to/test_file.dart` |
| Build release APK | `flutter build apk --release --split-per-abi` |
| Build release iOS | `flutter build ios --release --no-codesign` |

---

## Development Commands

### Install Dependencies

```bash
# Install all pub dependencies
flutter pub get

# Upgrade dependencies to latest compatible versions
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

### Run the Application

```bash
# Run in debug mode (hot reload enabled)
flutter run

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices

# Run in release mode
flutter run --release

# Run in profile mode (for performance testing)
flutter run --profile
```

### Clean Build Artifacts

```bash
# Clean all build outputs
flutter clean

# Full clean including pub cache
flutter clean && flutter pub get
```

---

## Code Generation

### Build Runner Commands

**CRITICAL**: Run code generation after modifying:
- Riverpod providers (`@Riverpod`, `@riverpod` annotations)
- Drift database tables or queries
- Files with `part '*.g.dart'` directives

```bash
# One-time build (recommended for CI and after changes)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (during active development)
dart run build_runner watch --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean
```

### Generated File Types

| File Pattern | Generator | Source |
|--------------|-----------|--------|
| `*.g.dart` | Multiple | Riverpod, Drift, dart_mappable |
| `db_service.g.dart` | Drift | Database tables |
| `*_provider.g.dart` | Riverpod | Provider annotations |

### When to Regenerate

Run code generation when you:
1. Add/modify `@Riverpod` or `@riverpod` annotated functions/classes
2. Add/modify Drift table definitions
3. Change Drift queries or DAOs
4. Add `part '*.g.dart'` to a file
5. See "The getter 'XXXProvider' isn't defined" errors

---

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run all tests with verbose output
flutter test --reporter expanded

# Run tests with coverage
flutter test --coverage

# View coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Single Test File

```bash
# Run a specific test file
flutter test test/path/to/test_file.dart

# Example
flutter test test/features/projects/project_service_test.dart
```

### Run Tests Matching Pattern

```bash
# Run tests with names matching pattern
flutter test --name "creates project"

# Run tests in files matching glob
flutter test test/features/projects/**/*_test.dart
```

### Run Tests for Specific Platform

```bash
# Run integration tests (if any)
flutter test integration_test/

# Run widget tests only
flutter test test/widget/
```

### Test with Random Seed

```bash
# For debugging flaky tests
flutter test --test-randomize-ordering-seed=12345
```

### Test Coverage Thresholds

```bash
# Check coverage meets threshold (CI usage)
flutter test --coverage
# Then parse coverage/lcov.info
```

---

## Building

### Debug Builds

```bash
# Debug APK
flutter build apk --debug

# Debug iOS (requires macOS)
flutter build ios --debug
```

### Release Builds

```bash
# Release APK (split by ABI for smaller downloads)
flutter build apk --release --split-per-abi

# Single fat APK (all ABIs)
flutter build apk --release

# Release App Bundle for Play Store
flutter build appbundle --release

# Release iOS (unsigned, for local testing)
flutter build ios --release --no-codesign

# Release iOS (requires valid signing)
flutter build ios --release
```

### Platform-Specific Builds

```bash
# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

### Build Artifacts Location

| Platform | Debug | Release |
|----------|-------|---------|
| Android APK | `build/app/outputs/flutter-apk/app-debug.apk` | `build/app/outputs/flutter-apk/app-release.apk` |
| Android AAB | N/A | `build/app/outputs/bundle/release/app-release.aab` |
| iOS | `build/ios/Debug-iphoneos/` | `build/ios/Release-iphoneos/` |
| macOS | `build/macos/Build/Products/Debug/` | `build/macos/Build/Products/Release/` |
| Web | N/A | `build/web/` |

---

## Linting and Formatting

### Analyze Code

```bash
# Run static analysis
flutter analyze

# Analyze specific directory
flutter analyze lib/features/projects/

# Show all issues (including infos)
flutter analyze --no-fatal-infos
```

### Format Code

```bash
# Format all Dart files (120 char line width as per analysis_options.yaml)
dart format . --line-length=120

# Check formatting without changing files
dart format . --line-length=120 --set-exit-if-changed

# Format specific file
dart format lib/path/to/file.dart --line-length=120
```

### Fix Lint Issues Automatically

```bash
# Apply automatic fixes
dart fix --apply

# Preview fixes without applying
dart fix --dry-run
```

### Custom Analysis Rules

The project uses `package:flutter_lints`. Custom rules are in `analysis_options.yaml`:

```yaml
formatter:
  page_width: 120

linter:
  rules:
    # Add custom rules here
```

---

## Debugging

### Flutter DevTools

```bash
# Launch DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Or open in browser during debug run
# DevTools URL printed in console when running `flutter run`
```

### Verbose Logging

```bash
# Run with verbose logs
flutter run -v

# Run with specific log filter
flutter run --verbose --device-log-filter=focus
```

### Performance Profiling

```bash
# Run in profile mode
flutter run --profile

# Record timeline
# Use DevTools Performance tab during profile run
```

### Debug Database

```bash
# Pull database from Android device/emulator
adb exec-out run-as com.defUserName404.focus cat databases/focus.sqlite > focus_debug.sqlite

# Open with any SQLite browser
sqlite3 focus_debug.sqlite
```

---

## CI/CD

### Commit Message Convention

Use structured commit messages for feature work:

```text
feature(<scope>): <intent>
```

Examples:

```text
feature(routing): implement go_router migration
feature(desktop-ui): implement master-detail layouts
feature(tasks): implement recurring tasks support
```

Recommended scopes: `routing`, `desktop-ui`, `tasks`, `projects`, `session`, `settings`, `stats`, `sync`, `onboarding`, `docs`.

### GitHub Actions

The project uses GitHub Actions for releases. Workflow at `.github/workflows/release.yml`.

**Triggers**: Push tags matching `v*.*.*` (e.g., `v1.0.0`)

### Local CI Simulation

```bash
# Simulate CI checks locally
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format . --line-length=120 --set-exit-if-changed
flutter test
flutter build apk --release --split-per-abi
```

### Creating a Release

```bash
# 1. Update version in pubspec.yaml
# version: 1.0.3+4

# 2. Commit changes
git add -A
git commit -m "chore: bump version to 1.0.3"

# 3. Create and push tag
git tag v1.0.3
git push origin main --tags

# GitHub Actions will build and create release
```

---

## Troubleshooting

### Code Generation Issues

```bash
# Error: "XXXProvider isn't defined"
# Solution: Regenerate code
dart run build_runner build --delete-conflicting-outputs

# Error: Conflicting outputs
# Solution: Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# Error: Part directive not found
# Solution: Ensure file has correct part directive
# part 'filename.g.dart';
```

### Build Failures

```bash
# Gradle issues (Android)
cd android && ./gradlew clean && cd ..
flutter clean
flutter pub get
flutter build apk

# CocoaPods issues (iOS/macOS)
cd ios && pod deintegrate && pod install && cd ..
flutter clean
flutter pub get
flutter build ios
```

### Dependency Issues

```bash
# Reset pub cache
flutter pub cache repair

# Force fresh dependencies
flutter clean
rm -rf pubspec.lock
flutter pub get
```

### Hot Reload Not Working

```bash
# Restart with clean state
flutter clean
flutter run

# Or use hot restart (loses state)
# Press 'R' in terminal during run
```

### Database Migration Errors

```bash
# 1. Back up existing database
adb pull /data/data/com.defUserName404.focus/databases/focus.sqlite ./backup.sqlite

# 2. Uninstall app (clears database)
adb uninstall com.defUserName404.focus

# 3. Reinstall
flutter run
```

---

## Environment Requirements

### Flutter Version

```bash
# Check version
flutter --version

# Required: Flutter 3.x with Dart SDK >=3.10.0 <4.0.0
# CI uses Flutter 3.38.3
```

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| Flutter SDK | Framework | [flutter.dev](https://flutter.dev) |
| Android Studio | Android builds | [developer.android.com](https://developer.android.com/studio) |
| Xcode | iOS/macOS builds | Mac App Store |
| VS Code | IDE (optional) | [code.visualstudio.com](https://code.visualstudio.com) |

### Verify Setup

```bash
# Check Flutter doctor for issues
flutter doctor -v
```
