#!/usr/bin/env bash

ci_run_create_dir() {
  local runs_root=$1

  mkdir -p "$runs_root"
  local absolute_runs_root
  absolute_runs_root=$(cd "$runs_root" && pwd)

  local base_run_identifier
  base_run_identifier=$(date +"%Y%m%d-%H%M%S")

  local collision_index=0
  local run_identifier
  local run_directory
  while :; do
    run_identifier=$(printf "%s-%04d" "$base_run_identifier" "$collision_index")
    run_directory="${absolute_runs_root}/${run_identifier}"
    if [[ ! -e "$run_directory" ]]; then
      break
    fi
    collision_index=$((collision_index + 1))
  done

  mkdir -p "$run_directory/logs" "$run_directory/results"
  : >"$run_directory/commands.txt"

  printf '%s\n' "$run_directory"
}

ci_run_capture_command() {
  local commands_file=$1
  shift

  local captured_at
  captured_at=$(date +"%Y-%m-%d %H:%M:%S %z")

  {
    printf '[%s] ' "$captured_at"
    local token_index=0
    local command_token
    for command_token in "$@"; do
      if [[ $token_index -gt 0 ]]; then
        printf ' '
      fi
      printf '%q' "$command_token"
      token_index=$((token_index + 1))
    done
    printf '\n'
  } >>"$commands_file"
}

ci_run_json_escape() {
  local escaped_value=$1

  escaped_value=${escaped_value//\\/\\\\}
  escaped_value=${escaped_value//\"/\\\"}
  escaped_value=${escaped_value//$'\n'/\\n}
  escaped_value=${escaped_value//$'\r'/\\r}
  escaped_value=${escaped_value//$'\t'/\\t}

  printf '%s' "$escaped_value"
}

ci_run_write_summary() {
  local summary_path=$1
  local run_identifier=$2
  local started_at=$3
  local ended_at=$4
  local overall_result=$5
  local run_note=$6
  local executed_steps_markdown=$7
  local failed_step=$8
  local failed_log=$9
  local logs_directory=${10}
  local results_directory=${11}
  local commands_file=${12}

  {
    printf '# CI Run Summary\n\n'
    printf -- '- Run ID: `%s`\n' "$run_identifier"
    printf -- '- Start time: `%s`\n' "$started_at"
    printf -- '- End time: `%s`\n' "$ended_at"
    printf -- '- Overall result: **%s**\n\n' "$overall_result"
    printf '## Overview\n\n'
    printf '%s\n\n' "$run_note"
    printf '## Executed Steps\n\n'
    printf '%s\n\n' "$executed_steps_markdown"
    if [[ "$overall_result" == "failure" ]]; then
      printf '## Failure Details\n\n'
      if [[ -n "$failed_step" ]]; then
        printf -- '- Failing step: `%s`\n' "$failed_step"
      else
        printf -- '- Failing step: unavailable\n'
      fi

      if [[ -n "$failed_log" ]]; then
        printf -- '- Log path: `%s`\n\n' "$failed_log"
      else
        printf -- '- Log path: unavailable\n\n'
      fi
    fi
    printf '## Artifact Paths\n\n'
    printf -- '- Commands: `%s`\n' "$commands_file"
    printf -- '- Logs: `%s`\n' "$logs_directory"
    printf -- '- Results: `%s`\n' "$results_directory"
  } >"$summary_path"
}

ci_run_write_meta() {
  local meta_path=$1
  local run_identifier=$2
  local started_at_iso=$3
  local ended_at_iso=$4
  local duration_seconds=$5
  local overall_result=$6
  local run_note=$7
  local failed_step=$8
  local failed_log=$9
  local commands_file=${10}
  local logs_directory=${11}
  local results_directory=${12}

  {
    printf '{\n'
    printf '  "run_id": "%s",\n' "$(ci_run_json_escape "$run_identifier")"
    printf '  "start_time": "%s",\n' "$(ci_run_json_escape "$started_at_iso")"
    printf '  "end_time": "%s",\n' "$(ci_run_json_escape "$ended_at_iso")"
    printf '  "duration_seconds": %s,\n' "$duration_seconds"
    printf '  "result": "%s",\n' "$(ci_run_json_escape "$overall_result")"
    printf '  "note": "%s",\n' "$(ci_run_json_escape "$run_note")"
    printf '  "failed_step": "%s",\n' "$(ci_run_json_escape "$failed_step")"
    printf '  "failed_log": "%s",\n' "$(ci_run_json_escape "$failed_log")"
    printf '  "commands_file": "%s",\n' "$(ci_run_json_escape "$commands_file")"
    printf '  "logs_dir": "%s",\n' "$(ci_run_json_escape "$logs_directory")"
    printf '  "results_dir": "%s"\n' "$(ci_run_json_escape "$results_directory")"
    printf '}\n'
  } >"$meta_path"
}

ci_run_prune_old_runs() {
  local runs_root=$1
  local retain_count=$2

  if [[ ! -d "$runs_root" ]]; then
    return 0
  fi

  local -a run_directories=()
  local run_directory
  while IFS= read -r run_directory; do
    run_directories+=("$run_directory")
  done < <(find "$runs_root" -mindepth 1 -maxdepth 1 -type d -print | LC_ALL=C sort)

  local total_runs=${#run_directories[@]}
  if [[ $total_runs -le $retain_count ]]; then
    return 0
  fi

  local remove_count=$((total_runs - retain_count))
  local index
  for ((index = 0; index < remove_count; index++)); do
    rm -rf "${run_directories[$index]}"
  done
}
