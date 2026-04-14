#!/bin/bash

set -euo pipefail

echo "Running Focus review checks..."

echo "1) Formatting check"
dart format . --line-length=120 --set-exit-if-changed

echo "2) Static analysis"
flutter analyze

echo "3) Basic logging anti-pattern check"
if rg --line-number "\b(print|debugPrint)\s*\(" lib; then
  echo "Found print/debugPrint usage. Replace with LogService."
  exit 1
else
  echo "No print/debugPrint usage detected in lib/."
fi

echo "4) Provider generation hint"
if rg --line-number "@(Riverpod|riverpod)" lib >/dev/null; then
  echo "Riverpod annotations detected. Ensure generated files are current when providers changed:"
  echo "  dart run build_runner build --delete-conflicting-outputs"
fi

echo "5) Optional tests"
if [[ -d test ]]; then
  flutter test
else
  echo "No test directory found, skipping flutter test."
fi

echo "Review checks completed."
