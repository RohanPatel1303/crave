# 0002. Monorepo with pub workspaces and Melos

- Status: Accepted
- Date: 2026-09-28

## Context
Crave ships a customer app and a staff app that share models, networking,
the design system, and offline sync. Copying that code between repos means
fixes land in one app and not the other.

## Options considered
1. **Separate repos with git-dependency packages.** Clean ownership
   boundaries, but every shared change becomes a multi-repo release dance.
2. **Single app with folders.** Simplest, but nothing stops a feature from
   importing another feature's internals; boundaries erode by convention.
3. **Monorepo of packages, Dart pub workspaces + Melos.** Pub workspaces
   (Dart 3.6+) give one lockfile and one version resolution for the whole
   repo, so two packages can never silently drift onto different versions
   of the same dependency. Melos adds scripted commands across packages.

## Decision
Option 3. Shared code lives in `packages/`, runnable apps in `apps/`.

## Consequences
- Package boundaries are enforced by the compiler: a package can only
  import what its pubspec declares.
- One `flutter pub get` at the root resolves everything.
- CI must be scoped with care as the repo grows; per-package change
  detection is a later optimization, not needed at this size.
