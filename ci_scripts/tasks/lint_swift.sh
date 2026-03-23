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

source "$repository_root/ci_scripts/lib/swiftlint.sh"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This script must run inside a git repository." >&2
  exit 1
fi

should_skip_environment_check=false
if [[ "${CI_SKIP_ENV_CHECK:-0}" == "1" || "${CI_SKIP_ENV_CHECK:-}" == "true" ]]; then
  should_skip_environment_check=true
fi

if ! $should_skip_environment_check; then
  bash "$repository_root/ci_scripts/tasks/check_environment.sh" --profile format
fi

swift_files=()
while IFS= read -r -d '' file; do
  swift_files+=("$file")
done < <(git ls-files -z -- '*.swift')

if [[ ${#swift_files[@]} -eq 0 ]]; then
  echo "No tracked Swift files found to lint."
  exit 0
fi

swiftlint_binary=$(ci_swiftlint_resolve_binary "$repository_root")

echo "Linting tracked Swift files with SwiftLint..."
"$swiftlint_binary" lint --quiet --no-cache --strict "${swift_files[@]}"
echo "Finished linting tracked Swift files."
