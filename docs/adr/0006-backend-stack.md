# 0006. Backend stack

- Status: Accepted
- Date: 2026-10-24

## Context

Crave needs a backend for its mobile client. The server stack should be
productive to develop, support reliable API boundaries, and build skills that
are useful beyond this project.

## Options considered

1. **Dart on the server with Dart Frog or Shelf.** Using Dart on both client
   and server could allow models or other code to be shared and would reduce
   the number of languages in the repository. The tradeoff is a smaller
   server ecosystem and fewer opportunities to practice backend skills
   commonly requested in the roles being targeted.
2. **Node.js, TypeScript, and Express.** This is a widely used backend
   combination with a large package ecosystem. TypeScript provides static
   types while keeping the server approachable to JavaScript developers.
   Choosing it also gives deliberate practice with a skill employers ask for.
   The tradeoff is introducing a second language alongside Dart and Flutter.
3. **Firebase as a managed backend.** Firebase can get authentication,
   storage, and other backend capabilities working quickly with little server
   code. That speed comes with less control over server behavior and greater
   reliance on a particular managed platform. I've used Firebase before and
   want to learn a different stack.

## Decision

Choose Node.js, TypeScript, and Express for the server. The ecosystem and
TypeScript's typing support provide a practical foundation, and learning a
backend stack sought by employers is an intentional part of this choice.

## Consequences

- Server and app code use different languages, so API models are not shared
  automatically. The API contract must be kept in sync by hand; `docs/api.md`
  records the response envelope and maps server error codes to Dart failures.
- The team must maintain Node dependencies and server quality checks alongside
  the Dart and Flutter toolchain.
- This choice can be revisited if sharing models becomes more valuable than
  the ecosystem and learning benefits, or if a managed backend better fits
  the product's needs.