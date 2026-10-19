# 0004. BLoC for application state

- Status: Accepted
- Date: 2026-10-18

## Context

Crave needs a consistent way to represent what the app is doing and what the
user can see. A feature should be able to describe its state transitions
without tying its business rules to Flutter widgets, and those transitions
should be straightforward to test.

Provider is a lightweight way to expose and observe values in the widget tree.
It works well for simple state, but teams can end up mixing state changes and
business decisions into widgets or notifier methods as a feature grows.
Riverpod improves dependency management and test overrides, and offers flexible
provider-based state patterns. It is a strong alternative, but it does not by
itself require the event-to-state workflow we want for more involved features.
BLoC makes that workflow explicit: inputs are events, and the feature responds
by emitting states.

## Decision

Use BLoC as Crave's standard for feature state. User actions and relevant
background updates enter a feature as typed events; the BLoC handles them and
emits states for the UI to render. Keep business decisions in the BLoC and
collaborating services rather than in widgets.

This explicit flow is especially useful in checkout, where we need to trace
validation, payment and submission; in sync, where local changes and remote
updates can overlap; and in live order tracking, where repeated incoming
updates must produce predictable UI states.

## Consequences

- Event and state types make transitions visible, testable, and easier to
  diagnose than implicit widget-driven changes.
- BLoC adds real overhead: a feature often needs separate files for its
  events, states, BLoC, and UI. Use it where feature state warrants that
  structure rather than adding layers without a clear need.
- Step 2 added dev, staging, and prod flavors to Android, but iOS still has
  only the default Runner scheme and configurations; it does not yet map
  native schemes to those flavors. The iOS bootstrap permits a missing native
  flavor, so Dart-side configuration can still be supplied, but native
  flavor-specific build configuration remains a known gap.
