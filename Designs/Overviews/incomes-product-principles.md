# Incomes Product and Design Principles

[日本語](incomes-product-principles.ja.md)

## Product purpose

Incomes is a budget planner for future income, payments, and available money.
Entering a schedule should help someone decide whether next month's or next
year's balance can support a plan. Recording transactions is a means to that
decision, rather than a goal of bookkeeping or investment administration.

Future Items express estimates. When a planned card payment of 100,000 becomes
an actual payment of 80,000 or 120,000, ordinary Item editing should remain
sufficient. Market valuations can change without a payment: unrealized gains,
sales within an investment account, and withdrawals are different events.
Treating those as ordinary cash flow would need a separate financial domain.

Simple interactions must preserve the meaning of financial records. Simplicity
does not justify ambiguous ownership, silently lost data, or incorrect totals.

## Item and Tag responsibilities

Items own financial facts: dates, descriptions, income, and outgo. A stored
`Item.balance` is a derived result, rather than another authoritative amount.
It is also the established baseline for later calculations. Incomes mirrors
real-world money and records; it cannot reconstruct every historical adjustment.
Changing a record updates balances from that day onward, using the preceding
saved balance. Reading or syncing data must not silently rebuild earlier history
and change a current balance that already matches reality.
Tags support classification, search, grouping, and technical indexes. User
categories coexist with system-managed year, month, and content tags; Tag has
never meant only an arbitrary user label.

The compact model grew through Core Data migration, early SwiftData constraints,
and query and section presentation requirements. Respect that rationale without
turning two models into a permanent limit. A financial book has stricter rules
than a many-to-many classification: each Item belongs to exactly one book.

Shared rules remain in IncomesLibrary, accessed through Operations. Views own
presentation. These principles complement accepted ADRs
[0001](../Decisions/0001-shared-library-source-of-truth.md),
[0004](../Decisions/0004-views-own-presentation-not-business-rules.md),
[0006](../Decisions/0006-operations-as-business-use-case-boundary.md),
[0007](../Decisions/0007-persisted-amount-boundaries.md), and
[0008](../Decisions/0008-cross-surface-financial-presentation.md).

## Reversibility and compatibility

Evaluate three different costs: reverting code, reverting a persisted format,
and recovering the meaning of saved data. UI experiments are usually easy to
reverse. A preference key, synced column, model, backup field, or structured
Tag convention can create a durable contract after distribution. An unchanged
database schema does not mean an unchanged persistence contract.

Start with the structure that best serves the current product. Then evaluate
old writers, offline CloudKit changes, concurrent edits, derived balances,
backup restoration, and companion surfaces. Keep safeguards proportionate to
the actual risk and usage. Even one person's silently reassigned or lost
financial record matters. Recomputable balances and lost ownership information
are materially different failures.

Update requests can reduce old-client use; they do not prove that offline
writers or system entry points have stopped. Adopt a dedicated field or model
when it is necessary for integrity and recovery, with migration evidence.
Avoiding a schema change is never a reason to sacrifice those properties.

## Keep separate product problems separate

Independent books, assumed compound returns, market valuation, and transfers
address different needs. One does not automatically require the others.

Generating interest as ordinary income Items could fit additive balance
calculation. However, changing rates from 3% to 4% to 5%, increasing monthly
contributions from 100,000 to 150,000, and reconciling confirmed results require
time-dependent rules and protection for actuals. A single annual-rate column
does not settle that behavior. Automatic creation and dynamic recalculation
are also different contracts.

Do not introduce a System Item or CompoundRule persistence abstraction before
concrete use cases and shared invariants justify it. A future transfer can be
represented conceptually by two ordinary Items; linked corrections, deletion,
and excluding internal transfers from combined reports require a separate
contract. That future possibility does not require a speculative schema now.

## Premium access and financial ownership

Entitlement belongs at the product boundary, rather than in financial records.
When Premium expires, retain additional books, their identities, and access to
view, select, and export them. The default book remains editable; additional
book mutations require Premium. Never merge, delete, or reassign saved records
because entitlement changed. A pending draft must retain its original owner.

## Decision history and the October 16, 2026 direction

1. The discussion began with household, business, and investment books and a
   uniform annual return for an investment book.
2. Item-owned identity, book Tags, and a dedicated Account model were compared.
   The compact existing graph and persistence costs favored investigating Tags.
3. Direct compound balance calculation evolved into materialized monthly income
   Items that could follow contribution changes, and then a broader System Item
   proposal.
4. Rate history, changed contributions, confirmed actuals, sales, paused
   contributions, and market movements exposed the difference between a budget
   planner and investment valuation.
5. Independent books retained their value without requiring interest, System
   Items, or transfer automation in the next major release.
6. Old-writer probes exposed Tag membership loss and global balance overwrites.
   Product fit, compatibility mitigation, and fallback selection became
   separate steps of the decision.

The October 16 direction targets independent books in the existing Premium
entitlement for 6.0. It starts by evaluating Tag ownership and retains
Item-owned identity as a fallback if membership cannot be protected or
recovered. Compound interest, System Items, market valuation, and automated
transfers are outside this slice. This is a dated direction, not a declaration
that a persistence design is safe or a release is approved.

## Sources of truth

- [Architecture guide](../Architecture/ARCHITECTURE_GUIDE.md):
  technical boundaries.
- [Product vocabulary](../Architecture/product-vocabulary.md):
  user-facing terms.
- [Current overview](incomes-current-overview.md):
  implemented feature inventory.
- [#371](https://github.com/muhiro12/Incomes/issues/371):
  release scope and roadmap.
- [#379](https://github.com/muhiro12/Incomes/issues/379):
  model evolution invariants.
- [#382](https://github.com/muhiro12/Incomes/issues/382):
  ledger decisions,
  comparison probes, and adoption conditions.
- [#383](https://github.com/muhiro12/Incomes/issues/383):
  implementation evidence.
- [#403](https://github.com/muhiro12/Incomes/issues/403):
  provenance of these principles.

The dated discussion above supplies context; those owning documents and Issues
remain authoritative for current contracts and release decisions.
