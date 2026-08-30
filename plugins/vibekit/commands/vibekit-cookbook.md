---
description: Show VibeKit integration guidance for one module.
argument-hint: "[module name]"
disable-model-invocation: true
---

# /vibekit cookbook

Surface the per-module usage cookbook for `@randroids-dojo/vibekit`.

## When to use

When wiring a specific kit module into a consuming project (joystick, editor-history, confetti, rng, math, storage, server kv/sign/rate-limit) and the kit's own README needs the "how to compose this in a Next.js / React project" view.

## How to invoke

Without arguments:

```
cat ${CLAUDE_PLUGIN_ROOT}/docs/cookbook.md
```

With a module name (joystick, editor-history, confetti, rng, math, storage, kv, sign, rate-limit):

```
awk -v m="$MODULE" 'BEGIN{p=0} /^## /{p=($2==m)?1:0} p' ${CLAUDE_PLUGIN_ROOT}/docs/cookbook.md
```

The cookbook is plain Markdown; reading it is enough. The slash command wrapper just makes it discoverable.

## Sections in the cookbook

Each module gets a section with: one-line pitch, import line, minimal usage example, common compositions / gotchas. Sections are ordered to match the kit's `index.ts` re-exports plus the `./server` subpath:

- `## joystick`
- `## editor-history`
- `## confetti`
- `## rng`
- `## math`
- `## storage`
- `## kv` (server-only)
- `## sign` (server-only)
- `## rate-limit` (server-only)

The cookbook is intentionally short. It documents wire-up patterns, not the API surface (the kit's README does that).
