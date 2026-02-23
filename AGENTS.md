# Agent Instructions — Skills Repo

This is the **source repository** for Claude Code skills. Skills are installed from here to `~/.claude/skills/` (and equivalent paths for other agents) via `npx skills`.

## Critical Rule: Never Edit Installed Files

**Installed skill files are build artifacts.** Do not modify them directly.

| Location | What it is | Editable? |
|----------|------------|-----------|
| `plugins/<skill>/` | Source of truth | YES — edit here |
| `~/.claude/skills/<skill>/` | Installed copy | NO — reinstall to update |
| `~/.codex/skills/<skill>/` | Installed copy | NO — reinstall to update |

If you edit `~/.claude/skills/slipbox/SKILL.md` instead of `plugins/slipbox/SKILL.md`, your changes will be lost the next time the skill is installed and will never reach other machines.

## Workflow for Skill Changes

1. Edit files under `plugins/<skill>/`
2. Commit and push to `main`
3. Reinstall on each machine (always use `-g` for global install):
   ```bash
   npx skills add randroids-dojo/skills --skill <name> -y -g
   ```

> **Do not rely on `npx skills update`** — the installed skills have an empty `skillFolderHash` in `~/.agents/.skill-lock.json`, so the CLI cannot detect changes and will always report "All skills are up to date". Always use `npx skills add` to pull the latest.

## Repository Structure

```
plugins/
├── godot/
├── loop/
├── slipbox/
│   ├── SKILL.md          # Full skill documentation and agent instructions
│   └── commands/
│       └── slipbox.md    # Slash command quick reference
├── task-tracking-dots/
└── unreal/
```

Each skill has:
- `SKILL.md` — loaded when the skill is invoked; contains full docs and behavioral instructions for the agent
- `commands/<name>.md` — loaded when the slash command is used; keep this concise

## Adding a New Skill

1. Create `plugins/<skill-name>/SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: skill-name
   description: "One-line description used for skill discovery."
   ---
   ```
2. Optionally add `commands/<skill-name>.md` for a slash command entry point
3. Update `README.md` skills table
4. Commit and push
