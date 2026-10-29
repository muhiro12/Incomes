# Item input qualification

## Scope

This record covers deterministic logic and UI-free real-model evaluation of
the two paths in
[Item template exchange](item-template-exchange.md), verified on 2026-10-29.
Inference tests supply fixed typed results; they do not invoke a model.
Template tests supply literal documents. Both exercise the shared Item value
and persistence contracts. A separate opt-in probe calls Foundation Models
with the production generation type and prompt code. Neither requires app UI
automation; their evidence is reported separately below.

## Behavioral coverage

| Boundary | Verified behavior |
| --- | --- |
| Generated values | Real canonical calendar days, nonempty content, nonnegative exact amounts, and mutually exclusive positive income/outgo are required. |
| Unknown values | An unspecified amount becomes a valid zero-valued draft with review metadata. Explicit zero remains distinct. An empty date keeps the selected date; ledger and priority remain unchanged. |
| Template grammar | Fixed fields, versions, strict values, size limits and review snapshots retain their existing tests. Lone carriage returns are rejected on read and export; CRLF is supported. |
| Localized amounts | `12.50` and `1.234` retain their numeric value under `en_US`, `ja_JP`, `fr_FR` and `de_DE`, including conversion to another editor locale and ledger reassignment. |
| Persistence and output | Both typed inference updates and templates pass through canonical Item creation, disk-backed save, store reopening, exact file-export comparison, and template export/read. |
| Field fidelity | Multiline Japanese/French content, literal headings, HTML and links remain data. Date, amounts, category, priority and default/additional ledger ownership survive the round trip. |

These regression tests exposed and corrected an empty generated date being
parsed as a default date in 2000, localized amounts losing their interpretation
locale, and a lone carriage return accepted on import but refused on export.
Unspecified-amount metadata also implements the selected zero-draft policy
without changing the persisted Item schema.

## Deterministic test results

- Full IncomesLibrary test plan: 1,762 passed, no failures or skips.
- Final focused inference/qualification run: 21 passed, no failures or skips.
  This is a separate regression run, not an additional unique-test total.
- Incomes consumer build passed; Xcode reported no warnings or errors.
- Repository SwiftLint, architecture and Operations boundary checks passed.
- Five new UI/error strings have English, Japanese, Spanish, French and
  Simplified Chinese translations.

The shared tests run with the Apple SDK and isolated temporary stores on an
iOS Simulator. They exercise logic, not simulated taps or the app's screens.
The qualification fixtures contain synthetic data only.

## UI-free real-model results

Run the [Item inference evaluator](../../Tools/Experiments/ItemInference/README.md)
to compile the production generation type and prompt helpers directly and
call `SystemLanguageModel.default` through `LanguageModelSession`. It uses
framework-default generation options and compares actual outputs afterwards;
the expected values are not supplied to the model. The process runs on macOS,
without app screens, Simulator taps, app records or settings changes. It does
not execute the iOS service's error wrapper or persistence path.

Final run on macOS 27.2 (26B123), arm64, Swift 6.4.2, SDK 27.2, with reference
date October 29, 2026, Asia/Tokyo: **16 requests completed, 10 matched, 6 semantic
mismatches, no request errors or timeouts**. Each case ran twice in a fresh
process/session. Elapsed times including process startup were 1.227–2.221 s;
these are Mac measurements, not iPhone performance or an accuracy estimate.

| Case | Matches | Observed issue |
| --- | ---: | --- |
| Explicit expense | 2/2 | None in the scored fields |
| Explicit income | 2/2 | None in the scored fields |
| Exact day, unknown amount | 2/2 | Zero amounts with unspecified-amount state |
| Explicit zero | 2/2 | Correctly distinct from unknown amount |
| Ambiguous month | 0/2 | Invented November 1 or October 29 instead of an empty date |
| Missing date | 0/2 | Supplied October 29 instead of an empty date |
| Yesterday | 0/2 | Returned October 29 instead of October 28 |
| English fractional expense | 2/2 | Decimal amount preserved |

Scored fields are exact day, income, outgo and unknown-amount state; content
must also be nonempty. Description wording and category meaning are recorded
without semantic scoring. The evaluator returns a failing exit status for
these mismatches. Reports retain raw fields, generated JSON, actual rendered
prompts, source hashes and host configuration outside the repository.

## Evidence boundary

A validator can reject an invalid date or an inexact amount. It cannot establish
that a valid value corresponds to the original prose. Exploratory generation
also produced an unsupported exact date for a source naming only a month;
adding a generated uncertainty flag did not resolve that case and the date-flag
experiment was reverted. This is a separate model-quality observation, not a
failure of the typed-value or template round-trip tests.

Generated unknown-state metadata describes what the model reported. It does
not independently verify that the source omitted a value. Proposals remain
editable and require the ordinary explicit Create action. These unit-test
results do not establish general extraction accuracy, UI quality, physical
phone performance, or release qualification. The real-model results above
demonstrate that date extraction still has concrete quality gaps despite the
typed-value tests passing.
