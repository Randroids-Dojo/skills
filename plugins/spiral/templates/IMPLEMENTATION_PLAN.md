# Implementation Plan

This document is the main operating loop for {{PROJECT_NAME}} implementation. Agents must keep working continuously until the planned scope is complete.

## Loop Contract

Every slice follows the same loop:

1. Read `AGENTS.md`, `README.md`, this plan, `docs/WORKING_AGREEMENT.md`, the relevant `docs/gdd/` files, `docs/PROGRESS_LOG.md`, `docs/OPEN_QUESTIONS.md`, `docs/FOLLOWUPS.md`, `docs/GDD_COVERAGE.json`, and the active backlog.
2. Pick the highest-priority unblocked task from this plan, coverage gaps, followups, the qualitative-gate docs, and the active backlog.
3. Create one branch for one PR-sized slice.
4. Build the slice completely using existing code patterns.
5. Add or update tests for the touched behavior.
6. Update continuity docs and the GDD coverage ledger.
7. Run local verification.
8. Open a PR.
9. Inspect review comments and threaded inline comments.
10. Fix actionable feedback, reply when useful, resolve threads.
11. After every push to the PR branch, wait for any configured bot reviewer to finish its review pass, then re-inspect reviews and threaded comments. The wait is settled only when all required checks are green AND at least 60 seconds have passed since the latest PR branch push or latest bot review activity, whichever is later. If no fresh bot review appears after that, record that no new bot feedback was posted after the push.
12. Wait for CI and preview deploy to pass.
13. Merge only when green and bot review has settled after the latest push.
14. Pull `main`, verify main CI and production deploy, smoke test production.
15. Close the backlog item with the PR number and verification evidence.
16. Immediately start the next slice.

Do not stop after planning, after opening a PR, or after merging. If a task is blocked, log the blocker in `docs/OPEN_QUESTIONS.md` or `docs/FOLLOWUPS.md`, update the backlog item, and move to the next unblocked slice.

## Slice Selection

Priority order:

1. Broken `main`, red CI, broken deploy, or failing required checks.
2. Active P0 or P1 backlog items.
3. Open `docs/OPEN_QUESTIONS.md` entries that block implementation and have enough information to resolve.
4. High-priority `docs/FOLLOWUPS.md` items.
5. `docs/GDD_COVERAGE.json` gaps marked `not_started` or `partial`.
6. GDD requirements with user-visible scope still marked partial.
7. **Once coverage is ≥80% done:** open items in `docs/PLAYTEST.md` and gaps in `docs/FUN_FACTOR_AUDIT.md`. These are the second gate. The loop is not finished until these resolve.
8. Cleanup that removes blockers, stale docs, or brittle test gaps.

Prefer the smallest slice that creates a useful PR. Avoid mixing unrelated work.

## Definition Of Done

A slice is done only when all apply:

- Code, docs, tests, and coverage ledger match the implemented behavior.
- Required local verification passes.
- PR is open and all actionable review comments are handled.
- Bot review has finished after the latest push, or no fresh bot feedback appeared after the settled wait.
- CI and preview deploy are green.
- PR is merged.
- Local `main` is updated from remote.
- Main CI and production deploy are green.
- Production smoke test passes or a blocker is logged.
- The backlog item or followup is closed with the PR number and verification.

## Project Closure

The loop ends when ALL apply:

1. Every row in `docs/GDD_COVERAGE.json` is `done` with implementation and test refs.
2. Every checklist item in `docs/PLAYTEST.md` is checked or explicitly deferred to a follow-up release.
3. `docs/FUN_FACTOR_AUDIT.md` has been re-run after the last system landed and produced no new P0 or P1 gaps.

Closing the loop without all three is the Flatline failure mode: shipping a complete-on-paper system that is not actually good.

## Current Planned Scope

Use `docs/gdd/` as the product scope. The current high-level remaining areas are reflected in `docs/GDD_COVERAGE.json`, with active spillover in `docs/FOLLOWUPS.md`.
