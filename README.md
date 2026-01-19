# skills

A Claude Code plugin marketplace by Randroids Dojo. Also works directly with Codex CLI.

## Available Plugins

| Plugin | Command | Description |
|--------|---------|-------------|
| **randroid** | `/randroid:loop` | Autonomous development loop with research and implementation modes |
| **godot** | `/godot:godot` | Develop, test, build, and deploy Godot 4.x games |

## Installation

### Claude Code

Install from the marketplace:

```bash
/plugin marketplace add Randroids-Dojo/skills
/plugin install randroid
/plugin install godot
```

### Codex CLI

Clone and run - the `.codex/skills` symlink is already configured:

```bash
git clone https://github.com/Randroids-Dojo/skills.git
cd skills
codex
```

## Repository Structure

```
.
├── .claude-plugin/
│   └── marketplace.json     # Claude Code marketplace manifest
├── .codex/
│   └── skills -> ../plugins # Symlink for Codex CLI
├── plugins/
│   ├── randroid/            # Autonomous dev loop
│   └── godot/               # Godot game development
└── README.md
```

## License

MIT
