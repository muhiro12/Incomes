# Item input and content sharing

## User journeys

Normal manual entry remains the basic Item creation path. On iOS 26 and later,
Input Assistance opens **Extract from Text** directly. People can type or paste
ordinary prose, OCR text, or output from an external tool into the same editor,
or obtain text from a photo or camera capture. No specialized external-AI mode,
prompt, or Markdown template is required.

The existing on-device Foundation Models service proposes values for the
ordinary editable form. Its availability and errors remain explicit; manual
entry stays available on unsupported systems. Nothing is sent to an external
model automatically. Inference does not save an Item or choose its ledger.
The normal Create or Save action remains necessary.

The form retains the source text while assistance is dismissed and reopened.
Failure and cancellation leave the draft available. Cancellation or changes to
the source or draft prevent an older response from replacing current edits.
The captured destination ledger, normal validation, entitlement checks, and
update checks remain in the canonical save path.

## Copy and share content

**Copy or Share Content** is available from Item details and the list context
menu. It presents selectable plaintext with explicit Copy Content and native
Share Content actions. The preview and both actions use the same representation.

The text contains the Item's calendar day, literal multiline content, income,
outgo, nonempty category, and the configured currency code when one is set.
Labels and dates follow the selected locale. Amounts use localized grouping and
decimal separators while preserving fractional precision; they are not rounded
to a currency's usual number of fraction digits. An unset currency does not
block copying or cause a currency to be guessed. No currency conversion occurs.

Identity, ledger, balance, priority, recurrence, history, and attachments are
omitted. This text is for use anywhere, with no re-import grammar or round-trip
promise. It is separate from Item reference/deep-link sharing, AppEntity and
App Intents, and portable `.incomes` file export/import. Wider native transfer
work remains tracked in [#396](https://github.com/muhiro12/Incomes/issues/396).

## Retirement of the 6.2 Markdown template

Version 6.2 shipped the dedicated Item Markdown template workflow. App Store
Connect was checked on November 12, 2026: version 6.2, build 725 was
READY_FOR_DISTRIBUTION. The `6.2` source tag includes the template reader and
writer. The format must therefore be treated as released, not as a discarded
unpublished experiment.

The 6.3 development change deliberately ends that workflow following
[#426](https://github.com/muhiro12/Incomes/issues/426). It removes prompt and
blank-template copying, Read Template and its dedicated review, Export Template,
and the template-only parser and tests. No template-specific App Intent or
file-opening route is retained; the prior workflow used manually pasted text.

Previously saved template text remains readable outside Incomes. To enter it
in 6.3, transfer the relevant values into the normal form, or explicitly paste
it into input assistance where available and review the interpreted result.
Assistance does not preserve the former deterministic import contract and may
interpret values differently. Content copied by 6.3 is likewise not a 6.2
import template. There is no automatic conversion or deletion of external text.

Existing saved Items need no migration. The independent `.incomes` format,
version readers, import review, and recovery behavior remain unchanged; see
[data import/export](data-import-export.md). Historical template details remain
in the `6.2` source tag rather than as an active compatibility specification.

## Inference and shared form boundaries

Foundation Models produces typed `@Generable` fields, rather than generating
a user-facing text format. Structured generation constrains the response
shape; it does not establish that extracted facts are correct. Before applying
a suggestion, the adapter rejects invalid calendar dates, empty descriptions,
negative or inexact amounts, and simultaneous positive income and outgo.
Unsupported output leaves the source text available for correction or manual
entry. Cancellation and source/draft changes prevent an older response from
replacing the current form.

Generation uses greedy sampling for this extraction task. The model selects one
transaction amount and a separate income/outgo/unspecified direction, so cash
tendered, change or points cannot populate a second monetary field. Purchase
receipts should use the final total; explicit description/category fields should
retain their text and description line breaks. These instructions are evaluated
behavior, not guarantees for arbitrary source documents.

The amount is generated as text, avoiding the numeric conversion artifacts
observed with generated `Decimal` values. `ItemInferenceAmountOperations` parses
complete source numbers with the input locale and requires the generated number
to identify one exactly storable, nonnegative source value. It permits normalized
decimal notation or restores dropped separators from a matching complete digit
sequence only when there is one possible source value. The source determines
decimal placement; competing interpretations are rejected. Numeric prefixes,
unsupported scaled expressions and values
requiring rounding are rejected. This checks numeric fidelity, not whether the
model chose the right number among several source amounts.

The generated `dateExpression` copies a date phrase verbatim from the source.
`ItemInferenceDateOperations` first verifies that it occurs in that source,
then resolves supported expressions with a Gregorian calendar in the reference
date's time zone. The model does not calculate calendar days. Missing,
unsupported, invalid or month-only expressions keep the selected form date
and display a review notice. The normalized `ItemFormInferenceResult` retains
the existing canonical `yyyyMMdd` date contract for the form and Intent adapter.

Supported expressions include year-first numeric and Japanese/Chinese dates,
Japanese/Chinese month/day in the reference year, English/French/Spanish
written-month dates, and exact relative-day words in the five app languages.
Japanese trailing case particles are accepted. Relative days use Calendar
arithmetic across month/year boundaries, leap days and DST. Other expressions,
including ambiguous slash notation and relative weekdays, remain unresolved
for review; this is not a general natural-language date parser.

An absent amount or unspecified payment direction is represented
separately from an explicit zero in the normalized result. By product policy,
it becomes an editable draft with income and outgo set to zero and a visible
review notice; the ordinary Create action remains available. Explicit zero
does not produce the unspecified-amount notice. These notices describe the
current draft, are cleared by manual edits to the corresponding fields, and
do not add a persisted status or change the Item schema. Reopening the text
editor retains the source for that form.

The resolver rejects unquoted, unsupported or incomplete expressions instead
of trusting a generated exact day. It does not prove that the model selected
the correct phrase when several dates occur. Other fields and uncertainty flags
still need review. See the [qualification record](item-input-qualification.md) for the
measured results and the distinction between value validation and model quality.

Typed inference updates continue through `ItemFormInput` and canonical saving.
Amounts carry their formatting locale until reformatted for the editor.

## Quality evaluation

The interface simplification preceded extraction changes. The
[extraction-quality record](item-extraction-quality.md) covers the subsequent
text/model evaluation, including real copied Item output, exact source amounts,
receipt totals and unresolved direction. Receipt descriptions/categories,
photo OCR and device qualification remain follow-up work in #426. Arbitrary
pasted text is not guaranteed to be interpreted correctly. The earlier
[qualification record](item-input-qualification.md) remains historical evidence.
