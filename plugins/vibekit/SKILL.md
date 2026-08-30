---
name: vibekit
description: Add @randroids-dojo/vibekit as a tag-pinned dependency and apply its per-module integration patterns. Use when a project needs VibeKit installation, dependency-ledger guidance, or cookbook help for its client and server modules.
---

# VibeKit

`@randroids-dojo/vibekit` is the in-house reusable-component library this workspace's game projects share. The default entry exposes framework-agnostic client modules (virtual-joystick, editor-history, confetti, rng, math, storage); the `./server` subpath exposes Node-only helpers (kv, sign, rate-limit) locked to `@upstash/redis` + `node:crypto`.

This skill is the bootstrap-and-cookbook layer for VibeKit. It is intentionally optional and lives alongside `spiral` (structural-discipline scaffold) and `randroid-loop` (research / implement loops) the same way: spiral defers to `randroid-loop` for execution; spiral defers to *this* skill for VibeKit-specific bootstrap and component usage. A project that prefers a different shared library swaps this skill out without touching spiral's gate, ledger, or loop machinery.

## Workflows

- **Add:** resolve `scripts/add.sh` relative to this skill directory, inspect its options, then use it to add a tag-pinned dependency and print the proposed dependency-ledger entry. Do not let it overwrite existing project-specific ledger prose.
- **Cookbook:** read `docs/cookbook.md` only when wiring a specific module or diagnosing an integration pattern.

## How this skill relates to spiral

- **Spiral** defines the Dependency Upgrade Gate, the ledger format, and the upgrade procedure. It does not know about any specific dependency.
- **VibeKit** (this skill) supplies the worked example for the spiral ledger and the cookbook for wiring up each module. A project that uses VibeKit gets a richer ledger entry (with import snippets) and a cookbook reference; a project that prefers a different shared library follows the same spiral procedure with that library's own skill.
- **Randroid Loop** is the optional slice executor. When a slice is "bump VibeKit from vX to vY," it follows Spiral's procedure; this skill supplies the VibeKit-specific migration patterns.

## Composition

```
spiral (methodology + scaffold + Dependency Upgrade Gate)
   ├─ defers execution to randroid-loop
   └─ defers VibeKit-specific bootstrap + cookbook to vibekit (this skill)
```

Replace any leg without affecting the others.

## Architecture

```
vibekit/
├── SKILL.md                    # This file
├── README.md                   # Human-facing one-pager
├── .claude-plugin/
│   └── plugin.json             # Plugin metadata
├── commands/
│   ├── vibekit-add.md          # /vibekit add slash command
│   └── vibekit-cookbook.md     # /vibekit cookbook slash command
├── docs/
│   └── cookbook.md             # Per-module usage cookbook
└── scripts/
    └── add.sh                  # Bootstrap into a target repo
```

## What's in the kit

The kit lives at https://github.com/Randroids-Dojo/VibeKit. Releases are cut by release-please on every push to its `main`; tags follow `vX.Y.Z`. Pre-1.0 the kit treats every `feat:` as a patch via `bump-patch-for-minor-pre-major`, so any patch tag may carry signature changes; consumers read the CHANGELOG between pinned and target.

Default entry (`@randroids-dojo/vibekit`):

- `virtual-joystick`. Float-where-you-tap touch joystick state.
- `editor-history`. Generic `EditorHistory<T>` undo / redo stack.
- `confetti`. Pure particle simulation for celebration overlays.
- `rng`. Seeded Mulberry32 PRNG plus `range`, `pick`, `gauss`.
- `math`. `TAU`, `clamp`, `lerp`, `inverseLerp`, `remap`, `smoothstep`, `wrapAngle`.
- `storage`. Defensive zod-validated `localStorage` helpers with cross-tab + same-tab change events.

Server entry (`@randroids-dojo/vibekit/server`, Node-only):

- `kv`. `getKv` cached singleton (null on missing env), `readKv<T>` zod-validated, `writeKv` with optional TTL, `removeKv`, `resetKvForTesting`.
- `sign`. HMAC-SHA256 `signToken` / `verifyToken` with constant-time comparison.
- `rate-limit`. `incrementWithExpiry` fixed-window primitive (returns post-increment count).
