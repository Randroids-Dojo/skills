# Agent Instructions: Skills Repo

This is the **source repository** for Claude Code and Codex skills. Skills are installed from here to `~/.agents/skills/` (the canonical universal path) and symlinked into `~/.claude/skills/` (Claude Code) via `npx skills`.

## Critical Rule: Never Edit Installed Files

**Installed skill files are build artifacts.** Do not modify them directly.

| Location | What it is | Editable? |
|----------|------------|-----------|
| `plugins/<skill>/` | Source of truth | YES, edit here |
| `~/.agents/skills/<skill>/` | Installed copy (canonical, read by Codex and other universal clients) | NO, reinstall to update |
| `~/.claude/skills/<skill>/` | Symlink into `~/.agents/skills/<skill>/` | NO, reinstall to update |

If you edit `~/.claude/skills/slipbox/SKILL.md` instead of `plugins/slipbox/SKILL.md`, your changes will be lost the next time the skill is installed and will never reach other machines.

## Workflow for Skill Changes

1. Edit files under `plugins/<skill>/`.
2. Run `./scripts/validate-skills.sh`.
3. Commit and push to `main` when the requested workflow authorizes it.
4. Reinstall on each machine (always use `-g` for global install):
   ```bash
   npx skills add randroids-dojo/skills --skill <name> -y -g
   ```

> **Do not rely on `npx skills update`**: the installed skills have an empty `skillFolderHash` in `~/.agents/.skill-lock.json`, so the CLI cannot detect changes and will always report "All skills are up to date". Always use `npx skills add` to pull the latest.

## Repository Structure

```
plugins/
├── godot/
├── randroid/
│   ├── SKILL.md          # Thin workflow router
│   ├── skills/           # Focused portable workflows
│   │   ├── randroid-loop/
│   │   ├── randroid-address-pr-comments/
│   │   ├── randroid-vibereview/
│   │   └── randroid-clean-slop/
│   ├── commands/         # Legacy Claude aliases
│   ├── hooks/
│   └── .claude-plugin/
├── slipbox/
│   ├── SKILL.md          # Concise portable entrypoint
│   └── references/       # Conditional detail
├── spiral/
├── task-tracking-dots/
└── unreal/
```

Each skill has:
- `SKILL.md`: portable entrypoint using only Agent Skills specification frontmatter
- `agents/openai.yaml`: Codex display metadata and explicit default prompt
- `.claude-plugin/plugin.json`: Claude Code package metadata for top-level plugins
- optional `references/`, `scripts/`, and `assets/` loaded only when needed
- optional `commands/` and `hooks/` as Claude-only adapters; keep them thin

Install nested Randroid workflows with `--full-depth`, for example:

```bash
npx skills add randroids-dojo/skills --skill randroid-loop --full-depth -y -g
```

## Adding a New Skill

1. Create `plugins/<skill-name>/SKILL.md` with portable YAML frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Performs a focused workflow. Use when the user asks for its concrete outcome.
   ---
   ```
2. Add `agents/openai.yaml` and `.claude-plugin/plugin.json`.
3. Add at least two positive and two negative routing cases to `tests/trigger-cases.json`.
4. Put detailed conditional material in `references/` and deterministic helpers in `scripts/`.
5. Update `README.md` and `.claude-plugin/marketplace.json`.
6. Add the catalog symlink: `ln -s ../../plugins/<skill-name> .agents/skills/<skill-name>` (the validator requires it).
7. Run `./scripts/validate-skills.sh` before committing.
