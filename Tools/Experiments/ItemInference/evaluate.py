#!/usr/bin/env python3
"""Run real Foundation Models extraction without app UI or persisted records."""

import argparse
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile
import time


ROOT = Path(__file__).resolve().parents[3]
DIRECTORY = Path(__file__).resolve().parent
SOURCES = [
    "Incomes/Sources/Features/Item/Inference/ItemFormInferenceResult.swift",
    "IncomesLibrary/Sources/Item/ItemFormInferencePromptBuilder.swift",
    "IncomesLibrary/Sources/Item/Inference/FoundationModelPromptTemplate.swift",
    "IncomesLibrary/Sources/Item/PromptLiteralSupport.swift",
    "IncomesLibrary/Sources/Item/LocaleLanguageCodeSupport.swift",
    "Tools/Experiments/ItemInference/Bundle+ItemInferenceProbe.swift",
    "Tools/Experiments/ItemInference/ItemInferenceProbe.swift",
]
RESOURCES = [
    "IncomesLibrary/Resources/FoundationModels/item-form-inference-instructions.prompt",
    "IncomesLibrary/Resources/FoundationModels/item-form-inference-user-prompt.prompt",
]


def command_output(arguments):
    return subprocess.check_output(arguments, text=True).strip()


def fields_needing_correction(candidate, expected):
    differences = []
    for field, value in expected.items():
        actual = candidate.get(field)
        if field in ("income", "outgo"):
            try:
                amount = Decimal(actual)
                matches = amount.is_finite() and amount == Decimal(value)
            except (InvalidOperation, TypeError, ValueError):
                matches = False
        else:
            matches = type(actual) is type(value) and actual == value
        if not matches:
            differences.append(field)
    if not isinstance(candidate.get("content"), str) or not candidate["content"].strip():
        differences.append("content")
    return differences


def run_case(binary, case, repetition, environment, timeout):
    result = {"case": case["id"], "repetition": repetition, "input": case["text"],
              "locale": case["locale"], "expected": case["expected"]}
    started = time.monotonic()
    try:
        response = subprocess.run(
            [str(binary)],
            input=json.dumps({"text": case["text"], "referenceDate": "20261029",
                              "locale": case["locale"]}, ensure_ascii=False),
            env=environment, capture_output=True, text=True, timeout=timeout,
        )
        if response.returncode:
            result.update(status="request_error", diagnostics=response.stderr or response.stdout)
        else:
            candidate = json.loads(response.stdout)
            if not isinstance(candidate, dict):
                raise ValueError("Expected an object from the native probe")
            differences = fields_needing_correction(candidate, case["expected"])
            result.update(candidate=candidate, fieldsNeedingCorrection=differences,
                          status="mismatch" if differences else "matched")
    except subprocess.TimeoutExpired:
        result.update(status="timeout", diagnostics="Native request process exceeded the deadline")
    except (json.JSONDecodeError, TypeError, ValueError) as error:
        result.update(status="invalid_response", diagnostics=str(error))
    result["elapsedSeconds"] = round(time.monotonic() - started, 3)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--repetitions", type=int, default=2)
    parser.add_argument("--timeout", type=int, default=45)
    arguments = parser.parse_args()
    if not 1 <= arguments.repetitions <= 3:
        parser.error("Use one to three repetitions")
    if not 1 <= arguments.timeout <= 120:
        parser.error("Use a per-request deadline between 1 and 120 seconds")
    output = arguments.output.resolve()
    if output == ROOT or ROOT in output.parents:
        parser.error("Write generated reports outside the repository")
    cases = json.loads((DIRECTORY / "cases.json").read_text())
    paths = SOURCES + RESOURCES + [
        "Tools/Experiments/ItemInference/cases.json",
        "Tools/Experiments/ItemInference/evaluate.py",
    ]
    report = {
        "startedAt": datetime.now(timezone.utc).isoformat(),
        "sourceRevision": command_output(["git", "-C", str(ROOT), "rev-parse", "HEAD"]),
        "sourceWorkingTreeDirty": bool(command_output(["git", "-C", str(ROOT), "status", "--porcelain"])),
        "sourceHashes": {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in paths},
        "host": {"os": platform.mac_ver()[0], "architecture": platform.machine(),
                 "osBuild": command_output(["sw_vers", "-buildVersion"]),
                 "sdk": command_output(["xcrun", "--sdk", "macosx", "--show-sdk-version"]),
                 "toolchain": command_output(["xcrun", "swiftc", "--version"])},
        "configuration": {"model": "SystemLanguageModel.default", "sampling": "framework default",
                          "referenceDate": "20261029", "timeZone": "Asia/Tokyo",
                          "host": "standalone macOS process; no Simulator or app UI",
                          "session": "new process and session per request"},
        "results": [],
    }
    try:
        evaluate(arguments, cases, report)
    except (subprocess.SubprocessError, OSError, ValueError) as error:
        report["setupError"] = str(error)
    finally:
        results = report["results"]
        report["summary"] = {
            "planned": len(cases) * arguments.repetitions,
            "completed": len(results),
            "matched": sum(result["status"] == "matched" for result in results),
            "mismatched": sum(result["status"] == "mismatch" for result in results),
            "errors": sum(result["status"] not in ("matched", "mismatch") for result in results),
        }
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(report["summary"], ensure_ascii=False), flush=True)
    summary = report["summary"]
    return 0 if summary["matched"] == summary["planned"] else 1


def evaluate(arguments, cases, report):
    with tempfile.TemporaryDirectory(prefix="incomes-item-inference-") as temporary:
        directory = Path(temporary)
        resources = directory / "Resources.bundle"
        resources.mkdir()
        for path in RESOURCES:
            shutil.copy2(ROOT / path, resources / Path(path).name)
        binary = directory / "probe"
        subprocess.run(
            ["xcrun", "swiftc", "-parse-as-library", "-target",
             platform.machine() + "-apple-macos26.0", "-module-cache-path",
             str(directory / "ModuleCache"), *[str(ROOT / path) for path in SOURCES],
             "-o", str(binary)], check=True, timeout=120,
        )
        environment = dict(os.environ, TZ="Asia/Tokyo",
                           INCOMES_MODEL_EVALUATION_RESOURCES=str(resources))
        for repetition in range(1, arguments.repetitions + 1):
            for case in cases:
                result = run_case(binary, case, repetition, environment, arguments.timeout)
                report["results"].append(result)
                print(json.dumps({key: result.get(key) for key in
                                  ("case", "repetition", "status", "fieldsNeedingCorrection",
                                   "elapsedSeconds")}, ensure_ascii=False), flush=True)
                if result["status"] not in ("matched", "mismatch"):
                    return


if __name__ == "__main__":
    raise SystemExit(main())
