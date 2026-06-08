# vibekit (skill)

Bootstrap-and-cookbook layer for [`@randroids-dojo/vibekit`](https://github.com/Randroids-Dojo/VibeKit), the in-house reusable-component library this workspace's game projects share.

## Why this skill is separate

The `spiral` skill defines methodology (gates, ledgers, loop). It is intentionally library-agnostic.

The `randroid:loop` skill executes slices (research / implement modes).

This skill, `vibekit`, supplies the worked-example layer for one specific shared library. A project that prefers a different shared library swaps this skill out without touching spiral's gate or randroid:loop's executor.

## Install

The skill is part of the `randroids-dojo/skills` plugin tree. With that tree on the agent's plugin path, the slash commands `/vibekit add` and `/vibekit cookbook` become available.

## Slash commands

- **`/vibekit add [tag]`** pins `@randroids-dojo/vibekit` in the current project's `package.json` (using a `github:` tag) and prints the matching `DEPENDENCY_LEDGER.md` entry to paste in. Defaults to the latest published tag.
- **`/vibekit cookbook [module]`** prints the per-module cookbook (or one section).

## Cookbook contents

`docs/cookbook.md` covers:

- `joystick`. Wire pointer events + render visual + apply deadzone in the consumer.
- `editor-history`. Wrap state in `EditorHistory<T>`, route mutations through `pushHistory`, gate keyboard shortcuts on `canUndo` / `canRedo`.
- `confetti`. Pure simulation + canvas renderer + self-stopping rAF loop.
- `rng`. One seeded generator per system; replay determinism contract.
- `math`. `lerp` / `clamp` / `smoothstep` / `wrapAngle` / `remap` / `inverseLerp` / `TAU` and the gotchas around clamping and degenerate ranges.
- `storage`. Defensive zod-validated `localStorage`, project-side React hook composition, hydrate-after-mount pattern.
- `kv` (server). `getKv` cached singleton, `readKv` / `writeKv` with optional TTL, dev-without-KV fallback.
- `sign` (server). HMAC-SHA256 race-token issue / verify with `iat` / `exp` checks.
- `rate-limit` (server). Fixed-window primitive, fail-open vs fail-closed decision rule.

The cookbook is a wire-up reference, not an API reference. Module APIs live in [the kit's own README](https://github.com/Randroids-Dojo/VibeKit#readme).

## How spiral and this skill compose

When a project follows spiral's Dependency Upgrade Gate and the watched dep is `@randroids-dojo/vibekit`:

1. Spiral's gate fires (after pulling main; before opening a PR). It reads `docs/DEPENDENCY_LEDGER.md`.
2. The ledger entry's `Detect-new` command surfaces a newer tag.
3. The agent runs spiral's per-dep upgrade procedure. The procedure is library-agnostic.
4. If the upgrade requires a migration, the agent consults this skill's cookbook for the affected module(s) (`/vibekit cookbook storage`) to see what wire-up patterns might shift.
5. The bump PR updates `Currently pinned` in the ledger; the cookbook stays untouched (it lives in this skill, not in the consuming project).

To replace this skill with a different shared library: swap the watched dep in the project's `DEPENDENCY_LEDGER.md`, point the cookbook reference at the other library's docs, and run that library's bootstrap command instead of `/vibekit add`. Spiral's machinery does not change.
