# Shared loop contract

Apply this contract after the selected mode-specific procedure.

## Durable context

Assume only repository state persists reliably between fresh-context iterations:

- tracked and intentionally created working-tree files;
- `.dots/` task state managed by one Dots CLI;
- git history created by the authorized workflow;
- `state/loop.local.md` relative to this skill directory when a bundled helper initialized it.

Re-read repository instructions, task state, and relevant ledgers at the start of every iteration. Never infer that a prior iteration finished a step without checking its durable evidence.

## Task tracker

Use exactly one tracker:

- `dot-html` when the project already contains `.dots/**/*.html`;
- `dot` when the project already contains `.dots/**/*.md`;
- the tracker explicitly selected before the loop when the project has no existing Dots state.

In the mode-specific examples, `<dot-cli>` means the selected literal command: either `dot` or `dot-html`. Replace the placeholder before running a command; do not depend on a shell variable carrying across tool calls.

Use the chosen CLI for every task change. Begin with its `ready` and `tree` views. Select one ready, bounded item; mark it active before work; close it only after its completion evidence exists. If the CLI is unavailable or the stored formats conflict, stop and report the blocker.

## Working-tree safety

Preserve pre-existing and unrelated changes. Inspect `git status` before editing and before any commit. Stage only explicit files changed for the selected task; never use a broad staging command that could capture user work.

If overlapping user changes prevent a safe edit, stop and request direction. A fresh-context wrapper does not grant permission to discard, overwrite, or absorb unrelated work.

## Git workflow

Read `git_workflow` from initialized state. If state is absent or malformed, use `commit` only when the user authorized commits; otherwise use `none` and leave verified changes uncommitted.

Supported values:

- `none`: make and verify the scoped changes without committing;
- `commit`: create a local commit containing only the iteration's files;
- `push`: commit and push only to the already authorized branch and remote;
- `pr`: push an authorized branch, open or update its PR, and report CI state;
- `pr-merge`: perform the `pr` workflow and merge only when merge authorization, required review, and CI are satisfied.

Push, PR creation, merge, deployment, publication, and reviewer replies are external mutations. Do not upgrade from a safer workflow or guess a destination. A command failure remains a failure; do not convert it into success with an unconditional fallback.

Use repository-specific branch and commit conventions. Verify the exact staged diff before committing and verify the relevant remote or CI state after an authorized external action.

## Iteration receipt

Finish each iteration with one concise machine-readable summary:

```text
<iteration-summary>Scoped work and verification result</iteration-summary>
```

If blocked, name the blocker and durable next step in the summary. Stop the loop when user input or new authority is required.

## Completion

Emit the completion promise only when:

- no ready item remains for the selected mode;
- required tests, artifact checks, ledgers, and task updates are complete;
- the explicitly authorized git or delivery workflow is complete;
- no known blocker or unresolved required action remains.

```text
<promise>RANDROID_LOOP_COMPLETE</promise>
```

In exact-count or explicitly continuous mode, the wrapper may ignore the promise for scheduling, but the promise must still reflect real completion rather than lack of progress in one iteration.
