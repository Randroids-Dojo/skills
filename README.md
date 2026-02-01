# skills

A dual-format skills repository for **Claude Code** and **Codex CLI** by Randroids Dojo.

## Available Skills

| Skill | Description |
|-------|-------------|
| **randroid** | Autonomous development loop with research and implementation modes |
| **godot** | Develop, test, build, and deploy Godot 4.x games |

## Installation

### Codex CLI

Install individual skills using the built-in skill installer:

```
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/randroid
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/godot
```

Or clone for all skills at once:

```bash
git clone https://github.com/Randroids-Dojo/skills.git ~/.codex/skills/randroids-dojo
```

Then symlink individual skills you want:

```bash
ln -s ~/.codex/skills/randroids-dojo/plugins/randroid ~/.codex/skills/randroid
ln -s ~/.codex/skills/randroids-dojo/plugins/godot ~/.codex/skills/godot
```

### Claude Code

Install from the marketplace:

```bash
/plugin marketplace add Randroids-Dojo/skills
/plugin install randroid
/plugin install godot
```

## Usage

### Codex CLI

Skills are triggered automatically based on context, or explicitly:

```
$randroid-loop    # Invoke randroid skill
$godot            # Invoke godot skill
```

### Claude Code

```
/randroid         # Interactive mode selection
/randroid:loop    # Direct loop invocation
/godot:godot      # Godot development assistance
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
│   ├── randroid/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   ├── commands/        # Claude Code slash commands
│   │   ├── scripts/         # Automation scripts
│   │   └── ...
│   └── godot/
│       ├── SKILL.md         # Skill definition (Codex + Claude)
│       ├── commands/        # Claude Code slash commands
│       ├── scripts/         # Helper scripts
│       └── references/      # Documentation
└── README.md
```

## Dual-Format Compatibility

This repository is structured to work with both tools:

| Feature | Codex CLI | Claude Code |
|---------|-----------|-------------|
| Skill definition | `SKILL.md` | `SKILL.md` + `plugin.json` |
| Discovery | `$skill-installer` or symlinks | Marketplace |
| Invocation | `$skill-name` | `/command-name` |
| Global install | `~/.codex/skills/` | `~/.claude/plugins/` |

The `SKILL.md` files use YAML frontmatter with `name` and `description` fields that both tools understand. Claude Code-specific fields (`triggers`, `hooks`) are ignored by Codex CLI.

## License

MIT
