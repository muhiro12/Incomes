#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

surface_sources=(
  "$repository_root/Incomes/Sources"
  "$repository_root/Watch/Sources"
  "$repository_root/Widgets/Sources"
)

library_sources=(
  "$repository_root/IncomesLibrary/Sources"
)

forbidden_collaborators=(
  SummaryCalculator
  BalanceCalculator
  CategoryChartSummaryCalculator
  MonthlySummaryDateSupport
  MonthlySummaryNarrativeBuilder
  MonthlySummaryNarrativeContextLoader
  ItemFormInferencePromptBuilder
  ItemFormSaveDecision
  ItemRepeatCountLimits
  LocaleLanguageCodeSupport
  RepeatMonthSelectionRules
  UpcomingPaymentPlanner
  UpcomingPaymentNotificationPresentationBuilder
  SearchResultSectionBuilder
  WidgetEntryFactory
  YearMonthComponentRules
  WatchSyncService
  SettingsStatusLoader
  SubscriptionStateCalculator
  TagTextSupport
  DataMaintenance
  ItemRelativeQueryCoordinator
  ItemSearchPredicateBuilder
  YearlyItemDuplicationPresentationBuilder
  YearlyDuplicationAutomationCoordinator
  MainNavigationStateLoader
  MainNavigationRouteExecutor
  IncomesContextMenuLinkBuilder
  CategoryNameSupport
  ErrorMessageSupport
  VersionComparator
)

failures=()

record_failure() {
  failures+=("$1")
}

collaborator_pattern=$(
  IFS='|'
  printf '%s' "${forbidden_collaborators[*]}"
)

collaborator_matches=$(
  rg \
    --line-number \
    "\\b(${collaborator_pattern})\\b" \
    "${surface_sources[@]}" \
    -g '*.swift' || true
)

if [[ -n "$collaborator_matches" ]]; then
  record_failure "Delivery surfaces must call public *Operations for business use cases:
$collaborator_matches"
fi

public_collaborator_declarations=$(
  rg \
    --line-number \
    "^[[:space:]]*(public|open)[[:space:]]+(final[[:space:]]+class|class|struct|enum|actor)[[:space:]]+(${collaborator_pattern})\\b" \
    "${library_sources[@]}" \
    -g '*.swift' || true
)

if [[ -n "$public_collaborator_declarations" ]]; then
  record_failure "Business collaborators must remain internal implementation details:
$public_collaborator_declarations"
fi

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "Operations boundary check failed." >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  exit 1
fi

echo "Operations boundary check passed."
