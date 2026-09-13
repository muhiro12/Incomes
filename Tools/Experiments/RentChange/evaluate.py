#!/usr/bin/env python3
"""Measure structured extraction for a synthetic, read-only rent-change case."""

import argparse
import json
from pathlib import Path
import statistics
import subprocess
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--repetitions", type=int, default=1)
    arguments = parser.parse_args()
    if not 1 <= arguments.repetitions <= 3:
        parser.error("Use between one and three repetitions for this small experiment")

    root = Path(__file__).resolve().parent
    cases = json.loads((root / "cases.json").read_text())
    instructions = (root / "instructions.txt").read_text()
    results = []
    for case in cases:
        for repetition in range(arguments.repetitions):
            started = time.monotonic()
            result = {
                "case": case["id"],
                "repetition": repetition + 1,
                "input": case["text"],
                "expected": case["expected"],
            }
            try:
                response = subprocess.run(
                    [
                        "fm", "respond", "--model", "system", "--no-stream",
                        "--greedy", "--schema", str(root / "schema.json"),
                        "--instructions", instructions,
                        json.dumps(case["text"], ensure_ascii=False),
                    ],
                    capture_output=True, text=True, timeout=60, check=True,
                )
                candidate = json.loads(response.stdout)
                result["candidate"] = candidate
                result["fieldsNeedingCorrection"] = [
                    field for field, expected in case["expected"].items()
                    if candidate.get(field) != expected
                ]
                result["exactMatch"] = not result["fieldsNeedingCorrection"]
                result["reviewStatus"] = review_status(candidate)
            except (subprocess.CalledProcessError, subprocess.TimeoutExpired,
                    json.JSONDecodeError, ValueError, TypeError) as error:
                result["error"] = str(error)
                if isinstance(error, subprocess.CalledProcessError):
                    result["diagnostics"] = error.stderr or error.stdout
                result["exactMatch"] = False
                result["reviewStatus"] = "manual_entry_required"
            result["elapsedSeconds"] = round(time.monotonic() - started, 3)
            results.append(result)
            print(json.dumps(result, ensure_ascii=False), flush=True)

    durations = [result["elapsedSeconds"] for result in results]
    report = {
        "referenceDate": "2026-09-13",
        "timeZone": "Asia/Tokyo",
        "model": "system",
        "sampling": "greedy",
        "scope": "Synthetic extraction only; no saved records or mutation APIs",
        "summary": {
            "samples": len(results),
            "exactMatches": sum(result["exactMatch"] for result in results),
            "medianSeconds": round(statistics.median(durations), 3),
            "maximumSeconds": max(durations),
        },
        "results": results,
    }
    arguments.output.parent.mkdir(parents=True, exist_ok=True)
    arguments.output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(report["summary"], ensure_ascii=False), flush=True)


def review_status(candidate):
    """An extraction result never authorizes record selection or a save."""
    if not isinstance(candidate, dict):
        raise ValueError("Expected an object")
    if candidate.get("cancelled") is True:
        return "cancelled"
    if candidate.get("cancelled") is not False:
        return "manual_entry_required"
    if not candidate.get("target") or not candidate.get("startMonth"):
        return "clarification_required"
    if candidate.get("amountMode") not in ("increase", "total"):
        return "clarification_required"
    amount = candidate.get("amountYen")
    if type(amount) is not int or amount <= 0:
        return "clarification_required"
    return "explicit_target_range_and_amount_review_required"


if __name__ == "__main__":
    main()
