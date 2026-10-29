# Item inference evaluation without UI

Call the real Foundation Models Swift API on a Mac with macOS 26 or later,
a compatible Xcode and Apple Intelligence available in the requested language:

```sh
python3 Tools/Experiments/ItemInference/evaluate.py \
  --repetitions 2 \
  --output /tmp/incomes-item-inference-results.json
```

No simulated taps, screenshot workflow, `fm` CLI, external AI account or saved
app data is used. Compilation and model-service access must be permitted in
the process environment. The runner is opt-in; normal unit tests never invoke it.

## Production code reuse

The script compiles the app's actual `ItemFormInferenceResult` (`@Generable`)
and shared prompt builder, resource renderer, JSON-literal and locale helpers
directly from their source files. It copies the two production prompt resources
unchanged into a temporary bundle. The probe provides only the standalone
equivalent of SwiftPM's generated `Bundle.module` accessor.

Like `ItemInferenceService`, it uses `SystemLanguageModel.default`, checks model
and locale availability, creates a fresh `LanguageModelSession` with the shared
instructions, and calls `respond(generating: ItemFormInferenceResult.self)`
with framework-default generation options. It supplies only the source text,
reference date and locale to the model. Expected values are used afterwards
for scoring and are never included in the model prompt.

This is a standalone macOS process, not the signed iOS app service wrapper.
It measures raw extraction before app error mapping, validation, form handoff
or persistence. Those later boundaries retain their ordinary unit tests.

## Cases and interpretation

Eight synthetic cases cover expense, income, an unknown amount, explicit zero,
an ambiguous month, a missing date, a relative day and an English fractional
amount. The reference day is fixed to October 29, 2026, in Asia/Tokyo. Missing
or ambiguous dates are expected to remain empty; unknown amounts are expected
to be explicitly marked and become zero-valued drafts under app policy.

The runner compares exact day, numeric Decimal values and unknown-amount state,
and requires nonempty content. Category labels and description wording are
recorded but not judged for semantic quality. Mismatches fail the command;
they are not corrected with expected values or counted as successful reads.

Each request starts a new process/session. A request error or deadline stops
the remaining cases and is recorded separately from a semantic mismatch.
Times include process startup and service work; they are not iPhone latency.
The report records raw fields, generated JSON, rendered prompts, source hashes,
host/toolchain and per-case comparisons outside the repository. Small repeated
samples do not establish a population accuracy rate or release qualification.
