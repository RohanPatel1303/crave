# 0008. HTTP client behind an API client

- Status: Accepted
- Date: 2026-10-29

## Context

Features need to call the Crave API. The choice of HTTP library affects how
features make requests, how common behavior is kept consistent, and how easily
the transport can be changed or tested. The client should keep network details
out of feature code without hiding useful capabilities behind an arbitrary
abstraction.

## Options considered

1. **Call `package:http` directly from features.** This uses a small,
   familiar HTTP API and avoids maintaining a project-specific wrapper.
   Features can make requests with little setup. As the app grows, however,
   each feature can end up handling base URLs, headers, errors, and other
   cross-cutting behavior on its own. Features also become coupled to the
   chosen package.
2. **Call Dio directly from features.** Dio provides a richer client, including
   interceptors and configurable request behavior, without requiring us to
   build a wrapper first. Features would gain direct access to those
   capabilities, but they would also depend on Dio and could implement shared
   concerns inconsistently. Replacing the transport or changing common
   behavior would touch feature code.
3. **Put Dio behind an `ApiClient` in `packages/data/api_client`.** Features
   depend on an app-facing API rather than constructing Dio requests
   themselves. The client can centralize shared transport configuration and
   behavior, and provide one seam for testing or changing the implementation.
   This adds a wrapper that the project must design and maintain. Dio features
   also remain unavailable to features until the `ApiClient` deliberately
   exposes them.
4. **Generate a client from an OpenAPI specification.** Generation can keep
   request and response types aligned with a maintained API contract and
   reduce handwritten endpoint code. It also introduces a specification,
   generator configuration, and generated-code workflow to maintain. This is
   deferred until the API has enough endpoints for those costs to pay off.

## Decision

Use Dio behind an `ApiClient` in `packages/data/api_client`. Feature packages
will call the `ApiClient`, not Dio or `package:http` directly. Keep the
interface focused on the API needs of the app and expose additional Dio
capabilities deliberately as those needs arise.

Defer generating a client from OpenAPI until the API has many endpoints.

## Consequences

- Shared request configuration and API behavior have one owner instead of
  being repeated across features.
- Features depend on the `ApiClient` contract rather than on Dio's request
  APIs, leaving the transport easier to replace and the client easier to
  substitute in tests.
- The `ApiClient` is a wrapper that must be maintained as API needs evolve.
- Dio capabilities are not automatically available to feature code; the
  `ApiClient` must expose each capability intentionally.
- For now, endpoint and model code remains handwritten. Revisit OpenAPI
  generation when the number of endpoints makes keeping that code in sync
  burdensome.
