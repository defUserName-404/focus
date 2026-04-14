#!/bin/bash

set -euo pipefail

TYPE="${1:-}"
SCOPE="${2:-}"
SUMMARY="${3:-}"
EXTRA_BODY="${4:-}"

if [[ -z "$TYPE" || -z "$SCOPE" || -z "$SUMMARY" ]]; then
  echo "Usage: bash .agents/commands/git_commit_writer.command <type> <scope> <summary> [why]"
  echo "Types: feat|fix|refactor|docs|test|chore"
  exit 1
fi

case "$TYPE" in
  feat|fix|refactor|docs|test|chore)
    ;;
  *)
    echo "Error: unsupported type '$TYPE'"
    echo "Allowed: feat|fix|refactor|docs|test|chore"
    exit 1
    ;;
esac

if [[ -z "$(git diff --cached --name-only)" ]]; then
  echo "Error: no staged changes. Stage files before running this command."
  exit 1
fi

TITLE="$TYPE($SCOPE): $SUMMARY"
FILES_SECTION="$(git diff --cached --name-status | sed 's/^/- /')"
STAT_SECTION="$(git diff --cached --stat)"

BODY="Why:\n${EXTRA_BODY:-Update grouped changes with clear intent and atomic scope.}\n\nChanges:\n$FILES_SECTION\n\nDiffstat:\n$STAT_SECTION"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  echo "DRY RUN"
  echo "Title: $TITLE"
  echo
  printf "%b\n" "$BODY"
  exit 0
fi

git commit -m "$TITLE" -m "$BODY"

echo "Committed: $TITLE"
