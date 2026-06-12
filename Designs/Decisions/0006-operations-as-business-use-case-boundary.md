# ADR 0006: Operations as Business Use-Case Boundary

- Date: 2026-06-11
- Status: Accepted

## Context

`IncomesLibrary` is the source of truth for reusable business behavior across
the iOS app, App Intents, Apple Watch, widgets, and other delivery surfaces.
Those surfaces need one stable way to call the library without learning its
internal calculators, builders, planners, loaders, or persistence details.

The repository already used many `*Operations` types, but some surfaces still
called public helper objects directly. That made the public library surface
less clear and made App Intents more likely to grow business branching outside
the shared library.

## Decision

Business use cases that delivery surfaces call must be exposed through public
`*Operations` facades in `IncomesLibrary`.

`Operations` is the shared library's application layer. It may orchestrate
models, value types, calculators, builders, planners, loaders, parsers, codecs,
and persistence queries, but those collaborators should not become the primary
public business interface for app, intent, watch, or widget surfaces.

Delivery surfaces may call public non-Operations contracts only when the type
is not a business use case. Examples include value types, route and deep-link
contracts, wire payloads, snapshot models, parsers, codecs, persistence setup,
and development or platform-support utilities.

## Consequences

- App Intents, widgets, watch code, and app UI adapters should call
  `*Operations` or a thin app-side adapter that calls `*Operations`.
- If a surface needs to call a calculator, builder, planner, or loader for
  business behavior, that is a sign that a library operation is missing.
- Implementation helpers can remain well-named and tested, but should usually
  be `internal` collaborators.
- Public result types remain valid when they are part of the stable operation
  contract.
- This decision does not require route, wire, snapshot, parser, codec, model,
  or persistence setup types to use the `Operations` suffix.
