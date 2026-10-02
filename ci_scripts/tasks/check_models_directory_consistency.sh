#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

if ! command -v rg >/dev/null 2>&1; then
  echo "Source boundary check could not run: ripgrep is unavailable." >&2
  exit 2
fi

set +e
matches=$(
  rg --line-number \
    --glob 'Incomes/Sources/**/Models/*.swift' \
    --glob 'Widgets/Sources/**/Models/*.swift' \
    --glob 'Watch/Sources/**/Models/*.swift' \
    '@ViewBuilder|: View\b|: LabelStyle\b' \
    Incomes/Sources Widgets/Sources Watch/Sources
)
search_status=$?
set -e
if (( search_status > 1 )); then
  echo "Source boundary check could not run: ripgrep exited $search_status." >&2
  exit 2
fi

if [[ -n "$matches" ]]; then
  echo "Models directory consistency check failed." >&2
  echo "Move View-related code out of */Sources/**/Models/." >&2
  echo "$matches" >&2
  exit 1
fi

echo "Models directory consistency check passed."
