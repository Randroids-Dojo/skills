# Methodology: how the spiral works

The agent does not remember the project. The project remembers itself. Every kind of state lives in git-tracked files with rigid templates. The agent's job collapses to: read ledgers, pick the next slice, run the loop, update ledgers.

This is the why behind every file the `spiral` skill writes.

## The shape

A loop returns to the same point. A spiral returns to the same artifacts but advanced. Every iteration grows the build logs, evidence rows, progress receipts, and resolved questions, so every revisit finds the substrate richer than the last. Drawn as a diagram, it is not a circle. It is a spiral: forward-while-circling.

Most agents fail at multi-week projects because they hold context in their head. This methodology externalizes every kind of state into git-tracked files with rigid templates. That removes the rediscovery tax that kills long-running loops.

## The seven parts

There are seven, and they map to the canonical scaffold files (eleven full templates plus three rules and two Codex symlinks):

### 1. Vision

`docs/gdd/` is the canonical spec. Each requirement is its own file. Each file carries a `Status:` line and gains a `### Build log` subsection as work ships. Build logs grow with the code so the next slice can read what landed without rediscovering it.

**Anti-pattern: monolith GDD.** A single `docs/GDD.md` file pushes coverage rows toward chapter granularity, which is the Flatline failure mode (rows that flip to `done` once any code lands).

### 2. Contract

Three always-on docs that compound, plus three path-scoped Rules:

- `AGENTS.md` codifies rules: em-dash ban, the pre-slice reading list (the file canon), stack constraints, commit-message style, the autonomous PR loop reference, secrets policy, testing expectations, motion / overlay QA, the pre-commit checklist. Read by Codex natively.
- `CLAUDE.md` is a one-line `@AGENTS.md` import shim. Lets Claude Code read the same contract Codex reads, so a single repo works in both tools.
- `docs/IMPLEMENTATION_PLAN.md` codifies the 16-step loop: read context, branch, implement, test, update ledgers, PR, handle review, wait for bot + CI, merge, pull main, smoke prod, close item, start next.
- `docs/WORKING_AGREEMENT.md` codifies process: branch naming, commit hygiene, PR contents, the bot-review settled-wait gate (60s + green CI), verification minimums (different for docs vs code), merge-and-deploy expectations, risk gates.

Plus three Claude Code Rules in `.claude/rules/` that load only when matching files are edited:

- `slice-discipline.md` loads when editing source code (`src/**`, `app/**`, `lib/**`, `components/**`, `pages/**`, `scripts/**`, `tests/**`). Enforces no drive-by refactors, no speculative abstractions, refactor-in-slice.
- `ledger-append-only.md` loads when editing the four ledger files. Enforces append-only and never-rewrite-past-entries.
- `gdd-build-log.md` loads when editing GDD section files. Enforces a build-log entry on every shipped feature.

The split between always-on docs (AGENTS.md, the plan, the agreement) and path-scoped Rules is deliberate. Always-on guidance is universal: every slice needs to know about the em-dash ban and the autonomous loop. Path-scoped guidance is specific: only slices that touch ledgers need the append-only rule, only slices that touch the GDD need the build-log rule. Loading them on demand saves context for the work the slice is actually doing.

Together they leave no slice-time decision to ad-hoc judgment. The agent does not negotiate the rules, it follows them.

### 3. Slice

The unit of work. One PR. One commit-message-sized change. One log entry. Bounded so the agent can finish before context drift, and small enough that a botched slice is reverted in one click.

The slice contract is also what enables compounding. Each slice shipping a feature also updates the build log + coverage row + progress entry. The next slice reads those updates and starts cheaper.

### 4. Ledgers

Externalized memory. Four append-only files:

- `docs/PROGRESS_LOG.md`: receipts, newest-on-top, never deleted. Each entry: Branch / Changed / Verification / Assumptions / GDD coverage / Followups.
- `docs/OPEN_QUESTIONS.md`: `Q-NNN` entries with Options, **Recommended default** (mandatory), Status, Resolution. The default lets the loop ship without blocking on dev sign-off.
- `docs/FOLLOWUPS.md`: `F-NNN` entries with **Priority** (`blocks-release` | `nice-to-have` | `polish`), Blocker condition, Unblock condition.
- `docs/GDD_COVERAGE.json`: atomic-row spec to code traceability. One row per requirement. Each row carries `gddRef`, `status`, `implementationRefs`, `testRefs`, `followupRefs`.

Append-only is the load-bearing convention. A future slice cannot trust ledgers that get retroactively edited.

### 5. Gates

What blocks merge. Two kinds:

**Mechanical:** CI green, type-check, tests, no em-dash, bot-review settled-wait. These are checked by tools.

**Qualitative:** `docs/PLAYTEST.md` (release checklist) and `docs/FUN_FACTOR_AUDIT.md` (gap audit). These are the second gate that re-opens the loop after systems land. Coverage rows say a *system* exists. The qualitative gate asks whether the system *delivers experience*.

Without the qualitative gate, the loop terminates the moment every coverage row is `done`, even if the product is not actually good. This is the Flatline failure mode and the reason `PLAYTEST.md` and `FUN_FACTOR_AUDIT.md` ship by default.

### 6. Selection rule

What to work on next. Priority order:

1. Broken `main`, red CI, broken deploy.
2. P0 / P1 backlog items.
3. Open questions with enough info to resolve under their recommended default.
4. High-priority followups.
5. Coverage gaps marked `not_started` or `partial`.
6. GDD requirements with user-visible scope still partial.
7. **Qualitative gate items** once coverage is ≥80% done.
8. Cleanup that removes blockers.

Plus the constraint: prefer the smallest slice that creates a useful PR. Avoid mixing unrelated work.

### 7. Loop

The continuous operation. Read context, pick slice, branch, implement, test, update ledgers, PR, handle review, wait for bot + CI, merge, pull main, smoke prod, close item, start next.

Never voluntarily idles. Executed by `randroid-loop`.

## The compounding effect

Each slice that ships also pays the doc-update tax that makes the next slice cheaper. When the next slice starts, it reads the build logs, coverage refs, progress receipts, and resolved questions: all of which are richer than they were one slice ago. That is what makes hundreds of slices in a few weeks tractable.

The fastest part of the loop is the part that has been done many times. Each pass through the spiral makes the next pass faster.

## Why convention beats configuration

`AGENTS.md` Rule 3 nails down the stack: framework, 3D, physics, audio, storage, validation, tests. There is no per-slice "should we add a library?" debate, which is the single biggest time sink in most projects.

The em-dash ban is the canary for the same principle: a rule trivial in isolation is useful as a tripwire. An agent that ships an em-dash (U+2014) is an agent that did not run its own pre-commit checklist. The rule doubles as a discipline test.

## The closure rule

The loop ends when all three conditions hold:

1. Every coverage row is `done` with implementation and test refs.
2. Every `PLAYTEST.md` checklist item is checked or explicitly deferred.
3. `FUN_FACTOR_AUDIT.md` has been re-run after the last system landed and produced no new P0 / P1 gaps.

Closing the loop without all three is the Flatline failure mode: a complete-on-paper system that is not actually good. The `spiral audit` script catches a missing qualitative gate so this failure mode is impossible by construction.

## Why one agent can sustain this

Externalize every kind of state. Externalize every kind of decision. Bound the unit of work. Make doc updates a checked merge gate. Define closure mechanically. Then the agent's job is not "build the project," it is "do the next slice and update the ledgers." That collapse is what makes weeks-long autonomous loops work.

Small agent, big paper trail. The agent rotates the spiral; the spiral advances.
