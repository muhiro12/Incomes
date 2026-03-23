#!/usr/bin/env bash
set -euo pipefail

argument_count=$#
if [[ $argument_count -ne 0 ]]; then
  echo "This script does not accept arguments." >&2
  exit 2
fi

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repository_root=$(cd "$script_directory/../.." && pwd)
cd "$repository_root"

run_swiftlint_fallback() {
  local swift_files=()
  while IFS= read -r -d '' file; do
    swift_files+=("$file")
  done < <(git ls-files -z -- '*.swift')

  if [[ ${#swift_files[@]} -eq 0 ]]; then
    echo "No tracked Swift files found."
    return 0
  fi

  if ! command -v swiftlint >/dev/null 2>&1; then
    echo "pre-commit is not installed, and swiftlint is also unavailable." >&2
    echo "Install one of the following and retry:" >&2
    echo "- pipx install pre-commit" >&2
    echo "- brew install pre-commit" >&2
    echo "- brew install swiftlint" >&2
    exit 1
  fi

  echo "pre-commit is not installed. Falling back to direct SwiftLint checks for tracked Swift files..."
  swiftlint lint --quiet --no-cache --fix --format "${swift_files[@]}"
  swiftlint lint --quiet --no-cache --strict "${swift_files[@]}"
}

if command -v pre-commit >/dev/null 2>&1; then
  echo "Running pre-commit checks..."
  pre_commit_output=$(mktemp "${TMPDIR:-/tmp}/pre-commit.XXXXXX.log")
  set +e
  pre-commit run --all-files 2>&1 | tee "$pre_commit_output"
  pre_commit_status=${PIPESTATUS[0]}
  set -e

  if [[ $pre_commit_status -eq 0 ]]; then
    rm -f "$pre_commit_output"
    exit 0
  fi

  if grep -q --fixed-strings "files were modified by this hook" "$pre_commit_output"; then
    rm -f "$pre_commit_output"
    echo "pre-commit reported formatter edits. Running equivalent SwiftLint checks directly..."
    run_swiftlint_fallback
    exit 0
  fi

  cat "$pre_commit_output" >&2
  rm -f "$pre_commit_output"
  exit "$pre_commit_status"
else
  run_swiftlint_fallback
fi
