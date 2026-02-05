#!/usr/bin/env bash
set -euo pipefail

argument_count=$#
if [[ $argument_count -ne 0 ]]; then
  echo "This script does not accept arguments." >&2
  exit 2
fi

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repository_root=$(cd "$script_directory/.." && pwd)
cd "$repository_root"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This script must run inside a git repository." >&2
  exit 1
fi

project_path="Incomes.xcodeproj"
derived_data_path="build/DerivedData"
results_directory="build"

local_home_directory="$repository_root/build/xcodebuild_home"
cache_directory="$repository_root/build/xcodebuild_cache"
temporary_directory="$repository_root/build/xcodebuild_tmp"
clang_module_cache_directory="$cache_directory/clang/ModuleCache"
package_cache_directory="$repository_root/build/xcodebuild_package_cache"
cloned_source_packages_directory="$repository_root/build/xcodebuild_source_packages"
swiftpm_cache_directory="$repository_root/build/xcodebuild_swiftpm_cache"
swiftpm_config_directory="$repository_root/build/xcodebuild_swiftpm_config"

mkdir -p \
  "$local_home_directory/Library/Caches" \
  "$local_home_directory/Library/Developer" \
  "$local_home_directory/Library/Logs" \
  "$cache_directory" \
  "$clang_module_cache_directory" \
  "$package_cache_directory" \
  "$cloned_source_packages_directory" \
  "$swiftpm_cache_directory" \
  "$swiftpm_config_directory" \
  "$temporary_directory"

mkdir -p "$derived_data_path" "$results_directory"

resolve_simulator_identifier() {
  local booted_simulator_identifier
  booted_simulator_identifier=$(xcrun simctl list devices | awk -F'[()]' '/Booted/ {print $2; exit}' || true)
  if [[ -n "$booted_simulator_identifier" ]]; then
    echo "$booted_simulator_identifier"
    return 0
  fi

  local candidate_simulator_identifier
  candidate_simulator_identifier=$(xcrun simctl list devices | awk -F'[()]' '/iPhone/ && /(Shutdown|Booted)/ {print $2; exit}' || true)
  if [[ -n "$candidate_simulator_identifier" ]]; then
    xcrun simctl boot "$candidate_simulator_identifier" >/dev/null 2>&1 || true
    echo "$candidate_simulator_identifier"
    return 0
  fi

  echo ""
}

resolved_simulator_identifier=$(resolve_simulator_identifier)
destination=()
if [[ -n "$resolved_simulator_identifier" ]]; then
  destination=( -destination "id=$resolved_simulator_identifier" )
else
  destination=( -destination "platform=iOS Simulator,OS=latest" )
fi

timestamp=$(date +%s)
result_bundle_path="$results_directory/TestResults_Incomes_${timestamp}.xcresult"

HOME="$local_home_directory" \
TMPDIR="$temporary_directory" \
XDG_CACHE_HOME="$cache_directory" \
CLANG_MODULE_CACHE_PATH="$clang_module_cache_directory" \
SWIFTPM_CACHE_PATH="$swiftpm_cache_directory" \
SWIFTPM_CONFIG_PATH="$swiftpm_config_directory" \
xcodebuild \
  -project "$project_path" \
  -scheme "Incomes" \
  "${destination[@]}" \
  -derivedDataPath "$derived_data_path" \
  -resultBundlePath "$result_bundle_path" \
  -clonedSourcePackagesDirPath "$cloned_source_packages_directory" \
  -packageCachePath "$package_cache_directory" \
  "CLANG_MODULE_CACHE_PATH=$clang_module_cache_directory" \
  build

echo "Finished Incomes build. Result bundle: $result_bundle_path"
