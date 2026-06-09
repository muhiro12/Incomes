#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"
source "$script_directory/../lib/ci_runs.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

ci_root="$repository_root/.build/ci"
runs_root="$ci_root/runs"
shared_directory="$ci_root/shared"
cache_directory="$shared_directory/cache"
derived_data_directory="$shared_directory/DerivedData"
shared_tmp_directory="$shared_directory/tmp"
shared_home_directory="$shared_directory/home"

run_directory=$(ci_run_create_dir "$runs_root")
run_identifier=$(basename "$run_directory")

commands_file="$run_directory/commands.txt"
summary_path="$run_directory/summary.md"
meta_path="$run_directory/meta.json"
logs_directory="$run_directory/logs"
results_directory="$run_directory/results"
run_work_directory="$run_directory/work"

mkdir -p \
  "$run_work_directory" \
  "$cache_directory" \
  "$derived_data_directory" \
  "$shared_tmp_directory" \
  "$shared_home_directory"

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
    if [[ "$run_note" != "A required step failed. Review failure details and logs." ]]; then
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
echo "CI run artifacts: $run_directory"

run_logged_step() {
  local step_identifier=$1
  local step_description=$2
  shift 2

  local log_path="$logs_directory/${step_identifier}.log"
  executed_steps+=("$step_description")

  ci_run_capture_command \
    "$commands_file" \
    "CI_RUN_DIR=$run_directory" \
    "CI_RUN_WORK_DIR=$run_work_directory" \
    "CI_SHARED_DIR=$shared_directory" \
    "CI_CACHE_DIR=$cache_directory" \
    "CI_DERIVED_DATA_DIR=$derived_data_directory" \
    "CI_RUN_RESULTS_DIR=$results_directory" \
    "AI_RUN_RESULTS_DIR=$results_directory" \
    "AI_RUN_WORK_DIR=$run_work_directory" \
    "AI_RUN_CACHE_ROOT=$cache_directory" \
    "$@"

  echo "Running ${step_description}."
  set +e
  CI_RUN_DIR="$run_directory" \
    CI_RUN_WORK_DIR="$run_work_directory" \
    CI_SHARED_DIR="$shared_directory" \
    CI_CACHE_DIR="$cache_directory" \
    CI_DERIVED_DATA_DIR="$derived_data_directory" \
    CI_RUN_RESULTS_DIR="$results_directory" \
    AI_RUN_RESULTS_DIR="$results_directory" \
    AI_RUN_WORK_DIR="$run_work_directory" \
    AI_RUN_CACHE_ROOT="$cache_directory" \
    "$@" 2>&1 | tee "$log_path"
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

should_force_full=false
if [[ "${CI_RUN_FORCE_FULL:-0}" == "1" || "${CI_RUN_FORCE_FULL:-}" == "true" ]]; then
  should_force_full=true
fi

should_skip_environment_check=false
if [[ "${CI_SKIP_ENV_CHECK:-0}" == "1" || "${CI_SKIP_ENV_CHECK:-}" == "true" ]]; then
  should_skip_environment_check=true
fi

needs_incomes_build=false
needs_incomes_library_tests=false
needs_mhplatform_boundary_checks=false
needs_incomes_architecture_boundary_checks=false
if $should_force_full; then
  echo "Forcing full verification regardless of local changes."
  needs_incomes_build=true
  needs_incomes_library_tests=true
  needs_mhplatform_boundary_checks=true
  needs_incomes_architecture_boundary_checks=true
  run_note="Executed a forced full verification run regardless of local changes."
else
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

  if grep -Eq '^Incomes/|^IncomesLibrary/|^Incomes\.xcodeproj/|^Widgets/|^Watch/' <<<"$changed_files"; then
    needs_incomes_build=true
  fi

  if grep -Eq '^IncomesLibrary/|^Incomes\.xcodeproj/' <<<"$changed_files"; then
    needs_incomes_library_tests=true
  fi

  if grep -Eq '^Incomes/|^IncomesLibrary/|^Incomes\.xcodeproj/|^Widgets/|^Watch/|^ci_scripts/' <<<"$changed_files"; then
    needs_mhplatform_boundary_checks=true
  fi

  if grep -Eq '^IncomesLibrary/|^ci_scripts/|^Designs/Architecture/|^Designs/Decisions/|^README\.md$' <<<"$changed_files"; then
    needs_incomes_architecture_boundary_checks=true
  fi

  if ! $needs_incomes_build && ! $needs_incomes_library_tests && ! $needs_mhplatform_boundary_checks && ! $needs_incomes_architecture_boundary_checks; then
    echo "No changes under Incomes/, IncomesLibrary/, Widgets/, Watch/, Incomes.xcodeproj/, ci_scripts/, Designs/Architecture/, Designs/Decisions/, or README.md."
    run_note="No changes under Incomes/, IncomesLibrary/, Widgets/, Watch/, Incomes.xcodeproj/, ci_scripts/, Designs/Architecture/, Designs/Decisions/, or README.md. Build/test steps were skipped."
    exit 0
  fi

  run_note="Executed required CI steps based on local changes."
fi

if ! $should_skip_environment_check && { $needs_incomes_build || $needs_incomes_library_tests; }; then
  run_logged_step \
    "check_environment" \
    "Check build environment" \
    bash "$repository_root/ci_scripts/tasks/check_environment.sh" --profile build
fi

if $needs_mhplatform_boundary_checks; then
  run_logged_step \
    "check_mhplatform_boundaries" \
    "Check MHPlatform boundaries" \
    bash "$repository_root/ci_scripts/tasks/check_mhplatform_boundaries.sh"
fi

if $needs_incomes_architecture_boundary_checks; then
  run_logged_step \
    "check_incomes_architecture_boundaries" \
    "Check Incomes architecture boundaries" \
    bash "$repository_root/ci_scripts/tasks/check_incomes_architecture_boundaries.sh"
fi

if $needs_incomes_build; then
  run_logged_step \
    "check_models_directory_consistency" \
    "Check Models directory consistency" \
    bash "$repository_root/ci_scripts/tasks/check_models_directory_consistency.sh"

  run_logged_step \
    "build_app" \
    "Build Incomes scheme" \
    bash "$repository_root/ci_scripts/tasks/build_app.sh"
fi

if $needs_incomes_library_tests; then
  run_logged_step \
    "test_shared_library" \
    "Test IncomesLibrary scheme" \
    bash "$repository_root/ci_scripts/tasks/test_shared_library.sh"
fi
