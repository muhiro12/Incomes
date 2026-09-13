# Rent Change Experiment

A bounded, non-persistent investigation for
[issue #366](https://github.com/muhiro12/Incomes/issues/366): a rent increase
starting next month. This is an experiment, not a shipping app feature.

## Boundaries

- Keep the app's existing dependencies, schema, and shared SDK APIs.
- Use synthetic Japanese requests with the fixed reference date
  September 13, 2026, in Asia/Tokyo.
- Ask the model to extract proposed fields, never to calculate balances,
  select persisted identifiers, or perform mutations.
- Require explicit review of the payment, start month, amount, and affected
  records even when every extracted field looks valid.
- Keep generated reports outside the repository. They are measurements,
  not additional app records.

## Extraction Probe

On macOS 27 with the Apple on-device model available:

```sh
fm available --model system
python3 Tools/Experiments/RentChange/evaluate.py \
  --repetitions 3 \
  --output /tmp/incomes-rent-change-results.json
```

The script uses Apple's `fm` CLI and its structured output schema. It reports
exact expected-field matches, fields needing correction, and wall-clock time
including process startup. Every request starts a fresh session with greedy
sampling. Three repetitions of ten cases are a small deterministic smoke
sample, not a population-level accuracy estimate or an iPhone latency study.

The corpus includes explicit increases, new totals, missing amount/date/target,
a one-month change, an explicit end month, and cancellation. Cancelled requests
are scored on cancellation only because other fields are discarded. Unknown
values must remain unknown. Do not silently replace missing fields with fixture
defaults when measuring accuracy.

`reviewStatus` is a coarse inspection aid. It is not production validation,
record retrieval, authorization to apply a change, or stale-proposal protection.
An unavailable model or failed request returns a manual-entry status.

## Authoritative Balance Comparison

In Xcode, use the `IncomesLibrary` scheme to run `RentChangeExperimentTests`
and `ItemBalanceProjectionOperationsTests`.

The experiment tests use the existing `ItemBalanceProjectionOperations` with
an isolated, in-memory container and CloudKit disabled. Fixture preparation
and simulated single-month overrides use existing domain operations only in
that container. No persistent app store is opened. Projection calls must leave
items, tags, and the context's change state intact.

The fixture has an opening balance of 130,000 yen on September 1, monthly
income of 50,000 yen on the 25th, and rent of 80,000 yen on the 28th, with
materialized records through December. September ends at 100,000 yen.
Selecting the existing October rent and entering 85,000 yen manually must
match a proposed 5,000 yen increase:

| Month | Current | Proposed | Difference |
| --- | ---: | ---: | ---: |
| October | 70,000 | 65,000 | -5,000 |
| November | 40,000 | 30,000 | -10,000 |
| December | 10,000 | -5,000 | -15,000 |

The tests also distinguish one-month changes, manually detached repeat rows,
nonuniform amounts within a representable series, and accidentally moving a
September item instead of selecting October. The ordinary projection suite
compares projected results with existing mutation operations on memory stores.

These two probes isolate extraction quality from financial correctness. They
do not constitute an end-to-end integration of model output into app UI.
There is no model-driven save path or new product-facing entrypoint.
