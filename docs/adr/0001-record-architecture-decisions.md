# 0001. Record architecture decisions

- Status: Accepted
- Date: 2026-09-28

## Context
Decisions made early (state management, package layout, error handling)
shape every later feature. Code shows *what* was chosen but not *why*, or
what else was considered. Six months later, nobody remembers.

## Decision
Every significant, hard-to-reverse choice gets a short ADR in `docs/adr/`,
using `0000-template.md`. ADRs are never edited after acceptance; a changed
mind is a new ADR that supersedes the old one.

## Consequences
The reasoning behind the codebase is reviewable in the same PR as the code.
The cost is a few minutes of writing per decision.
