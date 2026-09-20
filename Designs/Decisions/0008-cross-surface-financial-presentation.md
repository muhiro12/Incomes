# ADR 0008: Cross-Surface Financial Presentation

- Date: 2026-09-20
- Status: Accepted

## Context

The app, Apple Watch, and widgets each decide how a financial direction looks.
Reviewing them together showed three inconsistencies: Watch used color as the
only signal for a direction, widgets and the app named the same direction with
different symbols and colors, and the app's list indicator described negative
and zero net income to VoiceOver while drawing nothing for them.

## Decision

`ItemSummaryOperations.NetIncomePresentation` stays the single classifier:
income minus outgo greater than zero is `positive`, exactly zero is `neutral`,
and less than zero is `negative`. Zero is never described as a profit.

Presentation follows one matrix on every surface:

| Direction | Symbol | Color | Spoken as |
| --- | --- | --- | --- |
| Positive | `chevron.up` | accent | "Positive net income" |
| Neutral | `minus` | secondary | "Zero net income" |
| Negative | `chevron.down` | red | "Negative net income" |

- The symbol comes from `NetIncomePresentation.symbolName`, so no surface picks
  its own shape. Where a surface needs a filled badge instead of a bare glyph,
  such as an App Intents entity image, it uses the `.circle.fill` variant of the
  same symbol rather than a different shape.
- Color is never the only signal. Every surface that colors an amount also
  draws the symbol or states the direction in its accessibility label.
- Accessibility must match what is drawn. The app's list indicator marks only a
  positive result, so it stays silent for the other directions instead of
  describing an invisible state; the row still reads its localized amounts.
- Amounts, percentages, and dates use the active locale everywhere. Stored
  values never change for presentation.

## Consequences

- Widgets use the accent color for a positive result, like the app and Watch.
  All three targets define the accent as the system green, so the rendered color
  is unchanged.
- Adding a surface means reusing the classifier, the symbol, and this wording
  rather than defining a fourth rule.
- Changing a color or symbol is a change to this matrix, not to one surface.
