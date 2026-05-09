# /spiral init

Bootstrap the structural-discipline scaffold into the current repo.

## When to use

At the start of a fresh project, before any feature code. Writes the canonical files (`AGENTS.md` plus the `docs/` ledger set, including `docs/DEPENDENCY_LEDGER.md` and the qualitative-gate docs) so an autonomous PR loop can run against the repo.

Refuses to run if `AGENTS.md` already exists. Use `/spiral audit` on existing repos instead.

## How to invoke

Ask the user three questions via AskUserQuestion before running:

1. **Project name.** Used in headers and substituted as `{{PROJECT_NAME}}`.
2. **One-line pitch.** Substituted as `{{PITCH}}`. Used in `AGENTS.md` and the GDD index.
3. **Stack.** Substituted as `{{STACK}}`. Used in `AGENTS.md` Rule 3. Free text. Examples: "Next.js + Three.js + Vercel KV", "Godot 4.x + GDScript", "Rust + axum + Postgres".

Then run:

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init.sh "<name>" "<pitch>" "<stack>"
```

After the script completes:

1. Print the list of written files.
2. Tell the user the next step is to draft the first GDD section under `docs/gdd/<n>-<title>.md`.
3. Suggest `/randroid-loop implement` once the first GDD section exists.

## Output

The script prints every written file path, plus a one-line note for the user about next steps.
