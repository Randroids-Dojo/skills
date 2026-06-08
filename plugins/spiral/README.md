# spiral

Bootstrap and audit the structural-discipline scaffold that lets autonomous PR loops run for weeks without losing context, terminating prematurely, or accumulating debt.

## What this is

A skill for Claude Code and Codex agents. It writes (or audits) ten canonical files that turn a fresh repo into a substrate suitable for `randroid:loop` to drive.

## What it solves

Three sibling skills (`randroid:loop`, `task-tracking-dots`, and this one) form the autonomous-loop trio:

- `task-tracking-dots`: work items (the queue).
- `randroid:loop`: execution (the worker).
- `spiral`: substrate (the contract, vision, ledgers, and gates the worker consumes and updates).

Without `spiral`, `randroid:loop` runs against muscle memory: there is no copy-pasteable contract, no anti-Flatline guardrails (chapter-granular coverage, missing qualitative gate), and no audit pass for an existing repo.

## Quick start

In a fresh git repo:

```
/spiral init
```

Or from the shell:

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init.sh "MyProject" "one-line pitch" "Next.js + Three.js"
```

This writes `AGENTS.md` plus the `docs/` ledger set. Add your first GDD section under `docs/gdd/`, then start the loop with `/randroid:loop implement`.

In an existing repo:

```
/spiral audit
```

Prints a remediation checklist for any drift from the canonical structure.

## See also

- `docs/methodology.md`: the meta-pattern essay.
- `docs/case-studies.md`: VibeRacer, VibeGear2, Flatline distilled.
- `SKILL.md`: the agent-facing primary doc.
