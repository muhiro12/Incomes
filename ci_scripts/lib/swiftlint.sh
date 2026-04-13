#!/usr/bin/env bash

ci_swiftlint_shared_directory() {
  local repository_root=$1
  printf '%s\n' "${CI_SHARED_DIR:-$repository_root/.build/ci/shared}"
}

ci_swiftlint_cache_directory() {
  local repository_root=$1
  local shared_directory

  shared_directory=$(ci_swiftlint_shared_directory "$repository_root")
  printf '%s\n' "${CI_CACHE_DIR:-${AI_RUN_CACHE_ROOT:-$shared_directory/cache}}"
}

ci_swiftlint_derived_data_directory() {
  local repository_root=$1
  local shared_directory

  shared_directory=$(ci_swiftlint_shared_directory "$repository_root")
  printf '%s\n' "${CI_DERIVED_DATA_DIR:-$shared_directory/DerivedData}"
}

ci_swiftlint_source_packages_directory() {
  local repository_root=$1
  local cache_directory

  cache_directory=$(ci_swiftlint_cache_directory "$repository_root")
  printf '%s\n' "${CI_SWIFT_PACKAGE_DIR:-$cache_directory/source_packages}"
}

ci_swiftlint_package_cache_directory() {
  local repository_root=$1
  local cache_directory

  cache_directory=$(ci_swiftlint_cache_directory "$repository_root")
  printf '%s\n' "$cache_directory/package"
}

ci_swiftlint_swiftpm_cache_directory() {
  local repository_root=$1
  local cache_directory

  cache_directory=$(ci_swiftlint_cache_directory "$repository_root")
  printf '%s\n' "$cache_directory/swiftpm/cache"
}

ci_swiftlint_swiftpm_config_directory() {
  local repository_root=$1
  local cache_directory

  cache_directory=$(ci_swiftlint_cache_directory "$repository_root")
  printf '%s\n' "$cache_directory/swiftpm/config"
}

ci_swiftlint_temporary_directory() {
  local repository_root=$1
  local shared_directory

  shared_directory=$(ci_swiftlint_shared_directory "$repository_root")
  printf '%s\n' "$shared_directory/tmp"
}

ci_swiftlint_local_home_directory() {
  local repository_root=$1
  local shared_directory

  shared_directory=$(ci_swiftlint_shared_directory "$repository_root")
  printf '%s\n' "$shared_directory/home"
}

ci_swiftlint_global_derived_data_directory() {
  printf '%s\n' "${CI_XCODE_GLOBAL_DERIVED_DATA_DIR:-$HOME/Library/Developer/Xcode/DerivedData}"
}

ci_swiftlint_prepare_directories() {
  local repository_root=$1
  local shared_directory
  local cache_directory
  local derived_data_directory
  local source_packages_directory
  local package_cache_directory
  local swiftpm_cache_directory
  local swiftpm_config_directory
  local temporary_directory
  local local_home_directory

  shared_directory=$(ci_swiftlint_shared_directory "$repository_root")
  cache_directory=$(ci_swiftlint_cache_directory "$repository_root")
  derived_data_directory=$(ci_swiftlint_derived_data_directory "$repository_root")
  source_packages_directory=$(ci_swiftlint_source_packages_directory "$repository_root")
  package_cache_directory=$(ci_swiftlint_package_cache_directory "$repository_root")
  swiftpm_cache_directory=$(ci_swiftlint_swiftpm_cache_directory "$repository_root")
  swiftpm_config_directory=$(ci_swiftlint_swiftpm_config_directory "$repository_root")
  temporary_directory=$(ci_swiftlint_temporary_directory "$repository_root")
  local_home_directory=$(ci_swiftlint_local_home_directory "$repository_root")

  mkdir -p \
    "$shared_directory" \
    "$cache_directory" \
    "$derived_data_directory" \
    "$source_packages_directory" \
    "$package_cache_directory" \
    "$swiftpm_cache_directory" \
    "$swiftpm_config_directory" \
    "$temporary_directory" \
    "$local_home_directory/Library/Caches" \
    "$local_home_directory/Library/Developer" \
    "$local_home_directory/Library/Logs"
}

