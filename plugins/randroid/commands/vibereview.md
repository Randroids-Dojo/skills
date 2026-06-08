---
description: "Run VibeReview browser-game playtest sessions and feed captured evidence into Spiral-HTML ledgers."
argument-hint: "[start|capture|end|status|list] [project path or notes]"
---

# /randroid:vibereview

Use the VibeReview headless CLI to run browser-game playtest sessions, capture screenshot/browser-state evidence, and feed findings into Spiral-HTML review ledgers.

When doing the review yourself, use browser-control tools to open and play the game before capturing. Prefer the in-app Browser for local dev servers; use Chrome when the VibeReview extension, existing tabs, or logged-in browser state matters. If the extension is missing, load it unpacked from `../VibeReview/ChromeExtension`.

## Preflight

```bash
VIBEREVIEW_CLI=""
for candidate in \
  "../VibeReview/.build/reinstall/vibereview" \
  "../VibeReview/build/vibereview" \
  "/Users/randroid/Documents/Dev/VibeReview/.build/reinstall/vibereview" \
  "/Users/randroid/Documents/Dev/VibeReview/build/vibereview"
do
  if [[ -x "$candidate" ]]; then
    VIBEREVIEW_CLI="$candidate"
    break
  fi
done

if [[ -z "$VIBEREVIEW_CLI" ]]; then
  if [[ -x "../VibeReview/scripts/build.sh" ]]; then
    ../VibeReview/scripts/build.sh
    VIBEREVIEW_CLI="../VibeReview/build/vibereview"
  elif [[ -x "/Users/randroid/Documents/Dev/VibeReview/scripts/build.sh" ]]; then
    /Users/randroid/Documents/Dev/VibeReview/scripts/build.sh
    VIBEREVIEW_CLI="/Users/randroid/Documents/Dev/VibeReview/build/vibereview"
  else
    echo "Could not find VibeReview repo or standalone CLI. Set VIBEREVIEW_CLI to the headless binary path." >&2
    exit 1
  fi
fi

if [[ "$VIBEREVIEW_CLI" == *".app/Contents/MacOS/"* ]]; then
  echo "Refusing app-bundle path: $VIBEREVIEW_CLI" >&2
  exit 1
fi

"$VIBEREVIEW_CLI" --version
```

Do not start by running bare `vibereview`; on some machines `/usr/local/bin/vibereview` launches the GUI app. Also avoid `../VibeReview/build/VibeReview.app/Contents/MacOS/vibereview`; on case-insensitive APFS it collides with the GUI executable `VibeReview`. If the build artifact is unavailable, inspect any alternate path before executing it:

```bash
readlink /usr/local/bin/vibereview 2>/dev/null || true
```

Use the verified `"$VIBEREVIEW_CLI"` path in the commands below.

## Quick Reference

```bash
"$VIBEREVIEW_CLI" start --project <path> [--title <title>]
"$VIBEREVIEW_CLI" capture --project <path> --note <text> [--severity note|polish|issue|blocksRelease] [--rating 1...5] [--tags a,b,c]
"$VIBEREVIEW_CLI" capture --project <path> --note-file <path-or->
"$VIBEREVIEW_CLI" end --project <path>
"$VIBEREVIEW_CLI" status [--project <path>]
"$VIBEREVIEW_CLI" list
```

Before classifying review output in a Spiral-HTML project, read `AGENTS.md`, `docs/PLAYTEST.html`, `docs/FOLLOWUPS.html`, `docs/OPEN_QUESTIONS.html`, and `docs/FUN_FACTOR_AUDIT.html`. Preserve append-only `data-*` ledger entries.

For full guidance, read `${CLAUDE_PLUGIN_ROOT}/SKILL.md`.
