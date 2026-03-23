#!/usr/bin/env bash

CI_XCODEBUILD_LAST_RESULT_BUNDLE_PATH=""

ci_xcodebuild_shared_directory() {
  local repository_root=$1
  printf '%s\n' "${CI_SHARED_DIR:-$repository_root/.build/ci/shared}"
}

ci_xcodebuild_work_directory() {
  local repository_root=$1
  local shared_directory

  shared_directory=$(ci_xcodebuild_shared_directory "$repository_root")
  printf '%s\n' "${CI_RUN_WORK_DIR:-${AI_RUN_WORK_DIR:-$shared_directory/work}}"
}

ci_xcodebuild_cache_directory() {
  local repository_root=$1
  local shared_directory

  shared_directory=$(ci_xcodebuild_shared_directory "$repository_root")
  printf '%s\n' "${CI_CACHE_DIR:-${AI_RUN_CACHE_ROOT:-$shared_directory/cache}}"
}

ci_xcodebuild_derived_data_directory() {
  local repository_root=$1
  local shared_directory

  shared_directory=$(ci_xcodebuild_shared_directory "$repository_root")
  printf '%s\n' "${CI_DERIVED_DATA_DIR:-$shared_directory/DerivedData}"
}

ci_xcodebuild_results_directory() {
  local repository_root=$1
  local work_directory

  work_directory=$(ci_xcodebuild_work_directory "$repository_root")
  printf '%s\n' "${CI_RUN_RESULTS_DIR:-${AI_RUN_RESULTS_DIR:-$work_directory/results}}"
}

ci_xcodebuild_prepare_directories() {
  local repository_root=$1
  local shared_directory
  local work_directory
  local cache_directory
  local derived_data_directory
  local results_directory

  shared_directory=$(ci_xcodebuild_shared_directory "$repository_root")
  work_directory=$(ci_xcodebuild_work_directory "$repository_root")
  cache_directory=$(ci_xcodebuild_cache_directory "$repository_root")
  derived_data_directory=$(ci_xcodebuild_derived_data_directory "$repository_root")
  results_directory=$(ci_xcodebuild_results_directory "$repository_root")

  mkdir -p \
    "$work_directory" \
    "$shared_directory/home/Library/Caches" \
    "$shared_directory/home/Library/Developer" \
    "$shared_directory/home/Library/Logs" \
    "$cache_directory/clang/ModuleCache" \
    "$cache_directory/package" \
    "$cache_directory/source_packages" \
    "$cache_directory/swiftpm/cache" \
    "$cache_directory/swiftpm/config" \
    "$shared_directory/tmp" \
    "$derived_data_directory" \
    "$results_directory"
}

ci_xcodebuild_resolve_simulator_identifier() {
  local booted_simulator_identifier
  booted_simulator_identifier=$(xcrun simctl list devices | awk -F'[()]' '/Booted/ {print $2; exit}' || true)
  if [[ -n "$booted_simulator_identifier" ]]; then
    printf '%s\n' "$booted_simulator_identifier"
    return 0
  fi

  local candidate_simulator_identifier
  candidate_simulator_identifier=$(xcrun simctl list devices | awk -F'[()]' '/iPhone/ && /(Shutdown|Booted)/ {print $2; exit}' || true)
  if [[ -n "$candidate_simulator_identifier" ]]; then
    xcrun simctl boot "$candidate_simulator_identifier" >/dev/null 2>&1 || true
    printf '%s\n' "$candidate_simulator_identifier"
    return 0
  fi

  printf '\n'
}

ci_xcodebuild_run() {
  local repository_root=$1
  local scheme=$2
  local action=$3
  local result_bundle_name=$4
  shift 4

  local project_path="Incomes.xcodeproj"
  local shared_directory
  local work_directory
  local cache_directory
  local derived_data_directory
  local results_directory
  local local_home_directory
  local temporary_directory
  local clang_module_cache_directory
  local package_cache_directory
  local cloned_source_packages_directory
  local swiftpm_cache_directory
  local swiftpm_config_directory
  local resolved_simulator_identifier
  local timestamp
  local result_bundle_path
  local -a destination_arguments=()

  ci_xcodebuild_prepare_directories "$repository_root"

  shared_directory=$(ci_xcodebuild_shared_directory "$repository_root")
  work_directory=$(ci_xcodebuild_work_directory "$repository_root")
  cache_directory=$(ci_xcodebuild_cache_directory "$repository_root")
  derived_data_directory=$(ci_xcodebuild_derived_data_directory "$repository_root")
  results_directory=$(ci_xcodebuild_results_directory "$repository_root")

  local_home_directory="$shared_directory/home"
  temporary_directory="$shared_directory/tmp"
  clang_module_cache_directory="$cache_directory/clang/ModuleCache"
  package_cache_directory="$cache_directory/package"
  cloned_source_packages_directory="$cache_directory/source_packages"
  swiftpm_cache_directory="$cache_directory/swiftpm/cache"
  swiftpm_config_directory="$cache_directory/swiftpm/config"

  resolved_simulator_identifier=$(ci_xcodebuild_resolve_simulator_identifier)
  if [[ -n "$resolved_simulator_identifier" ]]; then
    destination_arguments=(-destination "id=$resolved_simulator_identifier")
  else
    destination_arguments=(-destination "platform=iOS Simulator,OS=latest")
  fi

  timestamp=$(date +%s)
  result_bundle_path="$results_directory/${result_bundle_name}_${timestamp}.xcresult"
  CI_XCODEBUILD_LAST_RESULT_BUNDLE_PATH="$result_bundle_path"

  HOME="$local_home_directory" \
  TMPDIR="$temporary_directory" \
  XDG_CACHE_HOME="$cache_directory" \
  CLANG_MODULE_CACHE_PATH="$clang_module_cache_directory" \
  SWIFTPM_CACHE_PATH="$swiftpm_cache_directory" \
  SWIFTPM_CONFIG_PATH="$swiftpm_config_directory" \
  PLL_SOURCE_PACKAGES_PATH="$cloned_source_packages_directory" \
  xcodebuild \
    -project "$project_path" \
    -scheme "$scheme" \
    "$@" \
    -skipPackagePluginValidation \
    "${destination_arguments[@]}" \
    -derivedDataPath "$derived_data_directory" \
    -resultBundlePath "$result_bundle_path" \
    -clonedSourcePackagesDirPath "$cloned_source_packages_directory" \
    -packageCachePath "$package_cache_directory" \
    "CLANG_MODULE_CACHE_PATH=$clang_module_cache_directory" \
    "$action"
}
