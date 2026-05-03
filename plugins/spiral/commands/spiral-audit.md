# /spiral audit

Diff the current repo against the canonical spiral scaffold and print a remediation checklist.

## When to use

On any existing repo to check whether it is a fit substrate for an autonomous PR loop. Runs eight checks and reports drift. Does not modify anything.

Run this:

- After `randroid-loop` completes a long run, to surface stale ledgers.
- Before assuming a project is "done." Catches the Flatline failure mode (chapter-granular coverage + missing qualitative gate = early termination).
- When inheriting a project that was set up without `spiral init`, to see how much retrofit is needed.

## How to invoke

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/audit.sh [path-to-repo]
```

Default path is the current directory.

## What it checks

1. Missing canonical files.
2. Monolith `docs/GDD.md` instead of a `docs/gdd/` tree.
3. Chapter-granular coverage rows (heuristic: fewer than 14 rows per project-week).
4. Missing qualitative gate (`docs/PLAYTEST.md` or `docs/FUN_FACTOR_AUDIT.md`).
5. Stale progress log (newest entry older than 7 days).
6. Open questions without `Recommended default:` lines.
7. Followups without `Priority:` tags.
8. Em-dash drift in the canonical files.

## Output

A checklist with one line per finding, ordered from most-blocking to least-blocking. No remediation file is written. Fix in place, re-run.
