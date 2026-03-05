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

source "$repository_root/ci_scripts/lib/ci_runs.sh"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This script must run inside a git repository." >&2
  exit 1
fi

runs_root="$repository_root/.build/ci_runs"
run_directory=$(ci_run_create_dir "$runs_root")
run_identifier=$(basename "$run_directory")

commands_file="$run_directory/commands.txt"
summary_path="$run_directory/summary.md"
meta_path="$run_directory/meta.json"
logs_directory="$run_directory/logs"
results_directory="$run_directory/results"

start_epoch=$(date +%s)
start_time_display=$(date +"%Y-%m-%d %H:%M:%S %z")
start_time_iso=$(date +"%Y-%m-%dT%H:%M:%S%z")

overall_result="success"
run_note="Evaluating local changes to determine required build/test steps."
failed_step=""
failed_log=""
executed_steps=()

finalize_run_artifacts() {
  local exit_code=$1
  set +e

  local end_epoch
  local end_time_display
  local end_time_iso
  local duration_seconds
  local executed_steps_markdown

  end_epoch=$(date +%s)
  end_time_display=$(date +"%Y-%m-%d %H:%M:%S %z")
  end_time_iso=$(date +"%Y-%m-%dT%H:%M:%S%z")
  duration_seconds=$((end_epoch - start_epoch))

  if [[ $exit_code -ne 0 ]]; then
    overall_result="failure"
    if [[ -z "$run_note" || "$run_note" == "Executed required build/test steps based on local changes." ]]; then
      run_note="A required step failed. Review failure details and logs."
    fi
  fi

  if [[ ${#executed_steps[@]} -eq 0 ]]; then
    executed_steps_markdown="- No build/test steps were required."
  else
    executed_steps_markdown=""
    local executed_step
    for executed_step in "${executed_steps[@]}"; do
      executed_steps_markdown+="- ${executed_step}"$'\n'
    done
    executed_steps_markdown=${executed_steps_markdown%$'\n'}
  fi

  ci_run_write_summary \
    "$summary_path" \
    "$run_identifier" \
    "$start_time_display" \
    "$end_time_display" \
    "$overall_result" \
    "$run_note" \
    "$executed_steps_markdown" \
    "$failed_step" \
    "$failed_log" \
    "$logs_directory" \
    "$results_directory" \
    "$commands_file" || true

  ci_run_write_meta \
    "$meta_path" \
    "$run_identifier" \
    "$start_time_iso" \
    "$end_time_iso" \
    "$duration_seconds" \
    "$overall_result" \
    "$run_note" \
    "$failed_step" \
    "$failed_log" \
    "$commands_file" \
    "$logs_directory" \
    "$results_directory" || true

  ci_run_prune_old_runs "$runs_root" 5 || true
}

trap 'finalize_run_artifacts "$?"' EXIT

ci_run_capture_command "$commands_file" "$0" "$@"
echo "AI run artifacts: $run_directory"

run_logged_step() {
  local step_identifier=$1
  local step_description=$2
  shift 2

  local log_path="$logs_directory/${step_identifier}.log"
  executed_steps+=("$step_description")

  ci_run_capture_command "$commands_file" "AI_RUN_RESULTS_DIR=$results_directory" "$@"

  echo "Running ${step_description}."
  set +e
  AI_RUN_RESULTS_DIR="$results_directory" "$@" 2>&1 | tee "$log_path"
  local command_status=${PIPESTATUS[0]}
  set -e

  if [[ $command_status -ne 0 ]]; then
    failed_step="$step_description"
    failed_log="$log_path"
    overall_result="failure"
    run_note="A required step failed. Review failure details and logs."
    return "$command_status"
  fi

  return 0
}

changed_files=$(
  {
    git diff --name-only --cached
    git diff --name-only
    git ls-files --others --exclude-standard
  } | sed '/^$/d' | sort -u
)

if [[ -z "$changed_files" ]]; then
  echo "No local changes detected."
  run_note="No local changes detected. Build/test steps were skipped."
  exit 0
fi

needs_incomes_build=false
needs_incomes_library_tests=false

if grep -Eq '^Incomes/|^Incomes\.xcodeproj/|^Widgets/|^Watch/' <<<"$changed_files"; then
  needs_incomes_build=true
fi

if grep -Eq '^IncomesLibrary/' <<<"$changed_files"; then
  needs_incomes_library_tests=true
fi

if ! $needs_incomes_build && ! $needs_incomes_library_tests; then
  echo "No changes under Incomes/, IncomesLibrary/, Widgets/, Watch/, or Incomes.xcodeproj/."
  run_note="No changes under Incomes/, IncomesLibrary/, Widgets/, Watch/, or Incomes.xcodeproj/. Build/test steps were skipped."
  exit 0
fi

run_note="Executed required build/test steps based on local changes."

if $needs_incomes_build; then
  run_logged_step \
    "check_models_directory_consistency" \
    "Check Models directory consistency" \
    bash "$repository_root/ci_scripts/tasks/check_models_directory_consistency.sh"

  run_logged_step \
    "build_incomes" \
    "Build Incomes scheme" \
    bash "$repository_root/ci_scripts/tasks/build_app.sh"
fi

if $needs_incomes_library_tests; then
  run_logged_step \
    "test_incomes_library" \
    "Test IncomesLibrary scheme" \
    bash "$repository_root/ci_scripts/tasks/test_shared_library.sh"
fi
