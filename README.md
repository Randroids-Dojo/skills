# skills

A dual-format skills repository for **Claude Code** and **Codex CLI** by Randroids Dojo.

## Available Skills

| Skill | Description |
|-------|-------------|
| **loop** | Autonomous development loop with research and implementation modes |
| **godot** | Develop, test, build, and deploy Godot 4.x games |

## Installation

### Recommended (all agents)

Install the loop skill via the Skills CLI:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill loop
```

Works with Codex CLI, Claude Code, OpenCode, Gemini CLI, and other Agent Skills-compatible tools.

To install the Godot skill:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill godot
```

### Manual installs

#### Codex CLI

Install individual skills using the built-in skill installer:

```
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/loop
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/godot
```

Or clone for all skills at once:

```bash
git clone https://github.com/Randroids-Dojo/skills.git ~/.codex/skills/randroids-dojo
```

Then symlink individual skills you want:

```bash
ln -s ~/.codex/skills/randroids-dojo/plugins/loop ~/.codex/skills/loop
ln -s ~/.codex/skills/randroids-dojo/plugins/godot ~/.codex/skills/godot
```

#### Claude Code

Install from the marketplace:

```bash
/plugin marketplace add Randroids-Dojo/skills
/plugin install loop
/plugin install godot
```

## Usage

### Codex CLI

Skills are triggered automatically based on context, or explicitly:

```
$loop             # Invoke loop skill
$godot            # Invoke godot skill
```

### Claude Code

```
/loop             # Interactive mode selection
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
│   ├── loop/
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
