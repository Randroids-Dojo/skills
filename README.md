# skills

A dual-format skills repository for **Claude Code**, **Codex CLI**, and **OpenCode** by Randroids Dojo.

## Available Skills

| Skill | Description |
|-------|-------------|
| **randroid-loop** | Autonomous development loop with research and implementation modes |
| **task-tracking-dots** | Task management with Dots using the dot CLI for tracking work items |
| **task-tracking-dots-html** | Task management with the HTML-backed Dots fork |
| **godot** | Develop, test, build, and deploy Godot 4.x games |
| **unreal** | Develop, test, and automate Unreal Engine 5.x projects (WIP). PlayUnreal: https://github.com/Randroids-Dojo/PlayUnreal |
| **slipbox** | Interact with the SlipBox semantic knowledge engine and read notes from PrivateBox |
| **spiral** | Bootstrap and audit the structural-discipline scaffold (Markdown ledgers) used by long-running autonomous PR loops |
| **spiral-html** | HTML-first variant of spiral. Same scaffold and audit checks, ledgers authored as semantic HTML with `data-*` ids |

## Installation

### Recommended (all agents)

Install the randroid-loop skill via the Skills CLI:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill randroid-loop
```

Works with Codex CLI, Claude Code, OpenCode, Gemini CLI, and other Agent Skills-compatible tools.

To install the task-tracking-dots skill:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill task-tracking-dots
```

To install the HTML-backed task-tracking-dots skill:

```bash
npx skills add https://github.com/Randroids-Dojo/skills --skill task-tracking-dots-html
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
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/randroid-loop
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/task-tracking-dots
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/task-tracking-dots-html
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/godot
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/unreal
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/slipbox
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/spiral
$skill-installer https://github.com/Randroids-Dojo/skills/tree/main/plugins/spiral-html
```

Or clone for all skills at once:

```bash
git clone https://github.com/Randroids-Dojo/skills.git ~/.agents/skills/randroids-dojo
```

Then symlink individual skills you want:

```bash
ln -s ~/.agents/skills/randroids-dojo/plugins/randroid-loop ~/.agents/skills/randroid-loop
ln -s ~/.agents/skills/randroids-dojo/plugins/task-tracking-dots ~/.agents/skills/task-tracking-dots
ln -s ~/.agents/skills/randroids-dojo/plugins/task-tracking-dots-html ~/.agents/skills/task-tracking-dots-html
ln -s ~/.agents/skills/randroids-dojo/plugins/godot ~/.agents/skills/godot
ln -s ~/.agents/skills/randroids-dojo/plugins/unreal ~/.agents/skills/unreal
ln -s ~/.agents/skills/randroids-dojo/plugins/slipbox ~/.agents/skills/slipbox
ln -s ~/.agents/skills/randroids-dojo/plugins/spiral ~/.agents/skills/spiral
ln -s ~/.agents/skills/randroids-dojo/plugins/spiral-html ~/.agents/skills/spiral-html
```

Note: Codex 2026 reads skills from `~/.agents/skills/` (the universal "Agent Skills" path), not `~/.codex/skills/`. The `npx skills` CLI also targets `~/.agents/skills/` for Codex.

#### Claude Code

Install from the marketplace:

```bash
/plugin marketplace add Randroids-Dojo/skills
/plugin install randroid-loop
/plugin install task-tracking-dots
/plugin install task-tracking-dots-html
/plugin install godot
/plugin install unreal
/plugin install slipbox
/plugin install spiral
/plugin install spiral-html
```

### Install locations (Skills CLI)

The `skills` CLI installs into a canonical directory and then symlinks to agent-specific paths by default. Canonical paths are `./.agents/skills/<skill>` (project) or `~/.agents/skills/<skill>` (global). Copy mode writes directly to each agent directory.

