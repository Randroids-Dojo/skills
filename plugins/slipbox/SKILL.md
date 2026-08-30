---
name: slipbox
description: Capture atomic notes, search and browse PrivateBox, and run SlipBox semantic link, cluster, tension, and theme-synthesis workflows. Use when the user asks to add an idea to SlipBox, find or connect notes, inspect the knowledge graph, or refresh its semantic analysis.
compatibility: Requires SLIPBOX_API_KEY, SLIPBOX_URL, and SLIPBOX_PRIVATEBOX_REPO. Reading PrivateBox also requires gh authentication or a GitHub token.
---

# SlipBox

Use the SlipBox service for writes and semantic passes. Use PrivateBox as the persisted read surface. Do not bypass the service by writing notes directly to the repository.

## Preflight

Check only whether the required variables are present; never print the secret value:

```bash
test -n "$SLIPBOX_API_KEY" && echo "SLIPBOX_API_KEY: set" || echo "SLIPBOX_API_KEY: missing"
test -n "$SLIPBOX_URL" && echo "SLIPBOX_URL: set" || echo "SLIPBOX_URL: missing"
test -n "$SLIPBOX_PRIVATEBOX_REPO" && echo "SLIPBOX_PRIVATEBOX_REPO: set" || echo "SLIPBOX_PRIVATEBOX_REPO: missing"
```

If a required value is missing, stop and name the missing variable. Do not search shell history or configuration files for secrets.

Verify the service before any write or analysis call:

```bash
curl -fsSL "$SLIPBOX_URL/api/health"
```

If the service is unavailable or an API call returns a non-2xx response or JSON `error`, stop, report the response safely, and wait for direction. Do not retry with altered data or fall back to direct repository writes.

## Choose the workflow

- **Capture an atomic note:** read [references/api.md](references/api.md), then call `POST /api/add-note`. Keep one focused idea per note. Use `type: meta` or `type: hypothesis` only when that semantic type is intentional.
- **Run semantic passes:** read [references/api.md](references/api.md). Run link, cluster, and tension passes in that order when refreshing the full graph.
- **Synthesize themes:** fetch `/api/theme-data`, write one focused synthesis per cluster, and post each through `/api/add-note` with `type: meta`.
- **Browse or search persisted notes:** read [references/privatebox.md](references/privatebox.md) and use authenticated GitHub reads. Do not mutate PrivateBox through this path.

All authenticated service requests use:

```text
Authorization: Bearer $SLIPBOX_API_KEY
```

## Completion

For writes, report returned note IDs and meaningful links without exposing secrets. For analysis passes, report processed counts and resulting graph state. For searches, distinguish exact matches from inferred relationships. Never claim persistence until the service response or PrivateBox readback confirms it.
