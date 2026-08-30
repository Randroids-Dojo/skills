# Loop architecture

The loop has one portable workflow and two optional client adapters. Repository files and Dots tasks are the durable source of truth; conversational memory is not.

## Portable workflow

`SKILL.md` collects or infers five choices before execution:

1. research or implementation mode;
2. exact count, until-complete, or explicitly requested continuous stopping condition;
3. no commit, local commit, push, PR, or PR-and-merge workflow;
4. fresh or retained conversational context;
5. run-specific priorities.

Mode-specific references define what one iteration may do. `loop-shared.md` defines task-state, working-tree, git, receipt, and completion behavior. The portable workflow stops at any missing authorization boundary.

## Claude Code adapter

The Randroid Claude plugin registers `hooks/stop-hook.sh`. For retained-context operation, `scripts/setup-loop.sh` writes state under `skills/randroid-loop/state/loop.local.md`; the Stop hook reads that state and rejects exit while iterations remain.

The hook does not create fresh conversational context. Fresh context requires launching independent client runs through a wrapper or scheduler. The Claude adapter uses `${CLAUDE_PLUGIN_ROOT}` only inside plugin-owned hook configuration, never in the portable `SKILL.md`.

## Codex adapter

`scripts/randroid-loop.sh` launches a separate `codex exec` process for each iteration, so each run starts with fresh model context while sharing the repository and task files. It builds the prompt from one mode reference plus the shared contract and records a local iteration log.

The wrapper intentionally omits `--yolo` and similar permission overrides. It inherits the user's configured Codex permissions. Its default stopping condition is until complete, and its default git workflow is local commit.

## State model

The helper state file records only scheduling and previously authorized choices:

```yaml
---
mode: implement
iteration: 0
iterations: 5
git_workflow: commit
task_tracker: dot
fresh_context: true
completion_promise: RANDROID_LOOP_COMPLETE
---
```

`iterations` values are:

- positive integer: exact count;
- `0`: until the verified completion contract is met;
- `-1`: continuous operation, allowed only after an explicit user request.

The state file is local and gitignored. It does not replace repository instructions, Dots tasks, progress ledgers, or external verification.

## Failure behavior

- A failed iteration is logged and does not become a successful receipt.
- A missing task CLI, overlapping working-tree change, permission request, or authorization boundary stops the loop for user input.
- Continuous mode may back off after an iteration with no ready work, but backoff does not prove completion.
- Temporary output files are scoped to the wrapper process and removed on exit; the log path is reported for diagnosis.

## Verification targets

When modifying the loop itself, verify:

- shell syntax for setup, wrapper, and hook scripts;
- state paths for both the nested skill and Claude plugin hook;
- safe defaults for stopping and git workflow;
- correct prompt paths relative to the nested skill;
- completion handling in exact-count and until-complete modes;
- no client permission override or implicit external mutation.

Do not claim fresh-context parity without executing at least two real client iterations and inspecting their state and logs.
