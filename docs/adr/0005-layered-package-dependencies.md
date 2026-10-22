# 0005. Layered package dependencies

- Status: Accepted
- Date: 2026-10-22

## Context
The workspace separates reusable code, features, and runnable apps into
packages. Package boundaries alone do not prevent dependencies from pointing
in every direction. Without a rule, features can become coupled to each
other, and lower-level packages can acquire UI or app-specific concerns.

## Options considered
1. **Allow dependencies wherever convenient.** This makes local integration
   easy, but lets the dependency graph become tangled over time.
2. **Enforce layers.** This constrains where code can live and which packages
   can depend on each other, but keeps dependencies directed and predictable.

## Decision
Workspace packages follow these layers:

| Layer | Packages | May depend on |
| --- | --- | --- |
| 0 | `packages/core` | External packages only; never Flutter |
| 1 | `packages/design_system`, `packages/data` | Layer 0 and external packages |
| 2 | `packages/features/*` | Layers 0 and 1, plus external packages |
| 3 | `apps/*` | Layers 0, 1, and 2, plus external packages |

A package may depend only on packages in a lower-numbered layer. Packages at
the same layer may not depend on one another. The dependency-check tool checks
workspace packages against this rule.

The `tool` package is exempt because it contains repository and development
utilities, not code used by the apps. It needs to inspect workspace packages
to enforce repository rules, so treating it as a product package in the
dependency hierarchy would not describe its role.
The coverage gate likewise scans only `packages/` and `apps/`; it does not
count `tool/` coverage.

In particular, feature packages cannot import each other. Cross-feature
navigation is coordinated through routes owned by the app, rather than one
feature reaching into another. Data that needs to be shared belongs in a
lower-level package, such as `packages/data` or `packages/core`, and features
can depend on it from there.

## Consequences
- Dependency direction is explicit and checked, reducing accidental
  cross-feature coupling.
- Some code that feels specific to one feature may need to move into a shared
  lower-level package if other features need it. That can make the shared
  package less feature-focused and requires care to keep its API appropriate.
- The app is responsible for composing feature routes; features cannot
  navigate directly into each other's internals.
