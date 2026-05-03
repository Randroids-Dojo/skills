# Case studies: VibeRacer, VibeGear2, Flatline

Three multi-week autonomous-loop projects. Three outcomes. The pattern is what `spiral` codifies.

## Comparison

|                       | Flatline                 | VibeRacer        | VibeGear2                                                          |
|-----------------------|--------------------------|------------------|--------------------------------------------------------------------|
| Duration              | 3 days                   | 14 days          | 7 days                                                             |
| Commits               | 94                       | 184              | 298                                                                |
| GDD shape             | One 29K monolith         | Single file      | Sectioned tree under `docs/gdd/`                                   |
| `GDD_COVERAGE` rows   | 11 (chapter-granular)    | 12 sections      | 102 atomic requirements                                            |
| Qualitative gate      | None                     | None visible     | `FUN_FACTOR_GAP_AUDIT.md` + `RELEASE_FUN_PLAYTEST.md` checklist    |
| Outcome               | Self-terminated early    | Shipped clean v1 | Still actively shipping P0 / P1 fun work                           |

## VibeRacer (the success)

14 days, 184 commits, single-file 28-section GDD with explicit out-of-scope §18 fence, build logs that grow per section as work ships. Operates a continuous PR loop with bot-review settled-wait gate, em-dash ban as a canary, simple-consistent-flow rule preventing branchy UX decisions, refactor-in-slice rule preventing cleanup piles.

Closed cleanly because:

- The GDD §18 fence prevented scope creep.
- Atomic-feature slices (one PR each) made the verification cost-per-slice low.
- Build logs in each GDD section paid the doc-update tax up front so the next slice could start cheap.
- The `PROGRESS_LOG` / `OPEN_QUESTIONS` / `FOLLOWUPS` ledgers kept the agent unstuck without dev sign-off.

What VibeRacer did NOT have: an explicit qualitative gate. It still terminated cleanly because v1 was scoped tightly and `§18: Out of scope` listed everything that would have triggered scope creep. The single-file monolithic GDD was the size of v1, not the limit of the methodology.

The lesson: a tightly-scoped product with a strong out-of-scope fence can survive without a qualitative gate. A more ambitious product cannot.

## VibeGear2 (the active success)

7 days, 298 commits, sectioned `docs/gdd/` tree, 102 atomic coverage rows, plus `FUN_FACTOR_GAP_AUDIT.md` (May 1) and `RELEASE_FUN_PLAYTEST.md` (May 2). The audit and playtest doc were added explicitly *after* the systems-level coverage was mostly done, in response to the realization that the loop was about to terminate prematurely if it kept using only the coverage ledger as its definition of done.

Still actively chasing P0 / P1 fun gaps a week in, despite having 3× the commits of VibeRacer at the same calendar moment. That is not a failure mode; it is the loop staying alive on the right work.

The two key VibeGear2 additions:

1. **`docs/gdd/` tree, not a monolith.** Coverage rows can be authored at requirement granularity (102 rows for a 7-day project, ~14 rows per project-day) instead of chapter granularity (Flatline's 11 rows for a 3-day project, ~4 rows per project-day).
2. **Qualitative gate.** `FUN_FACTOR_GAP_AUDIT.md` is the *backlog generator* and `RELEASE_FUN_PLAYTEST.md` is the *check* that the gate is closed. Together they keep the loop alive past the moment when systems exist.

## Flatline (the failure case)

3 days, 94 commits, single-file GDD, 11 chapter-granular coverage rows, no qualitative gate. By 2026-05-02 the project had 0 open dots, 0 open questions, and 1 deferred low-priority doc cleanup. A complete-on-paper game. Not a fun game.

Root cause: the ledger tracked *systems* at chapter granularity ("billboard enemies exist," "hazards exist"), so the moment each system had any implementation plus a smoke test, the row flipped to `implemented` and the loop self-terminated. There were no rows for "the first 90 seconds sells the loop," "AI archetypes feel different," or "the game is fun." There was no playtest doc that would surface those gaps.

VibeGear2 hit the same wall a week earlier and explicitly responded by writing the audit and playtest docs. Flatline did not, and the loop ran out of work before the product was good.

## The fix encoded in `spiral`

`spiral init` ships `PLAYTEST.md` and `FUN_FACTOR_AUDIT.md` by default. The Implementation Plan template's `Project Closure` rule names all three closure conditions: every coverage row is `done`, every playtest checklist item is checked or deferred, and the latest fun-factor audit produced no new P0 / P1 gaps.

`spiral audit` flags the Flatline anti-patterns directly: monolith GDD, chapter-granular coverage (heuristic: fewer than 14 rows per project-week), missing playtest, missing fun-factor audit. Running it on Flatline produces explicit warnings for both the chapter-granular coverage and the missing qualitative gate. Running it on VibeRacer produces zero structural warnings but flags the missing qualitative-gate docs as "you got away with it because §18 fenced scope, but a more ambitious project would have stalled."

## What this implies for new projects

Use `spiral init` at the start. Author the GDD as a tree from day one. Author coverage rows at requirement granularity from day one. Keep the qualitative gate docs in place even on small projects, because the cost is low and the protection is high.

If you inherit an existing project, run `spiral audit`. If it flags chapter-granular coverage or a missing qualitative gate, treat that as a P0 followup. Those are the failures that look like success right up to the moment the loop terminates with a not-fun product.