| Agent | Project install | Global install | Notes |
| --- | --- | --- | --- |
| Claude Code | `./.claude/skills/<skill>` (symlink to `./.agents/skills/<skill>`) | `~/.claude/skills/<skill>` (symlink to `~/.agents/skills/<skill>`) | Symlinked client. Uses `CLAUDE_CONFIG_DIR` when set. |
| Codex CLI | `./.agents/skills/<skill>` | `~/.agents/skills/<skill>` | Universal client. Reads canonical path directly, no symlink needed. |
| OpenCode | `./.opencode/skills/<skill>` | `${XDG_CONFIG_HOME:-~/.config}/opencode/skills/<skill>` | Symlinked client. Uses XDG config home. |

## Usage

### Codex CLI

Skills are triggered automatically based on context, or explicitly:

```
$randroid-loop      # Invoke randroid-loop skill
$task-tracking-dots # Task management with Dots
$task-tracking-dots-html # Task management with HTML-backed Dots
$godot              # Invoke godot skill
$unreal             # Invoke unreal skill
$slipbox            # Invoke slipbox skill
$spiral             # Bootstrap or audit a project scaffold
$spiral-html        # HTML-first variant of spiral
```

### Claude Code

```
/randroid-loop      # Interactive mode selection
/task-tracking-dots # Task management with Dots
/task-tracking-dots-html # Task management with HTML-backed Dots
/godot:godot        # Godot development assistance
/unreal:unreal      # Unreal development assistance
/slipbox:slipbox    # SlipBox knowledge engine
/spiral             # Bootstrap or audit a project scaffold (/spiral init, /spiral audit)
/spiral-html        # HTML-first variant (/spiral-html init, /spiral-html audit)
```

## Repository Structure

```
.
├── .claude-plugin/
│   ├── marketplace.json     # Claude Code marketplace manifest
│   └── plugin.json          # Collection metadata
├── .agents/
│   └── skills -> ../plugins # Symlink for local Codex (and any universal-path client) development
├── .codex/
│   └── skills -> ../plugins # Legacy alias for older Codex versions
├── plugins/
│   ├── randroid-loop/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   ├── commands/        # Claude Code slash commands
│   │   ├── scripts/         # Automation scripts
│   │   └── ...
│   ├── task-tracking-dots/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   └── commands/        # Claude Code slash commands
│   ├── task-tracking-dots-html/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   ├── commands/        # Claude Code slash commands
│   │   └── scripts/         # Installer for Randroids-Dojo/dots-html
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
│   ├── slipbox/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   └── commands/        # Claude Code slash commands
│   ├── spiral/
│   │   ├── SKILL.md         # Skill definition (Codex + Claude)
│   │   ├── commands/        # Claude Code slash commands (init, audit)
│   │   ├── templates/       # Files written into target repos by /spiral init
│   │   ├── scripts/         # init.sh and audit.sh
│   │   └── docs/            # methodology and case studies
│   └── spiral-html/
│       ├── SKILL.md         # Skill definition (YAML frontmatter + HTML body)
│       ├── commands/        # /spiral-html init, /spiral-html audit
│       ├── templates/       # HTML scaffold written into target repos
│       ├── scripts/         # init.sh and audit.sh (HTML-aware)
│       └── docs/            # methodology.html and case-studies.html
└── README.md
```

## Dual-Format Compatibility

This repository is structured to work with Claude Code, Codex CLI, and OpenCode:

| Feature | Codex CLI | Claude Code | OpenCode |
|---------|-----------|-------------|----------|
| Skill definition | `SKILL.md` | `SKILL.md` + `plugin.json` | `SKILL.md` |
| Discovery | Skills CLI or `$skill-installer` | Marketplace or Skills CLI | Skills CLI or `.opencode/skills` |
| Invocation | `$skill-name` | `/command-name` | Automatic via `skill` tool |
| Global install (Skills CLI) | `~/.agents/skills/` | `~/.claude/skills/` (symlink to `~/.agents/skills/`) | `~/.config/opencode/skills/` |

OpenCode loads skills on demand via the native `skill` tool; users typically invoke them by describing the desired behavior rather than using a slash command.

The `SKILL.md` files use YAML frontmatter with `name` and `description` fields that all tools understand. Additional metadata is ignored by tools that don't recognize it.

## Documentation Notes

See `docs/agent-skills-learnings.md` for key takeaways from agentskills.io and skills.sh docs.

## License

MIT
