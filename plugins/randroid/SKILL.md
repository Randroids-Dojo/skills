---
name: randroid
description: "Randroid command namespace. Use when the user asks for available Randroid slash commands or invokes /randroid directly. Includes /randroid:loop, /randroid:address-pr-comments, /randroid:vibereview, and /randroid:clean-slop."
---

# Randroid Commands

## loop

Run the autonomous research/implementation loop. In Claude Code, use `/randroid:loop`.

The loop supports either task tracker:
- `dot-html` for HTML-backed tasks under `.dots/`
- `dot` for Markdown-backed tasks under `.dots/`

Each iteration detects the project tracker and uses the selected command as `$DOT`. Do not mix `dot` and `dot-html` in one project.

Bundled loop resources:
- `commands/loop.md`: Claude Code slash command instructions
- `research-loop.md` and `implement-loop.md`: mode-specific prompts
- `loop-shared.md`: shared task tracker, git workflow, iteration, and completion rules
- `scripts/setup-loop.sh`: initializes loop state
- `scripts/randroid-loop.sh`: external loop wrapper for Codex
- `hooks/stop-hook.sh`: Claude Code keep-context loop hook

## address-pr-comments

Address every actionable PR review comment end to end: inspect the feedback, update the code, verify the change, and reply clearly.

### Workflow

1. Identify the target PR from the user's link/number, the current branch, or the available GitHub tooling. If no PR can be identified, ask for the PR URL or number.
2. Gather all review comments, review threads, requested changes, and relevant CI context. Prefer thread-aware APIs when available so resolved and outdated comments are not mistaken for open work.
3. Classify each comment as actionable, already addressed, outdated, duplicate, or needing clarification. Do not ignore requested changes.
4. Implement fixes for all actionable comments. Keep edits scoped to the review feedback unless a nearby change is required for correctness.
5. Run the smallest meaningful verification for the changed area. If verification cannot run, say exactly why in the PR response and final message.
6. Reply to each addressed thread, or leave a concise PR summary if the available tooling cannot reply inline. Mention what changed and any tests run.
7. Do not mark a thread resolved unless the issue is actually fixed or the reviewer explicitly made it non-actionable.

### Comment Signature

Every comment or reply posted to GitHub must end with this signature on its own line:

```text
-- Randroid (Randy's Bot)
```

Do not use a different sign-off. Do not omit the signature from inline review replies, PR comments, or review summaries.

### Response Style

- Be specific about the files or behavior changed.
- Keep replies short; reviewers need status, not a changelog.
- If a comment is not actionable, explain why and sign the reply.
- If user approval is required before posting comments in the current harness, prepare the exact signed comment text and ask before posting.

## vibereview

Run browser-game playtest review sessions with the VibeReview headless CLI. In Claude Code, use `/randroid:vibereview`.

VibeReview records review sessions, screenshots, browser-state snapshots, notes, severity, rating, and tags, then writes review artifacts into the target project. In Spiral-HTML projects, those artifacts are evidence for the qualitative gate: `docs/PLAYTEST.html`, `docs/FOLLOWUPS.html`, `docs/OPEN_QUESTIONS.html`, and `docs/FUN_FACTOR_AUDIT.html`.

Use this command when the user asks to review, playtest, capture feedback, record evidence, or turn a human game-review observation into project artifacts.

VibeReview does not replace hands-on review. When the agent is doing the review itself, it should use available browser-control tools to open the target game, interact with it, inspect visible behavior, and reproduce observations before running `"$VIBEREVIEW_CLI" capture`. Use the in-app Browser for local URLs such as `localhost`, `127.0.0.1`, or `file://` when available. Use Chrome when the review depends on an installed Chrome extension, logged-in browser state, existing tabs, or the VibeReview Chrome extension bridge.

### Preflight

