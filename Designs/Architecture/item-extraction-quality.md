# Item extraction quality

## Scope and method

This records the November 12, 2026 extraction-quality follow-up to the interface
changes in [#426](https://github.com/muhiro12/Incomes/issues/426). It evaluates
synthetic text using the production generation schema, prompts and normalization
code through the [Mac evaluator](../../Tools/Experiments/ItemInference/README.md).
No personal financial records or images are used.

The comparison set has 28 prose/receipt-like text cases and seven copied Items,
each run twice with independent sessions. The copy fixtures are verified against
the actual `ItemContentOperations` output by an iOS library test. Four additional
cases, introduced after the initial tuning, check different receipt values,
Spanish rental income and English direction uncertainty.

Scoring covers day, exact income/outgo, amount-review state and nonempty content.
Copied Items additionally require exact multiline content and category. Expected
values are used only for scoring. Receipt description/category semantics are
not included in the numerical match counts below.

## Observations and changes

The baseline selected product prices, tendered cash or change instead of receipt
totals, classified rent received as an expense, and shortened copied content.
Generated `Decimal` values also changed `1234.56` into
`1234.5599999999997952`. Existing precision validation rejects such a suggestion;
this evaluation does not establish corruption of saved Items.

Generation now selects one amount expression and a separate income/outgo/
unspecified direction. Greedy sampling and revised instructions guide receipt
totals, payment dates, literal source data, and preservation of explicit fields.
The model no longer supplies two independent monetary values.

The app parses complete source numbers as exact decimals. A generated value must
identify one source value, either numerically or, for a digits-only expression,
through an identical complete digit sequence. The latter restores decimal and
grouping separators from the source when the model drops them. Competing source
interpretations are rejected. Verbatim copied currency affixes can be removed
without currency conversion; Japanese scaled amounts such as `3万円`, negative
values, numeric prefixes and unsupported precision remain rejected.

When direction is unspecified, an unusable expression leaves a zero-valued draft
with the existing review state. Only a source-backed zero is known independently
of direction. The review notice now covers both an unresolved amount and an
unresolved income/expense direction in all five app languages.

## Results

| Scored sample | Baseline | Updated pipeline |
| --- | ---: | ---: |
| Original prose/receipt-like text, 28 cases twice | 40/56 | 56/56 |
| Actual copied Item text, seven cases twice | 5/14 | 14/14 |
| Additional cases, four cases twice | Not run | 8/8 |

The final evaluation completed 78 requests with 78 scored matches, no request
errors and no timeouts. It ran on arm64 macOS 27.2.1 (26B131), Swift 6.4.2,
SDK 27.2 and `SystemLanguageModel.default`. Reports retain rendered prompts,
raw generated fields, normalization failures, source hashes and timings outside
the repository. Request times including process startup ranged from 1.475 to
7.742 seconds; these are host observations, not iPhone performance measurements.
Several schema, instruction and normalization changes were evaluated together;
the result does not isolate the effect of greedy sampling alone.

The full iOS library plan passed 1,051 tests / 1,795 parameterized executions,
with no failures or skips. Coverage includes source-number selection, partial
numbers, exact precision, ambiguous separator recovery, currency affixes,
explicit zero, negative values and copied-text fixture fidelity. The app consumer
build and repository rules also passed.

## Remaining quality boundaries

The numerical score is not a claim that every generated Item is ready to save.
Receipt descriptions can still include receipt metadata, and inferred categories
need improvement: the synthetic bread/milk receipt produced `消費税` as its
category even though the date and total were correct. Explicit categories in
the copied-Item cases were preserved.

The source-number check cannot prove that the model chose the transaction total
rather than another valid source number. Small repeated synthetic samples are
not a population accuracy estimate, and copied text has no round-trip import
contract. Arbitrary source layouts, multiple transactions, mixed numeric locales
and scaled amounts need separate qualification.

This run begins with text. It does not measure photo acquisition, OCR reading
order, blurred/rotated images, or camera-to-form behavior. Mac model-service
results are separate from signed iOS app generation and physical-device latency.
Those boundaries, together with receipt description/category quality, remain
follow-up work in #426. Manual review and explicit canonical saving remain part
of the retained journey.
