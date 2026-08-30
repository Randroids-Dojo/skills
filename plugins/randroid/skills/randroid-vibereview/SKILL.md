---
name: randroid-vibereview
description: Run VibeReview browser-game playtests, capture screenshot and browser-state evidence, and feed findings into Spiral-HTML review ledgers. Use when the user asks to playtest a browser game, capture VibeReview evidence, inspect an existing VibeReview session, or turn playtest findings into durable follow-ups.
---

# VibeReview

Use the VibeReview headless CLI to capture evidence from an actual browser-game playtest.

## Preflight

1. Read the target repository's instructions and review ledgers.
2. Locate a headless `vibereview` binary. Prefer a project-relative build, then the known development checkout. Inspect unknown symlinks before executing them.
3. Reject GUI app-bundle executables and do not assume a bare `vibereview` command is the CLI.
4. Verify the selected binary with `--version`.
5. Open and play the game with the available browser-control capability before capturing evidence. Use an existing authenticated browser only when the session requires it.

## Session workflow

Use the verified CLI path for all commands:

```bash
"<vibereview-cli>" start --project <path> [--title <title>]
"<vibereview-cli>" capture --project <path> --note <text> [--severity note|polish|issue|blocksRelease] [--rating 1...5] [--tags a,b,c]
"<vibereview-cli>" capture --project <path> --note-file <path-or->
"<vibereview-cli>" end --project <path>
"<vibereview-cli>" status [--project <path>]
"<vibereview-cli>" list
```

1. Start or inspect the intended session.
2. Capture only after observing the relevant state. Write concrete notes describing the action, observed result, and user impact.
3. Use `blocksRelease` only for evidence that genuinely blocks release.
4. End the session and inspect the written artifacts.
5. Check `git status` because VibeReview may add media and mutate review ledgers.

## Spiral-HTML integration

Before classifying findings, read `AGENTS.md`, `docs/PLAYTEST.html`, `docs/FOLLOWUPS.html`, `docs/OPEN_QUESTIONS.html`, and `docs/FUN_FACTOR_AUDIT.html` when present.

- Preserve append-only `data-*` entries.
- Map severe evidence to a `blocks-release` follow-up unless the CLI already created one.
- Put ambiguous product choices in `OPEN_QUESTIONS.html` with options and a recommended default.
- Put experience-level gaps in `FUN_FACTOR_AUDIT.html`; do not mark implementation coverage complete merely because evidence was captured.
- For legacy Markdown projects, preserve artifacts without silently converting the ledger format.

Finish with the session ID, captured evidence, ledger changes, follow-ups, and any unverified behavior.

