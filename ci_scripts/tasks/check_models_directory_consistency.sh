#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

matches=$(
  rg --line-number \
    --glob 'Incomes/Sources/**/Models/*.swift' \
    --glob 'Widgets/Sources/**/Models/*.swift' \
    --glob 'Watch/Sources/**/Models/*.swift' \
    '@ViewBuilder|: View\b|: LabelStyle\b' \
    Incomes/Sources Widgets/Sources Watch/Sources || true
)

if [[ -n "$matches" ]]; then
  echo "Models directory consistency check failed." >&2
  echo "Move View-related code out of */Sources/**/Models/." >&2
  echo "$matches" >&2
  exit 1
fi

echo "Models directory consistency check passed."
