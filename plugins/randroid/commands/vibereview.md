---
description: "Run VibeReview browser-game playtest sessions and feed captured evidence into Spiral-HTML ledgers."
argument-hint: "[start|capture|end|status|list] [project path or notes]"
---

# /randroid:vibereview

Use the `vibereview` CLI to run browser-game playtest sessions, capture screenshot/browser-state evidence, and feed findings into Spiral-HTML review ledgers.

When doing the review yourself, use browser-control tools to open and play the game before capturing. Prefer the in-app Browser for local dev servers; use Chrome when the VibeReview extension, existing tabs, or logged-in browser state matters. If the extension is missing, load it unpacked from `../VibeReview/ChromeExtension`.

## Preflight

```bash
command -v vibereview
vibereview --version
```

If unavailable from this skills repo, use:

```bash
../VibeReview/scripts/cli.sh --version
```

Substitute `../VibeReview/scripts/cli.sh` for `vibereview` in the commands below when using the development wrapper.

## Quick Reference

```bash
vibereview start --project <path> [--title <title>]
vibereview capture --project <path> --note <text> [--severity note|polish|issue|blocksRelease] [--rating 1...5] [--tags a,b,c]
vibereview capture --project <path> --note-file <path-or->
vibereview end --project <path>
vibereview status [--project <path>]
vibereview list
```

Before classifying review output in a Spiral-HTML project, read `AGENTS.md`, `docs/PLAYTEST.html`, `docs/FOLLOWUPS.html`, `docs/OPEN_QUESTIONS.html`, and `docs/FUN_FACTOR_AUDIT.html`. Preserve append-only `data-*` ledger entries.

For full guidance, read `${CLAUDE_PLUGIN_ROOT}/SKILL.md`.
