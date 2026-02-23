# skills

A dual-format skills repository for **Claude Code**, **Codex CLI**, and **OpenCode** by Randroids Dojo.

## Available Skills

| Skill | Description |
|-------|-------------|
| **loop** | Autonomous development loop with research and implementation modes |
| **task-tracking-dots** | Task management with Dots using the dot CLI for tracking work items |
| **godot** | Develop, test, build, and deploy Godot 4.x games |
| **unreal** | Develop, test, and automate Unreal Engine 5.x projects (WIP). PlayUnreal: https://github.com/Randroids-Dojo/PlayUnreal |
| **slipbox** | Interact with the SlipBox semantic knowledge engine and read notes from PrivateBox |

## Installation

### Recommended (all agents)

Install the loop skill via the Skills CLI:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill loop
```

Works with Codex CLI, Claude Code, OpenCode, Gemini CLI, and other Agent Skills-compatible tools.

To install the task-tracking-dots skill:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill task-tracking-dots
```

To install the Godot skill:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill godot
```

To install the Unreal skill:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill unreal
```

To install the SlipBox skill:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill slipbox
```

### Manual installs

#### Codex CLI

Install individual skills using the built-in skill installer:

```
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/loop
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/task-tracking-dots
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/godot
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/unreal
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/slipbox
```

Or clone for all skills at once:

```bash
git clone https://github.com/Randroids-Dojo/skills.git ~/.codex/skills/randroids-dojo
```

Then symlink individual skills you want:

```bash
ln -s ~/.codex/skills/randroids-dojo/plugins/loop ~/.codex/skills/loop
ln -s ~/.codex/skills/randroids-dojo/plugins/task-tracking-dots ~/.codex/skills/task-tracking-dots
ln -s ~/.codex/skills/randroids-dojo/plugins/godot ~/.codex/skills/godot
ln -s ~/.codex/skills/randroids-dojo/plugins/unreal ~/.codex/skills/unreal
ln -s ~/.codex/skills/randroids-dojo/plugins/slipbox ~/.codex/skills/slipbox
```

#### Claude Code

Install from the marketplace:

```bash
/plugin marketplace add Randroids-Dojo/skills
/plugin install loop
/plugin install task-tracking-dots
/plugin install godot
/plugin install unreal
/plugin install slipbox
```

### Install locations (Skills CLI)

The `skills` CLI installs into a canonical directory and then symlinks to agent-specific paths by default. Canonical paths are `./.agents/skills/<skill>` (project) or `~/.agents/skills/<skill>` (global). Copy mode writes directly to each agent directory.

| Agent | Project install | Global install | Notes |
| --- | --- | --- | --- |
| Claude Code | `./.claude/skills/<skill>` | `${CLAUDE_CONFIG_DIR:-~/.claude}/skills/<skill>` | Uses `CLAUDE_CONFIG_DIR` when set. |
| Codex CLI | `./.codex/skills/<skill>` | `${CODEX_HOME:-~/.codex}/skills/<skill>` | Uses `CODEX_HOME` when set. |
| OpenCode | `./.opencode/skills/<skill>` | `${XDG_CONFIG_HOME:-~/.config}/opencode/skills/<skill>` | Uses XDG config home. |

## Usage

### Codex CLI

Skills are triggered automatically based on context, or explicitly:

```
$loop               # Invoke loop skill
$task-tracking-dots # Task management with Dots
$godot              # Invoke godot skill
$unreal             # Invoke unreal skill
$slipbox            # Invoke slipbox skill
```

### Claude Code

```
/loop               # Interactive mode selection
/task-tracking-dots # Task management with Dots
/godot:godot        # Godot development assistance
/unreal:unreal      # Unreal development assistance
/slipbox:slipbox    # SlipBox knowledge engine
```

## Repository Structure

```
.
├── .claude-plugin/
│   ├── marketplace.json     # Claude Code marketplace manifest
│   └── plugin.json          # Collection metadata
├── .codex/
│   └── skills -> ../plugins # Symlink for local Codex development
├── plugins/
│   ├── loop/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   ├── commands/        # Claude Code slash commands
│   │   ├── scripts/         # Automation scripts
│   │   └── ...
│   ├── task-tracking-dots/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   └── commands/        # Claude Code slash commands
│   ├── godot/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   ├── commands/        # Claude Code slash commands
│   │   ├── scripts/         # Helper scripts
│   │   └── references/      # Documentation
│   ├── unreal/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   ├── commands/        # Claude Code slash commands
│   │   ├── scripts/         # Helper scripts
│   │   └── references/      # Documentation
│   └── slipbox/
│       ├── SKILL.md         # Skill definition (Codex + Claude)
│       └── commands/        # Claude Code slash commands
└── README.md
```

## Dual-Format Compatibility

This repository is structured to work with Claude Code, Codex CLI, and OpenCode:

| Feature | Codex CLI | Claude Code | OpenCode |
|---------|-----------|-------------|----------|
| Skill definition | `SKILL.md` | `SKILL.md` + `plugin.json` | `SKILL.md` |
| Discovery | Skills CLI or `$skill-installer` | Marketplace or Skills CLI | Skills CLI or `.opencode/skills` |
| Invocation | `$skill-name` | `/command-name` | Automatic via `skill` tool |
| Global install (Skills CLI) | `~/.codex/skills/` | `~/.claude/skills/` | `~/.config/opencode/skills/` |

OpenCode loads skills on demand via the native `skill` tool; users typically invoke them by describing the desired behavior rather than using a slash command.

The `SKILL.md` files use YAML frontmatter with `name` and `description` fields that all tools understand. Additional metadata is ignored by tools that don't recognize it.

## Documentation Notes

See `docs/agent-skills-learnings.md` for key takeaways from agentskills.io and skills.sh docs.

## License

MIT
