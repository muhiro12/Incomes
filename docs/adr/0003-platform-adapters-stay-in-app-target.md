# ADR 0003: Platform Adapters Stay in App Target

- Date: 2026-03-04
- Status: Accepted

## Context

Some capabilities in Incomes depend directly on Apple frameworks, such as
Foundation Models, UserNotifications, StoreKit, ads, and deep-link handling.
These dependencies do not belong in the shared business layer.

## Decision

Keep platform-specific integrations in the `Incomes` target. Do not add
platform behavior to library domain services through app-target extensions.
Instead, use dedicated adapter services in the app target.

## Consequences

- `ItemInferenceService` and `NotificationService` remain app-target services.
- App-target adapters should return or consume library models and value types
  wherever possible.
- `IncomesLibrary` stays focused on platform-neutral business logic.
- When a new feature needs Apple-only APIs, the default design is an app-side
  adapter over shared services, not a new responsibility inside the library.
