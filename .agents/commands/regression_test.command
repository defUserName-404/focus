#!/bin/bash

set -euo pipefail

echo "Running Focus regression workflow..."

echo "1) Dependencies"
flutter pub get

echo "2) Code generation"
dart run build_runner build --delete-conflicting-outputs

echo "3) Formatting check"
dart format . --line-length=120 --set-exit-if-changed

echo "4) Static analysis"
flutter analyze

echo "5) Tests"
if [[ -d test ]]; then
  flutter test
else
  echo "No test directory found, skipping flutter test."
fi

if [[ "${FOCUS_RUN_BUILD:-0}" == "1" ]]; then
  echo "6) Optional debug build"
  flutter build apk --debug
else
  echo "6) Skipping build step (set FOCUS_RUN_BUILD=1 to enable)."
fi

echo "Regression workflow completed."
