# 0003. Expected failures are values, not exceptions

- Status: Accepted
- Date: 2026-10-06

## Context
The core package is the lowest shared layer in the workspace. It is depended on by
all other packages, so its error model has to stay simple, explicit, and easy for
teammates to reason about. We need a consistent way to represent expected domain
failures without forcing every caller to manually catch exceptions at every call
site.

We also want a boundary for runtime failures that are not part of the business
flow, so we can convert thrown exceptions into a known `AppFailure` instead of
leaking raw exceptions upward.

## Options considered
1. Throw exceptions and catch them in each caller.
   - Pros: familiar to Dart developers and works with existing code.
   - Cons: errors are not values, so control flow is harder to compose; callers
     must remember to catch and translate exceptions; typed error information is
     easy to lose; tests end up checking exception flow instead of explicit result
     handling.

2. Use a library like `fpdart` and model failures with `Either`.
   - Pros: battle-tested functional approach with a rich API and established
     semantics.
   - Cons: this is the lowest shared layer, so a large third-party dependency is a
     poor tradeoff. Every package would inherit the library's API surface and
     learning curve. New teammates need to learn not only our code, but also an
     entire functional-programming vocabulary and dependency lifecycle. If the
     library is abandoned or changes its API, we inherit that risk in every
     package that depends on it.

3. Write a small sealed `Result` and `AppFailure` hierarchy in the core package.
   - Pros: explicit, typed, dependency-light, and easy to understand. We keep
     the model small and local to our app. The API is easy to test and easy to
     review in code review.
   - Cons: call sites are a little more verbose, and we have to maintain a small
     set of helpers like `map`, `then`, and `fold` ourselves.

## Decision
We choose option 3: expected failures are represented as values using a small
sealed `Result<T>` plus a set of concrete `AppFailure` classes. Exceptions remain
reserved for truly exceptional runtime conditions.

`guard` catches thrown `Error` and `Exception` objects from the synchronous body
and converts them into `Result.err(...)`. If `onError` is provided, known
exceptions are mapped to domain-specific failures; otherwise they fall back to
`UnexpectedFailure` with the original value stored as `cause` and the current
stack trace attached.

This keeps the error contract explicit without introducing a heavyweight FP
library into the lowest layer of the codebase.

## Consequences
The code becomes clearer because success and failure are encoded in the type
system instead of hidden in exceptions. It is easier to test and reason about
when a call may fail. The real cost is slightly more verbose call sites and more
explicit handling of `Ok`/`Err` branches.

The tradeoff is intentional: we prefer a small, local contract over a large
shared dependency. That keeps the core package cheap to understand, cheap to
maintain, and resilient to dependency churn.
