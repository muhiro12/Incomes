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
