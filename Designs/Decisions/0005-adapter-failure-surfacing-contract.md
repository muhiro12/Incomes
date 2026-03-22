# ADR 0005: Adapter Failure-Surfacing Contract

- Date: 2026-03-22
- Status: Accepted

## Context

This repository already defines strong domain and adapter boundaries, but that
alone does not prevent silent failures. Recent mutation and sync paths exposed
several ways an adapter can still hide operational problems:

- a primary mutation can fail while the UI still dismisses
- an App Intent can return success after an adapter-level precondition failure
- a sync adapter can collapse transport or decode failures into an empty result
- post-mutation follow-up work can fail without a shared decision about whether
  the operation should block, degrade, retry, or log

Without a repository-wide contract, each adapter may make incompatible choices
about user feedback, retries, and observability.

## Decision

Every adapter-owned mutation or sync path must classify failures into one of
the phases below and surface them consistently.

| Phase | Examples | Contract |
| --- | --- | --- |
| Preflight failure before mutation | Missing item, invalid local dependency wiring, parameter conversion that cannot produce a valid domain call | Block success. Keep the current UI or throw from the App Intent. Do not dismiss, navigate away, or return a success result. |
| Primary domain mutation failure | Validation failure, fetch failure, persistence error, domain service throw | Block success. Surface the error to the current caller. The caller must not present the operation as saved, created, updated, or deleted. |
| Post-commit follow-up failure | Notification refresh, widget reload, other adapter-only side effects after the domain write has already committed | Treat as degraded success, not as rollback. Preserve the committed mutation result, but emit observable failure signals and schedule or expose repair when practical. |
| Sync transport or snapshot-apply failure | Phone unreachable, payload encode/decode failure, snapshot apply failure | Surface an explicit sync failure state. Do not collapse the failure into a valid empty-data result. Do not overwrite local state unless the apply step succeeded. |

## Required Surface Behavior

### UI adapters

- Keep the current screen or dialog context on blocking failures.
- Show an explicit error presentation when the user initiated the action.
- Do not dismiss edit or create flows after a blocking failure.

### App Intents

- Throw on blocking failures.
- Do not return `.result(...)` when adapter preconditions or primary mutations
  failed.
- If a follow-up fails after a committed mutation, do not claim the mutation
  itself was rolled back.

### Background and sync adapters

- Return or publish a state that distinguishes:
  - success with data
  - success with zero data
  - failure before data was refreshed
- Never use `[]`, `nil`, or other empty-state sentinels as the only failure
  signal.

## Observability Requirements

For degraded-success and sync-failure cases, adapters must emit enough context
for diagnosis:

- operation name
- surface (`View`, `AppIntent`, `Watch`, `Widget`, or background task)
- failure phase
- error payload
- follow-up hint or sync stage when applicable

Assertions may supplement this in debug builds, but they do not satisfy the
contract on their own.

## Recoverability Expectations

- Blocking failures stop the current success path immediately.
- Degraded-success follow-up failures should prefer idempotent repair paths,
  such as a later refresh or a manual retry entry point.
- Sync apply failures must preserve the last known-good local state until a new
  snapshot is applied successfully.

## Consequences

- Adapter code must make success semantics explicit instead of relying on
  assertions or empty sentinels.
- Mutation workflows should distinguish primary mutation errors from follow-up
  execution errors.
- Watch sync and other replication paths need explicit result models instead of
  ambiguous empty collections.
- Future adapter refactors can be reviewed against a repository-level contract
  rather than per-feature interpretation.