ci_swiftlint_find_binary() {
  local repository_root=$1
  local source_packages_directory
  local derived_data_directory
  local global_derived_data_directory
  local search_root
  local candidate

  if [[ -n "${CI_SWIFTLINT_BIN:-}" && -x "${CI_SWIFTLINT_BIN:-}" ]]; then
    printf '%s\n' "$CI_SWIFTLINT_BIN"
    return 0
  fi

  source_packages_directory=$(ci_swiftlint_source_packages_directory "$repository_root")
  derived_data_directory=$(ci_swiftlint_derived_data_directory "$repository_root")
  global_derived_data_directory=$(ci_swiftlint_global_derived_data_directory)

  for search_root in \
    "$source_packages_directory" \
    "$derived_data_directory/SourcePackages"
  do
    if [[ ! -d "$search_root/artifacts" ]]; then
      continue
    fi

    candidate=$(
      find \
        "$search_root/artifacts" \
        -path '*/SwiftLintBinary.artifactbundle/macos/swiftlint' \
        -type f \
        -print 2>/dev/null | LC_ALL=C sort | head -n 1
    )

    if [[ -n "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if [[ -d "$global_derived_data_directory" ]]; then
    candidate=$(
      find \
        "$global_derived_data_directory" \
        -path '*/SourcePackages/artifacts/*/SwiftLintBinary.artifactbundle/macos/swiftlint' \
        -type f \
        -print 2>/dev/null | LC_ALL=C sort | head -n 1
    )

    if [[ -n "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi

  return 1
}

ci_swiftlint_resolve_binary() {
  local repository_root=$1
  local project_path=${2:-Incomes.xcodeproj}
  local source_packages_directory
  local package_cache_directory
  local swiftpm_cache_directory
  local swiftpm_config_directory
  local temporary_directory
  local local_home_directory
  local resolve_output
  local resolve_status
  local candidate

  if candidate=$(ci_swiftlint_find_binary "$repository_root"); then
    printf '%s\n' "$candidate"
    return 0
  fi

  ci_swiftlint_prepare_directories "$repository_root"

  if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "xcodebuild command not found while resolving the project-managed SwiftLint binary." >&2
    return 1
  fi

  source_packages_directory=$(ci_swiftlint_source_packages_directory "$repository_root")
  package_cache_directory=$(ci_swiftlint_package_cache_directory "$repository_root")
  swiftpm_cache_directory=$(ci_swiftlint_swiftpm_cache_directory "$repository_root")
  swiftpm_config_directory=$(ci_swiftlint_swiftpm_config_directory "$repository_root")
  temporary_directory=$(ci_swiftlint_temporary_directory "$repository_root")
  local_home_directory=$(ci_swiftlint_local_home_directory "$repository_root")

  resolve_output=$(mktemp "${TMPDIR:-/tmp}/swiftlint-resolve.XXXXXX.log")
  echo "Resolving project-managed SwiftLint binary..." >&2
  set +e
  HOME="$local_home_directory" \
    TMPDIR="$temporary_directory" \
    XDG_CACHE_HOME="$(ci_swiftlint_cache_directory "$repository_root")" \
    SWIFTPM_CACHE_PATH="$swiftpm_cache_directory" \
    SWIFTPM_CONFIG_PATH="$swiftpm_config_directory" \
    xcodebuild \
      -resolvePackageDependencies \
      -project "$repository_root/$project_path" \
      -clonedSourcePackagesDirPath "$source_packages_directory" \
      -packageCachePath "$package_cache_directory" \
      -skipPackagePluginValidation >"$resolve_output" 2>&1
  resolve_status=$?
  set -e

  if [[ $resolve_status -ne 0 ]]; then
    cat "$resolve_output" >&2
    rm -f "$resolve_output"
    return "$resolve_status"
  fi

  rm -f "$resolve_output"

  if candidate=$(ci_swiftlint_find_binary "$repository_root"); then
    printf '%s\n' "$candidate"
    return 0
  fi

  echo "Could not locate the project-managed SwiftLint binary after resolving package dependencies." >&2
  return 1
}

ci_swiftlint_run() {
  local repository_root=$1
  local mode=$2
  local empty_message
  local start_message
  local finish_message
  local swiftlint_binary
  local -a swift_files=()

  case "$mode" in
    format)
      empty_message="No tracked Swift files found to format."
      start_message="Formatting tracked Swift files with SwiftLint..."
      finish_message="Finished formatting tracked Swift files."
      ;;
    lint)
      empty_message="No tracked Swift files found to lint."
      start_message="Linting tracked Swift files with SwiftLint..."
      finish_message="Finished linting tracked Swift files."
      ;;
    *)
      echo "Unknown SwiftLint mode: $mode" >&2
      return 2
      ;;
  esac

  while IFS= read -r -d '' file; do
    swift_files+=("$file")
  done < <(git ls-files -z -- '*.swift')

  if [[ ${#swift_files[@]} -eq 0 ]]; then
    echo "$empty_message"
    return 0
  fi

  swiftlint_binary=$(ci_swiftlint_resolve_binary "$repository_root")

  echo "$start_message"
  case "$mode" in
    format)
      "$swiftlint_binary" lint --quiet --no-cache --fix --format "${swift_files[@]}"
      ;;
    lint)
      "$swiftlint_binary" lint --quiet --no-cache --strict "${swift_files[@]}"
      ;;
  esac
  echo "$finish_message"
}
