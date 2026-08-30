---
name: spiral
description: Bootstrap or audit a Markdown structural-discipline scaffold for long-running product work, including GDD coverage, progress, questions, follow-ups, dependencies, and playtest gates. Use when starting a project that needs durable agent state or auditing an existing repository for scaffold drift.
---

# Spiral

The methodology for sustaining a multi-week autonomous PR loop without the agent losing context, running out of work prematurely, or accumulating debt.

The agent does not remember the project. The project remembers itself. Every kind of state lives in git-tracked ledger files with rigid templates. The agent's job collapses to: read ledgers, pick the next slice, run the loop, update ledgers. Every iteration returns to the same artifacts and finds them advanced. The shape is not a loop, it is a spiral: forward-while-circling.

## When to invoke

- **Initialize:** at the start of a fresh project, write the canonical scaffold into the current repository.
- **Audit:** on an existing project, diff the repository against the canonical structure and print a remediation checklist.

Per-slice execution is the job of `randroid-loop`. Per-task tracking is the job of `task-tracking-dots`. This skill is the substrate those two run against.

## Why this exists: the three case studies

Three multi-week autonomous-loop projects produced three outcomes. The pattern is in `docs/case-studies.md`. The short version:

- **VibeRacer (14 days, 184 commits)**: shipped a complete v1. Single-file 28-section GDD with explicit out-of-scope §18 fence. The loop terminated cleanly.
- **VibeGear2 (7 days, 298 commits)**: still actively shipping P0/P1 fun work a week in. Sectioned `docs/gdd/` tree, 102 atomic coverage rows, plus `FUN_FACTOR_GAP_AUDIT.md` and `RELEASE_FUN_PLAYTEST.md` as a second qualitative gate that re-opens the loop after systems land.
- **Flatline (3 days, 94 commits)**: self-terminated with 0 open dots, 0 open questions, 1 deferred doc cleanup. The product was not fun. Coverage rows were chapter-granular (11 rows, all `implemented` once *any* code shipped). No qualitative gate.

Flatline is the failure case this skill explicitly prevents. The audit script flags both the chapter-granular coverage anti-pattern and the missing qualitative gate.

## The scaffold

`/spiral init` writes these files into the target repo:

| Path | Role |
|------|------|
| `AGENTS.md` | Rules-as-contract: em-dash ban, pre-slice reading list, stack constraints, commit style, autonomous PR loop reference, secrets policy, testing expectations, pre-commit checklist. Read by Codex natively and by Claude Code via the CLAUDE.md import |
| `CLAUDE.md` | One-line `@AGENTS.md` import shim. Lets Claude Code pick up the same rules Codex reads, so the same repo works in both tools |
| `docs/IMPLEMENTATION_PLAN.md` | The 16-step loop contract. Slice selection priority. Definition of done |
| `docs/WORKING_AGREEMENT.md` | Process: branches, commits, PR template, bot-review settled-wait gate, verification minimums, merge-and-deploy expectations, risk gates |
| `docs/gdd/README.md` | GDD tree index. Each requirement is its own file. Build logs grow per-section as work ships |
| `docs/GDD_COVERAGE.json` | Atomic-row spec to code traceability. One row per requirement, not per chapter |
| `docs/PROGRESS_LOG.md` | Append-only slice receipts (Branch / Changed / Verification / Assumptions / GDD coverage / Followups). Newest on top |
| `docs/OPEN_QUESTIONS.md` | Q-NNN entries with options, recommended default, status, resolution. Defaults let the loop ship without blocking |
| `docs/FOLLOWUPS.md` | F-NNN entries with priority (blocks-release, nice-to-have, polish), blocker condition, unblock condition |
| `docs/DEPENDENCY_LEDGER.md` | Watched dependencies with currently-pinned version + per-dep upgrade procedure. The Dependency Upgrade Gate fires every loop iteration that touches `main` |
| `docs/PLAYTEST.md` | Qualitative second-gate checklist. The loop is not done until this resolves |
| `docs/FUN_FACTOR_AUDIT.md` | Qualitative gap-finder. Run when coverage is ≥80% done. Source of P0/P1 polish work |
| `.claude/rules/slice-discipline.md` | Path-scoped Rule. Loads when editing source. Enforces "no drive-by refactors, no speculative abstractions, refactor-in-slice" |
| `.claude/rules/ledger-append-only.md` | Path-scoped Rule. Loads when editing the four ledger files. Enforces append-only, never-rewrite-past-entries |
| `.claude/rules/gdd-build-log.md` | Path-scoped Rule. Loads when editing GDD section files. Enforces build-log-on-every-shipped-feature |

## Cross-tool compatibility

The scaffold is designed to work in both Claude Code and Codex without modification.