First choose a real headless CLI path and store it in `VIBEREVIEW_CLI`. Do not start by running the bare `vibereview` command. On some machines `/usr/local/bin/vibereview` is an app launcher into `/Applications/VibeReview.app`; calling it can open GUI windows instead of printing CLI output.

Prefer standalone build artifacts outside `VibeReview.app`. The known-good candidates are `.build/reinstall/vibereview` and `build/vibereview` inside the VibeReview repo. The snippet checks both a sibling repo from the current working directory and Randy's normal local source path:

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

If the build artifact is unavailable, inspect any alternate path before executing it. Avoid `/usr/local/bin/vibereview` when it resolves under `/Applications/VibeReview.app`. Also avoid `../VibeReview/build/VibeReview.app/Contents/MacOS/vibereview`: on case-insensitive APFS, lowercase `vibereview` collides with the GUI executable `VibeReview`, so that path can launch the app instead of the CLI.

```bash
readlink /usr/local/bin/vibereview 2>/dev/null || true
```

Use the verified `"$VIBEREVIEW_CLI"` path in every command below. Do not substitute bare `vibereview` unless it has already been verified not to launch the GUI.

For browser snapshots:

- Keep the VibeReview Chrome extension loaded in the Chromium browser tab under review.
- If the extension is not installed, install it from source: open Chrome or another Chromium browser to `chrome://extensions`, enable Developer Mode, click "Load unpacked", and choose `../VibeReview/ChromeExtension` from this skills repo. If working from a different directory, resolve that path to the sibling VibeReview repo.
- The CLI listens briefly on `http://127.0.0.1:37717/snapshot` during capture.
- If capture reports that the browser snapshot is unavailable, preserve the screenshot/note result and mention that the extension or port was not available.
- If port `37717` is occupied by the VibeReview app or another process, close the app/process or retry when the port is free.

### CLI Reference

```bash
"$VIBEREVIEW_CLI" start --project <path> [--title <title>]
"$VIBEREVIEW_CLI" capture --project <path> --note <text> [--severity note|polish|issue|blocksRelease] [--rating 1...5] [--tags a,b,c]
"$VIBEREVIEW_CLI" capture --project <path> --note-file <path-or->
"$VIBEREVIEW_CLI" end --project <path>
"$VIBEREVIEW_CLI" status [--project <path>]
"$VIBEREVIEW_CLI" list
"$VIBEREVIEW_CLI" --version
```

Defaults:

- `--severity` defaults to `issue`.
- `--rating` defaults to `3`.
- `--tags` is a comma-separated list; empty entries are ignored.
- `--note-file -` reads the note from stdin.

### Review Workflow

1. Identify the project root. Use the game repo path, not the skills repo path.
2. Start or resume a review session:

   ```bash
   "$VIBEREVIEW_CLI" start --project /path/to/game --title "Playtest review"
   "$VIBEREVIEW_CLI" status --project /path/to/game
   ```

3. Open the game with browser-control tools and play enough to observe behavior directly. Prefer the in-app Browser for local dev servers and Chrome when the VibeReview extension or existing browser state matters.
4. Capture observations while the game is in the browser:

   ```bash
   "$VIBEREVIEW_CLI" capture \
     --project /path/to/game \
     --note "Jump timing feels late after landing." \
     --severity issue \
     --rating 3 \
     --tags controls,feel
   ```

5. Read the CLI output. Record the session id, capture id, screenshot path, and browser snapshot path if present.
6. End the session when done:

   ```bash
   "$VIBEREVIEW_CLI" end --project /path/to/game
   ```

7. Inspect `git status` in the target project. VibeReview may mutate `docs/` ledgers and add media under `docs/reviews/<session-id>/`.

### Spiral-HTML Integration

Spiral-HTML projects use git-tracked HTML ledgers as the project memory. Treat VibeReview output as playtest evidence for those ledgers, not as a separate side channel.

Relationship to the Spiral-HTML skill:

