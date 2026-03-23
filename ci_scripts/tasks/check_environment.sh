#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

usage() {
  cat <<'EOF' >&2
Usage: bash ci_scripts/tasks/check_environment.sh --profile <format|build|verify>
EOF
}

argument_count=$#
if [[ $argument_count -ne 2 || "${1:-}" != "--profile" ]]; then
  usage
  exit 2
fi

profile=$2
case "$profile" in
  format | build | verify)
    ;;
  *)
    usage
    exit 2
    ;;
esac

ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

failures=()
next_steps=()

record_failure() {
  failures+=("$1")
}

record_next_step() {
  local message=$1
  local existing_message

  if [[ ${#next_steps[@]} -gt 0 ]]; then
    for existing_message in "${next_steps[@]}"; do
      if [[ "$existing_message" == "$message" ]]; then
        return 0
      fi
    done
  fi

  next_steps+=("$message")
}

ensure_command() {
  local command_name=$1
  local install_hint=$2

  if command -v "$command_name" >/dev/null 2>&1; then
    return 0
  fi

  record_failure "Missing command: $command_name"
  record_next_step "$install_hint"
}

check_swiftlint_environment() {
  local project_file="Incomes.xcodeproj/project.pbxproj"

  ensure_command "xcodebuild" "Install Xcode and ensure xcodebuild is available from the command line."

  if [[ ! -f "$project_file" ]]; then
    record_failure "Missing file: $project_file"
    record_next_step "Restore $project_file so the repository-managed SwiftLint package can be resolved."
    return 0
  fi

  if ! grep -q --fixed-strings "https://github.com/SimplyDanny/SwiftLintPlugins" "$project_file"; then
    record_failure "Incomes.xcodeproj is missing the SwiftLintPlugins package dependency."
    record_next_step "Add https://github.com/SimplyDanny/SwiftLintPlugins to Incomes.xcodeproj."
  fi
}

check_build_environment() {
  local incomes_secret_path="Incomes/Configurations/Secret.swift"
  local watch_secret_path="Watch/Configurations/Secret.swift"

  ensure_command "xcodebuild" "Install Xcode and ensure xcodebuild is available from the command line."
  ensure_command "xcrun" "Install Xcode command line tools and ensure xcrun is available."

  if [[ ! -f "$incomes_secret_path" && ! -f "$watch_secret_path" ]]; then
    record_failure "Missing files: $incomes_secret_path and $watch_secret_path"
    record_next_step "Create $incomes_secret_path and copy it to $watch_secret_path."
    return 0
  fi

  if [[ ! -f "$incomes_secret_path" ]]; then
    record_failure "Missing file: $incomes_secret_path"
    record_next_step "Create $incomes_secret_path with your local StoreKit and AdMob values."
  fi

  if [[ ! -f "$watch_secret_path" ]]; then
    record_failure "Missing file: $watch_secret_path"
    record_next_step "Copy $incomes_secret_path to $watch_secret_path."
  fi
}

case "$profile" in
  format)
    check_swiftlint_environment
    ;;
  build)
    check_build_environment
    ;;
  verify)
    check_swiftlint_environment
    check_build_environment
    ;;
esac

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "Environment check failed for profile '$profile'." >&2
  echo "Missing prerequisites:" >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  if [[ ${#next_steps[@]} -ne 0 ]]; then
    echo "Next actions:" >&2
    for next_step in "${next_steps[@]}"; do
      printf -- '- %s\n' "$next_step" >&2
    done
  fi

  exit 1
fi

echo "Environment check passed for profile '$profile'."
