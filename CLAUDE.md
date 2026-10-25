# Agent Guidelines

- Read `docs/adr/` before structural changes; propose an ADR rather than silently diverging from an accepted decision.
- Respect the package layers in ADR 0005; features must not depend on other features.
- Run `dart run melos run deps:check` after dependency or package-structure changes.
- Repositories return `Result<T>` for expected failures; never throw expected failures.
- Use constructor injection for dependencies everywhere except the composition root.
- Build UI with design-system components and tokens; avoid raw spacing numbers and color values.
- Server errors use the documented JSON envelope in `docs/api.md`.
- Read server configuration through `loadConfig`; do not read environment variables directly elsewhere.
- Never include stack traces or internal error details in API responses.
- Every change ships with relevant tests; keep total line coverage at or above 80%.
- Before finishing, run `dart format --set-exit-if-changed .`.
- Before finishing, run `dart analyze --fatal-infos`.
- Before finishing, run `dart run melos run test`.
- Before finishing, run `dart run melos run coverage:gate`.