- `spiral-html` owns scaffold bootstrap and drift audit. Use it when the project needs `init` or `audit`; do not recreate the full scaffold by hand inside this command.
- `randroid:loop` owns implementation slices after review feedback becomes work.
- `task-tracking-dots-html` owns durable HTML task tracking when `Q-NNN` or `F-NNN` entries become active work items.
- VibeReview owns capture evidence: session metadata, screenshots, browser snapshots, and the first pass of playtest ledger updates.

Expected project files:

- `AGENTS.md` and `CLAUDE.md`: discovery contracts for Codex and Claude Code.
- `docs/PLAYTEST.html`: second qualitative gate. Review evidence belongs here.
- `docs/FOLLOWUPS.html`: failed review items become `F-NNN` entries.
- `docs/OPEN_QUESTIONS.html`: ambiguous review findings become `Q-NNN` entries with a recommended default.
- `docs/FUN_FACTOR_AUDIT.html`: experience-level gaps and P0/P1 polish work.
- `docs/GDD_COVERAGE.json`: implementation traceability. Do not mark rows done only because a review was captured.
- `docs/PROGRESS_LOG.html`: append-only slice receipts, not a raw capture log.

When using VibeReview in a Spiral-HTML repo:

- Read `AGENTS.md`, `docs/PLAYTEST.html`, `docs/FOLLOWUPS.html`, `docs/OPEN_QUESTIONS.html`, and `docs/FUN_FACTOR_AUDIT.html` before deciding how to classify the feedback.
- Let VibeReview perform its automatic writes first. Then inspect the diff before adding anything manually.
- Preserve append-only ledger discipline. Add new `data-*` entries; do not rewrite or delete past entries.
- Severe captures (`--severity blocksRelease`) should correspond to `docs/FOLLOWUPS.html` entries with `data-priority="blocks-release"` unless the CLI already created them.
- Polish captures should usually become `data-priority="polish"` followups or evidence in `PLAYTEST.html`.
- Unclear product decisions should become `docs/OPEN_QUESTIONS.html` entries with `data-q="Q-NNN"`, `data-status="open"`, options, and a `Recommended default`.
- Experience-level gaps discovered during review belong in `docs/FUN_FACTOR_AUDIT.html` and usually generate P0/P1 followups.
- Do not close the qualitative gate until `PLAYTEST.html` items are checked or explicitly deferred and `FUN_FACTOR_AUDIT.html` has no new P0/P1 gaps.

VibeReview's current artifact behavior:

- Full or partial Spiral-HTML projects: writes media under `docs/reviews/<session-id>/`, appends playtest evidence to `docs/PLAYTEST.html`, and creates followups for severe captures.
- Legacy Markdown docs: writes review artifacts under `docs/reviews/<session-id>/` or `Docs/reviews/<session-id>/` but does not mutate Markdown ledgers.
- No docs: creates minimal Spiral-HTML review ledgers and a session review folder.

## clean-slop

Detect and fix AI "slop" in vibe-coded UIs, and prevent it from coming back. In Claude Code, use `/randroid:clean-slop`.

Use this command when a design "smells like AI" (generic one-shot LLM look), when the user asks to "de-slop" or clean up a frontend, or as a final polish pass before shipping a vibe-coded UI.

It names the telltale slop signs — random glows, purple gradients, Inter, harsh white borders, lazy selected states, cramped all-caps eyebrows, pointless status pills, uneven spacing, inconsistent section shapes, two-line button text, Unsplash photos, illustrations-instead-of-photos, Lucide icons — and gives a concrete fix-prompt for each, plus a prevention workflow (design systems, references, palettes, fonts, icons, sections, animations, polish). Slop is removed iteratively: scan a screenshot, fix the exact element, re-screenshot, repeat.

Bundled resources:
- `commands/clean-slop.md`: Claude Code slash command instructions and quick-scan checklist
- `clean-slop-rules.md`: the full ruleset (named fix per sign + prevention workflow), loaded via `${CLAUDE_PLUGIN_ROOT}`
