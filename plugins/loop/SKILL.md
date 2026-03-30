---
name: loop
description: "Automate iterative development by researching solutions then writing code across multiple cycles. Use when you want hands-off coding, automated development loops, iterative research-then-implement workflows, or autonomous task completion with git commits and task tracking."
metadata:
  claude_triggers: "/loop, /randroid, /randroid-loop"
  claude_hooks: "Stop: hooks/stop-hook.sh"
---

# Loop

A self-sustaining development loop with two modes: **Researcher** (explore, plan, create specs) and **Implementor** (write code, tests, docs from specs). Each iteration creates git commits, tracks progress via Dots, and optionally opens PRs.

## Prerequisites

**Full permissions required.** The loop runs autonomously.

| Agent | Command |
|-------|---------|
| Claude Code | `claude --dangerously-skip-permissions` |
| Codex | Automatically uses `--yolo` mode |

## Startup Flow

Ask the user these questions via AskUserQuestion (Q1–Q4), then a text prompt (Q5):

| # | Question | Options |
|---|----------|---------|
| 1 | Mode | `Research` (explore/plan/spec) · `Implement` (code/test/docs) |
| 2 | Git workflow | `Push` (default) · `Commit only` · `Open PR` · `PR and merge` |
| 3 | Context | `Fresh context` (default, recommended) · `Keep context` |
| 4 | Directions | `None` · mode-specific presets · `Other` (free-text) |
| 5 | Iterations (text prompt) | Number → exact count · `inf` → infinite · `comp` → until complete |

**Key distinction:** In infinite/N-iteration modes the completion promise is ignored. Only "until complete" mode stops on the completion promise.

After collecting answers:

1. **Initialize**: Run `./scripts/setup-loop.sh <mode> --iterations <N> --git-workflow <workflow> [--fresh-context] [--directions "..."]`
2. **Verify**: Confirm setup-loop.sh exits 0. If it fails, report the error and stop.
3. **Build prompt**: Read `<mode>-loop.md` + `loop-shared.md`, concatenate them. Append user directions if provided.
4. **Execute** based on context mode (see below).

### Fresh Context Mode (default)

You are the orchestrator. For each iteration, spawn a Task subagent with the built prompt:

- **Until complete** (`iterations=0`): Stop when result contains `RANDROID_LOOP_COMPLETE`.
- **Exact N** (`iterations>0`): Stop after N iterations.
- **Infinite** (`iterations=-1`): Never stop on completion promise. Apply exponential backoff (starting 5s, doubling) when idle; reset on meaningful work.

**CRITICAL**: After each Task returns, YOU must check termination conditions and spawn the next iteration. Do not stop just because one Task finished.

### Keep Context Mode

Run the loop in the current conversation. The stop hook intercepts exit and continues looping with accumulated context.

## Usage

```bash
/loop                          # Interactive — prompts for all options
/loop research                 # Research mode, prompts for iterations
/loop implement --iterations 5 # Implement mode, 5 iterations
/loop implement --open-pr      # Open PR after each task
/loop implement --pr-and-merge # PR with auto-merge
/loop implement --keep-context # Maintain conversation history
```

Aliases: `/randroid`, `/randroid-loop`

### Codex (External Script)

```bash
./scripts/randroid-loop.sh                        # Interactive
./scripts/randroid-loop.sh research -1            # Infinite research
./scripts/randroid-loop.sh implement 5 pr         # 5 iterations, open PR
./scripts/randroid-loop.sh implement 0 pr-merge   # Until complete, PR + merge
```

## Modes

### Research Mode
Creates `research:` dots to track exploration and `implement:` dots as deliverables for the implementor. Does NOT write production code — outputs findings, decisions, and implementation specs.

### Implementor Mode
Pulls from ready `implement:` dots. Writes code, tests, and documentation. Creates new `implement:` or `research:` dots as scope expands or unknowns surface.

## Loop Mechanics

Each iteration starts with **fresh context** (default). Only the filesystem persists: modified files, git history, `.dots/` task state, and written artifacts. Conversation history and token budget reset.

## Loop Termination

Output `<promise>RANDROID_LOOP_COMPLETE</promise>` when no more ready tasks exist for your mode and all work is committed. The loop also stops when `--iterations N` limit is reached.

## Architecture

```
loop/
├── SKILL.md              # This file
├── research-loop.md      # Research mode prompt
├── implement-loop.md     # Implementor mode prompt
├── loop-shared.md        # Shared sections (git, dots, termination)
├── LOOPING_DESIGN.md     # Technical design doc
├── hooks/
│   └── stop-hook.sh      # Claude Code stop hook
├── scripts/
│   ├── setup-loop.sh     # Initialize loop state
│   └── randroid-loop.sh  # Codex external wrapper
└── state/
    └── .gitignore        # Excludes local state files
```