- `AGENTS.md` is the cross-tool standard ([agents.md](https://agents.md/)) and is read natively by Codex.
- `CLAUDE.md` imports `AGENTS.md` via `@AGENTS.md` so Claude Code reads the same rules.
- `.claude/rules/` is Claude Code's path-scoped Rules mechanism. Codex ignores these but they do not interfere with Codex operation.
- `SKILL.md` in this plugin follows the cross-tool [Agent Skills open standard](https://www.agensi.io/learn/agent-skills-open-standard) shape (frontmatter `name` plus `description`, plain markdown body), making the plugin invocable from Codex's `.agents/skills/` mechanism if symlinked or copied there.

## The seven parts of the spiral

1. **Vision**: the canonical spec (GDD tree, atomic requirements).
2. **Contract**: the three docs that govern every iteration (rules, plan, agreement).
3. **Slice**: the bounded unit of work (one PR, one log entry, small enough that a botched slice is reverted in one click).
4. **Ledgers**: externalized memory (progress log, open questions, followups, coverage). Append-only.
5. **Gates**: what blocks merge AND what triggers a slice. Mechanical (CI green, type-check, tests, no em-dash, bot-review settled). Qualitative (playtest, fun-factor audit). Dependency Upgrade Gate (see `docs/DEPENDENCY_LEDGER.md`): a watched-dep release is the same kind of fresh state as a new commit on `main`; the agent observes and acts at every loop boundary that touches `main`. The qualitative gate is the second gate that prevents Flatline-style early termination.
6. **Selection rule**: what to work on next: red CI > pending dep upgrade > P0/P1 dot > answered open question > high-priority followup > coverage gap > partial GDD section > cleanup.
7. **Loop**: the continuous operation. Read context, pick slice, branch, implement, test, update ledgers, PR, handle review, wait for bot + CI, merge, pull main, smoke prod, close item, start next. Never voluntarily idles. Executed by `randroid-loop`.

## How `init` works

Resolve `scripts/init.sh` relative to this skill directory and run it from inside the target repository with `"<ProjectName>" "<one-line-pitch>" "<stack>"`.

The script:

1. Refuses to run if `AGENTS.md` already exists at the repo root. Use `audit` instead.
2. Prompts for project name, one-line pitch, and stack if not passed as args.
3. Copies every template file into the target repo, substituting `{{PROJECT_NAME}}`, `{{PITCH}}`, `{{STACK}}`, `{{TODAY}}`.
4. Creates `docs/gdd/` for the GDD tree and `.claude/rules/` for the path-scoped Rules.
5. Writes `CLAUDE.md` as a `@AGENTS.md` import shim so Claude Code and Codex read the same rules.
6. Verifies em-dash cleanliness on every written file.
7. Prints a next-steps note: draft the first GDD section under `docs/gdd/`, then use `randroid-loop` in implementation mode to start the spiral.

## How `audit` works

Resolve `scripts/audit.sh` relative to this skill directory and run it from inside the repository to audit.

The script runs nine checks and prints a remediation checklist:

1. **Missing canonical files.** Verifies the full scaffold (AGENTS.md, CLAUDE.md, the docs ledger set including DEPENDENCY_LEDGER.md, the three .claude/rules files) is present. Lists any missing.
2. **Monolith GDD.** Warns if `docs/GDD.md` exists alone without a `docs/gdd/` directory. Suggests splitting into a tree.
3. **Chapter-granular coverage.** Counts rows in `docs/GDD_COVERAGE.json`. Warns if row count is implausibly low for project age (heuristic: fewer than 14 rows per project-week).
4. **Missing qualitative gate.** Warns if `docs/PLAYTEST.md` or `docs/FUN_FACTOR_AUDIT.md` is missing. This is the Flatline failure mode.
5. **Stale progress log.** Reads newest entry date. Warns if older than 7 days (loop possibly stalled).
6. **Open questions without defaults.** Warns on any `Q-` entry missing a `Recommended default:` line.
7. **Followups without priority.** Warns on any `F-` entry missing a `Priority:` tag.
8. **Em-dash drift.** Greps the canonical files for U+2014 / U+2013. Warns on hits.
9. **Dependency ledger present.** Warns if `docs/DEPENDENCY_LEDGER.md` is missing or empty (no watched deps recorded). The gate has nothing to fire against without it.

The output is a checklist, not a generated remediation file. One canonical place per kind of state.

## Composition

- `randroid-loop` reads the ledgers this skill writes. The loop's research and implement modes both name `OPEN_QUESTIONS.md` and `FOLLOWUPS.md` as required reads.
- `task-tracking-dots` is the work-item tracker. `Q-NNN` entries that resolve into work become Dots. `F-NNN` entries with `Priority: blocks-release` become Dots.
- `vibekit` (optional) supplies bootstrap and per-module cookbook for the in-house `@randroids-dojo/vibekit` shared library. Spiral defers to it for VibeKit-specific knowledge the same way it defers to `randroid-loop` for slice execution. A project that prefers a different shared library swaps this skill out without touching spiral.
- This skill is stateless. All state lives in the target repo's ledger files.

## Architecture

```
spiral/
├── SKILL.md                    # This file
├── README.md                   # Human-facing one-pager
├── .claude-plugin/
│   └── plugin.json             # Plugin metadata
├── commands/
│   ├── spiral-init.md          # /spiral init slash command
│   └── spiral-audit.md         # /spiral audit slash command
├── templates/
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   ├── IMPLEMENTATION_PLAN.md
│   ├── WORKING_AGREEMENT.md
│   ├── docs-gdd-README.md
│   ├── GDD_COVERAGE.json
│   ├── PROGRESS_LOG.md
│   ├── OPEN_QUESTIONS.md
│   ├── FOLLOWUPS.md
│   ├── DEPENDENCY_LEDGER.md
│   ├── PLAYTEST.md
│   ├── FUN_FACTOR_AUDIT.md
│   ├── dot-claude-rules-slice-discipline.md
│   ├── dot-claude-rules-ledger-append-only.md
│   └── dot-claude-rules-gdd-build-log.md
├── scripts/
│   ├── init.sh                 # Bootstrap into a target repo
│   └── audit.sh                # Diff target repo against canon
└── docs/
    ├── methodology.md          # The meta-pattern essay
    └── case-studies.md         # VibeRacer / VibeGear2 / Flatline
```
