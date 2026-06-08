# Shared Loop Sections

This file contains sections shared between research-loop.md and implement-loop.md.
The orchestrator concatenates mode-specific content with this shared content.

---

## Autonomous Operation

You are running **autonomously** without user interaction.

**CRITICAL - READ THIS CAREFULLY:**
- **NEVER ask questions** - No "How would you like me to proceed?", no "Should I...?", no confirmation requests
- **NEVER output questions** - The user cannot respond. Questions waste the iteration.
- **Ignore pre-existing changes** - If `git status` shows modified files you didn't touch, IGNORE them completely. Only stage YOUR files.
- **Make decisions autonomously** - Pick the reasonable option and proceed
- **If blocked, note it and continue** - Log what happened, move to next task
- **If stuck, output completion promise** - Don't hang waiting for input that will never come

## Loop Context

You may be running in a continuous loop with fresh context each iteration. Only the filesystem persists between iterations:
- Modified files and git history
- `.dots/` task state (`dot` Markdown files or `dot-html` HTML files)
- Your artifacts (research docs, implementation code, etc.)
- Loop state in `state/loop.local.md` (relative to the skill root; use `$CLAUDE_PLUGIN_ROOT/state/loop.local.md` in Claude Code)

## Task Tracker Selection

Projects use exactly one task tracker:
- `dot-html`: HTML-backed dots stored as `.html` under `.dots/`
- `dot`: Markdown-backed dots stored as `.md` under `.dots/`

At the start of every iteration, select the command and use it for all task operations:
```bash
if command -v dot-html >/dev/null 2>&1 && find .dots -name '*.html' -print -quit 2>/dev/null | grep -q .; then
  DOT=dot-html
elif command -v dot >/dev/null 2>&1 && find .dots -name '*.md' -print -quit 2>/dev/null | grep -q .; then
  DOT=dot
elif command -v dot-html >/dev/null 2>&1; then
  DOT=dot-html
elif command -v dot >/dev/null 2>&1; then
  DOT=dot
else
  echo "No dot or dot-html CLI found"
fi
```

Do not mix trackers in a project. If `.dots/` already contains `.html`, use `dot-html`; if it already contains `.md`, use `dot`. Prefer the CLI for task changes instead of hand-editing `.dots/` files.

Start by checking task state:
```bash
$DOT ready
$DOT tree
```

Check loop state for git workflow configuration:
```bash
cat state/loop.local.md  # Check git_workflow and mode settings (from skill root)
```

## Git Workflow

Check the `git_workflow` setting in `state/loop.local.md`.

**IMPORTANT:** Only stage files YOU modified this iteration. Ignore unrelated changes.
```bash
# Stage only your changes (list specific files or use patterns)
git add .dots/<files-you-modified>
git add <other-files-you-created-or-modified>
# Do NOT use "git add -A" as it may include unrelated changes
```

Use branch prefix and commit message style appropriate for your mode:
- **Research mode**: Branch `research/...`, commits `research: ...`
- **Implement mode**: Branch `feature/...`, commits `feat/fix/refactor: ...`

**commit**: Local commit only (no push):
```bash
git commit -m "<prefix>: <summary of work>"
```

**push**: Commit and push to current branch (default):
```bash
git commit -m "<prefix>: <summary of work>"
git pull --rebase && git push
```

**pr**: Open a PR and wait for CI:
```bash
# Create branch BEFORE committing (if on main)
BRANCH_NAME="<prefix>/$(date +%Y%m%d-%H%M%S)"
git checkout -b "$BRANCH_NAME"

# Commit your changes only
git commit -m "<prefix>: <summary of work>"
git push -u origin HEAD

# Open PR
gh pr create --fill || echo "PR already exists"

# Wait for CI to pass
gh pr checks --watch || echo "No CI checks configured"
```

**pr-merge**: Open PR, wait for CI, then merge:
```bash
# Create branch BEFORE committing (if on main)
BRANCH_NAME="<prefix>/$(date +%Y%m%d-%H%M%S)"
git checkout -b "$BRANCH_NAME"

# Commit your changes only
git commit -m "<prefix>: <summary of work>"
git push -u origin HEAD

# Open PR
gh pr create --fill || echo "PR already exists"

# Wait for CI and merge, then return to main
gh pr checks --watch || echo "No CI checks configured"
gh pr merge --squash --delete-branch || gh pr merge --squash
git checkout main && git pull --rebase
```

If no state file exists, default to `push`.

## Iteration Summary

Before finishing, output a brief summary of what you accomplished this iteration:
```
<iteration-summary>Brief description of work done</iteration-summary>
```

Keep it to one line (under 100 chars). This is parsed by the loop script for progress tracking.

## Iterate

Return to step 1 of your mode's loop cycle.

## Completion

Output this ONLY when there is genuinely no more value to add this iteration:
```
<promise>RANDROID_LOOP_COMPLETE</promise>
```

**Note:** If running in infinite or exact-iteration mode, this promise is ignored and the loop continues. Use it to signal "this iteration found nothing new" but expect to run again.

## User Directions

If a `## User Directions` section appears at the end of this prompt, treat those instructions as your **primary focus** for this iteration.

Directions are **guidance**, not rigid commands. Use judgment to interpret them in the context of the project. They may include:
- Topics to focus on or priorities
- Specific tasks to create or work on
- Approaches to follow or avoid
- Scope changes (add/remove/modify tasks)
