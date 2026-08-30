---
description: Add a tag-pinned VibeKit dependency to the current project.
argument-hint: "[release tag] [--no-install]"
disable-model-invocation: true
---

# /vibekit add

Add `@randroids-dojo/vibekit` as a `github:` tag-pinned dependency in the current repo's `package.json`, and print the matching `docs/DEPENDENCY_LEDGER.md` entry.

## When to use

In a project that consumes the VibeKit shared library and does NOT already have it pinned. After running this command, run `/vibekit cookbook <module>` for the wire-up patterns of any module the project uses.

## How to invoke

```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/add.sh [tag]
```

`tag` defaults to the latest published tag (resolved via `gh api repos/Randroids-Dojo/VibeKit/releases/latest`). Pass an explicit tag like `v0.1.4` to pin to a specific release.

## What the script does

1. Confirms the repo has a `package.json`. Aborts with a hint if not.
2. Reads the current `@randroids-dojo/vibekit` pin (if any). If already present and equal to the target tag, prints "already up to date" and exits.
3. Resolves the target tag (passed argument or latest from GitHub).
4. Edits `package.json` to set `dependencies["@randroids-dojo/vibekit"]` to `github:Randroids-Dojo/VibeKit#<tag>`. Creates the dependencies block if missing.
5. Runs the project's lockfile-refresh command. Picks `pnpm install`, `npm install`, or `yarn install` based on which lockfile is present. Skipped with `--no-install`.
6. Prints the boilerplate `DEPENDENCY_LEDGER.md` entry to paste into `docs/DEPENDENCY_LEDGER.md` (or whichever case the project uses; FrackingAsteroids uses `Docs/`). The script does NOT modify the ledger directly to avoid clobbering project-specific text in already-existing entries.
7. Prints next steps: run `pnpm type-check` and any relevant tests; the kit's `./server` modules are Node-only (do not import them from client code).

## Output

A concise summary: target tag, package.json bump confirmation, install command run, and the ledger-entry boilerplate. The user pastes the ledger entry into their project's spiral ledger themselves.
