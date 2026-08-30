---
name: randroid-loop
description: Run a bounded research or implementation loop with persistent Dots task tracking and an explicitly selected git workflow. Use when the user asks for an autonomous multi-iteration development loop, research loop, implementation loop, or work-until-complete cycle. Do not use for an ordinary one-pass coding task.
---

# Randroid Loop

Run a sequence of independently verifiable work iterations whose durable state lives in the target repository.

## Before starting

1. Read the target repository's agent instructions and current task tracker.
2. Ask for any missing choices that cannot be inferred from the user's request:
   - mode: `research` or `implement`;
   - stopping condition: an exact iteration count, until complete, or explicitly requested continuous operation;
   - git workflow: no commit, commit only, push, open PR, or PR and merge;
   - whether each iteration should use fresh context;
   - which Dots tracker to initialize when the repository has no existing Dots state;
   - any run-specific priorities.
3. Treat push, PR creation, merge, deployment, publication, and other external mutations as separate authorization boundaries. Never select them merely because the repository appears ready.
4. Require a finite iteration count or `until complete` unless the user explicitly requests a continuous loop.

## Select the task tracker

- Use `dot-html` when `.dots/` contains HTML tasks and the command is available.
- Otherwise use `dot` when `.dots/` contains Markdown tasks and the command is available.
- Do not mix trackers in one project.
- If no Dots state exists and both CLIs are available, ask which format to initialize. If neither tracker is available, stop and report the missing prerequisite instead of inventing replacement state.

## Run the loop

1. Read [references/research-loop.md](references/research-loop.md) only in research mode, or [references/implement-loop.md](references/implement-loop.md) only in implementation mode.
2. Read [references/loop-shared.md](references/loop-shared.md) for the shared task, verification, git, and completion contract.
3. In each iteration:
   - re-read current repository and task state;
   - select one ready, bounded item;
   - perform only the selected mode's work;
   - run proportionate verification;
   - update the task and repository ledgers;
   - perform only the authorized git workflow;
   - emit a concise iteration receipt.
4. Stop when the requested count is reached, the shared completion contract is satisfied, user input is required, or an authorization boundary is reached.
5. Do not report completion while required verification, remote state, or an authorized delivery step remains unresolved.

## Bundled helpers

Resolve these paths relative to the directory containing this `SKILL.md`:

- `scripts/setup-loop.sh` writes local loop state. Run it only after the choices above are settled.
- `scripts/randroid-loop.sh` is an optional fresh-context Codex CLI wrapper. Review its selected mode, stopping condition, and git workflow before launching it.
- [references/looping-design.md](references/looping-design.md) explains the architecture; read it only when modifying or diagnosing the loop itself.
